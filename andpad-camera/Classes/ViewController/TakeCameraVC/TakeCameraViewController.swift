//
//  TakeCameraViewController.swift
//  andpad-camera
//
//  Created by Toshihiro Taniguchi on 2018/04/17.
//

import AVFoundation
import CoreMotion
import EasyPeasy
import MediaPlayer
import Photos
import Nuke
import AndpadCore
import RxCocoa
import RxSwift
import SnapKit
import AndpadUIComponent
#if targetEnvironment(simulator)
import Combine
#endif
import DKCamera

extension CountdownPreset {
    var displayedText: String {
        switch self {
        case .none:
            L10n.Camera.iconTitleOff
        case .threeSeconds, .tenSeconds:
            L10n.Camera.Timer.seconds(Int(self.duration))
        }
    }
}

open class TakeCameraViewController: UIViewController {
    
    struct Photo {
        let imageKey: DiskImageStore.Key
        let svgKey: DiskImageStore.Key?
        let exif: NSDictionary
        let isBlackboardAttached: Bool
        let modernBlackboardMaterial: ModernBlackboardMaterial?
        let legacyBlackboardType: BlackBoardType?

        /// 撮影時に適用された画質。カメラ上で画質を選択せずに撮影された場合は`nil`。
        let appliedQuality: PhotoQuality?
        
        func updating(imageKey: DiskImageStore.Key) -> Self {
            Photo(
                imageKey: imageKey,
                svgKey: svgKey,
                exif: exif,
                isBlackboardAttached: isBlackboardAttached,
                modernBlackboardMaterial: modernBlackboardMaterial,
                legacyBlackboardType: legacyBlackboardType,
                appliedQuality: appliedQuality
            )
        }
    }

    public struct ImageURLs {
        public let jpeg: URL
        public let svg: URL?

        public init(jpeg: URL, svg: URL? = nil) {
            self.jpeg = jpeg
            self.svg = svg
        }
    }

    // MARK: Public Variables
    public var selectedPhotoQuality: PhotoQuality? {
        photoQuality.value
    }
    
    // MARK: Const

    /// カメラのキャプチャエリアの幅に対する黒板の幅比率
    ///
    /// 要件: 45%に設定する
    static let blackboardToWidthRatio: CGFloat = 0.45

    // MARK: Outlets
    // For top header
    @IBOutlet private weak var headerContainerView: UIView!
    @IBOutlet private weak var photoCountLabel: UILabel!
    @IBOutlet private weak var thumbnailImageButton: UIButton!
    @IBOutlet private weak var timerButton: TakeCameraIconAndTitleButton!
    
    // For videoPreview
    @IBOutlet private weak var videoPreviewView: UIView!
    
    // For Slider
    @IBOutlet private weak var sliderContainerView: UIView!
    @IBOutlet private weak var slider: ZoomSlider!
    @IBOutlet weak var zoomScaleLabel: UILabel!
    
    // For footer container
    @IBOutlet weak var footerContainerView: UIView!
    
    // Buttons in left stack view
    @IBOutlet private weak var frontAndBackCameraSwitchButton: TakeCameraIconAndTitleButton!
    @IBOutlet private weak var flashButton: TakeCameraIconAndTitleButton!
    
    // Buttons in right stack view
    @IBOutlet private weak var mappingButton: UIButton!
    @IBOutlet private weak var shootingGuideButton: TakeCameraIconAndTitleButton!
    @IBOutlet private weak var blackBoardButton: TakeCameraIconAndTitleButton!

    @IBOutlet private weak var shutterButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    
    // For countdown
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    private let shootingGuideImageView: UIImageView?
    
    // iPhoneのカメラがキャプチャする領域の縦横比を反映させたビュー
    private var capturingAreaView = UIView(frame: .zero)
    
    // 音量変更監視KVO。「音量ボタンで撮影」問題でiOS15以上のみで利用
    private var outputVolumeObservation: NSKeyValueObservation?
    
    // GPS状態の警告表示エリア
    private let gpsWarningView = GpsWarningView()

    // MARK: Properties
    
    public typealias URLCompletionHandler = (
        TakeCameraViewController,
        [(
            urls: ImageURLs,
            exif: NSDictionary,
            isBlackboardAttached: Bool,
            modernBlackboardMaterial: ModernBlackboardMaterial?,
            legacyBlackboardType: BlackBoardType?,
            appliedPhotoQuality: PhotoQuality?
        )],
        ModernBlackboardConfiguration.InitialLocationData?
    ) -> Void
    
    private let disposeBag = DisposeBag()
    
    private let isOfflineMode: Bool
    
    private let modernBlackboardConfiguration: ModernBlackboardConfiguration
    private let analytics: AndpadAnalyticsCameraProtocol?
    private let completionHandler: URLCompletionHandler
    private let permissionNotAuthorizedHandler: (TakeCameraViewController, AVAuthorizationStatus) -> Void
    private let appBaseRequestData: AppBaseRequestData?
    private let snapshotData: SnapshotData?
    private let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
    
    // NOTE: 新黒板の場合、
    // 元のBlackBoardViewModelは使わず、直接、新黒板のモデルを取り扱う
    private var modernBlackboardMaterial: ModernBlackboardMaterial?
    private var blackboardViewAppearance: ModernBlackboardAppearance? {
        didSet {
            guard let blackboardViewAppearance else { return }
            viewModel?.inputPort.accept(.update(blackboardViewAppearance))
        }
    }
    
    private var navigationControllerIntoBlackboardList: UINavigationController?
    
    /// 写真撮影時のリサイズに利用される設定。
    ///
    /// 黒板付きカメラでは画質を選択することができ、その場合はそちらの設定が優先されます。
    /// - Note: 将来的にはCALS対応に向けて通常カメラでも画質を選択できるようになる予定で、その際この設定は削除されます。
    private let preferredResizeConfiguration: ResizeConfiguration
    
    /// カメラ上で選択可能な画質設定。
    private let photoQualityOptions: [PhotoQuality]
    
    // NOTE: 元々viewModelに置くつもりだったが、TakeCameraVMは新黒板でしか利用できないためここに置いた。
    private let photoQuality: BehaviorRelay<PhotoQuality?>
    
    private var maxPhotoCount: Int = 30
    private var orientationLast = UIInterfaceOrientation(rawValue: 0)!
    private var motionManager: CMMotionManager?
    
    // 連打防止のためのフラグ
    private var isCapturing = BehaviorRelay(value: false)

    // ズーム関連
    private var cameraType: CameraType = .single {
        didSet {
            guard oldValue != cameraType else { return }
            slider.minimumValue = cameraType.zoomRange.lowerBound
            slider.maximumValue = cameraType.zoomRange.upperBound
            slider.value = 1.0
            updateZoomScale()
        }
    }
    private var nowPinchScale: CGFloat = 1.0
    private var nowSliderValue: Float = 1.0
    // デフォルト倍率（1.0倍）になった際にHapticsFeedbackを行うためクラス初期化時にprepareしておく
    private let feedbackGenerator: UISelectionFeedbackGenerator = {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        return generator
    }()
    
    private var selectedType: BlackBoardType?
    
    private var allowMultiplePhotos = true
    /// 黒板付きで写真を撮れるかどうか
    ///
    /// 「黒板付きで写真を撮る」が選択された場合は `true` 、「写真を撮る」が選択された場合は `false`
    private var isBlackboardEnabled = false

    private enum FlashType {
        case auto
        case on
        case off

        var icon: UIImage? {
            switch self {
            case .auto: return .init(resource: .toolIconFlashAuto)
            case .on: return .init(resource: .toolIconFlashOn)
            case .off: return .init(resource: .toolIconFlashOff)
            }
        }

        var title: String {
            switch self {
            case .auto: return L10n.Camera.iconTitleAuto
            case .on: return L10n.Camera.iconTitleOn
            case .off: return L10n.Camera.iconTitleOff
            }
        }

        func next() -> FlashType {
            switch self {
            case .auto: return .on
            case .on: return .off
            case .off: return .auto
            }
        }
        
        /// AVCaptureDevice.FlashModeに変換する
        /// - Returns: AVCaptureDevice.FlashMode
        func toAVCaptureFlashMode() -> AVCaptureDevice.FlashMode {
            switch self {
            case .auto: return .auto
            case .on: return .on
            case .off: return .off
            }
        }
    }

    private var flashType: FlashType = .off {
        didSet {
            updateFlashButton()
        }
    }

    /// 黒板が非表示になる直前の黒板のフレーム
    private var preHideBlackboardFrame: CGRect?
    
    private var photos: [Photo] = []
    
    private let diskImageStore: DiskImageStore = .init()
    
    private var cancelHandler: (TakeCameraViewController, ModernBlackboardConfiguration.InitialLocationData?) -> Void = { _, _ in }

    private let focusView = FocusView()
    
    private let aeafLockLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: 0, y: 0, width: 92, height: 20))
        l.textColor = .black
        l.backgroundColor = .focus
        l.layer.cornerRadius = 3
        l.clipsToBounds = true
        l.text = L10n.Photo.lockAEAF
        l.font = UIFont.systemFont(ofSize: 13)
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()
    
    private var cameraOrientation: AVCaptureVideoOrientation = .portrait
    
    private var multitaskingAppManager = MultitaskingAppManager()
    
    open var blackboardMappingModel = BlackboardMappingModel()
    /// 新黒板用のViewModel（当面は一部機能に限定）
    private let viewModel: TakeCameraViewModel?
    
    private var ratio: CGFloat = 1.0 // 実際のviewとの比率
    
    private var blackboardView: BlackboardBaseView? {
        didSet {
            switch modernBlackboardConfiguration {
            case .enable:
                break
            case .disable:
                blackboardView?.viewAccessibilityIdentifier = .legacyBlackboardView
            }
        }
        willSet {
            guard newValue == nil else {
                blackboardLocationDataBeforeHideBlackboardView = nil
                return
            }
            guard let blackboardView else { return }
            blackboardLocationDataBeforeHideBlackboardView = .init(
                targetView: blackboardView,
                isLockedRotation: isLockedRotation,
                sizeType: blackboardViewAppearance?.sizeType ?? .free
            )
        }
    }

    private var isBlackboardVisible = false

    private var isLockedRotation = false {
        didSet {
            guard isLockedRotation != oldValue else { return }
            rotateBlackboardIfNeed(specifiedOrientation: nil)
        }
    }

    private var images: [Any] = []
    private var lockAEAFTimer: Timer?
    
    // Properties to control camera
    private var baseIso: Float = 0

    // 直近の黒板ロケーション情報（位置 / サイズ / 傾き等）
    private var currentBlackboardLocationData: ModernBlackboardConfiguration.InitialLocationData? {
        guard let blackboardView = blackboardView as? BlackboardImageView else {
            return blackboardLocationDataBeforeHideBlackboardView
        }
        return .init(
            targetView: blackboardView,
            isLockedRotation: isLockedRotation,
            sizeType: blackboardViewAppearance?.sizeType ?? .free
        )
    }

    private var isOldBlackboard: Bool {
        modernBlackboardConfiguration.isOldBlackboard
    }
    
    private var isModernBlackboard: Bool {
        modernBlackboardConfiguration.isModernBlackboard
    }
    
    private var doneInitializingLocationData = false

    /// 黒板イメージを非表示にする直前の、黒板ロケーション情報（位置 / サイズ / 傾き等）
    private var blackboardLocationDataBeforeHideBlackboardView: ModernBlackboardConfiguration.InitialLocationData?

    private var pastBlackboardOrientation: UIDeviceOrientation?

    private let cameraDriver: CameraDriver = {
        #if DEBUG && targetEnvironment(simulator)
        return DummyCameraDriver()
        #else
        return SystemCameraDriver()
        #endif
    }()
    
    /// 撮影データの破棄操作をユーザーに確認するアラート
    private var photoDeletionConfirmationAlert: CustomizedAlertView?
    /// 写真の最大撮影枚数に到達したことをユーザーに通知するアラート
    private var maxPhotoLimitReachedAlert: CustomizedAlertView?
    /// 黒板の豆図ファイル画像の読み込みに失敗したことをユーザーに通知するアラート
    private var miniatureMapImageLoadingFailureAlert: CustomizedAlertView?
    /// 共通アラート
    private var commonAlert: CustomizedAlertView?
    /// 黒板をどのように変更するかユーザーに選択させるアラート
    ///
    /// 元はアクションシートで実装されていたが、画面の向きをポートレートに固定したまま、
    /// 向きの回転を可能にするために、アラートに変更された。
    private var blackboardChangeOptionsAlert: CustomizedAlertView?
    private var blackboardSettingsView: BlackboardSettingsView?

    // マルチタスキング対応のアプリから起動されたかどうか
    var launchedByMultitaskingApp = false

    /// 黒板のデフォルトサイズの長辺
    private var defaultBlackboardLongSide: CGFloat {
        capturingAreaView.frame.width * Self.blackboardToWidthRatio
    }

    /// 黒板サイズ「自由値」を選択している場合に一時的に黒板のFrameを保持するプロパティ
    ///
    /// ユーザーが黒板設定モーダルを開いた時に現在の黒板のFrameを記録し、モーダルを閉じる際にはこの情報を削除する。
    /// これにより、ユーザーが再び「自由値」を選択した場合に、以前の設定を素早く復元することができる。
    /// 注意: このプロパティはモーダルの開閉にのみ関連し、その他の時点では使用されない。
    private var temporaryFreeBlackboardFrame: CGRect?

    /// ユーザーが設定した透過度設定値 (一時的に保持しておくための変数)
    ///
    /// SVG で撮影する際はユーザーの設定に関わらず透過度無しにする必要がある。
    /// 一方で、JPEG 撮影に戻した場合は元の設定に戻して上げる必要がある。
    /// そのため、SVG 設定中は本変数に一時的に透過度設定を格納する。
    private var temporaryCurrentAlphaLevelForJPEG: ModernBlackboardAppearance.AlphaLevel?

    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var countdownPreset: CountdownPreset = .none {
        didSet {
            updateTimerButton()
        }
    }
    private var cameraCountdown: CameraCountdown?
    
    private weak var countdownPresetSelectionViewController: CountdownPresetSelectionViewController?
    
    // This array keeps track of all the subviews that are hidden when the countdown appears. Later, they will all be shown again
    private var viewsHiddenByCountdown = [UIView]()

    #if targetEnvironment(simulator)
    private var subscriptions = Set<AnyCancellable>()
    #endif

    // MARK: - Initializers


    open var locationManager: DKCameraLocationManager?
    open var locationStatusManager: LocationStatusManager?

    open var containsGPSInMetadata = false

    private init(
        isOfflineMode: Bool,
        modernBlackboardConfiguration: ModernBlackboardConfiguration,
        analytics: AndpadAnalyticsCameraProtocol?,
        completionHandler: @escaping URLCompletionHandler,
        appBaseRequestData: AppBaseRequestData?,
        shootingGuideImageUrl: URL?,
        preferredResizeConfiguration: ResizeConfiguration,
        photoQualityOptions: [PhotoQuality],
        initialPhotoQuality: PhotoQuality?,
        permissionNotAuthorizedHandler: @escaping (TakeCameraViewController, AVAuthorizationStatus) -> Void,
        storage: (any ModernBlackboardCameraStorageProtocol)?
    ) {
        _ = NetworkReachabilityHandler.shared
        
        self.isOfflineMode = isOfflineMode
        
        self.modernBlackboardConfiguration = modernBlackboardConfiguration
        self.analytics = analytics
        self.completionHandler = completionHandler
        self.permissionNotAuthorizedHandler = permissionNotAuthorizedHandler
        self.appBaseRequestData = appBaseRequestData
        self.preferredResizeConfiguration = preferredResizeConfiguration
        self.photoQualityOptions = photoQualityOptions
        self.photoQuality = BehaviorRelay(value: initialPhotoQuality)
        if let initialPhotoQuality {
            precondition(photoQualityOptions.contains(initialPhotoQuality))
        } else {
            precondition(photoQualityOptions.isEmpty)
        }
        
        if let shootingGuideImageUrl = shootingGuideImageUrl {
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.isHidden = true
            imageView.setNetworkImageUrl(shootingGuideImageUrl)
            
            self.shootingGuideImageView = imageView
        } else {
            self.shootingGuideImageView = nil
        }
        
        switch modernBlackboardConfiguration {
        case .enable(let arguments):
            self.snapshotData = arguments.snapshotData
            self.advancedOptions = arguments.advancedOptions
            let newModernBlackboardMaterial = arguments.defaultModernBlackboardMaterial.updating(
                by: arguments.snapshotData,
                shouldForceUpdateConstructionName: true
            )
            
            newModernBlackboardMaterial.prettyDebug(with: "newModernBlackboardMaterial")
            modernBlackboardMaterial = newModernBlackboardMaterial
            blackboardViewAppearance = arguments.appearance
            selectedType = nil // 新黒板の場合はtypeを指定しない

            let apiManager: ApiManager
            if isOfflineMode {
                apiManager = ApiManager(
                    client: OfflineStorageClient(userID: arguments.snapshotData.userID)
                )
            } else {
                apiManager = ApiManager(client: AlamofireClient())
            }

            if let appBaseRequestData = appBaseRequestData,
               let appearance = blackboardViewAppearance {
                self.viewModel = .init(
                    networkService: ModernBlackboardNetworkService(
                        appBaseRequestData: appBaseRequestData,
                        apiManager: apiManager
                    ),
                    storage: storage,
                    orderID: arguments.orderID,
                    appearance: appearance,
                    snapshotData: arguments.snapshotData,
                    appBaseRequestData: appBaseRequestData,
                    advancedOptions: arguments.advancedOptions,
                    isOfflineMode: isOfflineMode,
                    canEditBlackboardStyle: arguments.canEditBlackboardStyle,
                    blackboardSizeTypeOnServer: arguments.blackboardSizeTypeOnServer,
                    photoFormat: arguments.preferredPhotoFormat
                )
            } else {
                self.viewModel = nil
            }
        case .disable:
            selectedType = .case0
            self.snapshotData = nil
            self.advancedOptions = []
            self.viewModel = nil
        }
        
        super.init(nibName: nil, bundle: .andpadCamera)
        overrideUserInterfaceStyle = .light
        addBindingIfNeeded()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    override open func viewDidLoad() {
        super.viewDidLoad()

        setAccessibilityIdentifiers()
        setNeedsStatusBarAppearanceUpdate()

        setUpViews()

        addNotificationObserver()
        observeIsEnabledNextButton()
        observeIsTakePhotoFinished()

        #if targetEnvironment(simulator)
        observeDeviceOrientationChangeForSimulator()
        #endif

        startListeningVolumeButton()
        
        setUpGestureRecognizers()

        addBindings()
    }

    @objc private func viewWillEnterForeground(_ notification: Notification?) {
        if self.isViewLoaded && (self.view.window != nil) {
            initView()
        }
    }
    
    @objc private func didBecomeActiveNotification(_ notification: Notification?) {
        // WORKAROUND:
        // 原因わかっていないが、ここで遅延処理をいれないと
        // コントロールセンター及びバックグラウンドにて音量を変更して戻ってきたあとに
        // 音量変更のイベントを拾ってしまう（撮影処理が走る）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.addVolumeObserver()
        }
        setAudioSessionActive(true)
    }
    
    @objc private func willResignActiveNotification(_ notification: Notification?) {
        // MEMO:
        // コントロールセンターを開いたときには
        // willResignActiveNotification は呼ばれるが
        // didEnterBackgroundNotification は呼ばれないので、ここでの処理も必要
        // ただしアプリをバックグラウンドの状態にしたときは removeVolumeObserver() まわりの処理が2度走ってしまう
        didEnterBackgroundNotification(notification)
    }
    
    @objc private func didEnterBackgroundNotification(_ notification: Notification?) {
        removeVolumeObserver()
        setAudioSessionActive(false)
        
        cameraCountdown?.cancel()
        cameraCountdown = nil
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isOldBlackboard {
            initView()
        } else if !isModernBlackboard || doneInitializingLocationData {
            // NOTE: isOldBlackboardではなかった場合、ここは通らず後続のinitializeMotionManagerでstartRunningが呼ばれるはず
            // 問題がなさそうだったら削除したい
            cameraDriver.startRunning()
            assertionFailure("startRunning should call once")
        }
        
        initializeMotionManager()

        prepareLocationManagerIfNeeded()

        // カメラの権限チェック
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    DispatchQueue.main.async {
                        self.permissionNotAuthorizedHandler(self, .denied)
                    }
                }
            }
        case .restricted, .denied:
            self.permissionNotAuthorizedHandler(self, status)
        case .authorized:
            break
        @unknown default:
            self.permissionNotAuthorizedHandler(self, status)
        }
        
        print("👀 videoPreviewView.bounds.size.width: ", videoPreviewView.bounds.size.width)
        print("👀 videoPreviewView.bounds.size.height: ", videoPreviewView.bounds.size.height)
        print("👀 height / width: ", Double(videoPreviewView.bounds.height) / Double(videoPreviewView.bounds.size.width))
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        nextButton.isHidden = photos.isEmpty
        setAudioSessionActive(true)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        motionManager?.stopAccelerometerUpdates()
        cameraDriver.stopRunning()
        setAudioSessionActive(false)
        locationManager?.stopUpdatingLocation()
        locationStatusManager?.stopUpdateLocation()
    }
    
    @objc func tapAction(recognizer: UITapGestureRecognizer) {
        aeafLockLabel.isHidden = true
        cameraDriver.lockFocusAndExposure(false)
        commonAction(recognizer: recognizer)
    }
    
    private func commonAction(recognizer: UIGestureRecognizer) {
        let point = recognizer.location(in: videoPreviewView)
        // 黒板の外側
        if blackboardView != nil || !(blackboardView?.isHidden ?? true) {
            // 表示されている場合
            let rect = CGRect(
                x: blackboardView?.frame.origin.x ?? 0.0,
                y: blackboardView?.frame.origin.y ?? 0.0,
                width: blackboardView?.frame.size.width ?? 0.0,
                height: blackboardView?.frame.size.height ?? 0.0
            )
            let path = UIBezierPath(ovalIn: rect)
            if path.contains(point) {
                return
            }
        }
        
        videoPreviewView.addSubview(focusView)
        if let blackboardView = self.blackboardView {
            videoPreviewView.bringSubviewToFront(blackboardView)
        }
        
        baseIso = cameraDriver.getISO()
        focusView.show(
            center: point,
            parentViewFrame: capturingAreaView.frame,
            orientation: cameraOrientation.uiDeviceOrientation,
            didTap: true
        )
        
        let focusPoint: CGPoint = {
            let screenSize = videoPreviewView.bounds.size
            let touchPointX = point.y / screenSize.height
            let touchPointY = 1.0 - point.x / screenSize.width
            return CGPoint(x: touchPointX, y: touchPointY)
        }()
        
        cameraDriver.updateFocusPoint(to: focusPoint)
    }
    
    @objc func longPressAction(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            commonAction(recognizer: recognizer)
            lockAEAFTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(beganLongPressAction),
                userInfo: recognizer,
                repeats: false
            )
        case .ended:
            lockAEAFTimer?.invalidate()
        default:
            break
        }
    }
    
    @objc private func beganLongPressAction() {
        cameraDriver.lockFocusAndExposure(true)
    }
    
    private func aeafLockAnimation() {
        let margin: CGFloat = 24
        focusView.lockAnimation()
        
        aeafLockLabel.isHidden = false
        videoPreviewView.bringSubviewToFront(aeafLockLabel)
        if let blackboardView = blackboardView {
            videoPreviewView.bringSubviewToFront(blackboardView)
        }
        aeafLockLabel.transform = CGAffineTransform(rotationAngle: CGFloat(cameraOrientation.rotateAngle))
        switch cameraOrientation {
        case .portrait, .portraitUpsideDown:
            aeafLockLabel.center = CGPoint(x: videoPreviewView.center.x, y: margin)
        case .landscapeLeft:
            let center = videoPreviewView.convert(capturingAreaView.center, to: videoPreviewView)
            aeafLockLabel.center = CGPoint(
                x: capturingAreaView.frame.maxX - margin,
                y: center.y
            )
        case .landscapeRight:
            let center = videoPreviewView.convert(capturingAreaView.center, to: videoPreviewView)
            aeafLockLabel.center = CGPoint(
                x: capturingAreaView.frame.minX + margin,
                y: center.y
            )
        @unknown default:
            fatalError()
        }
    }
    
    private func addNotificationObserver() {
        // フォアグラウンドに戻った際に、撮影画面が固まってしまうのを防ぐためにリロードする
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TakeCameraViewController.viewWillEnterForeground(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TakeCameraViewController.didBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TakeCameraViewController.willResignActiveNotification(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TakeCameraViewController.didEnterBackgroundNotification(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(TakeCameraViewController.orientationDidChange(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func orientationDidChange(_ notification: Notification?) {
        guard launchedByMultitaskingApp else { return }
        
        if let orientation = MultitaskingAppManager.detectOrientation() {
            if orientation != multitaskingAppManager.currentOrientation {
                multitaskingAppManager.currentOrientation = orientation
                onOrientationChange()
            }
        }
    }
    
    /// 黒板をどのように変更するかユーザーに選択させるアラートを表示する
    /// - Parameter orderID: 案件ID
    private func showBlackboardChangeOptionsAlert(with orderID: Int) {
        guard case .enable = modernBlackboardConfiguration else {
            assertionFailure()
            return
        }
        blackboardChangeOptionsAlert = CustomizedAlertView(title: L10n.Blackboard.Alert.Title.blackboardChangeOptions)

        blackboardChangeOptionsAlert?.addAction(
            CustomizedAlertAction(title: L10n.Blackboard.Alert.Button.BlackboardChangeOption.editBlackboard, style: .default) { [weak self] _ in
                self?.goToEditBlackboard()
            }
        )
        blackboardChangeOptionsAlert?.addAction(
            CustomizedAlertAction(title: L10n.Blackboard.Alert.Button.BlackboardChangeOption.selectBlackboard, style: .default, handler: self.routeBlackboardListHandler(orderID: orderID))
        )
        
        // SVGで黒板を生成する場合、たまに失敗する場合がある
        // アプリからはその状態を取得できないため、ユーザーに更新してもらう
        blackboardChangeOptionsAlert?.addAction(
            CustomizedAlertAction(
                title: L10n.Blackboard.Alert.Button.BlackboardChangeOption.reloadBlackboard,
                style: .default,
                handler: { [weak self] _ in
                    self?.pastBlackboardOrientation = self?.blackboardView?.orientation
                    self?.reloadBlackboard()
                }
            )
        )
        
        blackboardChangeOptionsAlert?.addAction(
            CustomizedAlertAction(title: L10n.Common.cancel, style: .cancel)
        )

        blackboardChangeOptionsAlert?.show(in: view, initialRotationAngle: cameraOrientation.rotateAngle)
    }
    
    private func goToEditBlackboard() {
        switch modernBlackboardConfiguration {
        case .enable(let arguments):
            guard let modernBlackboardMaterial,
                  let appBaseRequestData,
                  let blackboardViewAppearance else {
                assertionFailure("[failed] cannot move edit blackboard vc. (ModernBlackboardMaterial is nil)")
                return
            }

            let modifiedBlackboardViewAppearance: ModernBlackboardAppearance
            if let viewModel, let temporaryCurrentAlphaLevelForJPEG, viewModel.photoFormat.value == .svg {
                // SVG 撮影の場合は SVG 設定前の透過度設定をセットする
                modifiedBlackboardViewAppearance = blackboardViewAppearance.updating(by: temporaryCurrentAlphaLevelForJPEG)
            } else {
                modifiedBlackboardViewAppearance = blackboardViewAppearance
            }

            // 開発中の新黒板用の編集画面
            let editBlackboardVC = AppDependencies.shared.modernEditBlackboardViewController(
                .init(
                    orderID: arguments.orderID,
                    appBaseRequestData: appBaseRequestData,
                    snapshotData: arguments.snapshotData,
                    advancedOptions: arguments.advancedOptions,
                    modernblackboardMaterial: modernBlackboardMaterial,
                    blackboardViewAppearance: modifiedBlackboardViewAppearance,
                    memoStyleArguments: blackboardViewAppearance.memoStyleArguments,
                    editableScope: .all,
                    shouldResetBlackboardEditLoggingHandler: false,
                    isOfflineMode: isOfflineMode
                )
            )
            
            let navigationController = UINavigationController(rootViewController: editBlackboardVC)
            navigationController.modalPresentationStyle = .overFullScreen

            // 黒板編集画面の閉じるボタンで戻ってきた場合も、黒板情報と黒板設定の更新を反映するため、ここに含む
            editBlackboardVC.modernCompletedHandler = setModernCompletedHandler()
            editBlackboardVC.selectableBlackboardListCancelResultHandler = setSelectableBlackboardListCancelResultHandler()
            pastBlackboardOrientation = blackboardView?.orientation
            present(navigationController, animated: true) { [weak self] in
                // 黒板編集画面から撮影画面に戻ってきた瞬間に、黒板が表示完了していないのに撮影ボタンがタップできてしまう状態を回避するため、画面遷移時に撮影ボタン等を無効化しておく
                self?.setShutterButtonsEnabled(false)
            }

        case .disable:
            guard let selectedType else {
                assertionFailure("[failed] cannot move edit blackboard vc. (selectedType is nil)")
                return
            }
            
            let editBlackboardVC = EditBlackboardViewController()
            let navigationController = UINavigationController(rootViewController: editBlackboardVC)

            editBlackboardVC.setViewModel(viewModel: self.blackboardMappingModel)
            
            editBlackboardVC.setSelectedType(type: selectedType)
            
            editBlackboardVC.completedHandler = { [weak self] _, viewModel, type in
                guard let self else { return }
                
                self.selectedType = type
                self.blackboardMappingModel = viewModel
                self.blackboardMappingModel.type = type
                
                // 画面の回転中に差し替え前の黒板が見えないようにする
                blackboardView?.alpha = 0

                // - Note: iPadの横向き対応を追加した際、特定の問題が見つかった。ランドスケープモードの黒板編集画面からポートレートモードのカメラ画面に戻ると、画面の回転により黒板のFrame設定に不具合が生じる。
                // これを解決するには、黒板編集画面を閉じて画面の回転が完了するまで少し待つ必要があり、試行したところ0.62秒かかった。そのため、一時的な解決策として遅延時間を0.7秒に設定している。
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
                    guard let self else {
                        return
                    }
                    self.willMakeBlackboard(originalFrame: blackboardView?.frame)
                }
            }

            editBlackboardVC.didTapCancelButtonHandler = { [weak self] in
                // 閉じるボタンタップ時は黒板の再表示処理がなく、そのルート上の撮影ボタン有効化を通らないので、ここで撮影ボタン等を有効化する
                self?.setShutterButtonsEnabled(true)
            }

            present(navigationController, animated: true) { [weak self] in
                // 黒板編集画面から撮影画面に戻ってきた瞬間に、黒板が表示完了していないのに撮影ボタンがタップできてしまう状態を回避するため、画面遷移前に撮影ボタン等を無効化しておく
                self?.setShutterButtonsEnabled(false)
            }
        }
    }
    
    // 本来はprivateだが、UnitTestから実行するためinternalとする
    func _pressShutter() {
        if isCapturing.value {
            return
        }
        
        if photos.count >= maxPhotoCount {
            maxPhotoLimitReachedAlert = CustomizedAlertView(
                title: L10n.Camera.reachedPhotoLimit,
                message: L10n.Camera.Variables.countPhotoLimit(maxPhotoCount)
            )
            let okAction = CustomizedAlertAction(title: L10n.Common.ok, style: .default, handler: nil)
            maxPhotoLimitReachedAlert?.addAction(okAction)
            maxPhotoLimitReachedAlert?.show(in: view, initialRotationAngle: cameraOrientation.rotateAngle)
            return
        }
        
        takePhoto()
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapShutterButton() {
        _pressShutter()
    }
    
    /// カメラの前面・背面切替ボタンがタップされたときの処理
    @IBAction private func didTapFrontAndBackCameraSwitchButton() {
        frontAndBackCameraSwitchButton.isSelected.toggle()
        let blackboardFrame = blackboardView?.frame

        /// 黒板を表示したいかどうか
        let shouldShowBlackboard: Bool
        if launchedByMultitaskingApp {
            shouldShowBlackboard = multitaskingAppManager.isBlackboardOn
        } else {
            // タップ前に黒板が表示されていたら表示する
            shouldShowBlackboard = isBlackboardVisible
        }

        if shouldShowBlackboard {
            // 黒板を表示する場合、初期状態はdisabledにしておく
            // 有効化は黒板の表示完了時の処理に任せる
            setShutterButtonsEnabled(false)
        }

        removeBlackboard()

        // 重い処理部分をバックグラウンドスレッドで実行
        DispatchQueue.global().async {
            self.cameraDriver.destroyCamera()

            // カメラの準備が完了したらメインスレッドでUI更新
            DispatchQueue.main.async {
                self.prepareCamera(
                    position: self.cameraDriver.position == .back ? .front : .back,
                    originalModernBlackboardFrame: self.isModernBlackboard
                        ? blackboardFrame // 消す直前の新黒板のframeを渡す
                        : nil,
                    shouldShowBlackboard: shouldShowBlackboard
                )
            }
        }
    }
    
    @IBAction private func didTapFlashButton() {
        flashType = flashType.next()
    }
    
    @IBAction private func didTapMappingButton() {
        // NOTE: not released yet
    }
    
    @IBAction private func didTapShootingGuideButton() {
        shootingGuideButton.isSelected.toggle()
        shootingGuideImageView?.isHidden.toggle()
        
        assert(shootingGuideImageView?.isHidden ?? true != shootingGuideButton.isSelected)
    }
    
    @IBAction private func didTapTimerButton(_ sender: Any) {
        let viewController = CountdownPresetSelectionViewController(
            selectedPreset: countdownPreset
        ) { [weak self] selectedPreset in
            guard let self else { return }
            countdownPreset = selectedPreset
        }
        countdownPresetSelectionViewController = viewController
        
        if !launchedByMultitaskingApp {
            viewController.rotateContent(angle: cameraOrientation.rotateAngle)
        }
        
        let sourceRect = view.convert(timerButton.frame, from: timerButton.superview)
        let anchorRelation = CameraDropdownTransitioning.AnchorRelation(
            postion: .bottom,
            alignment: .leading,
            offset: .init(horizontal: -7, vertical: 0)
        )
        viewController.present(
            on: self,
            sourceRect: sourceRect,
            anchorRelation: anchorRelation,
            animated: true,
            completion: nil
        )
    }
    
    @IBAction private func didTapCancelCountdownButton(_ sender: Any) {
        cameraCountdown?.cancel()
        cameraCountdown = nil
    }
    
    /// 黒板設定ボタンタップ時の処理
    @IBAction private func didTapBlackboardSettingsButton() {
        blackboardSettingsView = BlackboardSettingsView(
            isBlackboardVisible: isBlackboardVisible,
            isRotationLocked: isLockedRotation,
            canSelectSize: {
                guard let viewModel else {
                    // 旧黒板の場合
                    return modernBlackboardConfiguration.canEditBlackboardStyle
                }
                return viewModel.canEditBlackboardStyle
            }(),
            sizeType: blackboardViewAppearance?.sizeType,
            sizeTypeOnServer: {
                guard let viewModel else {
                    // 旧黒板の場合
                    return modernBlackboardConfiguration.blackboardSizeTypeOnServer
                }
                return viewModel.blackboardSizeTypeOnServer
            }(),
            photoQuality: selectedPhotoQuality,
            photoQualityOptions: photoQualityOptions,
            photoFormat: viewModel?.photoFormat.value ?? .jpeg,
            isModernBlackboard: isModernBlackboard,
            blackboardVisibilityDidChangeHandler: { [weak self] in
                self?.didTapBlackboardVisibilityButton(shouldShowBlackboard: $0)
            },
            rotationLockDidChangeHandler: { [weak self] isLockedRotation in
                self?.isLockedRotation = isLockedRotation
                Task {
                    guard let self, let blackboardView = self.blackboardView else { return }
                    // 黒板設定で画面ロックを行った場合は pastBlackboardOrientation に変更時点の向き情報をセットしておく
                    if isLockedRotation {
                        self.pastBlackboardOrientation = blackboardView.orientation
                    }
                }
            },
            sizeTypeDidChangeHandler: { [weak self] sizeType in
                guard let self, let appearance = blackboardViewAppearance else { return }
                blackboardViewAppearance = appearance.updating(by: sizeType)

                Task {
                    await self.updateBlackboardFrame(with: sizeType)
                }
            },
            photoQualityDidChangeHandler: { [weak self] in
                self?.photoQuality.accept($0)
            },
            photoFormatDidChangeHandler: { [weak self] in
                self?.viewModel?.photoFormat.accept($0)
                Task {
                    // 撮影時ファイル形式が変更される場合、透過度設定が変更となる可能性があるため、黒板レイアウトの表示を更新する。
                    // なお、黒板の向きがロックされている場合は向き情報を渡す必要があるため、 pastBlackboardOrientation を渡す
                    guard let self, let blackboardView = self.blackboardView else { return }
                    self.willMakeBlackboard(
                        originalFrame: blackboardView.frame,
                        specifiedOrientation: self.isLockedRotation
                            ? self.pastBlackboardOrientation
                            : self.cameraOrientation.uiDeviceOrientation
                    )
                }
            }
        )

        saveTemporaryFreeBlackboardFrameIfNeeded()
        blackboardSettingsView?.present(
            on: view,
            from: blackBoardButton,
            orientation: cameraOrientation.uiDeviceOrientation,
            rotateAngle: cameraOrientation.rotateAngle
        ) { [weak self] in
            guard let self else { return }
            blackboardSettingsView = nil
            temporaryFreeBlackboardFrame = nil

            guard let viewModel else { return }
            if blackBoardButton.isSelected {
                // 黒板設定モーダル表示前に、未読通知バッジが表示されていた場合のみ
                // 既読フラグを立てる
                viewModel.setBlackboardSettingsReadFlagAsTrue()
            }
            // 未読通知バッジの表示を更新
            showNotifyBadgeOnBlackBoardButton(
                viewModel.shouldShowBadgeForModernBlackboardSettings(
                    currentBlackboardSizeType: blackboardViewAppearance?.sizeType ?? .free
                )
            )
        }
    }
    
    @IBAction private func didTapThumbnailImageButton() {
        guard !photos.isEmpty else { return }
        let previewVC = PhotoPreviewViewController(
            photos: photos,
            imageStore: diskImageStore,
            allowsEditing: !isBlackboardEnabled,
            maxPhotoCount: maxPhotoCount
        ) { [weak self] in
            self?.photos = $0
            self?.nextButton.isHidden = $0.isEmpty
            self?.updatePhotoStatus()
        }
        previewVC.delegate = self

        let navigationController = UINavigationController(rootViewController: previewVC)
        navigationController.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black
        ]
        navigationController.presentationController?.delegate = previewVC
        
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction private func didTapCancelButton() {
        if shouldShowDestroyPhotosAlert() {
            showDestroyPhotosAlert(
                destructiveHandler: { [weak self] _ in
                    self?.analytics?.sendLogEvent(
                        cameraEventTargetView: .takeCamera(.tapDestroyButton)
                    )
                    self?.destroyPhotos()
                },
                uploadHandler: { [weak self] _ in
                    self?.analytics?.sendLogEvent(
                        cameraEventTargetView: .takeCamera(.tapUploadButton)
                    )
                    self?.executeCompletionAndDismiss()
                },
                saveHandler: { [weak self] _ in
                    self?.executeCompletionAndDismiss()
                }
            )
        } else {
            destroyPhotos()
        }
    }
    
    @IBAction private func didTapNextButton() {
        analytics?.sendLogEvent(
            cameraEventTargetView: .takeCamera(.tapNextButton)
        )
        executeCompletionAndDismiss()
    }
    
    @IBAction private func didChangeSliderValue(_ sender: UISlider) {
        // デフォルト倍率の通知として、下記のタイミングでHapticsFeedbackを行う
        // 1.0より上からスライダーを1.0以下へスライドさせた時
        // 1.0より下からスライダーを1.0以上へスライドさせた時
        func feedbackIfNeeded() {
            let shouldFeedback = (nowSliderValue > 1 && sender.value <= 1)
            || (nowSliderValue < 1 && sender.value >= 1)

            if shouldFeedback {
                feedbackGenerator.selectionChanged()
            }
        }
        
        print(sender.value)
        /// MEMO: OS標準カメラのUIのようにカチッとフィットさせるため1.0倍のところで丸め込みを行う
        let range: ClosedRange<Float> = 0.95...1.05
        if range.contains(sender.value) {
            slider.value = 1.0
        }
        feedbackIfNeeded()
        nowSliderValue = sender.value
        cameraScale(sliderValue: CGFloat(slider.value))
        updateZoomScale()
    }
    
    @IBAction private func didPinchVideoPreviewView(_ sender: UIPinchGestureRecognizer) {
        let tempSliderValue = Float(sender.scale - nowPinchScale) + slider.value
        nowPinchScale = sender.state == .ended ? 1.0 : sender.scale
        
        if tempSliderValue < cameraType.zoomRange.lowerBound {
            slider.value = cameraType.zoomRange.lowerBound
        } else if tempSliderValue > cameraType.zoomRange.upperBound {
            slider.value = cameraType.zoomRange.upperBound
        } else {
            slider.value = tempSliderValue
        }
        cameraScale(sliderValue: CGFloat(slider.value))
        updateZoomScale()
    }
    
    // MARK: - Private functions
    
    private func cameraScale(sliderValue: CGFloat) {
        cameraDriver.updateScale(to: sliderValue, with: cameraType)
    }
    
    /// スライダーの値をzoomScaleLabelに反映する
    private func updateZoomScale() {
        let ceiledScale = ceil(slider.value * 10) / 10
        zoomScaleLabel.text = "\(ceiledScale)x"
    }
    
    private func initView() {
        /*
         * NOTE:
         * initViewはデバイスが動くたびにonOrientationChange経由で実行されている。
         * 他のViewのセットアップもここではなくviewDidLoadで行った方が良さそう。
         */
        print("initView")
        if let type = self.blackboardMappingModel.type {
            self.selectedType = type
        }

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.prepareCamera(position: self.cameraDriver.position)
            }
        }
    }

    // 端末の向きがかわったら呼び出される.
    // FIXME: 新黒板の場合だと端末の向きが変わらなくても呼び出される場合がある
    private func onOrientationChange() {
        rotateBlackboardIfNeed(specifiedOrientation: nil)
        rotateUI(angle: cameraOrientation.rotateAngle)
        blackboardSettingsView?.rotate(
            to: cameraOrientation.uiDeviceOrientation,
            rotateAngle: cameraOrientation.rotateAngle
        )

        if cameraOrientation.uiDeviceOrientation != focusView.deviceOrientation {
            focusView.show(
                center: focusView.center,
                parentViewFrame: capturingAreaView.frame,
                orientation: cameraOrientation.uiDeviceOrientation
            )
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.initView()
        }

        if !aeafLockLabel.isHidden {
            cameraDriver.lockFocusAndExposure(true)
        }
    }

    // 必要があれば黒板を回転
    private func rotateBlackboardIfNeed(specifiedOrientation: UIDeviceOrientation?) {
        guard isVisibleTakeCameraViewController else {
            return
        }

        let deviceOrientation: UIDeviceOrientation
        if launchedByMultitaskingApp {
            // 端末回転対応済みの場合は何も回転させたくないため
            deviceOrientation = .portrait
        } else {
            deviceOrientation = specifiedOrientation ?? cameraOrientation.uiDeviceOrientation
        }
        
        guard !isLockedRotation,
              let blackboardView = self.blackboardView as? BlackboardImageView,
              blackboardView.orientation != deviceOrientation else { return }
        blackboardView.configure(orientation: deviceOrientation)
        adjustIfBlackboardGoOut()
    }

    // （黒板以外の）UIパーツを回転させる
    private func rotateUI(angle: Double) {
        if launchedByMultitaskingApp { return }
        
        let views: [UIView] = [
            thumbnailImageButton,
            photoCountLabel,
            frontAndBackCameraSwitchButton,
            flashButton,
            mappingButton,
            shootingGuideButton,
            timerButton,
            blackBoardButton,
            cancelButton,
            nextButton,
            zoomScaleLabel,
            countdownLabel
        ]
        
        views.forEach {
            $0.rotateAnimation(angle: angle)
        }

        // アラートも回転の対象に追加
        // 上記の回転アニメーションだと、ボタンのタップ可能エリアが回転しなかったため、
        // `CGAffineTransform` を使った回転を採用した
        let alerts = [
            photoDeletionConfirmationAlert,
            maxPhotoLimitReachedAlert,
            miniatureMapImageLoadingFailureAlert,
            commonAlert,
            blackboardChangeOptionsAlert
        ]
        .compactMap { $0 }
        alerts.forEach { alert in
            alert.transform = CGAffineTransform(rotationAngle: angle)
        }
        
        countdownPresetSelectionViewController?.rotateContent(angle: cameraOrientation.rotateAngle)
    }
    
    // 回転させたことで撮影キャプチャ領域から黒板がはみ出してしまった場合調整する
    private func adjustIfBlackboardGoOut() {
        guard let blackboardView = self.blackboardView as? BlackboardImageView else { return }
        
        let x: CGFloat
        let y: CGFloat
        if blackboardView.frame.origin.x < capturingAreaView.frame.origin.x {
            // x が下限より下の時
            x = capturingAreaView.frame.origin.x
            y = blackboardView.frame.origin.y
        } else if blackboardView.frame.origin.x + blackboardView.frame.width > capturingAreaView.frame.origin.x + capturingAreaView.frame.width {
            // x が上限より上の時
            x = capturingAreaView.frame.origin.x + capturingAreaView.frame.width - blackboardView.frame.width
            y = blackboardView.frame.origin.y
        } else if blackboardView.frame.origin.y < capturingAreaView.frame.origin.y {
            // y が下限より下の時
            x = blackboardView.frame.origin.x
            y = capturingAreaView.frame.origin.y
        } else if blackboardView.frame.origin.y + blackboardView.frame.height > capturingAreaView.frame.origin.y + capturingAreaView.frame.height {
            // y が上限より上の時
            x = blackboardView.frame.origin.x
            y = capturingAreaView.frame.origin.y + capturingAreaView.frame.height - blackboardView.frame.height
        } else {
            // それ以外の時ははみ出してないので何もしない
            return
        }
        
        blackboardView.frame = .init(
            x: x,
            y: y,
            width: blackboardView.frame.width,
            height: blackboardView.frame.height
        )
    }
    
    private func executeCompletionHandler() {
        let photosWithURL = photos.map {
            (
                urls: ImageURLs(photo: $0),
                exif: $0.exif,
                isBlackboardAttached: $0.isBlackboardAttached,
                $0.modernBlackboardMaterial,
                legacyBlackboardType: $0.legacyBlackboardType,
                appliedPhotoQuality: $0.appliedQuality
            )
        }
        completionHandler(self, photosWithURL, currentBlackboardLocationData)
    }

    // NOTE: 「黒板一覧から選択」フローから新たな黒板データを取得、黒板イメージに反映する
    private func blackboardResultCompletedHandler(
        selectionBlackboardListResult result: TakeCameraViewModel.SelectionBlackboardListResult
    ) {
        result.blackboardMaterial.prettyDebug(
            with: "「黒板一覧から選択」フローから新たな黒板データを選択"
        )

        modernBlackboardMaterial = result.blackboardMaterial
        blackboardViewAppearance = result.blackboardAppearance
        
        // 画面の回転中に差し替え前の黒板が見えないようにする
        blackboardView?.alpha = 0

        // - Note: iPadの横向き対応を追加した際、特定の問題が見つかった。ランドスケープモードの選択用黒板一覧画面からポートレートモードのカメラ画面に戻ると、画面の回転により黒板のFrame設定に不具合が生じる。
        // これを解決するには、選択用黒板一覧画面を閉じて画面の回転が完了するまで少し待つ必要があり、試行したところ0.62秒かかった。そのため、一時的な解決策として遅延時間を0.7秒に設定している。
        Task {
            try? await Task.sleep(nanoseconds: 700_000_000) // 0.7秒待機

            willMakeBlackboard(
                originalFrame: blackboardView?.frame,
                specifiedOrientation: isLockedRotation
                    ? pastBlackboardOrientation // （「黒板一覧から選択」画面遷移前の）黒板の向きデータを指定する
                    : cameraOrientation.uiDeviceOrientation
            )
        }
    }

    private var preX: CGFloat = 0.0
    private var preY: CGFloat = 0.0
    
    /// カメラ機能、カメラ領域の描画準備
    /// - Parameters:
    ///   - position: デバイスのカメラの種類（フロント or バックカメラ）
    ///   - originalModernBlackboardFrame: 黒板に指定したいframe（ただし、画面初回表示時、旧黒板、またマルチタスキングアプリ使用時は無効となる）
    ///   - shouldShowBlackboard: カメラの描画後に黒板を表示するかどうか（デフォルトはtrue）
    private func prepareCamera(
        position: AVCaptureDevice.Position,
        originalModernBlackboardFrame: CGRect? = nil,
        shouldShowBlackboard: Bool = true
    ) {
        do {
            var orientation: AVCaptureVideoOrientation?
            
            if launchedByMultitaskingApp {
                orientation = multitaskingAppManager.currentAVCaptureVideoOrientation
            }
            
            cameraType = CameraType.preferred(for: position)
            let result = try cameraDriver.prepareCameraAndMakePreviewLayer(
                position: position,
                orientationForMultitaskingApp: orientation,
                cameraType: cameraType
            )
            // カメラ初期化時にはズーム倍率は1倍にリセット
            cameraDriver.updateScale(to: 1.0, with: cameraType)
            // 最低倍率が1.0倍の時以外はスライダーに1.0倍の目盛を表示
            if cameraType == .single {
                slider.hideScale()
            } else {
                slider.setUpScale()
            }
            
            if result.isFlashAvailable {
                flashButton.isHidden = false
            } else {
                flashButton.isHidden = true
                flashType = FlashType.off
            }
            
            let previewLayer = result.previewLayer
            
            if launchedByMultitaskingApp {
                videoPreviewView.layer.sublayers?.forEach({ layer in
                    if layer is AVCaptureVideoPreviewLayer {
                        layer.removeFromSuperlayer()
                    }
                })
            }
            
            videoPreviewView.layer.addSublayer(previewLayer)
            
            // ビューのサイズの調整
            previewLayer.position = CGPoint(x: self.videoPreviewView.frame.width / 2, y: self.videoPreviewView.frame.height / 2)
            previewLayer.bounds = videoPreviewView.frame
           
            if launchedByMultitaskingApp {
                self.multitaskingAppManager.captureVideoPreviewLayer = previewLayer
            }
            
            let videoDimensions = result.videoDimentions
            
            // ここの処理は「端末が縦長だろうが横長だろうが、横長のdimension情報が返ってくるため
            // 同じこと言っている記事 -> https://qiita.com/shu223/items/057351d41229861251af#avcapturedevice-%E3%81%AE-activeformat-%E3%81%AF%E5%9B%9E%E8%BB%A2%E5%90%91%E3%81%8D%E3%81%AB%E5%BD%B1%E9%9F%BF%E3%81%99%E3%82%8B%E3%81%8B
            // swiftlint:disable:previous line_length
            let long = max(CGFloat(videoDimensions.width), CGFloat(videoDimensions.height))
            let short = min(CGFloat(videoDimensions.width), CGFloat(videoDimensions.height))
            
            var videoAspectRatio = long / short
            
            if launchedByMultitaskingApp {
                videoAspectRatio = multitaskingAppManager.detectVideoAspectRatio(videoDimensions: videoDimensions)
            }
            
            let videoPreviewAspectRatio = videoPreviewView.frame.size.height / videoPreviewView.frame.size.width
            let frame: CGRect
            if videoAspectRatio > videoPreviewAspectRatio {
                // 表示領域よりもiPhoneのカメラが返す撮影領域が縦長のとき
                let width = videoPreviewView.frame.size.height / videoAspectRatio
                frame = CGRect(
                    x: (videoPreviewView.frame.size.width - width) / 2,
                    y: 0,
                    width: width,
                    height: videoPreviewView.frame.size.height
                )
            } else {
                // 表示領域よりもiPhoneのカメラが返す撮影領域が横長のとき
                let height = videoAspectRatio * videoPreviewView.frame.size.width
                frame = CGRect(
                    x: 0,
                    y: (videoPreviewView.frame.size.height - height) / 2,
                    width: videoPreviewView.frame.size.width,
                    height: height
                )
            }
            capturingAreaView.frame = frame
            
            // 黒板を表示するか判定
            guard shouldShowBlackboard else {
                return
            }

            // 黒板の表示を行う
            switch modernBlackboardConfiguration {
            case .enable(let arguments):
                guard !doneInitializingLocationData, let initialLocationData = arguments.initialLocationData else {
                    if launchedByMultitaskingApp {
                        willMakeBlackboard(
                            // マルチタスキングアプリはoriginalModernBlackboardFrameを反映しない
                            originalFrame: nil,
                            specifiedOrientation: multitaskingAppManager.detectBlackboardOrientation()
                        )
                        // willTransitionで保存したかったが、回転前のorientationがなぜか正しく取れなかったため
                        multitaskingAppManager.previousOrientation = multitaskingAppManager.currentOrientation
                    } else {
                        willMakeBlackboard(originalFrame: originalModernBlackboardFrame)
                    }
                    return
                }
                // 画面初期表示時はoriginalModernBlackboardFrameではなくinitialLocationDataを反映する
                willMakeBlackboard(initializeWith: initialLocationData)
            case .disable:
                // 旧黒板はoriginalModernBlackboardFrameを反映しない
                if launchedByMultitaskingApp {
                    willMakeBlackboard(
                        originalFrame: nil,
                        specifiedOrientation: multitaskingAppManager.detectBlackboardOrientation()
                    )
                } else {
                    willMakeBlackboard()
                }
            }
        } catch {
            print(error)
        }
    }

    /// 黒板の表示・非表示ボタンがタップされた時の処理を行う
    ///
    /// - Parameters:
    ///   - shouldShowBlackboard: 黒板が表示されるかどうかを示すブール値
    private func didTapBlackboardVisibilityButton(shouldShowBlackboard: Bool) {
        if shouldShowBlackboard {
            // 黒板を追加し、オンにする
            willMakeBlackboard(
                originalFrame: preHideBlackboardFrame,
                specifiedOrientation: isLockedRotation
                    ? pastBlackboardOrientation
                    : cameraOrientation.uiDeviceOrientation
            )
        } else {
            guard let blackboardView else {
                AndpadCameraConfig.logger.nonFatalError(
                    domain: "CameraViewBlackboardButtonInconsistencyError",
                    message: "カメラ画面の黒板表示不具合: 黒板の表示のオン/オフボタンがオンでも黒板が表示されず、ボタン表示と黒板表示の連携に問題があります。"
                )
                return
            }
            preHideBlackboardFrame = blackboardView.frame
            pastBlackboardOrientation = blackboardView.orientation
            // 黒板を削除し、オフにする
            removeBlackboard()
        }
    }

    /// NOTE: 画面初期表示時の1回のみコールする黒板生成ロジック（以前の黒板ロケーション情報を反映する）
    private func willMakeBlackboard(initializeWith locationData: ModernBlackboardConfiguration.InitialLocationData) {
        isLockedRotation = locationData.isLockedRotation
        blackboardViewAppearance = blackboardViewAppearance?
            .updating(by: locationData.sizeType)

        // 黒板設定で画面ロックを行っていた場合は、 pastBlackboardOrientation に初期表示時点の黒板向き情報を保持する
        // Note: pastBlackboardOrientation は画面ロック有効時に保存形式を変更した際に黒板の向きを復元するのに必要となる。
        if locationData.isLockedRotation {
            pastBlackboardOrientation = locationData.orientation
        }

        // NOTE:
        // 新黒板に限り、前回保存した黒板ロケーション情報（位置 / サイズ）があれば、それらを反映してView生成する
        willMakeBlackboard(
            originalFrame: locationData.frame,
            // 傾きに限り、傾きロックの有無により値を替える
            specifiedOrientation: locationData.isLockedRotation
                ? locationData.orientation
                : cameraOrientation.uiDeviceOrientation
        )
        doneInitializingLocationData = true
    }
    
    private func takePhoto() {
        isCapturing.accept(true)
        
        switch countdownPreset {
        case .none:
            proceedCapturingPhoto()
        case .threeSeconds, .tenSeconds:
            proceedCapturingPhotoCountdown()
        }
    }
    
    private func proceedCapturingPhotoCountdown() {
        cameraCountdown = CameraCountdown(
            preset: countdownPreset,
            isFlashOn: flashType == .on
        )
        
        cameraCountdown?.flashlightModeRelay
            .subscribe(onNext: { [weak self] mode in
                guard let self else { return }
                switch mode {
                case .blink:
                    cameraDriver.blinkFlashlight()
                case .continuous:
                    cameraDriver.turnOnFlashlight()
                }
            })
            .disposed(by: disposeBag)
        
        cameraCountdown?.remainingDurationRelay
            .subscribe(onNext: { [weak self] remainingTime in
                guard let self else { return }
                updateCountdownLabel(remainingTime: remainingTime)
            })
            .disposed(by: disposeBag)
        
        cameraCountdown?.stateRelay
            .subscribe(onNext: { [weak self] status in
                guard let self else { return }
                
                switch status {
                case .running:
                    showCountdownView()
                case .completed:
                    cameraCountdown = nil
                    hideCountdownView()
                    proceedCapturingPhoto()
                case .cancelled:
                    cameraCountdown = nil
                    hideCountdownView()
                    isCapturing.accept(false)
                case .notRunning:
                    // Do nothing
                    break
                }
            })
            .disposed(by: disposeBag)
        
        cameraCountdown?.start()
    }
    
    private func proceedCapturingPhoto() {
        cameraDriver
            .capturePhoto(flashMode: flashType.toAVCaptureFlashMode())
            .observe(on: MainScheduler.instance)
            .do(onDispose: { [weak self] in self?.isCapturing.accept(false) })
            .subscribe(onSuccess: { [weak self] result in
                guard let self else { return }

                let applyingPhotoQuality = photoQuality.value
                let resizeConfiguration = applyingPhotoQuality?.resizeConfiguration ?? preferredResizeConfiguration

                var image = makeMirroredImageIfNeeded(result.image)

                if launchedByMultitaskingApp {
                    image = multitaskingAppManager.adjustImageRotation(
                        image: image,
                        cameraPosition: cameraDriver.position
                    )
                }

                // Exif update
                let exif = NSMutableDictionary(dictionary: result.exif)
                exif[kCGImageDestinationLossyCompressionQuality] = resizeConfiguration.compressionQuality

                if let tiff = exif["{TIFF}"] as? NSMutableDictionary {
                    tiff["Orientation"] = nil
                }
                exif["Orientation"] = nil

                if containsGPSInMetadata,
                   let gpsMetadata = locationManager?.gpsMetadataForLatestLocation() {
                    exif[kCGImagePropertyGPSDictionary as String] = gpsMetadata
                }

                let blackboardImage = makeBlackboardImageIfVisible(with: image.size)
                let rotatedCaptureImages = rotatedCaptureImages(
                    blackboardImage: blackboardImage,
                    captureImage: image,
                    cameraOrientation: cameraOrientation
                )

                // カメラ画像と黒板を合成する
                let captureAndBlackboardImage = rotatedCaptureImages.captureImage.combineImage(
                    image: rotatedCaptureImages.blackboardImage?.image ?? UIImage(),
                    ratio: 1.0,
                    targetX: rotatedCaptureImages.blackboardImage?.origin.x ?? .zero,
                    targetY: rotatedCaptureImages.blackboardImage?.origin.y ?? .zero
                )

                guard let resizedImages = resizedCaptureImages(
                    blackboardImage: rotatedCaptureImages.blackboardImage,
                    captureImage: rotatedCaptureImages.captureImage,
                    captureAndBlackboardImage: captureAndBlackboardImage,
                    resizeConfiguration: resizeConfiguration
                ) else {
                    assertionFailure()
                    return
                }

                let svgKey = saveSVGIfSVGPhotoEnabled(
                    captureImage: resizedImages.captureImage,
                    blackboardImage: resizedImages.blackboardImage,
                    exif: exif
                )
                guard let imageKey = save(captureImage: resizedImages.captureAndBlackboardImage, exif: exif) else {
                    return
                }

                photos.append(
                    .init(
                        imageKey: imageKey,
                        svgKey: svgKey,
                        exif: exif,
                        isBlackboardAttached: isBlackboardVisible,
                        modernBlackboardMaterial: isBlackboardVisible ? modernBlackboardMaterial : nil,
                        legacyBlackboardType: isBlackboardVisible ? selectedType : nil,
                        appliedQuality: applyingPhotoQuality
                    )
                )

                guard allowMultiplePhotos else {
                    assert(photos.count == 1)
                    executeCompletionHandler()
                    dismiss(animated: true, completion: nil)
                    return
                }

                updatePhotoStatus(newImage: captureAndBlackboardImage)
                blackboardMappingModel.initFrame = blackboardView?.frame
            })
            .disposed(by: disposeBag)
    }

    private func removeBlackboard() {
        isBlackboardVisible = false

        blackboardView?.removeFromSuperview()
        blackboardView = nil
    }
    
    /// 黒板描画の準備
    private func willMakeBlackboard(
        originalFrame: CGRect? = nil,
        specifiedOrientation: UIDeviceOrientation? = nil
    ) {
        // Web の黒板設定で SVG 撮影を設定した場合は、透過度設定によらず、透過設定を一律非透過固定にする(ただし、 JPG に戻した場合に透過度設定を元に戻す)必要がある。
        // 黒板描画前のこのタイミングで透過度設定を一時的に保持し、JPG 設定の場合は設定をもとに戻すようにした。
        // NOTE: 本来であればwillMakeBlackboard の責務を超える処理だが、willMakeBlackboard が呼ばれている箇所が広範囲のため、実装漏れを防ぐためにここで処理を行う。
        if let viewModel, let blackboardViewAppearance {
            switch viewModel.photoFormat.value {
            case .svg:
                // 透過度設定を非透過固定に設定し、設定値を一時的に保持する
                temporaryCurrentAlphaLevelForJPEG = blackboardViewAppearance.alphaLevel
                self.blackboardViewAppearance = blackboardViewAppearance.updating(by: ModernBlackboardAppearance.AlphaLevel.zero)
            case .jpeg:
                // 透過度設定を元に戻す
                if let temporaryCurrentAlphaLevelForJPEG {
                    self.blackboardViewAppearance = blackboardViewAppearance.updating(by: temporaryCurrentAlphaLevelForJPEG)
                    self.temporaryCurrentAlphaLevelForJPEG = nil
                }
            }
        }

        guard !isOfflineMode else {
            willMakeOfflineBlackboard(
                originalFrame: originalFrame,
                specifiedOrientation: specifiedOrientation
            )
            return
        }

        // 豆図画像のロード
        func loadMiniatureMapImage(with blackboardMaterial: ModernBlackboardMaterial?) {
            guard let blackboardMaterial = modernBlackboardMaterial else {
                assertionFailure()
                return
            }
            guard let imageUrl = blackboardMaterial.miniatureMap?.imageURL else {
                self.makeBlackboard(
                    originalFrame: originalFrame,
                    specifiedOrientation: specifiedOrientation,
                    // 画像URLがなければ、豆図エリアはブランク表示する
                    miniatureMapImageState: .noURL(useCameraView: true)
                )
                return
            }
            
            let completion: (MiniatureMapImageState) -> Void = { [weak self] miniatureMapImageState in
                switch miniatureMapImageState {
                case .beforeLoading:
                    assertionFailure()
                case .loadSuccessful, .noURL:
                    self?.makeBlackboard(
                        originalFrame: originalFrame,
                        specifiedOrientation: specifiedOrientation,
                        miniatureMapImageState: miniatureMapImageState
                    )
                case .loadFailed:
                    // カメラ画面の場合、黒板イメージは表示せず、また表示できない旨をアラート表示する
                    self?.showCannotGetMiniatureMapImageAlert(
                        retryHandler: { _ in loadMiniatureMapImage(with: blackboardMaterial) },
                        cancelHandler: { [weak self] _ in self?.dismiss(animated: true) }
                    )
                }
            }
            
            MiniatureMapImageLoader.load(
                imageUrl: imageUrl,
                // ネットワークの状態を確認（オフライン時は失敗扱いとする）
                shouldCheckNetworkStatusBeforeLoading: true,
                completion: completion
            )
        }
        
        // （黒板描画前に）豆図画像の取得が必要かチェックする
        if shouldShowMiniatureMap {
            loadMiniatureMapImage(with: modernBlackboardMaterial)
        } else {
            makeBlackboard(
                originalFrame: originalFrame,
                specifiedOrientation: specifiedOrientation,
                miniatureMapImageState: nil
            )
        }
    }

    /// オフラインモードの場合に、保存済みの豆図画像を取得してから黒板を生成する
    private func willMakeOfflineBlackboard(
        originalFrame: CGRect?,
        specifiedOrientation: UIDeviceOrientation?
    ) {
        let state = offlineMiniatureMapImageState()
        if case .loadFailed = state {
            // カメラ画面の場合、黒板イメージは表示せず、また表示できない旨をアラート表示する
            showCannotGetMiniatureMapImageAlert(cancelHandler: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            return
        }
        makeBlackboard(
            originalFrame: originalFrame,
            specifiedOrientation: specifiedOrientation,
            miniatureMapImageState: state
        )
    }

    /// オフラインの場合の豆図取得状態
    /// - Returns: オフラインの場合の豆図取得状態
    private func offlineMiniatureMapImageState() -> MiniatureMapImageState {
        guard let id = modernBlackboardMaterial?.miniatureMap?.id else {
            // 豆図なし
            return .noURL(useCameraView: true)
        }
        guard let image = OfflineStorageHandler.shared.blackboard.fetchMiniatureMap(withID: id, imageType: .rawImage) else {
            // 豆図IDは存在するのに、画像の取得に失敗
            return .loadFailed
        }
        return .loadSuccessful(image)
    }

    /// 黒板描画
    private func makeBlackboard(
        originalFrame: CGRect?,
        specifiedOrientation: UIDeviceOrientation?,
        miniatureMapImageState: MiniatureMapImageState?
    ) {
        
        func configureBlackBoardImageView(
            frame: CGRect,
            prohibitArea: CGRect?,
            blackboardImage: UIImage
        ) -> BlackboardImageView? {
            guard let blackboardImageView = CustomViewType.blackboard.getActualView(blackboardType: .image) as? BlackboardImageView else {
                return nil
            }
            
            blackboardImageView.configure(defaultImage: blackboardImage)
            blackboardImageView.configure(orientation: specifiedOrientation ?? cameraOrientation.uiDeviceOrientation)

            blackboardImageView.frame = frame
            blackboardImageView.enableMove()
            
            blackboardImageView.moveCompletedHandler = { view in
                print(view.moveEndPoint ?? "moveEndPoint is nil.")
            }

            // 黒板のドラッグハンドルを使ったサイズ変更の設定をする
            switch modernBlackboardConfiguration {
            case .enable:
                if let viewModel {
                    blackboardImageView.resizeEnabled = viewModel.isResizeEnabled()
                    blackboardImageView.resizeCompletedHandler = { [weak self] in
                        guard let self else { return }
                        // 黒板のドラッグハンドルを使ったら、ユーザーの操作した黒板サイズは「自由値」に更新
                        // 仮にユーザーの操作した結果が、「小・中・大」のサイズと一致していても、「自由値」とする
                        blackboardViewAppearance = blackboardViewAppearance?
                            .updating(by: .free)
                    }
                }
            case .disable:
                // 旧黒板の場合、常にリサイズ可能とする
                blackboardImageView.resizeEnabled = true
            }

            blackboardImageView.tapHandler = { [weak self] in
                guard let self else { return }
                switch self.modernBlackboardConfiguration {
                case .enable(let arguments):
                    self.showBlackboardChangeOptionsAlert(with: arguments.orderID)
                case .disable:
                    self.goToEditBlackboard()
                }
            }
            
            blackboardImageView.prohibitArea = prohibitArea
            return blackboardImageView
        }
        
        guard isBlackboardEnabled else {
            return
        }
        
        if blackboardView != nil {
            removeBlackboard()
        }

        Task { @MainActor in
            // 黒板の表示が完了するまで撮影ボタン等を無効化
            setShutterButtonsEnabled(false)
            defer {
                // 黒板の表示が完了したら撮影ボタン等を有効化
                setShutterButtonsEnabled(true)
            }

            // マルチタスキング対応アプリだと黒板表示時は毎回ここの処理が走るので、ユーザ体験的にこのdelayを小さめにした
            let delayAmount: UInt64 = launchedByMultitaskingApp ? 180_000_000 : 500_000_000 // 0.18秒または0.5秒待機
            try? await Task.sleep(nanoseconds: delayAmount)

            guard blackboardView == nil else { return }

            if self.launchedByMultitaskingApp {
                self.isBlackboardVisible = self.multitaskingAppManager.isBlackboardOn
            } else {
                self.isBlackboardVisible = true
            }

            let orientation = specifiedOrientation ?? cameraOrientation.uiDeviceOrientation
            
            // 新黒板
            if
                let modernBlackboardMaterial = self.modernBlackboardMaterial,
                let appearance = self.blackboardViewAppearance,
                let modernBlackboardView = ModernBlackboardView(
                    modernBlackboardMaterial,
                    appearance: appearance,
                    miniatureMapImageState: miniatureMapImageState,
                    displayStyle: .normal(shouldSetCornerRounder: false)
                ),
                // 新黒板の場合、initでViewModelが生成されている
                let viewModel {
                let useBlackboardGeneratedWithSVG = viewModel.remoteConfig?.fetchUseBlackboardGeneratedWithSVG() ?? false
                if useBlackboardGeneratedWithSVG {
                    // SVG生成は時間がかかるので、ローディングを表示する
                    // 従来では不要なので、不恰好であるが、分岐する
                    self.showLoading()
                }
                let blackboardImage = await modernBlackboardView.exportImage(
                    miniatureMapImageType: .rawImage,
                    shouldShowMiniatureMapFromLocal: isOfflineMode,
                    isShowEmptyMiniatureMap: false,
                    // 撮影画面では、豆図の部分が、豆図画像ロード前の画像か豆図登録なしの画像の場合、非表示にする。
                    isHiddenNoneAndEmptyMiniatureMap: true,
                    useBlackboardGeneratedWithSVG: useBlackboardGeneratedWithSVG
                )
                if useBlackboardGeneratedWithSVG {
                    self.hideLoading()
                }
                
                guard let blackboardImage else { return }

                // NOTE: 元の黒板ではviewModelのセットを最初に行っていた
                // （上のswitch文で必要なデータは渡す想定なので不要そう）
                
                modernBlackboardView.frame = originalFrame ?? TakeCameraViewController.calcBlackboardFrame(
                    parentFrame: self.capturingAreaView.frame,
                    deviceOrientation: orientation,
                    targetViewFrame: modernBlackboardView.frame,
                    prioritizeFrame: nil
                )
                
                modernBlackboardView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
                modernBlackboardView.orientation = orientation
                
                guard let blackBoardImageView = configureBlackBoardImageView(
                    frame: modernBlackboardView.frame,
                    prohibitArea: self.capturingAreaView.frame,
                    blackboardImage: blackboardImage
                ) else { return }
                
                self.videoPreviewView.addSubview(blackBoardImageView)
                // インスタンスを保持
                self.blackboardView = blackBoardImageView

                await forceUpdateBlackboardFrameIfNeeded()

                // 新黒板にグリッド線を表示する
                setUpGridLine(below: blackBoardImageView)

                // 黒板設定の未読バッジの表示状態の更新は、表示される黒板のサイズが確定してからでないとバッジ表示判定ができないので、ここで行う
                showNotifyBadgeOnBlackBoardButton(
                    viewModel.shouldShowBadgeForModernBlackboardSettings(
                        currentBlackboardSizeType: blackboardViewAppearance?.sizeType ?? .free
                    )
                )
            // 既存黒板
            } else if let blackBoardView = CustomViewType.blackboard.getView(
                blackboardType: self.selectedType,
                shouldIgnoreValueOfCombinedItem: false
            ) as? BlackBoardView {
                blackBoardView.setViewModel(viewModel: self.blackboardMappingModel)
                guard (try? blackBoardView.toImage()) != nil else { return }
                
                do {
                    let blackboardImage = try blackBoardView.toImage()
                    blackBoardView.frame = originalFrame ?? TakeCameraViewController.calcBlackboardFrame(
                        parentFrame: self.capturingAreaView.frame,
                        deviceOrientation: orientation,
                        targetViewFrame: blackBoardView.frame,
                        prioritizeFrame: self.blackboardMappingModel.initFrame
                    )
                    blackBoardView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
                    blackBoardView.orientation = orientation
                    
                    guard let blackBoardImageView = configureBlackBoardImageView(
                        frame: blackBoardView.frame,
                        prohibitArea: self.capturingAreaView.frame,
                        blackboardImage: blackboardImage
                    ) else { return }
                    self.videoPreviewView.addSubview(blackBoardImageView)
                    self.blackboardView = blackBoardImageView
                    // Note: 旧黒板にはグリッド線は表示しない
                } catch {
                    print(error)
                }
            }
            self.rotateBlackboardIfNeed(specifiedOrientation: specifiedOrientation)
        }
    }

    /// カメラのキャプチャエリアに9分割グリッド線を表示する
    ///
    /// ユーザーが黒板の位置を決めるためのガイドラインの役割を果たす。
    /// 黒板より下のレイヤーにする。
    /// - Parameter blackboardImageView: グリッド線の上に重なる兄弟Viewである黒板。
    private func setUpGridLine(below blackboardImageView: BlackboardImageView) {
        // 黒板と同じ親ビューにする必要がある
        let gridLineView = TakeCameraGridLineView()
        videoPreviewView.insertSubview(gridLineView, belowSubview: blackboardImageView)

        gridLineView.snp.makeConstraints { make in
            // カメラのキャプチャエリアに端を合わせる
            make.edges.equalTo(capturingAreaView)
        }
    }

    private func initializeMotionManager() {
        motionManager = CMMotionManager()
        motionManager?.accelerometerUpdateInterval = 0.2
        motionManager?.gyroUpdateInterval = 0.2
        motionManager?.startAccelerometerUpdates(
            to: (OperationQueue.current)!,
            withHandler: { accelerometerData, error -> Void in
                if error == nil {
                    self.outputAccelertionData((accelerometerData?.acceleration)!)
                } else {
                    print("\(error!)")
                }
            }
        )
        
        // NOTE: 画面初期表示時に .faceUp、.faceDownだったケースでカメラの初期化がうまくいかないことがあったため、
        // こちらで明示的にコールする（新黒板で且つ画面初期表示時のみ）
        if isModernBlackboard, !doneInitializingLocationData {
            onOrientationChange()
        }
    }

    private func prepareLocationManagerIfNeeded() {
        // have checked location permission before go to TakeCameraViewController
        // containsGPSInMetadata = true when location permission is grant
        guard containsGPSInMetadata else { return }
        locationManager = DKCameraLocationManager()
        locationManager?.startUpdatingLocation()
        locationStatusManager = LocationStatusManager()
        locationStatusManager?.delegate = self
        locationStatusManager?.checkLocationPermission()
        locationStatusManager?.startUpdateLocation()
        
        // GPS機能がONで端末の位置情報のパーミッションがOFFの場合は警告メッセージを表示
        view.addSubview(gpsWarningView)
        gpsWarningView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gpsWarningView.leadingAnchor.constraint(equalTo: videoPreviewView.leadingAnchor),
            gpsWarningView.trailingAnchor.constraint(equalTo: videoPreviewView.trailingAnchor),
            gpsWarningView.topAnchor.constraint(equalTo: photoCountLabel.superview!.bottomAnchor, constant: 32),
            gpsWarningView.heightAnchor.constraint(equalToConstant: 39)
        ])
    }

    private func outputAccelertionData(_ acceleration: CMAcceleration) {
        guard !launchedByMultitaskingApp else { return }
        
        var orientationNew: AVCaptureVideoOrientation
        if acceleration.x >= 0.75 {
            orientationNew = .landscapeRight
        } else if acceleration.x <= -0.75 {
            orientationNew = .landscapeLeft
        } else if acceleration.y <= -0.75 {
            orientationNew = .portrait
        } else if acceleration.y >= 0.75 {
            orientationNew = .portraitUpsideDown
        } else {
            // Consider same as last time
            return
        }

        if isOldBlackboard, orientationNew == cameraOrientation { return }
        
        cameraOrientation = orientationNew
        onOrientationChange()
    }
    
    private func startListeningVolumeButton() {
        // MPVolumeViewを画面の外側に追い出して見えないようにする
        let frame = CGRect(x: -100, y: -100, width: 100, height: 100)
        let volumeView = MPVolumeView(frame: frame)
        volumeView.sizeToFit()
        view.addSubview(volumeView)
        addVolumeObserver()
    }
    
    private func addVolumeObserver() {
        if #available(iOS 15.0, *) {
            let audioSession = AVAudioSession.sharedInstance()
            outputVolumeObservation = audioSession.observe(
                \.outputVolume,
                 // swiftlint:disable:next vertical_parameter_alignment_on_call
                 changeHandler: { [weak self]  _, _ in
                     self?.takePhoto()
                 }
            )
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(TakeCameraViewController.volumeChanged(notification:)),
                name: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
                object: nil
            )
        }
    }
    
    private func removeVolumeObserver() {
        if #available(iOS 15.0, *) {
            outputVolumeObservation = nil
        } else {
            NotificationCenter.default.removeObserver(
                self,
                name: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
                object: nil
            )
        }
    }
    
    @objc func volumeChanged(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String,
            volumeChangeType == "ExplicitVolumeChange" else {
            return
        }
        
        takePhoto()
    }
    
    private func setAudioSessionActive(_ bool: Bool) {
        // 「音量ボタンで撮影」問題でiOS15以上で必要
        if #available(iOS 15.0, *) {
            try? AVAudioSession.sharedInstance().setActive(bool)
        }
    }
    
    private func makeMirroredImageIfNeeded(_ image: UIImage) -> UIImage {
        switch cameraDriver.position {
        case .front:
            // MEMO: インカムで撮影するとphotoOutputでやってくる画像が左右または上下逆さまになっているので補正する
            return UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
        case .back, .unspecified:
            return image
        @unknown default:
            return image
        }
    }
    
    /// 撮影した写真群を破棄してカメラ画面を閉じる
    private func destroyPhotos() {
        switch modernBlackboardConfiguration {
        case .enable:
            cancelHandler(self, currentBlackboardLocationData)
            dismiss(animated: true, completion: nil)
        case .disable:
            // NOTE:
            // 新黒板（.enable）は黒板ロケーション情報の反映を是正するためにdismissの順序を変更した
            // 旧黒板（.disable）については極力変更しないよう言われているので、処理順序は変更していない
            // （何か問題が発生した際は、新黒板と同じ処理順序にすること）
            dismiss(animated: true, completion: nil)
            cancelHandler(self, nil)
        }
    }

    ///　撮影した写真群を遷移元画面に渡した上でカメラを閉じる
    private func executeCompletionAndDismiss() {
        executeCompletionHandler()
        dismiss(animated: true, completion: nil)
    }

    /// 黒板サイズ「自由値」を選択している場合に一時的に黒板のFrameを保存する
    private func saveTemporaryFreeBlackboardFrameIfNeeded() {
        guard blackboardViewAppearance?.sizeType == .free else {
            return
        }
        temporaryFreeBlackboardFrame = blackboardView?.frame
    }

    private func showNotifyBadgeOnBlackBoardButton(_ showNotifyBadge: Bool) {
        blackBoardButton.isSelected = showNotifyBadge
    }

    private func shouldHideBlackboardSettingButton() -> Bool {
        switch modernBlackboardConfiguration {
        case .enable(let configureArguments):
            configureArguments.isHiddenBlackboardSwitchButton
        case .disable:
            !isBlackboardEnabled
        }
    }

    /// フラッシュの種類が更新されるたび、ボタンのUIを更新する
    ///
    /// 3種類あるので、UIControl.State（isSelected等）で代用することはできない
    private func updateFlashButton() {
        flashButton.setImage(flashType.icon, for: .normal)
        flashButton.setTitle(flashType.title, for: .normal)
    }
    
    private func updateTimerButton() {
        timerButton.setTitle(countdownPreset.displayedText, for: .normal)
    }

    private func setUpViews() {
        nextButton.setTitle(
            isOfflineMode ? L10n.Common.save : L10n.Camera.Button.next,
            for: .normal
        )
        nextButton.setTitleColor(.tsukuri.system.andpadDarkRed, for: .normal)
        nextButton.setTitleColor(UIColor.hexStr("BBBBBB", alpha: 1.0), for: .disabled)

        // ヘッダー部分
        // ヘッダーの左側
        if isBlackboardEnabled {
            mappingButton.isHidden = true // NOTE: not released yet
            
            if let shootingGuideImageView {
                shootingGuideButton.isHidden = false
                shootingGuideButton.setTitle(L10n.Camera.iconTitleOff, for: .normal)
                shootingGuideButton.setTitle(L10n.Camera.iconTitleOn, for: .selected)
                shootingGuideButton.isSelected = true

                shootingGuideImageView.isHidden = false
                view.addSubview(shootingGuideImageView)
                shootingGuideImageView.snp.makeConstraints { make in
                    make.edges.equalTo(videoPreviewView)
                }
            } else {
                shootingGuideButton.isHidden = true
            }
        } else {
            mappingButton.isHidden = true
            shootingGuideButton.isHidden = true
        }

        // ヘッダーの右側
        thumbnailImageButton.contentHorizontalAlignment = .fill
        thumbnailImageButton.contentVerticalAlignment = .fill
        thumbnailImageButton.imageView?.contentMode = .scaleAspectFill
        thumbnailImageButton.imageView?.layer.cornerRadius = 2.0

        photoCountLabel.isHidden = !allowMultiplePhotos

        updatePhotoStatus()

        // フッター部分
        slider.minimumTrackTintColor = .tsukuri.system.andpadRed
        slider.maximumTrackTintColor = .tsukuri.system.white

        // フッターの左側
        flashButton.isHidden = true
        updateFlashButton()

        frontAndBackCameraSwitchButton.setTitle(L10n.Camera.iconTitleSwitchBack, for: .normal)
        frontAndBackCameraSwitchButton.setTitle(L10n.Camera.iconTitleSwitchFront, for: .selected)

        // フッターの右側
        blackBoardButton.isHidden = shouldHideBlackboardSettingButton()
        // 初期状態はdisabledにしておく
        blackBoardButton.isEnabled = false
        blackBoardButton.setTitle(L10n.Camera.iconTitleBlackboardSettings, for: .normal)

        if isBlackboardEnabled {
            // 「黒板付きで写真を撮る」が選択された場合、初期状態はdisabledにしておく
            // 有効化は黒板の表示完了時の処理に任せる
            shutterButton.isEnabled = false
        }

        // キャプチャエリア全体
        capturingAreaView.isUserInteractionEnabled = false
        videoPreviewView.addSubview(capturingAreaView)
        videoPreviewView.addSubview(aeafLockLabel)
        
        countdownLabel.layer.shadowColor = UIColor.black.cgColor
        countdownLabel.layer.shadowRadius = 15.0
        countdownLabel.layer.shadowOpacity = 0.75
        countdownLabel.layer.shadowOffset = .zero
        countdownLabel.layer.masksToBounds = false
        
        updateTimerButton()
    }

    private func setUpGestureRecognizers() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(TakeCameraViewController.tapAction)
        )
        tap.delegate = self
        videoPreviewView.addGestureRecognizer(tap)

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(TakeCameraViewController.longPressAction)
        )
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        videoPreviewView.addGestureRecognizer(longPress)
    }

    private func addBindings() {
        cameraDriver
            .didLockFocusAndExposure
            .emit(onNext: { [weak self] _ in
                self?.aeafLockAnimation()
            })
            .disposed(by: disposeBag)

        focusView.sliderValue
            .asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let self else { return }
                cameraDriver.updateISO(to: value, baseISO: baseIso)
            })
            .disposed(by: disposeBag)
    }

    private func observeIsTakePhotoFinished() {
        Observable.combineLatest(
            diskImageStore.saveImageProgress.rx.observe(\.isFinished),
            isCapturing
        )
        .map { $0 && !$1 }
        .distinctUntilChanged()
        .asDriver(onErrorJustReturn: true)
        .drive { [weak self] in
            self?.handleIsTakePhotoFinished($0)
        }
        .disposed(by: disposeBag)
    }

    private func handleIsTakePhotoFinished(_ isTakePhotoFinished: Bool) {
        nextButton.isEnabled = isTakePhotoFinished
        nextButton.isHidden = photos.isEmpty
    }

    private func observeIsEnabledNextButton() {
        nextButton.rx.observe(\.isEnabled)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .map { $0 ? .tsukuri.system.white : UIColor.grayDD() }
            .drive(nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    /// 撮影ボタンと黒板設定ボタンの有効/無効を設定
    /// - Parameter isEnabled: 有効/無効
    private func setShutterButtonsEnabled(_ isEnabled: Bool) {
        // 撮影ボタンの有効/無効を設定
        shutterButton.isEnabled = isEnabled
        // 黒板設定ボタンの有効/無効を設定
        blackBoardButton.isEnabled = isEnabled
    }
}

// MARK: - CameraNavigationController

/// ルートビューコントローラーをカメラ画面とするUINavigationController
///
/// カメラ画面と、カメラ画面に表示される標準アラートをportrait固定にして、
/// それ以外のビューコントローラーは全ての向きに対応させる
///
/// - Note: iOS 16 未満の場合、遷移先画面での画面回転を可能にするには、
/// Appleの非公式APIを使うしかなく、これはアプリの審査でリジェクトされるリスクがある。
/// PM・営業を含めて相談したところ、OSごとに対応を分ける方針で承諾をもらった。
/// この方針に決まった理由としては、(1)審査でリジェクトされるリスクはとれないこと、
/// (2)遷移先画面での画面回転をさせたい場合は、ユーザーにOSをアップデートしてもらう、もしくは、
/// 新しい端末購入を検討してもらうという説明で通る、という点が挙げられた。
private final class CameraNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard #available(iOS 16, *) else {
            // iOS 16 未満の場合、従来通り遷移先画面で画面回転しなくていいものとする
            return .portrait
        }

        if visibleViewController is TakeCameraViewController {
            return .portrait
        } else if
            viewControllers.first is TakeCameraViewController,
            (presentedViewController is UIAlertController) || (presentedViewController is CameraDropdownPresentable) {
            // カメラ画面では標準アラートの使用をやめるのでここを通ることはない想定だが、
            // 意図せず標準アラートが表示された場合、標準アラートに釣られて
            // カメラ画面自体が回転してしまうのを防ぐために、これもportrait固定にする
            // The presented dropdown viewController should also follow the same orientation of the TakeCameraViewController
            return .portrait
        } else {
            return .all
        }
    }
}

// MARK: - Location Status Manager Delegate functions
extension TakeCameraViewController: LocationStatusManagerDelegate {
    public func cameralocation(status: CLAuthorizationStatus) {
        guard containsGPSInMetadata else { return }
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            gpsWarningView.setGPSNotReceivedMessage()
        case .notDetermined, .denied, .restricted:
            // パーミッションが未設定/拒否/使用不可設定されている場合、
            // パーミッションがないため位置情報が取得できないメッセージを表示
            gpsWarningView.setGPSDisabledMessage()
        @unknown default:
            // このルートはありえないためfatalErrorとする
            fatalError()
        }
    }
    
    public func cameralocation(coordinate: CLLocationCoordinate2D) {
        gpsWarningView.hideMessage()
    }
}

// MARK: - Static functions
extension TakeCameraViewController {
    
    // Note: 現状、navigationControllerに対してpushしている箇所があるためnavigationControllerが必須
    // navigationControllerがない状態で動作するようにできるか要検討 @yukkobay
    
    /// TODO
    /// - Parameters:
    ///   - data: TODO
    ///   - appBaseRequestData: TODO
    ///   - isBlackboardEnabled: 黒板付きで写真を撮れるかどうか。「黒板付きで写真を撮る」が選択された場合は `true` 、「写真を撮る」が選択された場合は `false` 。
    ///   - modernBlackboardConfiguration: TODO
    ///   - allowMultiplePhotos: TODO
    ///   - inspectionTemplateEnabled: TODO
    ///   - shootingGuideImageUrl: TODO
    ///   - maxPhotoCount: TODO
    ///   - preferredResizeConfiguration: 写真撮影時のリサイズに利用される設定。`photoQualityOptions`に1つ以上の選択肢を渡すとカメラ上で画質を選択することができ、その場合はそちらの設定が優先されます。将来的にはCALS対応に向けて通常カメラでも画質を選択できるようになる予定で、その際この設定は削除されます。
    ///   - photoQualityOptions: カメラ上で選択可能な画質設定。画質設定オプションを無効にしたい場合は空配列を渡してください。
    ///   - initialPhotoQuality: 画質設定の初期値。`photoQualityOptions`に含まれた値であること。
    ///   - cancelHandler: TODO
    ///   - completedHandler: TODO
    ///   - permissionNotAuthorizedHandler: TODO
    ///   - launchedByMultitaskingApp: マルチタスキング対応アプリから起動されたかどうか（今のところ図面のipadのみ）
    ///   - storage: 新黒板付きカメラのストレージ。新黒板付きカメラのみで指定する必要がある。旧黒板や黒板なしのカメラでは使用しないので、デフォルト値 `nil` でよい。
    /// - Returns: TODO
    public static func makeNavigationInstance(
        isOfflineMode: Bool = false,
        data: BlackBoard? = nil,
        appBaseRequestData: AppBaseRequestData? = nil,
        isBlackboardEnabled: Bool = true,
        modernBlackboardConfiguration: ModernBlackboardConfiguration = .disable,
        analytics: AndpadAnalyticsCameraProtocol? = nil,
        allowMultiplePhotos: Bool = true,
        inspectionTemplateEnabled: Bool = false,
        shootingGuideImageUrl: URL? = nil,
        maxPhotoCount: Int = 30,
        preferredResizeConfiguration: ResizeConfiguration = .init(
            size: "2300x2300",
            compressionQuality: 0.8
        ),
        photoQualityOptions: [PhotoQuality],
        initialPhotoQuality: PhotoQuality?,
        cancelHandler: @escaping (TakeCameraViewController, ModernBlackboardConfiguration.InitialLocationData?) -> Void,
        completedHandler: @escaping URLCompletionHandler,
        permissionNotAuthorizedHandler: @escaping (TakeCameraViewController, AVAuthorizationStatus) -> Void,
        launchedByMultitaskingApp: Bool = false,
        storage: (any ModernBlackboardCameraStorageProtocol)? = nil,
        containsGPSInMetadata: Bool = false
    ) -> UINavigationController {
        let cameraViewController = make(
            isOfflineMode: isOfflineMode,
            data: data,
            appBaseRequestData: appBaseRequestData,
            isBlackboardEnabled: isBlackboardEnabled,
            modernBlackboardConfiguration: modernBlackboardConfiguration,
            analytics: analytics,
            allowMultiplePhotos: allowMultiplePhotos,
            inspectionTemplateEnabled: inspectionTemplateEnabled,
            shootingGuideImageUrl: shootingGuideImageUrl,
            maxPhotoCount: maxPhotoCount,
            completionHandler: completedHandler,
            preferredResizeConfiguration: preferredResizeConfiguration,
            photoQualityOptions: photoQualityOptions,
            initialPhotoQuality: initialPhotoQuality,
            cancelHandler: cancelHandler,
            permissionNotAuthorizedHandler: permissionNotAuthorizedHandler,
            launchedByMultitaskingApp: launchedByMultitaskingApp,
            storage: storage,
            containsGPSInMetadata: containsGPSInMetadata
        )
        
        let navigationController = CameraNavigationController(rootViewController: cameraViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        
        return navigationController
    }
    
    static func make(
        isOfflineMode: Bool,
        data: BlackBoard? = nil,
        appBaseRequestData: AppBaseRequestData? = nil,
        isBlackboardEnabled: Bool = true,
        modernBlackboardConfiguration: ModernBlackboardConfiguration = .disable,
        analytics: AndpadAnalyticsCameraProtocol? = nil,
        allowMultiplePhotos: Bool = true,
        inspectionTemplateEnabled: Bool = false,
        shootingGuideImageUrl: URL? = nil,
        maxPhotoCount: Int = 30,
        completionHandler: @escaping URLCompletionHandler,
        preferredResizeConfiguration: ResizeConfiguration,
        photoQualityOptions: [PhotoQuality],
        initialPhotoQuality: PhotoQuality?,
        cancelHandler: @escaping (TakeCameraViewController, ModernBlackboardConfiguration.InitialLocationData?) -> Void,
        permissionNotAuthorizedHandler: @escaping (TakeCameraViewController, AVAuthorizationStatus) -> Void,
        launchedByMultitaskingApp: Bool = false,
        storage: (any ModernBlackboardCameraStorageProtocol)?,
        containsGPSInMetadata: Bool = false
    ) -> TakeCameraViewController {
        BlackBoardTypeManager.inspectionTemplateEnabled = inspectionTemplateEnabled
        
        let takeCameraVC = TakeCameraViewController(
            isOfflineMode: isOfflineMode,
            modernBlackboardConfiguration: modernBlackboardConfiguration,
            analytics: analytics,
            completionHandler: completionHandler,
            appBaseRequestData: appBaseRequestData,
            shootingGuideImageUrl: shootingGuideImageUrl,
            preferredResizeConfiguration: preferredResizeConfiguration,
            photoQualityOptions: photoQualityOptions,
            initialPhotoQuality: initialPhotoQuality,
            permissionNotAuthorizedHandler: permissionNotAuthorizedHandler,
            storage: storage
        )
        takeCameraVC.modalPresentationStyle = .fullScreen
        
        takeCameraVC.cancelHandler = cancelHandler

        // 旧黒板であれば、マッピングモデルにデータをセットする
        if case .disable = modernBlackboardConfiguration {
            takeCameraVC.blackboardMappingModel.setModel(model: data)
        }
        
        takeCameraVC.isBlackboardEnabled = isBlackboardEnabled
        takeCameraVC.allowMultiplePhotos = allowMultiplePhotos
        takeCameraVC.maxPhotoCount = maxPhotoCount
        takeCameraVC.launchedByMultitaskingApp = launchedByMultitaskingApp
        takeCameraVC.containsGPSInMetadata = containsGPSInMetadata
        
        return takeCameraVC
    }
    
    static func calcBlackboardFrame(
        parentFrame: CGRect,
        deviceOrientation: UIDeviceOrientation,
        targetViewFrame: CGRect,
        prioritizeFrame: CGRect?
    ) -> CGRect {
        guard let prioritizeFrame else {
            let blackboardWidth = parentFrame.size.width * blackboardToWidthRatio
            let blackboardHeight = blackboardWidth * targetViewFrame.size.height / targetViewFrame.size.width
            let blackboardX: CGFloat
            let blackboardY: CGFloat
            
            // 画面の向きに応じて、黒板の初期フレーム位置を計算
            // 角にピッタリつくようにする
            switch deviceOrientation {
            case .landscapeLeft, .landscapeRight:
                blackboardX = parentFrame.size.width - blackboardHeight + parentFrame.origin.x
                blackboardY = parentFrame.size.height - blackboardWidth + parentFrame.origin.y
            default:
                blackboardX = parentFrame.size.width - blackboardWidth + parentFrame.origin.x
                blackboardY = parentFrame.size.height - blackboardHeight + parentFrame.origin.y
            }
            return .init(
                x: blackboardX,
                y: blackboardY,
                width: blackboardWidth,
                height: blackboardHeight
            )
        }
        return prioritizeFrame
    }
    
    public static func clearData() {
        DiskImageStore.clear()
    }
}

// MARK: - for blackboard list view controller
extension TakeCameraViewController {
    private func routeBlackboardListHandler(orderID: Int) -> ((CustomizedAlertAction) -> Void)? {
        return { [weak self] _ in
            guard let self, let snapshotData else { return }
            pastBlackboardOrientation = blackboardView?.orientation

            let newAppBaseRequestData: AppBaseRequestData? = isOfflineMode ? .offlineData : appBaseRequestData
            guard let newAppBaseRequestData else { return }

            let viewController = AppDependencies.shared.modernBlackboardListViewController(
                .init(
                    orderID: orderID,
                    appBaseRequestData: newAppBaseRequestData,
                    snapshotData: snapshotData,
                    selectedBlackboard: self.modernBlackboardMaterial,
                    advancedOptions: self.advancedOptions,
                    isOfflineMode: isOfflineMode
                )
            )
            self.navigationControllerIntoBlackboardList = UINavigationController(rootViewController: viewController)
            self.navigationControllerIntoBlackboardList?.modalPresentationStyle = .overFullScreen

            if let viewModel = self.viewModel {
                viewController.didTapBlackboardImageButtonSignal
                    .map { TakeCameraViewModel.Input.didTapBlackboardImageButtonInBlackboardListView($0) }
                    .emit(to: viewModel.inputPort)
                    .disposed(by: viewController.disposeBag)
                
                viewController.didTapEditButtonSignal
                    .map { TakeCameraViewModel.Input.didTapEditButtonInBlackboardListView($0) }
                    .emit(to: viewModel.inputPort)
                    .disposed(by: viewController.disposeBag)
                
                viewController.didTapTakePhotoButtonSignal
                    .map { TakeCameraViewModel.Input.didTapTakePhotoButtonInBlackboardListView($0) }
                    .emit(to: viewModel.inputPort)
                    .disposed(by: viewController.disposeBag)

                viewController.cancelResultHandler = setSelectableBlackboardListCancelResultHandler()
            }
            
            guard let navigationController = self.navigationControllerIntoBlackboardList else { return }

            self.present(navigationController, animated: true) { [weak self] in
                // 選択用黒板一覧から黒板を選択して撮影画面に戻ってきた瞬間に、黒板が表示完了していないのに撮影ボタンがタップできてしまう状態を回避するため、画面遷移時に撮影ボタン等を無効化しておく
                self?.setShutterButtonsEnabled(false)
            }
        }
    }

    private func returnToTakeCameraViewController(
        targetViewController: UIViewController?,
        selectionBlackboardListResult result: TakeCameraViewModel.SelectionBlackboardListResult
    ) {
        blackboardResultCompletedHandler(selectionBlackboardListResult: result)
        targetViewController?.dismiss(animated: true, completion: nil)
    }

    /// 黒板編集画面から戻ってきたときに、新黒板の黒板情報や黒板の見た目を更新するハンドラー
    private func setModernCompletedHandler() -> ((ModernEditBlackboardViewController.CompletedHandlerData) -> Void) {
        { [weak self] data in
            guard let self else { return }
            self.modernBlackboardMaterial = data.modernBlackboardMaterial
            self.blackboardViewAppearance = data.modernBlackboardAppearance
            self.modernBlackboardMaterial?.prettyDebug(with: "編集完了後の黒板データ")

            // 画面の回転中に差し替え前の黒板が見えないようにする
            blackboardView?.alpha = 0
            // APIから取得した、黒板スタイル変更可否と黒板サイズレート、撮影形式を受け取り、撮影画面のプロパティに反映する
            viewModel?.inputPort.accept(
                .updateBlackboardSettings(
                    canEditBlackboardStyle: data.canEditBlackboardStyle,
                    blackboardSizeTypeOnServer: data.blackboardSizeTypeOnServer,
                    preferredPhotoFormat: data.preferredPhotoFormat
                )
            )

            // - Note: iPadの横向き対応を追加した際、特定の問題が見つかった。ランドスケープモードの黒板編集画面からポートレートモードのカメラ画面に戻ると、画面の回転により黒板のFrame設定に不具合が生じる。
            // これを解決するには、黒板編集画面を閉じて画面の回転が完了するまで少し待つ必要があり、試行したところ0.62秒かかった。そのため、一時的な解決策として遅延時間を0.7秒に設定している。
            Task {
                try? await Task.sleep(nanoseconds: 700_000_000) // 0.7秒待機
                self.reloadBlackboard()
            }
        }
    }
    
    /// 選択用黒板一覧の閉じるボタンタップ時のハンドラーを設定する
    /// - Returns: 選択用黒板一覧の閉じるボタンタップ時のハンドラー
    private func setSelectableBlackboardListCancelResultHandler() -> ((ModernBlackboardListViewModel.CancelResult) -> Void)? {
        { [weak self] result in
            guard let self else { return }
            // FIXME: 黒板編集画面の閉じるボタンタップ時のハンドラーには、黒板情報と黒板設定の更新の反映がある一方で、選択用黒板一覧の閉じるボタンタップ時のハンドラーには、黒板設定の更新の反映しかない。仕様を確認して、処理を統一すること。
            // 選択用黒板一覧の閉じるボタンタップ時は黒板の再表示処理がなく、そのルート上の撮影ボタン有効化を通らないので、ここで撮影ボタン等を有効化する
            setShutterButtonsEnabled(true)
            // 最新化された黒板設定を反映する
            viewModel?.inputPort.accept(
                .updateBlackboardSettings(
                    canEditBlackboardStyle: result.canEditBlackboardStyle,
                    blackboardSizeTypeOnServer: result.blackboardSizeTypeOnServer,
                    preferredPhotoFormat: result.preferredPhotoFormat
                )
            )

            Task {
                await self.forceUpdateBlackboardFrameIfNeeded()
            }
        }
    }

    /**
     黒板のサイズや向きを保持したまま、黒板を更新する
     
     @note
     画面ロックを有効している場合の向きに対しては pastBlackboardOrientation を利用する
     
     @example
     ```swift
     pastBlackboardOrientation = blackboardView?.orientation
     reloadBlackboard(orientation: nil)
     ```
     */
    private func reloadBlackboard() {
        willMakeBlackboard(
            originalFrame: blackboardView?.frame,
            specifiedOrientation: isLockedRotation
                ? pastBlackboardOrientation // （編集画面遷移および再読み込み前の）黒板の向きデータを指定する
                : cameraOrientation.uiDeviceOrientation
        )
    }

    /// 必要に応じて、黒板アピアランスの黒板サイズタイプと黒板のフレームを強制的に更新する
    @MainActor
    private func forceUpdateBlackboardFrameIfNeeded() async {
        guard
            let viewModel,
            let sizeType = viewModel.getSizeTypeForForcedUpdate() else {
            return
        }
        blackboardViewAppearance = blackboardViewAppearance?
            .updating(by: sizeType)

        await updateBlackboardFrame(with: sizeType)
    }

    @MainActor
    private func updateBlackboardFrame(with sizeType: ModernBlackboardAppearance.ModernBlackboardSizeType) async {
        guard let blackboardView else { return }

        switch sizeType {
        case .small, .medium, .large:
            guard let scaleFactor = sizeType.scaleFactor else { return }
            await blackboardView.updateFrame(
                withDefaultLongSide: defaultBlackboardLongSide,
                scaleFactor: scaleFactor
            )
        case .free:
            // 黒板設定画面においてサイズ自由値(.free)選択時に黒板をリサイズする場合
            guard let temporaryFreeBlackboardFrame else { return }
            let freeBlackboardSize = temporaryFreeBlackboardFrame.size
            let longestSideLength = max(freeBlackboardSize.width, freeBlackboardSize.height)
            await blackboardView.updateFrame(
                withDefaultLongSide: longestSideLength,
                scaleFactor: 1.0 // サイズ自由値(.free)へと黒板をリサイズするため、`temporaryFreeBlackboardFrame` からサイズを与え、`scaleFactor` は 1.0 とし拡大はしない
            )
        }
    }
}

// MARK: - private (for take camera view model)
extension TakeCameraViewController {
    /// （新黒板用のViewModelがあれば）バインドする
    private func addBindingIfNeeded() {
        guard let viewModel else { return }
        
        viewModel.outputPort
            .bind(onNext: { [weak self] event in
                guard let self else { return }
                switch event {
                case .presentEditViewController(let argument):
                    self.presentEditViewController(argument: argument)
                case .returnToTakeCameraViewController(let result):
                    self.returnToTakeCameraViewController(
                        targetViewController: self,
                        selectionBlackboardListResult: result
                    )
                case .showErrorMessage:
                    self.showCommonErrorAlert()
                case .showLoadingView:
                    self.showLoading()
                case .hideLoadingView:
                    self.hideLoading()
                case .resizeEnabled(enabled: let enabled):
                    blackboardView?.resizeEnabled = enabled
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 選択用黒板一覧画面から撮影編集画面 (黒板編集画面) への遷移処理を行う。
    ///
    /// - Note: 選択用黒板一覧画面から撮影編集画面 (黒板編集画面) へ遷移する際には透過度設定はデフォルト値になるので、 SVG 撮影時の透過度保持についてはここでは行わない。
    private func presentEditViewController(argument: AppDependencies.ModernEditBlackboardViewArguments) {
            let viewController = AppDependencies.shared.modernEditBlackboardViewController(argument)
            viewController.modernCompletedHandler = self.setModernCompletedHandler()

            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.modalTransitionStyle = .crossDissolve
            
            navigationControllerIntoBlackboardList?.present(navigationController, animated: true)

        viewController.replace(
            otherBlackboardMaterial: argument.modernblackboardMaterial,
            blackboardViewAppearance: argument.blackboardViewAppearance
        )
    }
}

// MARK: - private (for present / dismiss logic)
extension TakeCameraViewController {
    /// 黒板編集画面が既にスタックされているか / 否か
    private var hasEditBlackboardViewController: Bool {
        self.hasAlreadyStacked(
            vcType: ModernEditBlackboardViewController.self,
            findType: .presented
        )
    }
}

// MARK: - private (alert)
extension TakeCameraViewController {
    private func showCommonErrorAlert() {
        commonAlert = CustomizedAlertView(
            title: L10n.Blackboard.Error.commonText,
            message: nil
        )
        let okAction = CustomizedAlertAction(
            title: L10n.Common.ok,
            style: .default,
            handler: nil
        )
        commonAlert?.addAction(okAction)

        commonAlert?.show(in: view, initialRotationAngle: cameraOrientation.rotateAngle)
    }
    
    private func shouldShowDestroyPhotosAlert() -> Bool {
        !photos.isEmpty
    }
    
    private func showDestroyPhotosAlert(
        destructiveHandler: @escaping ((CustomizedAlertAction) -> Void),
        uploadHandler: @escaping ((CustomizedAlertAction) -> Void),
        saveHandler: @escaping ((CustomizedAlertAction) -> Void)
    ) {
        photoDeletionConfirmationAlert = CustomizedAlertView(
            title: L10n.Camera.Alert.Title.destroyPhotos,
            message: L10n.Camera.Alert.Description.destroyPhotos
        )
        
        let actions: [CustomizedAlertAction] = [
            .init(
                title: L10n.Common.destroy,
                style: .destructive,
                handler: destructiveHandler
            ),
            isOfflineMode
                ? .init(
                    title: L10n.Photo.save,
                    style: .default,
                    handler: saveHandler
                )
                : .init(
                    title: L10n.Camera.Alert.UploadButton.destroyPhotos,
                    style: .default,
                    handler: uploadHandler
                ),
            .init(
                title: L10n.Camera.Alert.CancelButton.destroyPhotos,
                style: .cancel,
                handler: { [weak self] _ in
                    self?.analytics?.sendLogEvent(
                        cameraEventTargetView: .takeCamera(.tapCancelButton)
                    )
                }
            )
        ].compactMap { $0 }
        actions.forEach { photoDeletionConfirmationAlert?.addAction($0) }
        photoDeletionConfirmationAlert?.show(in: view, initialRotationAngle: cameraOrientation.rotateAngle)
    }
}

extension TakeCameraViewController {
    private func rotateImageByOrientation(image: UIImage, orientation: AVCaptureVideoOrientation) -> UIImage {
        switch cameraOrientation {
        case .portrait:
            return image
        case .landscapeLeft:
            return imageRotatedByDegrees(oldImage: image, deg: 270)
        case .landscapeRight:
            return imageRotatedByDegrees(oldImage: image, deg: 90)
        case .portraitUpsideDown:
            return imageRotatedByDegrees(oldImage: image, deg: 180)
        default:
            return image
        }
    }
    
    private func updatePhotoStatus(newImage: UIImage? = nil) {
        photoCountLabel.text = "\(photos.count)"
        
        if let newImage = newImage {
            thumbnailImageButton.setImage(
                newImage.resize(size: .init(width: 32.0, height: 32.0)),
                for: .normal
            )
            
            return
        }
        
        guard let imageKey = photos.last?.imageKey else {
            thumbnailImageButton.setImage(nil, for: .normal)
            return
        }
        
        diskImageStore.resizedImage(
            for: imageKey,
            targetSize: .init(width: 32.0, height: 32.0)
        ) { [weak self] image in
            DispatchQueue.main.async {
                self?.thumbnailImageButton.setImage(image, for: .normal)
            }
        }
    }
    
    // 画像を回転させる処理
    private func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        // Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let affineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = affineTransform
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        // Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        // Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MEMO: 回転前に呼ばれるメソッド
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if launchedByMultitaskingApp {
            
            // 回転前に各種情報を保存
            multitaskingAppManager.isBlackboardOn = isBlackboardVisible
            multitaskingAppManager.isLockOn = isBlackboardVisible
            multitaskingAppManager.previousBlackboardOrientation = blackboardView?.orientation ?? .portrait
            
            removeBlackboard()
            multitaskingAppManager.captureVideoPreviewLayer?.isHidden = true
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
}

// MARK: for UI test
extension TakeCameraViewController {
    private func setAccessibilityIdentifiers() {
        shutterButton.viewAccessibilityIdentifier = .shutterButton
        photoCountLabel.viewAccessibilityIdentifier = .photoCountLabel
        blackBoardButton.viewAccessibilityIdentifier = .blackboardSettingsButton
        nextButton.viewAccessibilityIdentifier = .takeCameraNextButton
        cancelButton.viewAccessibilityIdentifier = .takeCameraCancelButton
        thumbnailImageButton.viewAccessibilityIdentifier = .thumbnailImageButton
        shootingGuideButton.viewAccessibilityIdentifier = .shootingGuideButton
        shootingGuideImageView?.viewAccessibilityIdentifier = .shootingGuideImage
    }
}

extension TakeCameraViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let blackBoardView = self.blackboardView,
           blackBoardView.bounds.contains(gestureRecognizer.location(in: blackBoardView)) {
            return false
        }
        
        let point = gestureRecognizer.location(in: capturingAreaView)
        return capturingAreaView.bounds.contains(point)
    }
}

// MARK: - 豆図レイアウト動作確認用
extension TakeCameraViewController {
    /// 再試行ボタン付きの豆図画像取得失敗のアラートを表示する（オンライン用）
    private func showCannotGetMiniatureMapImageAlert(
        retryHandler: @escaping (CustomizedAlertAction) -> Void,
        cancelHandler: @escaping (CustomizedAlertAction) -> Void
    ) {
        miniatureMapImageLoadingFailureAlert = CustomizedAlertView(
            title: L10n.Blackboard.MiniatureMap.Alert.Title.failedToLoadMiniatureMap,
            message: L10n.Blackboard.MiniatureMap.Alert.Description.failedToLoadMiniatureMap
        )
        miniatureMapImageLoadingFailureAlert?.addAction(
            .init(
                title: L10n.Blackboard.MiniatureMap.Alert.CancelButton.failedToLoadMiniatureMap,
                style: .default,
                handler: cancelHandler
            )
        )
        miniatureMapImageLoadingFailureAlert?.addAction(
            .init(
                title: L10n.Common.retry,
                style: .default,
                handler: retryHandler
            )
        )
        miniatureMapImageLoadingFailureAlert?.show(in: view, initialRotationAngle: cameraOrientation.rotateAngle)
    }
    
    /// 再試行ボタンなしの豆図画像取得失敗のアラートを表示する（オフラインモード用）
    private func showCannotGetMiniatureMapImageAlert(cancelHandler: @escaping (CustomizedAlertAction) -> Void) {
        miniatureMapImageLoadingFailureAlert = CustomizedAlertView(
            title: L10n.Blackboard.MiniatureMap.Alert.Title.failedToLoadMiniatureMap
        )
        miniatureMapImageLoadingFailureAlert?.addAction(
            .init(
                title: L10n.Blackboard.MiniatureMap.Alert.CancelButton.failedToLoadMiniatureMap,
                style: .default,
                handler: cancelHandler
            )
        )
        miniatureMapImageLoadingFailureAlert?.show(in: view, initialRotationAngle: cameraOrientation.rotateAngle)
    }

    private var shouldShowMiniatureMap: Bool {
        guard let modernBlackboardMaterial,
              let pattern = ModernBlackboardContentView.Pattern(by: modernBlackboardMaterial.layoutTypeID) else { return false }
        return pattern.hasMiniatureMapView
    }
}

private extension TakeCameraViewController {
    /// カメラ画面が主な画面として表示されているかどうか
    var isVisibleTakeCameraViewController: Bool {
        if navigationController?.visibleViewController is TakeCameraViewController {
            return true
        } else if
            navigationController?.viewControllers.first is TakeCameraViewController,
            presentedViewController is UIAlertController {
            // カメラ画面では標準アラートの使用をやめるのでここを通ることはない想定だが、
            // 意図せず標準アラートが表示された場合
            return true
        } else {
            // それ以外の場合（カメラ画面の上にモーダルビューが表示されている場合など）
            return false
        }
    }
}

// MARK: - for takePhoto
private extension TakeCameraViewController {
    typealias BlackboardImageRepresentation = (image: UIImage, origin: CGPoint)
    typealias RotatedCaptureImages = (blackboardImage: BlackboardImageRepresentation?, captureImage: UIImage)
    typealias ResizedCaptureImages = (blackboardImage: BlackboardImageRepresentation?, captureImage: UIImage, captureAndBlackboardImage: UIImage)

    func makeBlackboardImageIfVisible(with captureImageSize: CGSize) -> BlackboardImageRepresentation? {
        // 黒板が存在する場合は合成する
        guard let blackboardView else { return nil }
        // 撮影領域に対する画像とのスケール
        let scaleForCapturingAreaViewToImage = captureImageSize.width / capturingAreaView.frame.width

        let blackboardViewX = (blackboardView.frame.origin.x - capturingAreaView.frame.origin.x) * scaleForCapturingAreaViewToImage
        let blackboardViewY = (blackboardView.frame.origin.y - capturingAreaView.frame.origin.y) * scaleForCapturingAreaViewToImage
        let resizedBlackboardImageSize = CGSize(
            width: blackboardView.frame.size.width * scaleForCapturingAreaViewToImage,
            height: blackboardView.frame.size.height * scaleForCapturingAreaViewToImage
        )

        guard
            let blackboardImageView = blackboardView.subviews.compactMap({ $0 as? UIImageView }).last,
            let blackboardImage = try? blackboardImageView.toImage(),
            let resizedBlackboardImage = blackboardImage.resize(size: resizedBlackboardImageSize)
        else {
            return nil
        }

        return (resizedBlackboardImage, .init(x: blackboardViewX, y: blackboardViewY))
    }

    func rotatedBlackboardImage(_ blackboardImage: BlackboardImageRepresentation?, captureImageSize: CGSize) -> BlackboardImageRepresentation? {
        guard let blackboardImage else { return nil }

        let rotatedBlackboardImage = rotateImageByOrientation(image: blackboardImage.image, orientation: cameraOrientation)
        let blackboardImageRect = CGRect(origin: blackboardImage.origin, size: blackboardImage.image.size)
        let rotatedBlackboardTopLeftAnchorPoint = switch cameraOrientation {
        case .portrait:
            blackboardImageRect.origin
        case .landscapeLeft:
            CGPoint(x: blackboardImageRect.minY, y: captureImageSize.width - blackboardImageRect.maxX)
        case .landscapeRight:
            CGPoint(x: captureImageSize.height - blackboardImageRect.maxY, y: blackboardImageRect.minX)
        case .portraitUpsideDown:
            CGPoint(x: captureImageSize.width - blackboardImageRect.maxX, y: captureImageSize.height - blackboardImageRect.maxY)
        default:
            blackboardImageRect.origin
        }

        return (rotatedBlackboardImage, rotatedBlackboardTopLeftAnchorPoint)
    }

    func rotatedCaptureImages(
        blackboardImage: BlackboardImageRepresentation?,
        captureImage: UIImage,
        cameraOrientation: AVCaptureVideoOrientation
    ) -> RotatedCaptureImages {
        // カメラの向きに応じて写真を回転させる
        let rotatedBlackboardImage = rotatedBlackboardImage(blackboardImage, captureImageSize: captureImage.size)
        // このコードがないと画像が回転しないので追加
        let workaroundCaptureImage = captureImage.combineImage(image: UIImage(), ratio: 1.0, targetX: 0, targetY: 0)
        let rotatedCaptureImage = rotateImageByOrientation(image: workaroundCaptureImage, orientation: cameraOrientation)

        return (rotatedBlackboardImage, rotatedCaptureImage)
    }

    func resizedBlackboardImage(_ blackboardImage: BlackboardImageRepresentation, captureImageSize: CGSize, resizeConfiguration: ResizeConfiguration) -> BlackboardImageRepresentation? {
        let (image, origin) = blackboardImage
        // ResizeConfiguration.size (widthxheight) 形式のため強制アンラップ
        let longestResizeLength = resizeConfiguration.size.components(separatedBy: "x").compactMap(Int.init).max()!

        let longestCaptureImageSideLength = max(captureImageSize.width, captureImageSize.height)
        let resizeRatio = CGFloat(longestResizeLength) / longestCaptureImageSideLength
        let resizeSpec = String(format: "%.3f", image.size.width * resizeRatio)
        guard let resizedImage = image.resizedImage(byMagick: resizeSpec) else { return nil }
        let resizedOrigin = origin.applying(.init(scaleX: resizeRatio, y: resizeRatio))

        return (resizedImage, resizedOrigin)
    }

    func resizedCaptureImages(
        blackboardImage: BlackboardImageRepresentation?,
        captureImage: UIImage,
        captureAndBlackboardImage: UIImage,
        resizeConfiguration: ResizeConfiguration
    ) -> ResizedCaptureImages? {
        // 黒板非表示時は blackboardImage: nil になり、返り値は resizedBlackboardImage: nil とする
        let resizedBlackboardImage = blackboardImage.flatMap {
            self.resizedBlackboardImage(
                $0,
                captureImageSize: captureImage.size,
                resizeConfiguration: resizeConfiguration
            )
        }

        guard
            let resizedCaptureAndBlackboardImage = captureAndBlackboardImage.resizedImage(byMagick: resizeConfiguration.size),
            let resizedCaptureImage = captureImage.resizedImage(byMagick: resizeConfiguration.size)
        else {
            return nil
        }

        return (resizedBlackboardImage, resizedCaptureImage, resizedCaptureAndBlackboardImage)
    }

    func save(captureImage: UIImage, exif: NSDictionary) -> DiskImageStore.Key? {
        #if targetEnvironment(simulator)
            // シミュレーターで撮影した画像には日付等の情報が不足しているため改善検知関数(TamperUtil.writeHashValue())で例外になるため
            let isEnableTamperProof = false
        #else
            let isEnableTamperProof = isBlackboardEnabled
        #endif

        return diskImageStore.save(
            captureImage,
            cacheSize: MainImageScrollView.maximumImageSize,
            exif: exif,
            withTamperProof: isEnableTamperProof
        )
    }

    func saveSVGIfSVGPhotoEnabled(
        captureImage: UIImage,
        blackboardImage: BlackboardImageRepresentation?,
        exif: NSDictionary
    ) -> DiskImageStore.Key? {
        #if targetEnvironment(simulator)
            // シミュレーターで撮影した画像には日付等の情報が不足しているため改善検知関数(TamperUtil.svgCalculateHashValue())で例外になるため
            return nil
        #else
            let isSVGPhotoEnabled = viewModel?.photoFormat.value == .svg
            guard isModernBlackboard, isSVGPhotoEnabled, let blackboardImage else { return nil }
            return diskImageStore.saveSVG(
                captureImage: captureImage,
                blackboardImage: blackboardImage.image,
                blackboardImageOrigin: blackboardImage.origin,
                exif: exif
            )
        #endif
    }
}

extension TakeCameraViewController: PhotoPreviewViewControllerDelegate {
    func photoPreviewViewControllerDidFinish(photos: [Photo]) {
        self.photos = photos
        nextButton.isHidden = photos.isEmpty
        updatePhotoStatus()
    }
}

// MARK: - For countdown

extension TakeCameraViewController {
    private func showCountdownView() {
        countdownView.alpha = 1
        countdownView.isHidden = false
        
        // Hide other buttons
        if !headerContainerView.isHidden {
            viewsHiddenByCountdown.append(headerContainerView)
        }
        
        if !footerContainerView.isHidden {
            viewsHiddenByCountdown.append(footerContainerView)
        }
        
        if !sliderContainerView.isHidden {
            viewsHiddenByCountdown.append(sliderContainerView)
        }
        
        if !zoomScaleLabel.isHidden {
            viewsHiddenByCountdown.append(zoomScaleLabel)
        }
        
        if let shootingGuideImageView, !shootingGuideImageView.isHidden {
            viewsHiddenByCountdown.append(shootingGuideImageView)
        }
        
        if !gpsWarningView.isHidden {
            viewsHiddenByCountdown.append(gpsWarningView)
        }
        
        // Hide all views
        viewsHiddenByCountdown.forEach { $0.isHidden = true }
    }
    
    private func hideCountdownView() {
        guard !countdownView.isHidden else { return }
        
        UIView.animate(
            withDuration: 0.9,
            delay: 0.0,
            options: .curveEaseIn
        ) { [weak self] in
            self?.countdownView.alpha = 0
        } completion: { [weak self] _ in
            self?.countdownView.isHidden = true
        }
        
        // Show other views
        viewsHiddenByCountdown.forEach { $0.isHidden = false }
        viewsHiddenByCountdown.removeAll()
    }
    
    private func updateCountdownLabel(remainingTime: TimeInterval) {
        countdownLabel.text = "\(Int(remainingTime))"
    }
}

/// カメラ起動をした「瞬間」の諸情報
/// （原則カメラキルまで不変な値の想定だが、clientNameに限りアプリ操作によっては書き変わるので注意）
public struct SnapshotData {
    public let userID: Int
    public let orderName: String
    public let clientName: String
    public let startDate: Date
    
    public init(
        userID: Int,
        orderName: String,
        clientName: String,
        startDate: Date
    ) {
        self.userID = userID
        self.orderName = orderName
        self.clientName = clientName
        self.startDate = startDate
    }
}

#if targetEnvironment(simulator)
extension TakeCameraViewController {
    func observeDeviceOrientationChangeForSimulator() {
        guard !launchedByMultitaskingApp else { return }

        func transformToVideoOrientation(from deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
            switch deviceOrientation {
            case .portrait:
                   .portrait
            case .landscapeLeft:
                   .landscapeLeft
            case .landscapeRight:
                   .landscapeRight
            case .portraitUpsideDown:
                   .portraitUpsideDown
            default:
                   .portrait
            }
        }

        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .map(transformToVideoOrientation(from:))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newOrientation in
                guard let self else { return }
                cameraOrientation = newOrientation
                onOrientationChange()
            }
            .store(in: &subscriptions)
    }
}
#endif

private extension TakeCameraViewController.ImageURLs {
    init(photo: TakeCameraViewController.Photo) {
        self.jpeg = DiskImageStore.url(for: photo.imageKey, pathExtension: .jpg)
        self.svg = photo.svgKey.map { DiskImageStore.url(for: $0, pathExtension: .svg) }
    }
}
// swiftlint:disable:this file_length

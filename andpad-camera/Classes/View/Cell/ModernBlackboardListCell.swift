//
//  ModernBlackboardListCell.swift
//  andpad-camera
//
//  Created by msano on 2022/01/05.
//

import AndpadUIComponent
import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa
import SnapKit
import WebKit

public final class ModernBlackboardListCell: UITableViewCell, BlackboardWebViewConfigurable {
    public struct Dependency {
        public let modernBlackboardMaterial: ModernBlackboardMaterial
        public let layoutType: LayoutType
        public let dateFormatType: ModernBlackboardCommonSetting.DateFormatType
        public let memoStyleArguments: ModernBlackboardMemoStyleArguments
        
        /// 選択されている黒板か否か
        public let isSelectedBlackboard: Bool
        
        /// ハイライト機能を使えるか否か
        public let canHighlight: Bool
        /// ダウンロード済みマークを非表示にするか否か
        public let isDownloadedMarkHidden: Bool

        /// ローカルに保存した豆図画像を読み込むかどうか。
        ///
        /// - Note: オフライン対応でローカルから豆図画像を読み込むかどうか判別するために使用します。使用しない場合はfalseを指定してください。
        public let shouldShowMiniatureMapFromLocal: Bool
        
        /// SVGで生成された黒板を利用するかどうか
        ///
        /// Remote Configで従来の画像化とSVGの画像化を切り替えている。
        public let useBlackboardGeneratedWithSVG: Bool

        public init(
            modernBlackboardMaterial: ModernBlackboardMaterial,
            layoutType: ModernBlackboardListCell.LayoutType,
            dateFormatType: ModernBlackboardCommonSetting.DateFormatType,
            memoStyleArguments: ModernBlackboardMemoStyleArguments,
            isSelectedBlackboard: Bool,
            canHighlight: Bool,
            isDownloadedMarkHidden: Bool,
            shouldShowMiniatureMapFromLocal: Bool,
            useBlackboardGeneratedWithSVG: Bool
        ) {
            self.modernBlackboardMaterial = modernBlackboardMaterial
            self.layoutType = layoutType
            self.dateFormatType = dateFormatType
            self.memoStyleArguments = memoStyleArguments
            self.isSelectedBlackboard = isSelectedBlackboard
            self.canHighlight = canHighlight
            self.isDownloadedMarkHidden = isDownloadedMarkHidden
            self.shouldShowMiniatureMapFromLocal = shouldShowMiniatureMapFromLocal
            self.useBlackboardGeneratedWithSVG = useBlackboardGeneratedWithSVG
        }
    }
    
    public enum LayoutType {
        case takePhoto
        case editAndTakePhoto
    }

    private var dependency: Dependency?
    private var imageState: MiniatureMapImageState?
    private var webView: WKWebView?
    /// [HTMLを使わない従来の画像化] 黒板を従来の画像化で表示するためのUIImageView
    private var notHTMLBlackboardImageView: UIImageView?

    // IBOutlet
    // 黒板
    @IBOutlet private var blackboardContainer: UIView!
    @IBOutlet private weak var blackboardImageButton: UIButton!
    // 未定義黒板用のView
    @IBOutlet private weak var undefinedContainerView: UIView!
    // 「編集」ボタン
    @IBOutlet private weak var editButtonView: UIView!
    @IBOutlet private weak var editIconImageView: UIImageView!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var editButtonLabel: UILabel!
    // 「撮影」ボタン
    @IBOutlet private weak var takePhotoButtonView: UIView!
    @IBOutlet private weak var takePhotoIconImageView: UIImageView!
    @IBOutlet private weak var takePhotoButton: UIButton!
    @IBOutlet private weak var takePhotoButtonLabel: UILabel!
    // 黒板選択アイコン
    @IBOutlet private weak var selectedBlackboardIconImageView: UIImageView!
    
    // 写真枚数カウンタ
    @IBOutlet private weak var photoCountLabel: UILabel!
    /// ダウンロード済みマーク
    @IBOutlet private weak var downloadedMarkView: DownloadedMarkView!

    public var disposeBag = DisposeBag()

    private var blackboardMaterial: ModernBlackboardMaterial? {
        didSet {
            guard let blackboardMaterial else { return }
            isUndefinedLayout = ModernBlackboardContentView.Pattern(by: blackboardMaterial.layoutTypeID) == nil
        }
    }
    
    private var isUndefinedLayout = false {
        didSet {
            let isHidden = !isUndefinedLayout
            undefinedContainerView.isHidden = isHidden
            if isUndefinedLayout {
                webView?.removeFromSuperview()
                webView = nil
            }
            editButton.isEnabled = isHidden
            takePhotoButton.isEnabled = isHidden

            let color: UIColor = isUndefinedLayout ? .grayC5C6C8 : .gray222
            takePhotoButtonLabel.textColor = color
            takePhotoIconImageView.tintColor = color
            takePhotoButtonView.layer.borderColor = color.cgColor
            editButtonLabel.textColor = color
            editIconImageView.tintColor = color
            editButtonView.layer.borderColor = color.cgColor
        }
    }
    
    private let undefinedView = ModernBlackboardUndefinedView(with: .init())
    
    // life cycle
    override public func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        undefinedContainerView.addSubview(undefinedView)
        undefinedView.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        dependency = nil
        imageState = nil
        notHTMLBlackboardImageView?.image = nil
        webView?.stopLoading()
        photoCountLabel.text = nil
        switchHighlightStyle(doHighlight: false)
    }
}

// MARK: - subscribe対象
extension ModernBlackboardListCell {
    public var tappedBlackboardImageButton: Signal<ModernBlackboardMaterial> {
        blackboardImageButton.rx.tap
            .asSignal()
            .compactMap { [weak self] in self?.dependency?.modernBlackboardMaterial }
    }
    
    public var tappedEditButton: Signal<ModernBlackboardMaterial> {
        editButton.rx.tap
            .asSignal()
            .compactMap { [weak self] in self?.dependency?.modernBlackboardMaterial }
    }
    
    public var tappedTakePhotoButton: Signal<ModernBlackboardMaterial> {
        takePhotoButton.rx.tap
            .asSignal()
            .compactMap { [weak self] in self?.dependency?.modernBlackboardMaterial }
    }
}

// MARK: - private
extension ModernBlackboardListCell {
    private func configureCell() {
        guard let dependency else { fatalError() }
        
        switch dependency.layoutType {
        case .editAndTakePhoto:
            editButtonView.isHidden = false
            takePhotoButtonView.isHidden = false
        case .takePhoto:
            editButtonView.isHidden = true
            takePhotoButtonView.isHidden = false
        }
        
        editIconImageView.image = editIconImageView.image?
            .withRenderingMode(.alwaysTemplate)
        editButtonView.layer.borderWidth = 1
        takePhotoIconImageView.image = takePhotoIconImageView.image?
            .withRenderingMode(.alwaysTemplate)
        takePhotoButtonView.layer.borderWidth = 1
        
        self.blackboardMaterial = dependency.modernBlackboardMaterial
        
        set(photoCount: dependency.modernBlackboardMaterial.photoCount)
        
        if dependency.canHighlight {
            switchHighlightStyle(doHighlight: dependency.isSelectedBlackboard)
        }

        downloadedMarkView.isHidden = dependency.isDownloadedMarkHidden

        // Remote Configから取得した黒板の生成方法にもとづいて、処理を分岐する。
        if dependency.useBlackboardGeneratedWithSVG {
            // HTMLで黒板を表示
            setUpBlackboardWebView()

            Task {
                await loadBlackboard()
            }
        } else {
            // HTMLを使わない従来の画像化で黒板を表示
            setUpNotHTMLBlackboardImage()

            switch imageState {
            case .none, .beforeLoading:
                let thumbnailURL = dependency.modernBlackboardMaterial.miniatureMap?.imageThumbnailURL
                updateNotHTMLMiniatureMapImageState(with: thumbnailURL)
                updateNotHTMLBlackboardImage(miniatureMapImageState: imageState)

                // 豆図画像を読み込む
                if dependency.shouldShowMiniatureMapFromLocal {
                    if let id = dependency.modernBlackboardMaterial.miniatureMap?.id {
                        loadNotHTMLMiniatureMapImageFromLocal(with: id)
                    }
                } else {
                    if let thumbnailURL {
                        loadNotHTMLMiniatureMapImage(with: thumbnailURL)
                    }
                }
            default:
                break
            }
        }
    }
    
    private func switchHighlightStyle(doHighlight: Bool) {
        blackboardImageButton.layer.borderColor = doHighlight
            ? UIColor.orangeFEA.cgColor
            : UIColor.clear.cgColor
        selectedBlackboardIconImageView.isHidden = !doHighlight
    }

    private func setUpBlackboardWebView() {
        guard webView == nil else {
            return
        }
        webView = createAndConfigureBlackboardWebView()
        blackboardContainer.addSubview(webView!)
        webView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// [HTMLを使わない従来の画像化] 黒板を従来の画像化で表示するためのUIImageViewを設定する
    private func setUpNotHTMLBlackboardImage() {
        guard notHTMLBlackboardImageView?.image == nil else {
            return
        }
        notHTMLBlackboardImageView = UIImageView()
        notHTMLBlackboardImageView?.contentMode = .scaleAspectFit
        blackboardContainer.addSubview(notHTMLBlackboardImageView!)
        notHTMLBlackboardImageView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - HTMLで黒板を表示する処理

extension ModernBlackboardListCell {
    /// 黒板WebViewをロードする
    private func loadBlackboard() async {
        guard let dependency, let webView else { return }
        do {
            let blackboardContent = try ModernBlackboardContent(
                material: dependency.modernBlackboardMaterial,
                theme: dependency.modernBlackboardMaterial.blackboardTheme,
                memoStyleArguments: dependency.memoStyleArguments,
                dateFormatType: dependency.dateFormatType,
                // 黒板一覧は透過させない
                alphaLevel: .zero,
                miniatureMapImageState: imageState,
                // 黒板一覧では「自動入力値についての情報」を表記する
                displayStyle: .withAutoInputInformation,
                // 黒板一覧では「(案件名)」と表記するため、案件名の改行反映なし
                shouldBeReflectedNewLine: false
            )
            let blackboardProp = await BlackboardProps(
                blackboardContent: blackboardContent,
                size: blackboardContainer.frame.size,
                // 黒板一覧では豆図画像をサムネイルサイズで表示する
                miniatureMapImageType: .thumbnail,
                shouldShowMiniatureMapFromLocal: dependency.shouldShowMiniatureMapFromLocal,
                isShowEmptyMiniatureMap: false,
                // 黒板一覧では、豆図の部分が、豆図画像ロード前の画像か豆図登録なしの画像の場合、非表示にしない。
                isHiddenNoneAndEmptyMiniatureMap: false,
                shouldShowPlaceholder: false
            )
            let query = try blackboardProp.makeQueryParameter()
            blackboardWebView(webView, loadHTMLWithQuery: query)
        } catch let error as ModernBlackboardContent.BlackboardContentError {
            print(error.localizedDescription)
            switch error {
            case .undefinedBlackboard(let layoutTypeID):
                // 未定義黒板エラー
                isUndefinedLayout = true
            }
        } catch {
            print("予期しないエラーが発生しました: \(error.localizedDescription)")
            // 黒板WebViewのロードに失敗した場合は、未定義黒板として扱う
            isUndefinedLayout = true
        }
    }
}

// MARK: - HTMLを使わない従来の画像化で黒板を表示する処理

extension ModernBlackboardListCell {
    /// [HTMLを使わない従来の画像化] 豆図画像URLの有無をもとに黒板の豆図画像の状態を更新する
    /// - Parameter imageURL: 豆図画像URL
    private func updateNotHTMLMiniatureMapImageState(with imageURL: URL?) {
        guard imageURL != nil else {
            imageState = .noURL(useCameraView: false)
            return
        }
        imageState = imageState ?? .beforeLoading
    }

    /// [HTMLを使わない従来の画像化] 黒板の豆図画像を読み込む
    /// - Parameter imageURL: 豆図画像URL
    private func loadNotHTMLMiniatureMapImage(with imageURL: URL) {
        MiniatureMapImageLoader.load(
            imageUrl: imageURL,
            shouldCheckNetworkStatusBeforeLoading: false
        ) { [weak self] result in
            switch result {
            case .beforeLoading:
                assertionFailure()
            case .loadSuccessful, .loadFailed, .noURL:
                self?.updateNotHTMLBlackboardImage(miniatureMapImageState: result)
            }
        }
    }

    /// [HTMLを使わない従来の画像化] ローカルに保存された黒板の豆図画像を読み込む
    /// - Parameter miniatureMapID: 豆図ID
    private func loadNotHTMLMiniatureMapImageFromLocal(with miniatureMapID: Int) {
        guard
            let localMiniatureMapImage = OfflineStorageHandler.shared.blackboard.fetchMiniatureMap(
                withID: miniatureMapID,
                imageType: .thumbnail
            ) else {
            // オフラインモード時に豆図付き黒板の豆図取得エラーの発生頻度を計測する
            // see: https://88-oct.atlassian.net/browse/KOKUBAN-5877
            AndpadCameraConfig.logger.nonFatalError(
                domain: "OfflineMiniatureMapImageFetcherError",
                additionalUserInfo: [
                    NSLocalizedDescriptionKey: "OfflineMiniatureMapImageFetcherError",
                    "Message": "failed to load MiniatureMap image. MiniatureMap ID:\(miniatureMapID)"
                ]
            )
            assertionFailure("failed to load MiniatureMap image. MiniatureMap ID:\(miniatureMapID)")
            return
        }
        updateNotHTMLBlackboardImage(miniatureMapImageState: .loadSuccessful(localMiniatureMapImage))
    }

    /// [HTMLを使わない従来の画像化] 黒板画像を更新する
    private func updateNotHTMLBlackboardImage(miniatureMapImageState: MiniatureMapImageState?) {
        self.imageState = miniatureMapImageState

        guard let dependency else { return }
        notHTMLBlackboardImageView?.image = ModernBlackboardView.image(
            dependency.modernBlackboardMaterial,
            dateFormatType: dependency.dateFormatType,
            memoStyleArguments: dependency.memoStyleArguments,
            miniatureMapImageState: imageState,
            displayStyle: .withAutoInputInformation,
            shouldBeReflectedNewLine: false // "(案件名)" 固定表示なので改行の考慮不要(常にfalse)
        )
    }
}

// MARK: - private (for photo count label)
extension ModernBlackboardListCell {
    func set(photoCount: Int) {
        photoCountLabel.text = L10n.Blackboard.List.Photo.count(photoCount)
        photoCountLabel.textColor = photoCount > 0
            ? .tsukuri.system.primaryTextOnSurface1
            : .placeholderText
    }
}

// MARK: - NibType
extension ModernBlackboardListCell: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension ModernBlackboardListCell: Reusable {
    public func inject(_ dependency: Dependency) {
        self.dependency = dependency
        configureCell()
    }
}

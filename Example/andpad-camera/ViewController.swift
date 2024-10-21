//
//  ViewController.swift
//  andpad-camera
//
//  Created by Toshihiro Taniguchi on 04/17/2018.
//  Copyright (c) 2018 ANDPAD Inc. All rights reserved.
//

import andpad_camera
import AndpadCore

import Photos
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class ViewController: UIViewController {

    private let stackView: UIStackView = .init()
    private let imageView: UIImageView = .init()

    private struct DummyData {
        static let appBaseRequestData = AppBaseRequestData(
            deviceUUID: "EB82CBC0-3645-4810-BD8A-70A8E166A7DD",
            osType: "IOS",
            version: "000500370001",
            accessToken: "38r6HLBsXIQI20Ey_iAWLIhcc-SDi3D2M-z5TrXhc21aIo6tsE5KP9RS2Hhi9tXD_H0",
            sharedBundleId: "jp.reformpad.ios.develop",
            apiBaseURLString: "https://feature2.apli.andpaddev.xyz/base_app/api/v1",
            authenticatedDeviceUUID: ""
        )
        
        static let doFillTexts = true
        static let miniatureMapStubImageType = ModernBlackboardMaterialStub.MiniatureMapStubImageType.landscape
        
        static let modernBlackboardConfiguration = ModernBlackboardConfiguration.enable(
            .init(
                orderID: 131637,
                // NOTE: 黒板データはあくまでサンプルのためforce unwrap
                defaultModernBlackboardMaterial: ModernBlackboardMaterialStub.layout1502(
                    doFillTexts: doFillTexts,
                    miniatureMapStubImageType: miniatureMapStubImageType
                ).value!,
                snapshotData: SnapshotData.stub(doFillTexts: doFillTexts),
                appearance: .init(
                    theme: .white,
                    alphaLevel: .zero,
                    dateFormatType: .defaultValue,
                    shouldBeReflectedNewLine: false
                ),
                initialLocationData: nil,
                advancedOptions: [
                    // 黒板履歴機能を使うためのオプションをセット
                    .useHistoryView(.init(blackboardHistoryHandler: DummyBlackboardHistoryHandler()))
                ],
                canEditBlackboardStyle: true,
                blackboardSizeTypeOnServer: .free,
                preferredPhotoFormat: .jpeg
            )
        )
    }

    private let enableBlackboardSwitchView: SwitchRowView = .init(
        title: "黒板",
        defaultValue: true,
        viewAccessibilityIdentifier: .enableLegacyBlackboardSwitch
    )
    
    private let enableBlackboardWithDefaultValueSwitchView: SwitchRowView = .init(
        title: " └ 旧黒板に初期値セット",
        defaultValue: false,
        type: .sub
    )

    private let enableInspectionTemplateSwitchView: SwitchRowView = .init(
        title: "検査用テンプレート",
        defaultValue: true,
        viewAccessibilityIdentifier: .enableInspectionLegacyBlackboardSwitch
    )
    
    private let enableInspectionTemplateWithDefaultValueSwitchView: SwitchRowView = .init(
        title: " └ 検査黒板に初期値セット",
        defaultValue: false,
        type: .sub
    )
    
    private let enableMultiplePhotosSwitchView: SwitchRowView = .init(
        title: "複数枚撮影 (10枚)",
        defaultValue: true
    )

    private let enableShootingGuideSwitchView: SwitchRowView = .init(
        title: "撮影ガイド",
        defaultValue: true,
        viewAccessibilityIdentifier: .enableShootingGuideImageSwitch
    )

    // NOTE: この機能の名称については、プロダクトオーナーに確認し、必要があればリネームする
    private let enableModernBlackboardsSwitchView: SwitchRowView = .init(
        title: "新黒板テンプレート",
        defaultValue: true,
        viewAccessibilityIdentifier: .enableModernBlackboardSwitch
    )

    private let enableBlackboardInitialLocationDataSwitchView: SwitchRowView = .init(
        title: "前回の黒板ロケーション情報を反映",
        defaultValue: false
    )
    
    private let enablePhotoQualitySettingsSwitchView: SwitchRowView = .init(
        title: "画質設定",
        defaultValue: true
    )
    
    private let enablePhotoHighQualityPermissionSettingSwitchView: SwitchRowView = .init(
        title: " └ 高画質権限",
        defaultValue: true,
        type: .sub
    )
    
    private let enableOfflineModeSwitchView: SwitchRowView = .init(
        title: "オフラインモード",
        defaultValue: false
    )

    private let enableBlackboardStyleEditingSwitchView: SwitchRowView = .init(
        title: "黒板のスタイル変更可否",
        defaultValue: true
    )

    private let enableBlackboardSizeTypeOnServerSwitchView: SwitchRowView = .init(
        title: "黒板のサイズタイプ「大」に指定",
        defaultValue: false
    )
    
    private let enableGPSEnableSwitchView: SwitchRowView = .init(
        title: "GPS情報を付与",
        defaultValue: false
    )

    private let enablePreferredPhotoFormatSwitchView: SwitchRowView = .init(
        title: "撮影画像形式「SVG」に指定",
        defaultValue: false
    )

    // のちにAndpadCameraDependenciesProtocolの実装が増えた場合に、複数箇所からでも変更しやすいよう変数として定義しておいた。
    private var remoteConfigStub = RemoteConfigHandlerStub(useBlackboardGeneratedWithSVG: false)
    private let useBlackboardGeneratedWithSVGSwitchView: SwitchRowView = .init(
        title: "黒板をHTMLで表示",
        defaultValue: false,
        viewAccessibilityIdentifier: .useBlackboardGeneratedWithSVGSwitch
    )

    private let selectModernBlackboardLayoutButton = UIButton(type: .system)

    private var blackboard: BlackBoard?

    private var initialLocationDataForModernBlackboard: ModernBlackboardConfiguration.InitialLocationData?

    private var selectedModernBlackboardMaterial: ModernBlackboardMaterial? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
            make.width.equalTo(scrollView).inset(16)
        }

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4.0

        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.height.equalTo(96.0)
        }

        let layoutTypeIDString = modernBlackboardConfiguration.modernBlackboardLayoutTypeID != nil
            ? "\(modernBlackboardConfiguration.modernBlackboardLayoutTypeID!)"
            : "なし"
        selectModernBlackboardLayoutButton.setTitle("[全\(ModernBlackboardMaterialStub.total)件]\n選択中の新黒板レイアウト： " + layoutTypeIDString, for: .normal)
        selectModernBlackboardLayoutButton.titleLabel?.numberOfLines = 0
        selectModernBlackboardLayoutButton.titleLabel?.textAlignment = .center
        selectModernBlackboardLayoutButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        selectModernBlackboardLayoutButton.addTarget(self,
                                     action: #selector(didTapSelectModernBlackboardLayoutButton),
                                     for: .touchUpInside)
        
        let launchCameraButton = UIButton(type: .system)
        launchCameraButton.setTitle("カメラ起動", for: .normal)
        launchCameraButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        launchCameraButton.addTarget(self,
                                     action: #selector(didTapLaunchCameraButton),
                                     for: .touchUpInside)
        launchCameraButton.viewAccessibilityIdentifier = .launchCameraButton

        enableBlackboardInitialLocationDataSwitchView.onHandler =  { [weak self] isOn in
            guard isOn else { return }
            let alert = UIAlertController(
                title: "機能説明",
                message: "カメラ起動時に、前回の黒板ロケーション情報（位置、サイズ、向きなど）を反映した上で黒板を表示します。\n\n※この機能は新黒板のみ有効です",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true)
        }

        // RemoteConfigの初期設定
        AndpadCameraDependencies.shared.setup(remoteConfigHandler: remoteConfigStub)
        // 黒板をHTMLで表示するかどうかのスイッチが変更されたときの処理
        useBlackboardGeneratedWithSVGSwitchView.onHandler = { [weak self] isOn in
            guard let self else { return }
            remoteConfigStub = RemoteConfigHandlerStub(useBlackboardGeneratedWithSVG: isOn)
            AndpadCameraDependencies.shared.setup(remoteConfigHandler: remoteConfigStub)
        }

        [
            imageView,
            selectModernBlackboardLayoutButton,
            launchCameraButton,
            enableBlackboardSwitchView,
            enableBlackboardWithDefaultValueSwitchView,
            enableInspectionTemplateSwitchView,
            enableInspectionTemplateWithDefaultValueSwitchView,
            enableMultiplePhotosSwitchView,
            enableShootingGuideSwitchView,
            enableModernBlackboardsSwitchView,
            enableBlackboardInitialLocationDataSwitchView,
            enablePhotoQualitySettingsSwitchView,
            enablePhotoHighQualityPermissionSettingSwitchView,
            enableOfflineModeSwitchView,
            enableBlackboardStyleEditingSwitchView,
            enableBlackboardSizeTypeOnServerSwitchView,
            enableGPSEnableSwitchView,
            enablePreferredPhotoFormatSwitchView,
            useBlackboardGeneratedWithSVGSwitchView
        ].forEach {
            stackView.addArrangedSubview($0)
        }

        #if DEBUG
        let openSandboxButton = UIButton(type: .system)
        openSandboxButton.setTitle("Sandbox", for: .normal)
        openSandboxButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        openSandboxButton.addTarget(self,
                                    action: #selector(didTapSandboxButton),
                                    for: .touchUpInside)
        stackView.addArrangedSubview(openSandboxButton)
        #endif
    }
    
    var modernBlackboardConfiguration: ModernBlackboardConfiguration {
        guard enableModernBlackboardsSwitchView.isOn else { return .disable }

        switch DummyData.modernBlackboardConfiguration {
        case .disable:
            return .disable
        case .enable(let arguments):
            var updated = arguments
                .updating(withCanEditBlackboardStyle: enableBlackboardStyleEditingSwitchView.isOn)
                // ONにした場合、サーバー側の黒板サイズタイプをテスト用に「大」に設定する（小でも中でもいい）
                .updating(withBlackboardSizeTypeOnServer: enableBlackboardSizeTypeOnServerSwitchView.isOn ? .large : .free)
                .updating(withPreferredPhotoFormat: enablePreferredPhotoFormatSwitchView.isOn ? .svg : .jpeg)
            // 位置サイズ情報だけ更新した上で、新黒板の設定情報を返却する
            if
                enableBlackboardInitialLocationDataSwitchView.isOn,
                let initialLocationData = initialLocationDataForModernBlackboard {
                updated = updated
                    .updating(with: initialLocationData)
            }
            if let selectedModernBlackboardMaterial {
                updated = updated
                    .updating(with: selectedModernBlackboardMaterial)
            }
            return .enable(updated)
        }
    }
    
    @objc private func didTapSelectModernBlackboardLayoutButton() {
        let actionSheet = UIAlertController(title: "新黒版のレイアウトを選択（全\(ModernBlackboardMaterialStub.total)件）", message: nil, preferredStyle: .actionSheet)
        ModernBlackboardMaterialStub
            .allCases(
                doFillTexts: DummyData.doFillTexts,
                miniatureMapStubImageType: DummyData.miniatureMapStubImageType
            )
            .forEach { stub in
                actionSheet.addAction(
                    .init(
                        title: "\(stub.layoutID)",
                        style: .default,
                        handler: { [weak self] _ in
                            guard let self else { return }
                            self.selectedModernBlackboardMaterial = stub.value
                            self.selectModernBlackboardLayoutButton.setTitle("[全\(ModernBlackboardMaterialStub.total)件]\n選択中の新黒板レイアウト： \(stub.value!.layoutTypeID)", for: .normal)
                        }
                    )
                )
            }
        actionSheet.configurePopoverForIPadIfNeeded(parentView: view)
        present(actionSheet, animated: true)
    }

    @objc private func didTapLaunchCameraButton() {

        setBlackboardIfNeeded()

        let shootingGuideImageUrl: URL? = {
            if enableShootingGuideSwitchView.isOn {
                return URL(
                    string: "https://storage.googleapis.com/shooting_guides/image%2015.png"
                )!
            } else {
                return nil
            }
        }()

        let navigationContoller = TakeCameraViewController.makeNavigationInstance(
            isOfflineMode: enableOfflineModeSwitchView.isOn,
            data: blackboard,
            appBaseRequestData: DummyData.appBaseRequestData,
            isBlackboardEnabled: enableBlackboardSwitchView.isOn,
            modernBlackboardConfiguration: modernBlackboardConfiguration,
            allowMultiplePhotos: enableMultiplePhotosSwitchView.isOn,
            inspectionTemplateEnabled: enableInspectionTemplateSwitchView.isOn,
            shootingGuideImageUrl: shootingGuideImageUrl,
            maxPhotoCount: 20,
            photoQualityOptions: enablePhotoQualitySettingsSwitchView.isOn ? PhotoQuality.defaultOptions(containsHighQuality: enablePhotoHighQualityPermissionSettingSwitchView.isOn) : [],
            initialPhotoQuality: enablePhotoQualitySettingsSwitchView.isOn ? .defaultStandard : nil,
            cancelHandler: { [weak self] _, locationDataForModernBlackboard in
                self?.initialLocationDataForModernBlackboard = locationDataForModernBlackboard
            },
            completedHandler: { [weak self] viewController, photos, initialLocationDataForModernBlackboard in
                self?.initialLocationDataForModernBlackboard = initialLocationDataForModernBlackboard
                self?.blackboard = viewController.blackboardMappingModel.toModel()

                guard let jpegURL = photos.last?.urls.jpeg else {
                    logger.debug("No photos")
                    return
                }

                do {
                    let data = try Data(contentsOf: jpegURL)
                    self?.imageView.image = UIImage(data: data)
                } catch {
                    #if targetEnvironment(simulator)
                    // シミュレーターで実行された場合、ファイルの読み込みに失敗するが、エラーを無視して続行する
                    logger.debug("\(error.localizedDescription) 写真URL: \(jpegURL.absoluteString)")
                    #else
                    assertionFailure(error.localizedDescription)
                    #endif
                }

                TakeCameraViewController.clearData()
            }, permissionNotAuthorizedHandler: { _, _ in
                //
            },
            storage: ModernBlackboardCameraStorageStub(),
            containsGPSInMetadata: enableGPSEnableSwitchView.isOn
        )

        navigationContoller.modalPresentationStyle = .fullScreen
        present(navigationContoller, animated: true, completion: nil)
    }

    #if DEBUG
    @objc private func didTapSandboxButton() {
        present(SandboxViewController(), animated: true)
    }
    #endif
    
    // NOTE: 必要であれば、初期表示時の旧黒板（もしくは検査黒板）を指定する
    //       ※ なお新黒板は別の箇所でセットしているので注意
    private func setBlackboardIfNeeded() {
        guard enableBlackboardSwitchView.isOn else {
            blackboard = nil
            return
        }
        
        if enableBlackboardWithDefaultValueSwitchView.isOn || enableInspectionTemplateSwitchView.isOn {
            var type: BlackBoardType?
            if enableBlackboardWithDefaultValueSwitchView.isOn {
                type = .case3
            }
            
            if enableInspectionTemplateSwitchView.isOn {
                type = .inspectionCase1
            }
            
            if let type = type {
                blackboard = .init(
                    constractionName: "constractionNameのダミー文です。",
                    constractionPlace: "constractionPlaceのダミー文です。",
                    constractionPlayer: "constractionPlayerのダミー文です。",
                    memo: "memoのダミー文です。",
                    constractionCategory: "constractionCategoryのダミー文です。",
                    constractionState: "constractionStateのダミー文です。",
                    constractionPhotoClass: "constractionPhotoClassのダミー文です。",
                    photoTitle: "photoTitleのダミー文です。",
                    detail: "detailのダミー文です。",
                    inspectionReportTitle: enableInspectionTemplateSwitchView.isOn && enableInspectionTemplateWithDefaultValueSwitchView.isOn
                        ? "inspectionReportTitleのダミー文です。"
                        : "",
                    inspectionItem: enableInspectionTemplateSwitchView.isOn && enableInspectionTemplateWithDefaultValueSwitchView.isOn
                        ? "inspectionItemのダミー文です。"
                        : "",
                    inspectionTitle: enableInspectionTemplateSwitchView.isOn && enableInspectionTemplateWithDefaultValueSwitchView.isOn
                        ? "inspectionTitleのダミー文です。"
                        : "",
                    inspectionPoint: enableInspectionTemplateSwitchView.isOn && enableInspectionTemplateWithDefaultValueSwitchView.isOn
                        ? "inspectionPointのダミー文です。"
                        : "",
                    inspector: enableInspectionTemplateSwitchView.isOn && enableInspectionTemplateWithDefaultValueSwitchView.isOn
                        ? "inspectorのダミー文です。"
                        : "",
                    client: "clientのダミー文です。",
                    type: type
                )
            }
        } else {
            blackboard = nil
        }
    }
}

// MARK: SwitchRowView
private final class SwitchRowView: UIView {

    private let titleLabel: UILabel = .init()
    private let switchView: UISwitch = .init()

    private let disposeBag = DisposeBag()

    var isOn: Bool {
        switchView.isOn
    }

    var onHandler: ((_ isOn: Bool) -> Void)?

    init(
        title: String,
        defaultValue: Bool,
        type: TextStyleType = .main,
        viewAccessibilityIdentifier: ViewAccessibilityIdentifier? = nil
    ) {
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.textColor = type.textColor
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(4)
            make.centerY.equalToSuperview()
        }

        switchView.setOn(defaultValue, animated: false)
        self.addSubview(switchView)
        switchView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(4)
            make.centerY.equalToSuperview()
        }

        if let viewAccessibilityIdentifier {
            switchView.viewAccessibilityIdentifier = viewAccessibilityIdentifier
        }

        switchView.rx.controlEvent(.valueChanged)
            .withLatestFrom(switchView.rx.value)
            .subscribe(onNext: { [weak self] isOn in
                self?.onHandler?(isOn)
            })
            .disposed(by: disposeBag)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum TextStyleType {
        case main
        case sub
        
        var textColor: UIColor {
            switch self {
            case .main:
                    return .label
            case .sub:
                return .secondaryLabel
            }
        }
    }
}

// MARK: Example用のスタブデータ
extension SnapshotData {
    public static func stub(doFillTexts: Bool) -> SnapshotData {
        // 各項目の最大文字数
        enum MaxTextValue {
            case text10
            case text30
            case text200
            case text254

            var string: String {
                switch self {
                case .text10:
                    return "これで１０文字です。"
                case .text30:
                    return "これで１０文字です。これで１０文字です。これで１０文字です。"
                case .text200:
                    return "これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。"
                case .text254:
                    return "これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。２５４字"
                }
            }
        }
        
        return .init(
            userID: 999999,
            orderName: doFillTexts ? MaxTextValue.text254.string : "ANDPAD株式会社",
            clientName: doFillTexts ? MaxTextValue.text30.string : "鈴木一郎",
            startDate: Date()
        )
    }
}

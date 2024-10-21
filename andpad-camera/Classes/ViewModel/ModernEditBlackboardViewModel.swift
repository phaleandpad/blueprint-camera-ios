//
//  ModernEditBlackboardViewModel.swift
//  andpad-camera
//
//  Created by msano on 2022/01/26.
//

import RxCocoa
import RxSwift
import SnapKit

// MARK: EditableBlackboardDataProtocol
protocol EditableBlackboardDataProtocol {}

public final class ModernEditBlackboardViewModel {
    
    enum TappedButtonType {
        case cancel
        case selectBlackboard
        case selectBlackboardLayout
        
        var isCancel: Bool {
            switch self {
            case .cancel:
                return true
            case .selectBlackboard, .selectBlackboardLayout:
                return false
            }
        }
    }
    
    enum RequestedBlackboardType {
        case posted
        case put
    }
    
    typealias DataSource = ModernEditBlackboardDataSource
    
    // MARK: - define Inputs, Outputs
    enum Input {
        case viewDidLoad
        case updateBlackboardItems([ModernBlackboardMaterial.Item])
        case update(EditableBlackboardDataProtocol)
        case didTapArrowButton
        case didTapSelectBlackboardButton
        case didTapCancelButton
        case didTapSaveButton
        case didTapCell
        case didTapSelectLayoutButton
        case didTapDestroyEditingBlackboardButton(tappedButtonType: TappedButtonType)
        /// 黒板一覧など、他画面から別の黒板データを受け取った時に使用
        case replaceOtherBlackboardMaterialAndAppearance(ModernBlackboardMaterial, ModernBlackboardAppearance)
        case receiveNewLayoutPattern(ModernBlackboardContentView.Pattern)
        
        // 黒板一覧のボタンアクション
        case didTapBlackboardImageButtonInBlackboardListView(ModernBlackboardMaterial)
        case didTapEditButtonInBlackboardListView(ModernBlackboardMaterial)
        case didTapTakePhotoButtonInBlackboardListView(ModernBlackboardMaterial)
        case didTapEditButtonInAlert
    }
    
    enum Output {
        case changeSaveButtonState(isEnabled: Bool)
        case updatePreview(MaterialAndAppearance, MiniatureMapImageState?)
        case updateWebPreview(query: String)
        case dismiss(ModernEditBlackboardViewController.CompletedHandlerData?)
        case endEditing
        case presentBlackboardListViewController(AppDependencies.BlackboardListViewArguments)
        case presentBlackboardLayoutListViewController  // swiftlint:disable:this identifier_name
        case showErrorMessage(error: AndpadCameraError)
        case showPostBlackboardErrorMessage
        case showLoadingView
        case hideLoadingView
        case showValidateErrorAlert
        case showDestoryEditingBlackboardAlert(okHandler: (UIAlertAction) -> Void)
        case showWillSelectNewLayoutAlert(okHandler: (UIAlertAction) -> Void)
        case showOverwriteOrCreateNewAlert(overwriteHandler: (UIAlertAction) -> Void, createNewHandler: (UIAlertAction) -> Void)
        case showUpdateBlackboardByAdminActionAlert(okHandler: (UIAlertAction) -> Void, cancelHandler: (UIAlertAction) -> Void)
        case showDuplicateBlackboardAlert(
            viewType: UIAlertController.DuplicateBlackboardAlertViewType,
            confirmBlackboardHandler: (UIAlertAction) -> Void
        )
        case returnToEditViewController(ModernBlackboardMaterial, ModernBlackboardAppearance)
        case returnToTakeCameraViewController(ModernEditBlackboardViewController.CompletedHandlerData)
        case updateSaveButtonState(isEnabled: Bool)
        case showAppStoreAlert
        case update(hasMiniatureMap: Bool)
    }

    private struct StaticState {
        let orderID: Int
        let title: String = L10n.Blackboard.Edit.title
        let snapshotData: SnapshotData
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
        let initialModernBlackboardMaterial: ModernBlackboardMaterial
        let initialBlackboardViewAppearance: ModernBlackboardAppearance
        let memoStyleArguments: ModernBlackboardMemoStyleArguments
        let editableScope: ModernEditBlackboardViewController.EditableScope
    }
    
    let inputPort: PublishRelay<Input> = .init()
    let outputPort: ControlEvent<Output>
    let dataSource = DataSource()
    let items = BehaviorRelay<[DataSource.Section]>(value: [])

    private let networkService: ModernBlackboardNetworkServiceProtocol
    private let staticState: StaticState
    private let updatedModernBlackboardMaterialRelay = BehaviorRelay<MaterialAndAppearance?>(value: nil)
    private let disposeBag = DisposeBag()
    private let outputRelay: PublishRelay<Output>

    private let hasOverwritePermissionRelay = PublishRelay<Bool>()
    private let hasAdminRoleRelay = PublishRelay<Bool>()
    private let hasNoPhotoRelay = PublishRelay<Bool>()
    private let isMyBlackboardRelay = PublishRelay<Bool>()
    
    private var miniatureMapImageStateRelay = BehaviorRelay<MiniatureMapImageState?>(value: nil)

    private let shouldShowOverwriteOrCreateNewAlertRelay = PublishRelay<Bool>()

    // TextView側でemitするタイミングがAPIのレスポンスが返るよりも遅いので、BehaviorRelayにして貯めておくようにする
    private let constructionNameShouldBeEditableRelay
        = BehaviorRelay<(isEditable: Bool, shouldBeFocus: Bool)>(value: (true, false))

    struct MaterialAndAppearance {
        let blackboardMaterial: ModernBlackboardMaterial
        let appearance: ModernBlackboardAppearance
    }
    
    private var initialMaterialAndAppearance: MaterialAndAppearance {
        .init(
            blackboardMaterial: staticState.initialModernBlackboardMaterial,
            appearance: staticState.initialBlackboardViewAppearance
        )
    }
    
    /// 編集されているか否か
    private var beforeEditing: Bool {
        switch editableScope {
        case .all:
            guard let updatedModernBlackboardMaterial = updatedModernBlackboardMaterialRelay.value?.blackboardMaterial,
                  let updatedAppearance = updatedModernBlackboardMaterialRelay.value?.appearance else { return true }
            return updatedModernBlackboardMaterial == staticState.initialModernBlackboardMaterial
                && updatedAppearance == staticState.initialBlackboardViewAppearance
        case .onlyBlackboardItems:
            return beforeEditingWithoutAppearance
        }
    }
    
    /// （アピアランス関連および工事名のタイトル、工事名、撮影日、施工者は無視して）それ以外の値が編集されているか否か
    private var beforeEditingWithoutAppearance: Bool {
        
        // NOTE: 工事名のタイトル、工事名、撮影日、施工者、黒板色以外の値で、変更がない場合はtrueとする
        //  -> 上記値を揃えた上で差異比較
        //
        // なお、備考書式、透明度は
        // 管理しているモデル（ModernBlackboardAppearance）自体が違うので、比較もしない
        
        // 比較対象1（編集された黒板データ）
        let modernBlackboardMaterial = updatedModernBlackboardMaterialRelay.value?
            .blackboardMaterial
            .updating(
                by: staticState.snapshotData, // 工事名、撮影日、施工者を揃える
                shouldForceUpdateConstructionName: true
            )
            // 工事名のタイトルを差分チェック対象外にするために同じ値を入れる
            .updating(constructionNameTitle: "")

        guard let editedBlackboardMaterial = modernBlackboardMaterial else { return true }

        // 比較対象2（画面生成時、編集前の黒板データ）
        let targetModernBlackboardMaterial = initialModernBlackboardMaterial
                .updating(by: editedBlackboardMaterial.blackboardTheme) // 黒板色を揃える
                .updating(
                    by: staticState.snapshotData, // 工事名、撮影日、施工者を揃える
                    shouldForceUpdateConstructionName: true
            )
            // 工事名のタイトルを差分チェック対象外にするために同じ値を入れる
            .updating(constructionNameTitle: "")

        return targetModernBlackboardMaterial == editedBlackboardMaterial
    }
    
    private var tappedButtonTypeForBlackboardList: ModernBlackboardListViewController.TappedButtonType?
    
    private var canEditBlackboardStyle = false
    private var canEditDate = true // web側リリース前のため、一律可能とする（現状はリリース後もこのままの予定）
    private var localValidateErrorData: LocalValidateErrorData?
    /// APIから取得した黒板のサイズタイプ
    private var blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType = .free
    /// APIから取得した撮影画像形式
    private var preferredPhotoFormat: ModernBlackboardCommonSetting.PhotoFormat = .jpeg
    private var previewWebViewSize: CGSize = .zero

    let isOfflineMode: BehaviorRelay<Bool>
    private let remoteConfig: (any AndpadCameraDependenciesRemoteConfigProtocol)?
    /// 表示統一対応用の黒板レイアウトを利用するかどうか
    ///
    /// - Note: 従来式のレイアウトを利用しなくなった場合は本フラグは利用しなくなる。
    var useBlackboardGeneratedWithSVG: Bool {
        remoteConfig?.fetchUseBlackboardGeneratedWithSVG() ?? false
    }

    init(
        networkService: ModernBlackboardNetworkServiceProtocol,
        orderID: Int,
        snapshotData: SnapshotData,
        advancedOptions: [ModernBlackboardConfiguration.AdvancedOption],
        modernBlackboardMaterial: ModernBlackboardMaterial,
        blackboardViewAppearance: ModernBlackboardAppearance,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        editableScope: ModernEditBlackboardViewController.EditableScope,
        shouldResetBlackboardEditLoggingHandler: Bool,
        isOfflineMode: Bool,
        remoteConfig: AndpadCameraDependenciesRemoteConfigProtocol? = AndpadCameraDependencies.shared.remoteConfigHandler
    ) {
        // MARK: - configure Outputs
        let relay = PublishRelay<Output>()
        self.outputPort = .init(events: relay)
        self.outputRelay = relay
        self.networkService = networkService
        
        self.staticState = .init(
            orderID: orderID,
            snapshotData: snapshotData,
            advancedOptions: advancedOptions,
            initialModernBlackboardMaterial: modernBlackboardMaterial,
            initialBlackboardViewAppearance: blackboardViewAppearance,
            memoStyleArguments: memoStyleArguments,
            editableScope: editableScope
        )
        
        self.isOfflineMode = .init(value: isOfflineMode)
        self.remoteConfig = remoteConfig

        if shouldResetBlackboardEditLoggingHandler {
            BlackboardEditLoggingHandler.reset()
        }
        
        inputPort
            .bind(onNext: { [weak self] event in
                switch event {
                case .viewDidLoad:
                    self?.viewDidLoadEvent()
                case .updateBlackboardItems(let blackboardItems):
                    self?.updateBlackboardMaterial(by: blackboardItems)
                case .update(let editableData):
                    self?.updateBlackboardMaterial(by: editableData)
                case .didTapArrowButton:
                    self?.didTapArrowButtonEvent()
                case .didTapSelectBlackboardButton:
                    self?.didTapSelectBlackboardButtonEvent()
                case .didTapCancelButton:
                    self?.didTapCancelButtonEvent()
                case .didTapSaveButton:
                    self?.didTapSaveButtonEvent()
                case .didTapCell:
                    self?.didTapCellEvent()
                case .didTapSelectLayoutButton:
                    self?.didTapSelectLayoutButtonEvent()
                case .didTapDestroyEditingBlackboardButton(let tappedButtonType):
                    self?.didTapDestroyEditingBlackboardButtonEvent(tappedButtonType: tappedButtonType)
                case .replaceOtherBlackboardMaterialAndAppearance(let blackboardMaterial, let appearance):
                    self?.replace(blackboardMaterial: blackboardMaterial, blackboardViewAppearance: appearance)
                case .receiveNewLayoutPattern(let pattern):
                    self?.receiveNewLayoutPatternEvent(pattern: pattern)
                case .didTapBlackboardImageButtonInBlackboardListView(let modernBlackboardMaterial):
                    self?.didTapBlackboardImageButtonEventInBlackboardListView(modernBlackboardMaterial: modernBlackboardMaterial)
                case .didTapEditButtonInBlackboardListView(let modernBlackboardMaterial):
                    self?.didTapEditButtonEventInBlackboardListView(modernBlackboardMaterial: modernBlackboardMaterial)
                case .didTapTakePhotoButtonInBlackboardListView(let modernBlackboardMaterial):
                    self?.didTapTakePhotoButtonEventInBlackboardListView(modernBlackboardMaterial: modernBlackboardMaterial)
                case .didTapEditButtonInAlert:
                    // アラート経由で入力をオンにする場合のみ、フォーカスを当てるようにする
                    self?.constructionNameShouldBeEditableRelay.accept((true, true))
                }
            })
            .disposed(by: disposeBag)
        
        // 上書き保存アラート出しわけ用のsubscriber
        Observable
            .zip(
                hasOverwritePermissionRelay,
                hasAdminRoleRelay,
                isMyBlackboardRelay,
                hasNoPhotoRelay
            )
            .map { hasOverwritePermission, hasAdminRole, isMyBlackboard, hasNoPhoto in
                (hasOverwritePermission || hasAdminRole || isMyBlackboard) && hasNoPhoto
            }
            .bind(to: shouldShowOverwriteOrCreateNewAlertRelay)
            .disposed(by: disposeBag)
        
        shouldShowOverwriteOrCreateNewAlertRelay
            .asSignal()
            .emit(onNext: { [weak self] shouldShowAlert in
                guard let self,
                      let blackboardMaterial = self.updatedModernBlackboardMaterialRelay.value?.blackboardMaterial else { return }
                let orderID = self.staticState.orderID
                
                guard shouldShowAlert else {
                    // 黒板データをコピー新規でPOST
                    self.postBlackboard(blackboardMaterial: blackboardMaterial)
                    return
                }
                self.outputRelay.accept(
                    .showOverwriteOrCreateNewAlert(
                        overwriteHandler: { [weak self] _ in self?.putBlackboard(blackboardMaterial: blackboardMaterial) },
                        createNewHandler: { [weak self] _ in self?.postBlackboard(blackboardMaterial: blackboardMaterial) }
                    )
                )
            })
            .disposed(by: disposeBag)
        
        updatedModernBlackboardMaterialRelay
            .asSignal(onErrorJustReturn: nil)
            .do(onNext: { [weak self] in
                guard let self,
                      let blackboardMaterial = $0?.blackboardMaterial else { return }
                let hasMiniatureMap = ModernBlackboardContentView.Pattern(
                        by: blackboardMaterial.layoutTypeID
                    )?
                    .hasMiniatureMapView
                self.outputRelay.accept(.update(hasMiniatureMap: hasMiniatureMap ?? false))
                self.outputRelay.accept(.changeSaveButtonState(isEnabled: !self.beforeEditing))
            })
            .compactMap { $0 }
            .flatMap { [weak self] materialAndAppearance -> Signal<Output> in
                guard let self else { return .empty() }
 
                let useBlackboardGeneratedWithSVG = remoteConfig?.fetchUseBlackboardGeneratedWithSVG() ?? false
                if useBlackboardGeneratedWithSVG {
                    // HTMLで黒板を表示
                    return Single.fromAwait {
                        try await self.makeBlackboardWebViewQuery(
                            blackboardMaterial: materialAndAppearance.blackboardMaterial,
                            blackboardAppearance: materialAndAppearance.appearance
                        )
                    }
                    .asObservable()
                    .map { Output.updateWebPreview(query: $0) }
                    // クエリ生成に失敗した場合、内部処理エラーを表示（仕様ではない）
                    .asSignal(onErrorJustReturn: Output.showErrorMessage(error: .operationCouldNotBeCompleted))
                } else {
                    // HTMLを使わない従来の画像化で黒板を表示
                    return Signal.just((materialAndAppearance, self.miniatureMapImageStateRelay.value))
                        .map { Output.updatePreview($0.0, $0.1) }
                }
            }
            .emit(to: outputRelay)
            .disposed(by: disposeBag)
        
        miniatureMapImageStateRelay
            .asSignal(onErrorJustReturn: nil)
            .compactMap { [weak self] state -> (MaterialAndAppearance, MiniatureMapImageState?)? in
                guard let self else { return nil }
                let materialAndAppearance = self.updatedModernBlackboardMaterialRelay.value
                  ?? .init(
                    blackboardMaterial: self.initialModernBlackboardMaterial,
                    appearance: self.initialBlackboardViewAppearance
                  )
                return (materialAndAppearance, state)
            }
            .map { Output.updatePreview($0.0, $0.1) }
            .emit(to: outputRelay)
            .disposed(by: disposeBag)
        
        networkService.getBlackboardCommonSettingObservable
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                let originalMaterialAndAppearance = self.updatedModernBlackboardMaterialRelay.value
                let modernBlackboardMaterial = originalMaterialAndAppearance?.blackboardMaterial
                    ?? self.staticState.initialModernBlackboardMaterial
                let blackboardViewAppearance = originalMaterialAndAppearance?.appearance
                    ?? self.staticState.initialBlackboardViewAppearance
                let datePosition = ModernBlackboardContentView.Pattern(by: modernBlackboardMaterial.layoutTypeID)?
                    .specifiedPosition(by: .date)
                
                guard let object = $0.data.object else { return }
                
                // NOTE: 黒板スタイル（備考書式 / 黒板色）および撮影日の編集可否を反映
                self.canEditBlackboardStyle = object.canEditBlackboardStyle
                self.canEditDate = object.canEditDate
                blackboardSizeTypeOnServer = .init(sizeRate: object.blackboardDefaultSizeRate)
                preferredPhotoFormat = object.preferredPhotoFormat

                let snapshotData = SnapshotData(
                    userID: self.staticState.snapshotData.userID,
                    orderName: object.constructionNameConsideringDisplayType ?? self.staticState.snapshotData.orderName,
                    clientName: object.selectedConstructionPlayerName,
                    startDate: modernBlackboardMaterial.items.first { $0.position == datePosition }?.body.asDateFromDateString()
                        ?? self.staticState.snapshotData.startDate
                )

                let theme = object.defaultTheme
                let memoStyleArguments = object.memoStyleArguments ?? .defaultSetting(with: theme)
                
                // 更新した黒板アピアランスを用意
                var updatedBlackboardViewAppearance = blackboardViewAppearance
                    .updating(by: theme)
                    .updating(by: memoStyleArguments)
                    .updating(by: object.dateFormatType)
                    .updating(shouldBeReflectedNewLine: object.shouldBeReflectedNewLine)

                if editableScope == .all {
                    // 撮影編集の場合のみ、設定APIから取得した黒板の透明度を適用する
                    // ※上書き編集の場合、透明度を適用しない（将来的には検討）
                    let blackboardTransparencyType = object.blackboardTransparencyType
                    updatedBlackboardViewAppearance = updatedBlackboardViewAppearance
                        .updating(by: blackboardTransparencyType)
                }
                
                // 更新した黒板データを用意
                let updatedBlackboardMaterial = modernBlackboardMaterial
                    .updating(by: object.defaultTheme) // 黒板色の更新
                    .updating(by: snapshotData, shouldForceUpdateConstructionName: true) // 施工者名の更新
                    // 工事名のタイトル部分のテキストを更新
                    .updating(constructionNameTitle: object.constructionNameTitle)
                    // 工事名をWebから取得した最新設定値に更新する
                    .updating(constructionNameBody: object.constructionName)

                if object.constructionNameDisplayType == .customConstructionNameReflectedNewline {
                    constructionNameShouldBeEditableRelay.accept((false, false))
                } else {
                    constructionNameShouldBeEditableRelay.accept((true, false))
                }

                // 工事名(前の画面から渡ってきた初期値(編集した工事名が入ることもある))
                let initialConstructionName = modernBlackboardMaterial.constructionNameItem?.body
                // 工事名(Webから取得した最新設定値)
                let currentConstructionNameFromAPI = object.constructionName
                let currentConstructionNameTitle = modernBlackboardMaterial.constructionNameItem?.itemName

                guard let tappedButtonTypeForBlackboardList = self.tappedButtonTypeForBlackboardList else {
                    switch editableScope {
                    case .onlyBlackboardItems:
                        // 更新した黒板データ、黒板アピアランスを画面に反映する
                        let materialAndAppearance = MaterialAndAppearance(
                            blackboardMaterial: updatedBlackboardMaterial,
                            appearance: updatedBlackboardViewAppearance
                        )
                        self.updatedModernBlackboardMaterialRelay.accept(materialAndAppearance)
                        self.loadMiniatureMapImageIfNeeded(miniatureMap: materialAndAppearance.blackboardMaterial.miniatureMap) { [weak self] in
                            self?.setItems(materialAndAppearance: materialAndAppearance, miniatureMapImageState: $0)
                        }
                    case .all:
                        // NOTE:
                        // 撮影編集の場合、画面表示時に「自動では」データ更新しない、データ更新するかどうかはユーザーに判断してもらう
                        // （なぜなら、この画面を表示する前に、ユーザーが意図して黒板内容を変更している可能性があるため）
                        //
                        // 以下いずれかが異なる場合（ = web側で設定変更されていた場合）、データ更新するか否かについてアラートを出す
                        //  - 黒板色
                        //  - 備考書式
                        //  - 黒板の透明度
                        //  - 日付フォーマット
                        //  - 工事名(案件名)
                        //  - 施工者名
                        //  - 工事名(タイトル)
                        if updatedBlackboardViewAppearance.matchesAppearance(with: blackboardViewAppearance),
                           snapshotData.clientName == self.staticState.snapshotData.clientName,
                           initialConstructionName == currentConstructionNameFromAPI,
                           object.constructionNameTitle == currentConstructionNameTitle {
                            self.loadMiniatureMapImageIfNeeded(miniatureMap: modernBlackboardMaterial.miniatureMap) { [weak self] in
                                let materialAndAppearance = MaterialAndAppearance(
                                    blackboardMaterial: modernBlackboardMaterial,
                                    appearance: blackboardViewAppearance
                                )
                                self?.setItems(
                                    materialAndAppearance: materialAndAppearance,
                                    miniatureMapImageState: $0
                                )
                            }
                        } else {
                            self.outputRelay.accept(
                                .showUpdateBlackboardByAdminActionAlert(
                                    okHandler: { [weak self] _ in
                                        guard let self else { return }
                                        self.updateBlackboardMaterial(
                                            by: updatedBlackboardMaterial,
                                            appearance: updatedBlackboardViewAppearance
                                        )
                                    },
                                    cancelHandler: { [weak self] _ in
                                        guard let self else { return }
                                        self.loadMiniatureMapImageIfNeeded(miniatureMap: modernBlackboardMaterial.miniatureMap) { [weak self] in
                                            let materialAndAppearance = MaterialAndAppearance(
                                                blackboardMaterial: modernBlackboardMaterial,
                                                appearance: blackboardViewAppearance
                                            )
                                            self?.setItems(
                                                materialAndAppearance: materialAndAppearance,
                                                miniatureMapImageState: $0
                                            )
                                        }
                                        // 工事名(案件名)に差分があり、かつ「管理者が設定を変更しました」アラートでキャンセルを押下した場合、
                                        // 「改行位置の設定を解除して、工事名を編集しますか？」アラートは表示しない
                                        if initialConstructionName != currentConstructionNameFromAPI {
                                            constructionNameShouldBeEditableRelay.accept((true, false))
                                        }
                                    }
                                )
                            )
                        }
                    }
                    return
                }
                
                let output: Output
                switch tappedButtonTypeForBlackboardList {
                case .edit:
                    output = .returnToEditViewController(
                        updatedBlackboardMaterial,
                        updatedBlackboardViewAppearance
                    )
                case .blackboardImage, .takePhoto:
                    output = .returnToTakeCameraViewController(
                        .init(
                            modernBlackboardMaterial: updatedBlackboardMaterial,
                            modernBlackboardAppearance: updatedBlackboardViewAppearance,
                            blackboardEditLogs: BlackboardEditLoggingHandler.blackboardTypes,
                            canEditBlackboardStyle: canEditBlackboardStyle,
                            blackboardSizeTypeOnServer: blackboardSizeTypeOnServer,
                            preferredPhotoFormat: preferredPhotoFormat
                        )
                    )
                }
                self.outputRelay.accept(output)
                self.tappedButtonTypeForBlackboardList = nil
            })
            .disposed(by: disposeBag)
        
        networkService.getBlackboardDetailObservable
            .subscribe(onNext: { [weak self] in
                guard let self,
                      let blackboard = $0.data.object else {
                    self?.hasNoPhotoRelay.accept(false)
                    return
                }
                
                // NOTE: 対象の黒板が、自身が作成者である黒板が確認
                if let id = blackboard.createdUser?.id {
                    self.isMyBlackboardRelay.accept(self.staticState.snapshotData.userID == id)
                } else {
                    self.isMyBlackboardRelay.accept(false)
                }
                self.hasNoPhotoRelay.accept(blackboard.photoCount == 0)
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                networkService.postBlackboardObservable
                    .map { ($0, RequestedBlackboardType.posted) },
                networkService.putBlackboardObservable
                    .map { ($0, RequestedBlackboardType.put) }
            )
            .subscribe(onNext: { [weak self] result, requestedBlackboardType in
                guard let self else { return }
                self.doEnableSaveButton()
                guard let blackboardMatarial = result.data.object else { return }
                blackboardMatarial.prettyDebug(with: "編集（コピー新規 or 上書き保存）に成功した黒板データ")
                let isDuplicatedBlackboard = blackboardMatarial.isDuplicated
                
                // dismiss時に行う諸処理をまとめたもの
                let dismissHandler = { [weak self] in
                    guard let self else { return }
                    let resetBlackboardMatarial = blackboardMatarial.resetDuplicateFlag()

                    var deletedBlackboardId: Int?
                    var type: BlackboardEditLoggingHandler.BlackboardType?
                    switch requestedBlackboardType {
                    case .posted:
                        type = .posted(.copy, blackboardID: resetBlackboardMatarial.id)
                        self.updateBlackboardMaterial(by: resetBlackboardMatarial.id)
                    case .put:
                        // NOTE: 上書き保存の場合、上書きマージ（編集の結果、既存黒板と完全一致し、マージされる）ことがある
                        //  -> 確認のため、リクエスト前の黒板と、レスポンスの黒板のidが一致しているか検証する
                        guard let original = self.updatedModernBlackboardMaterialRelay.value?.blackboardMaterial else {
                            fatalError() // 上書き保存の場合、必ず存在する想定のため
                        }
                        if original.id != resetBlackboardMatarial.id {
                            deletedBlackboardId = original.id
                        }
                        self.updateBlackboardMaterial(by: resetBlackboardMatarial.id)
                    
                        guard let updated = self.updatedModernBlackboardMaterialRelay.value?.blackboardMaterial else { fatalError() }
                        type = .put(updated)
                    }
                    
                    // post / put操作のログを追加する（ただし黒板が重複していないケースに限る）
                    if !isDuplicatedBlackboard {
                        // typeの削除および追加
                        if let deletedBlackboardId = deletedBlackboardId {
                            BlackboardEditLoggingHandler.deleteTypeBy(
                                blackboardID: deletedBlackboardId,
                                withoutPostedBlackboard: true
                            )
                        }
                        if let type = type {
                            BlackboardEditLoggingHandler.add(type: type)
                        }
                    }

                    outputRelay.accept(
                        makeDismissOutput(shouldUseLatestData: true)
                    )
                }
                
                guard !isDuplicatedBlackboard else {
                    showDuplicateAlert(
                        editableScope: editableScope,
                        confirmBlackboardHandler: { [weak self] _ in
                            dismissHandler()
                        }
                    )
                    return
                }
                dismissHandler()
            })
            .disposed(by: disposeBag)

        networkService.getOrderPermissionObservable
            .subscribe(onNext: { [weak self] in
                guard let permissions = $0.data.object?.permissions.list else { return }
                self?.hasOverwritePermissionRelay.accept(permissions.contains(PermissionEnum.blackboardEdit.string))
                
                let hasAdminRole = $0.data.object?.order?.teamRoleType == .ADMIN
                self?.hasAdminRoleRelay.accept(hasAdminRole)
            })
            .disposed(by: disposeBag)
        
        // receive error
        networkService.catchErrorDriver
            .compactMap { [weak self] errorInformation -> Output? in
                guard let self else { return nil }
                self.doEnableSaveButton()
                
                let requestType = errorInformation.requestType
                
                if requestType == ApiRouter.PostBlackboardRequest.self
                    || requestType == ApiRouter.PutBlackboardRequest.self {
                    return .showPostBlackboardErrorMessage
                } else if requestType == ApiRouter.BlackboardCommonSettingRequest.self {
                    self.canEditDate = false // ネットワークエラー時は一律変更不可とする
                    
                    let modernBlackboardMaterial = self.updatedModernBlackboardMaterialRelay.value?.blackboardMaterial
                        ?? self.initialModernBlackboardMaterial
                    let appearance = self.updatedModernBlackboardMaterialRelay.value?.appearance
                        ?? self.initialBlackboardViewAppearance
                    
                    // NOTE: 特にエラーメッセージは出さず、無加工の黒板データを元に次画面へ遷移させていく
                    switch self.tappedButtonTypeForBlackboardList {
                    case .edit:
                        self.tappedButtonTypeForBlackboardList = nil
                        return .returnToEditViewController(modernBlackboardMaterial, appearance)
                    case .blackboardImage, .takePhoto:
                        self.tappedButtonTypeForBlackboardList = nil
                        return .returnToTakeCameraViewController(
                            .init(
                                modernBlackboardMaterial: modernBlackboardMaterial,
                                modernBlackboardAppearance: appearance,
                                blackboardEditLogs: BlackboardEditLoggingHandler.blackboardTypes,
                                canEditBlackboardStyle: canEditBlackboardStyle,
                                blackboardSizeTypeOnServer: blackboardSizeTypeOnServer,
                                preferredPhotoFormat: preferredPhotoFormat
                            )
                        )
                    case .none:
                        if isOfflineMode {
                            return .showErrorMessage(error: .operationCouldNotBeCompleted)
                        } else {
                            // オンラインの場合は影響がわからないので、既存のまま nil を返す
                            return nil
                        }
                    }
                }
                return .showErrorMessage(error: isOfflineMode ? .operationCouldNotBeCompleted : .network)
            }
            .drive(onNext: { [weak self] in self?.outputRelay.accept($0) })
            .disposed(by: disposeBag)
        
        // receive sidekicks
        networkService.showLoadingDriver
            .drive(onNext: { [weak self] in self?.outputRelay.accept(.showLoadingView) })
            .disposed(by: disposeBag)

        networkService.hideLoadingDriver
            .drive(onNext: { [weak self] in self?.outputRelay.accept(.hideLoadingView) })
            .disposed(by: disposeBag)
    }
}

extension ModernEditBlackboardViewModel {
    var title: String {
        staticState.title
    }
    
    var initialBlackboardViewAppearance: ModernBlackboardAppearance {
        staticState.initialBlackboardViewAppearance
    }
    
    var initialModernBlackboardMaterial: ModernBlackboardMaterial {
        staticState.initialModernBlackboardMaterial
    }
    
    var hasMiniatureMapAtInit: Bool {
        let pattern = ModernBlackboardContentView.Pattern(
            by: staticState.initialModernBlackboardMaterial.layoutTypeID
        )
        return pattern?.hasMiniatureMapView ?? false
    }
    
    var editableScope: ModernEditBlackboardViewController.EditableScope {
        staticState.editableScope
    }
    
    var tappedMiniatureMapCellHandler: ModernBlackboardConfiguration.TappedMiniatureMapCellHandler {
        staticState.advancedOptions
            .compactMap { $0.tappedMiniatureMapCellHandler }
            .first
    }
}

// MARK: - private (event)
extension ModernEditBlackboardViewModel {
    private func viewDidLoadEvent() {
        getBlackboardCommonSetting()
    }
    
    private func didTapArrowButtonEvent() {
        outputRelay.accept(.endEditing)
    }
    
    private func didTapSelectBlackboardButtonEvent() {
        let tappedButtonType: TappedButtonType = .selectBlackboard
        
        outputRelay.accept(.endEditing)
        outputRelay.accept(
            beforeEditing
                ? .presentBlackboardListViewController(
                    .init(
                        orderID: staticState.orderID,
                        appBaseRequestData: networkService.appBaseRequestData,
                        snapshotData: staticState.snapshotData,
                        
                        // NOTE:
                        // 現在「カメラ画面で」選択中の黒板データを、黒板一覧上ではハイライトする必要があるため、
                        // このViewModelが生成時に渡された黒板データを、黒板一覧にも渡す
                        selectedBlackboard: staticState.initialModernBlackboardMaterial,
                        advancedOptions: staticState.advancedOptions,
                        isOfflineMode: isOfflineMode.value
                    )
                )
                : .showDestoryEditingBlackboardAlert(
                    okHandler: { [weak self] _ in self?.inputPort.accept(.didTapDestroyEditingBlackboardButton(tappedButtonType: tappedButtonType)) }
                )
        )
    }
    
    private func didTapCancelButtonEvent() {
        let tappedButtonType: TappedButtonType = .cancel
        
        outputRelay.accept(
            beforeEditing
                ? makeDismissOutput(shouldUseLatestData: false)
                : .showDestoryEditingBlackboardAlert(
                    okHandler: { [weak self] _ in self?.inputPort.accept(.didTapDestroyEditingBlackboardButton(tappedButtonType: tappedButtonType)) }
                )
        )
    }
    
    private func didTapSaveButtonEvent() {
        doDisableSaveButton()
        
        // ローカルでバリデーションチェックを行う
        guard !hasLocalValidateError() else {
            showValidateError()
            outputRelay.accept(.showValidateErrorAlert)
            doEnableSaveButton()
            return
        }
        
        // postが必要な編集内容かチェックを行う（黒板色 / 備考書式 / 透明度いずれかの変更で、それ以外は変更がない場合はpost不要）
        guard shouldPostBlackboard else {
            switch editableScope {
            case .all: // 撮影黒板編集の場合
                // NOTE: スタイルの変更（黒板色 / 備考書式 / 透明度など）だけでも、別画面に伝える必要があるので、
                outputRelay.accept(
                    makeDismissOutput(shouldUseLatestData: true)
                )
            case .onlyBlackboardItems: // 黒板編集の場合
                // NOTE: 撮影黒板編集と違い、スタイルの変更を別画面に伝える必要がない（そもそもユーザーの意思で変更できない）ため、
                // -> nilを渡す
                outputRelay.accept(.dismiss(nil))
            }
            doEnableSaveButton()
            return
        }

        // NOTE: ここから先はオフラインモードかどうかで処理がわかれます。

        if isOfflineMode.value {
            doEnableSaveButton()
            saveOfflineBlackboardIfNeeded()
        } else {
            // 上書き保存アラートを出す or そのままコピー新規保存するか確認 (オンラインモード)
            shouldShowOverwriteOrCreateNewAlert()
        }
    }

    /// オフラインモード時の編集保存処理を実行する
    ///
    /// - Note: 本メソッドはオフラインモードでのみ使用される想定です。
    private func saveOfflineBlackboardIfNeeded() {
        assert(isOfflineMode.value)

        Task<_, Never> { @MainActor in
            guard let blackboardMaterial = self.updatedModernBlackboardMaterialRelay.value?.blackboardMaterial else {
                return
            }

            do {
                // ユーザID, 案件IDで黒板全件検索し、同じ黒板が存在していないか確認する。同じ黒板があった場合は重複扱いとなる。
                let duplicatedBlackboard = try OfflineStorageHandler.shared.blackboard.duplicatedBlackboard(
                    with: blackboardMaterial,
                    userID: self.staticState.snapshotData.userID,
                    orderID: self.staticState.orderID
                )

                if let duplicatedBlackboard {
                    // 重複の場合はアラートを出す
                    showDuplicateAlert(editableScope: editableScope) { [weak self] _ in
                        self?.updateBlackboardMaterialAndDismiss(with: duplicatedBlackboard)
                    }
                } else {
                    // 重複してなければコピー新規で保存する
                    let now = Date()
                    let copiedBlackboard = try OfflineStorageHandler.shared.blackboard.createBlackboardCopy(
                        userID: self.staticState.snapshotData.userID,
                        orderID: self.staticState.orderID,
                        layoutTypeID: blackboardMaterial.layoutTypeID,
                        contents: blackboardMaterial.items,
                        miniatureMap: blackboardMaterial.miniatureMap,
                        // NOTE: 黒板レイアウトを変更した場合は新規作成になるため、各種日付が入らない。
                        // そのため、日付が入ってない場合は現在時刻をセットするようにする。
                        creationDateOnServer: blackboardMaterial.createdAt ?? now,
                        modificationDateOnServer: blackboardMaterial.updatedAt ?? now,
                        // 起点となるコピー元黒板の黒板IDを保存する
                        originalBlackboardID: {
                            if blackboardMaterial.originalBlackboardID != nil {
                                // コピー元黒板にoriginal_blackboard_idが設定されている場合
                                blackboardMaterial.originalBlackboardID
                            } else if blackboardMaterial.id >= 0 {
                                // コピー元黒板の黒板IDが正の数の場合
                                blackboardMaterial.id
                            } else {
                                // それ以外の場合、差し込み対応の対象外となる
                                // 例）差し込み対応のリリース前にオフラインモードでコピー新規した黒板をコピー元とする場合
                                nil
                            }
                        }()
                    )

                    if let copiedBlackboard {
                        BlackboardEditLoggingHandler.add(type: .posted(.copy, blackboardID: copiedBlackboard.id))
                        updateBlackboardMaterialAndDismiss(with: copiedBlackboard)
                    }
                }
            } catch {
                self.outputRelay.accept(.showErrorMessage(error: .operationCouldNotBeCompleted))
            }
        }
    }

    /// blackboardMaterial の更新と黒板詳細画面への遷移を行う
    private func updateBlackboardMaterialAndDismiss(with blackboardMaterial: ModernBlackboardMaterial) {
        updateBlackboardMaterial(by: blackboardMaterial.id)
        // 黒板詳細画面へ遷移
        outputRelay.accept(
            makeDismissOutput(shouldUseLatestData: true)
        )
    }
    
    private func didTapCellEvent() {
        outputRelay.accept(.endEditing)
    }
    
    private func didTapDestroyEditingBlackboardButtonEvent(tappedButtonType: TappedButtonType) {
        var outputEvent: Output
        switch tappedButtonType {
        case .cancel:
            outputEvent = makeDismissOutput(shouldUseLatestData: false)
        case .selectBlackboard:
            outputEvent = .presentBlackboardListViewController(
                .init(
                    orderID: staticState.orderID,
                    appBaseRequestData: networkService.appBaseRequestData,
                    snapshotData: staticState.snapshotData,

                    // NOTE:
                    // 現在「カメラ画面で」選択中の黒板データを、黒板一覧上ではハイライトする必要があるため、
                    // このViewModelが生成時に渡された黒板データを、黒板一覧にも渡す
                    selectedBlackboard: staticState.initialModernBlackboardMaterial,
                    advancedOptions: staticState.advancedOptions,
                    isOfflineMode: isOfflineMode.value
                )
            )
        case .selectBlackboardLayout:
            outputEvent = .presentBlackboardLayoutListViewController
        }
        outputRelay.accept(outputEvent)
        
        switch tappedButtonType {
        case .cancel, .selectBlackboardLayout:
            break
        case .selectBlackboard:
            // 初期状態の黒板をセットし直す
            updatedModernBlackboardMaterialRelay.accept(
                .init(
                    blackboardMaterial: staticState.initialModernBlackboardMaterial,
                    appearance: staticState.initialBlackboardViewAppearance
                )
            )
            guard let materialAndAppearance = updatedModernBlackboardMaterialRelay.value else { return }
            loadMiniatureMapImageIfNeeded(miniatureMap: materialAndAppearance.blackboardMaterial.miniatureMap) { [weak self] in
                self?.setItems(
                    materialAndAppearance: materialAndAppearance,
                    miniatureMapImageState: $0
                )
            }
        }
    }
    
    private func didTapSelectLayoutButtonEvent() {
        let tappedButtonType: TappedButtonType = .selectBlackboardLayout
        
        outputRelay.accept(.endEditing)
        
        // NOTE: 編集画面の場合、新規作成画面とは異なり「編集済みか否か」に関わらず編集内容がリセットされる旨のアラートを表示させる
        outputRelay.accept(
            .showWillSelectNewLayoutAlert(
                okHandler: { [weak self] _ in self?.inputPort.accept(.didTapDestroyEditingBlackboardButton(tappedButtonType: tappedButtonType)) }
            )
        )
    }
    
    private func receiveNewLayoutPatternEvent(pattern: ModernBlackboardContentView.Pattern) {
        localValidateErrorData = nil
        updateOriginalBlackboardMaterial(pattern: pattern)
        
        // 上記のように、黒板レイアウトから黒板データを作成 / 更新した場合、黒板idなど一部パラメータが空の状態になる
        //
        // （新規作成などであれば問題ないが）
        // 上書き保存の時など、黒板idが無いと困るケースがあるため、元の黒板idを更新した黒板データに対し付与し直す
        updateBlackboardMaterial(by: staticState.initialModernBlackboardMaterial.id)
        
        getBlackboardCommonSetting()
    }
    
    private func didTapBlackboardImageButtonEventInBlackboardListView(modernBlackboardMaterial: ModernBlackboardMaterial) {
        guard ModernBlackboardContentView.Pattern(by: modernBlackboardMaterial.layoutTypeID) != nil else {
            // 未定義黒板の場合は、AppStoreへ誘導する
            outputRelay.accept(.showAppStoreAlert)
            return
        }
        
        tappedButtonTypeForBlackboardList = .blackboardImage
        replace(
            blackboardMaterial: modernBlackboardMaterial,
            // 黒板設定APIのレスポンスによりappearanceが変わる可能性があるので、この時点ではreplaceしない（nilを渡す）
            blackboardViewAppearance: nil
        )
        getBlackboardCommonSetting()
    }
    
    private func didTapEditButtonEventInBlackboardListView(modernBlackboardMaterial: ModernBlackboardMaterial) {
        tappedButtonTypeForBlackboardList = .edit
        replace(
            blackboardMaterial: modernBlackboardMaterial,
            // 黒板設定APIのレスポンスによりappearanceが変わる可能性があるので、この時点ではreplaceしない（nilを渡す）
            blackboardViewAppearance: nil
        )
        getBlackboardCommonSetting()
    }
    
    private func didTapTakePhotoButtonEventInBlackboardListView(modernBlackboardMaterial: ModernBlackboardMaterial) {
        tappedButtonTypeForBlackboardList = .takePhoto
        replace(
            blackboardMaterial: modernBlackboardMaterial,
            // 黒板設定APIのレスポンスによりappearanceが変わる可能性があるので、この時点ではreplaceしない（nilを渡す）
            blackboardViewAppearance: nil
        )
        getBlackboardCommonSetting()
    }

    /// dismiss時に渡すデータを生成する
    ///
    /// - Parameters:
    ///     - shouldUseLatestData:
    ///         - `true` : すべて最新のデータを使う
    ///         - `false` : 黒板情報と黒板アピアランスは初期のデータを使い、他のスタイル関連プロパティは最新のデータを使う
    /// - Returns: dismiss時に渡すデータ
    private func makeDismissOutput(shouldUseLatestData: Bool) -> Output {
        // 黒板情報と黒板アピアランスの取得
        let material: ModernBlackboardMaterial
        let appearance: ModernBlackboardAppearance

        if shouldUseLatestData {
            // 最新のデータを使う
            material = updatedModernBlackboardMaterialRelay.value?.blackboardMaterial ?? initialModernBlackboardMaterial
            appearance = updatedModernBlackboardMaterialRelay.value?.appearance ?? initialBlackboardViewAppearance
        } else {
            // 初期のデータを使う
            material = initialModernBlackboardMaterial
            appearance = initialBlackboardViewAppearance
        }

        return .dismiss(
            .init(
                modernBlackboardMaterial: material,
                modernBlackboardAppearance: appearance,
                blackboardEditLogs: BlackboardEditLoggingHandler.blackboardTypes,
                canEditBlackboardStyle: canEditBlackboardStyle,
                blackboardSizeTypeOnServer: blackboardSizeTypeOnServer,
                preferredPhotoFormat: preferredPhotoFormat
            )
        )
    }
}

// MARK: - private (fetch)
extension ModernEditBlackboardViewModel {
    private func getBlackboardCommonSetting() {
        networkService.getBlackboardCommonSetting(orderID: staticState.orderID)
    }
}

// MARK: - private (post / put)
extension ModernEditBlackboardViewModel {
    /// postが必要な編集内容か（工事名 / 撮影日 / 施工者 / 黒板色 / 備考書式 / 透明度いずれかの変更で、それ以外は変更がない場合はpost不要）
    private var shouldPostBlackboard: Bool {
        !beforeEditingWithoutAppearance
    }
    
    private func postBlackboard(blackboardMaterial: ModernBlackboardMaterial) {
        networkService.postNewBlackboard(
            blackboardMaterial: blackboardMaterial,
            type: .copy, // NOTE: コピー新規 = .copy
            orderID: staticState.orderID
        )
    }
    
    private func putBlackboard(blackboardMaterial: ModernBlackboardMaterial) {
        networkService.putBlackboard(blackboardMaterial: blackboardMaterial, orderID: staticState.orderID)
    }
}

// MARK: - private (validation)
extension ModernEditBlackboardViewModel {
    private func hasLocalValidateError() -> Bool {
        
        var errorTexts: [String] = []
        var errorItems: [ModernBlackboardMaterial.Item] = []

        guard let items = updatedModernBlackboardMaterialRelay.value?.blackboardMaterial.items,
              let layoutTypeID = updatedModernBlackboardMaterialRelay.value?.blackboardMaterial.layoutTypeID,
              let pattern = ModernBlackboardContentView.Pattern(by: layoutTypeID) else { return false }
        // NOTE: 「撮影日」を除外したitemを対象にする
        let itemsWithoutDate = items.filter { pattern.specifiedPosition(by: .date) != $0.position }
        
        // NOTE: バリデーションチェック処理
        
        // 1：未入力チェック（項目名のみ）
        // 「すべての項目名を入力してください」
        
        let emptyNameItems = itemsWithoutDate.filter { $0.itemName.isEmpty }
        if !emptyNameItems.isEmpty {
            errorTexts.append(L10n.Blackboard.Edit.Validate.shouldinputAllBlackboardItemName)
            errorItems.append(contentsOf: emptyNameItems)
        }

        // 2：入力内容の重複チェック（項目名のみ）
        //
        // -> 現状の仕様では実施しないこととなりました
        // https://88oct.slack.com/archives/C01CG2FGM6H/p1645676929724879
        
        // 3：文字数制限
        // 「項目名は10文字以内で入力してください」
        // 「項目内容は30文字以内で入力してください」
        // 「備考欄は200文字以内で入力してください」
        // 「工事名は254文字以内で入力してください」
        // 「施工者名は30文字以内で入力してください」
        //
        // ※ なお、これのみ特別扱いで、強制エラー表記の対象としない
        //
        
        let constructionPosition = pattern.specifiedPosition(by: .constructionName)
        let memoPosition = pattern.specifiedPosition(by: .memo)
        let datePosition = pattern.specifiedPosition(by: .date)
        let constructionPlayerPosition = pattern.specifiedPosition(by: .constructionPlayer)
        
        func setMaxLengthErrorIFNeeded(
            itemNameLength: Int = 0,
            bodyLength: Int = 0,
            itemNameMaxLength: Int = 0,
            bodyMaxLength: Int = 0,
            itemNameErrorText: String = "",
            bodyErrorText: String = ""
        ) {
            // それぞれ対応するエラー文言がない場合は、文字長チェックを行わない
            if !itemNameErrorText.isEmpty {
                if itemNameLength > itemNameMaxLength {
                    errorTexts.append(itemNameErrorText)
                }
            }
            if !bodyErrorText.isEmpty {
                if bodyLength > bodyMaxLength {
                    errorTexts.append(bodyErrorText)
                }
            }
        }
        
        itemsWithoutDate.forEach { item in
            switch item.position {
            case constructionPosition:
                setMaxLengthErrorIFNeeded(
                    itemNameLength: item.itemName.count,
                    bodyLength: item.body.count,
                    itemNameMaxLength: 10,
                    bodyMaxLength: 254,
                    itemNameErrorText: L10n.Blackboard.Edit.Validate.shouldinputWithin10charsInBlackboardItemName,
                    bodyErrorText: L10n.Blackboard.Edit.Validate.shouldinputWithin254charsInConstructionName
                )
            case memoPosition:
                setMaxLengthErrorIFNeeded(
                    bodyLength: item.body.count,
                    bodyMaxLength: 200,
                    bodyErrorText: L10n.Blackboard.Edit.Validate.shouldinputWithin200charsInMemo
                )
            case datePosition:
                break // 「撮影日」は文字数制限の対象外のため、何もしない
            case constructionPlayerPosition:
                setMaxLengthErrorIFNeeded(
                    bodyLength: item.body.count,
                    bodyMaxLength: 30,
                    bodyErrorText: L10n.Blackboard.Edit.Validate.shouldinputWithin30charsInConstructionPlayerName
                )
            default:
                setMaxLengthErrorIFNeeded(
                    itemNameLength: item.itemName.count,
                    bodyLength: item.body.count,
                    itemNameMaxLength: 10,
                    bodyMaxLength: 30,
                    itemNameErrorText: L10n.Blackboard.Edit.Validate.shouldinputWithin10charsInBlackboardItemName,
                    bodyErrorText: L10n.Blackboard.Edit.Validate.shouldinputWithin30charsInBlackboardItemValue
                )
            }
        }
        
        guard let uniqueErrorTexts = NSOrderedSet(array: errorTexts).array as? [String],
              let uniqueErrorItems = NSOrderedSet(array: errorItems).array as? [ModernBlackboardMaterial.Item] else { return false }

        let forceWarningInputsCellDatas = uniqueErrorItems
            .map {
                ForceWarningInputsCellData(
                    position: $0.position,
                    // NOTE: 強制エラー表記の対象はいずれも「項目名」のみのため、フラグは以下となる
                    isItemName: true,
                    isBody: false
                )
            }
        
        localValidateErrorData = .init(
            strings: uniqueErrorTexts,
            forceWarningInputsCellDatas: forceWarningInputsCellDatas
        )
        
        return !uniqueErrorTexts.isEmpty
    }
    
    private func showValidateError() {
        loadMiniatureMapImageIfNeeded(miniatureMap: miniatureMap) { [weak self] in
            // （エラー文言をセットするため）setUpdatedItemsする
            self?.setUpdatedItems(miniatureMapImageState: $0)
        }
    }
}

// MARK: - private (sidekick)
extension ModernEditBlackboardViewModel {
    private func doEnableSaveButton() {
        outputRelay.accept(.updateSaveButtonState(isEnabled: true))
    }
    
    private func doDisableSaveButton() {
        outputRelay.accept(.updateSaveButtonState(isEnabled: false))
    }
}

// MARK: - private (etc)
extension ModernEditBlackboardViewModel {
    /// NOTE: オフラインモードでは本メソッドは呼ばれない。
    private func shouldShowOverwriteOrCreateNewAlert() {
        // 1. 内部ロジック上、上書き保存の権限を持っているか確認
        guard staticState.editableScope.hasOverwriteBlackboardLocalPermission else {
            doEnableSaveButton()
            shouldShowOverwriteOrCreateNewAlertRelay.accept(false)
            return
        }
        
        // 2. アカウントに対して編集（ = 上書き保存）権限があるか確認
        networkService.getOrderPermissions(orderID: staticState.orderID)
        
        // 3. 黒板が自身の作成したものか、また写真枚数が0枚か確認
        networkService.getBlackboardDetail(
            throttleConfiguration: .disable,
            orderID: staticState.orderID,
            blackboardID: staticState.initialModernBlackboardMaterial.id
        )
        
        doEnableSaveButton()
    }
    
    /// 起点となる黒板情報（ = 編集中か判定するための、元のデータとなる）を更新
    private func updateOriginalBlackboardMaterial(pattern: ModernBlackboardContentView.Pattern) {
        // 新しいレイアウト情報を元に画面を更新する
        let newModernBlackboardMaterial = ModernBlackboardMaterial(
            layout: .init(
                pattern: pattern,
                theme: staticState.initialBlackboardViewAppearance.theme
            )
        )
        
        let updatedModernBlackboardMaterial = newModernBlackboardMaterial.updating(
            by: staticState.snapshotData,
            shouldForceUpdateConstructionName: false
        )
        updatedModernBlackboardMaterialRelay.accept(
            .init(
                blackboardMaterial: updatedModernBlackboardMaterial,
                appearance: staticState.initialBlackboardViewAppearance
            )
        )
    }
    
    private func updateBlackboardMaterial(by blackboardID: Int) {
        let original = updatedModernBlackboardMaterialRelay.value
            ?? .init(
                blackboardMaterial: staticState.initialModernBlackboardMaterial,
                appearance: staticState.initialBlackboardViewAppearance
            )
        
        updatedModernBlackboardMaterialRelay.accept(
            .init(
                blackboardMaterial: original.blackboardMaterial.updating(by: blackboardID),
                appearance: original.appearance
            )
        )
    }
    
    private func updateBlackboardMaterial(by blackboardItems: [ModernBlackboardMaterial.Item]) {
        let original = updatedModernBlackboardMaterialRelay.value
            ?? .init(
                blackboardMaterial: staticState.initialModernBlackboardMaterial,
                appearance: staticState.initialBlackboardViewAppearance
            )
        
        updatedModernBlackboardMaterialRelay.accept(
            .init(
                blackboardMaterial: original.blackboardMaterial.updating(by: blackboardItems),
                appearance: original.appearance
            )
        )
    }
    
    private func updateBlackboardMaterial(
        by blackboardMaterial: ModernBlackboardMaterial,
        appearance: ModernBlackboardAppearance
    ) {
        updatedModernBlackboardMaterialRelay.accept(
            .init(blackboardMaterial: blackboardMaterial, appearance: appearance)
        )
        loadMiniatureMapImageIfNeeded(miniatureMap: miniatureMap) { [weak self] in
            // （エラー文言をセットするため）setUpdatedItemsする
            self?.setUpdatedItems(miniatureMapImageState: $0)
        }
    }
    
    private func updateBlackboardMaterial(by target: EditableBlackboardDataProtocol) {
        outputRelay.accept(.endEditing)
        
        let original = updatedModernBlackboardMaterialRelay.value
            ?? .init(
                blackboardMaterial: staticState.initialModernBlackboardMaterial,
                appearance: staticState.initialBlackboardViewAppearance
            )
        
        if let memoStyleSelectedValue = target as? ModernMemoStyleCell.SelectedValue {
            updatedModernBlackboardMaterialRelay.accept(
                .init(
                    blackboardMaterial: original.blackboardMaterial,
                    appearance: original.appearance.updating(
                        by: .init(
                            textColor: original.appearance.memoStyleArguments.textColor,
                            adjustableMaxFontSize: memoStyleSelectedValue.adjustableMaxFontSize,
                            verticalAlignment: memoStyleSelectedValue.verticalAlignment,
                            horizontalAlignment: memoStyleSelectedValue.horizontalAlignment
                        )
                    )
                )
            )
        } else if let theme = target as? ModernBlackboardAppearance.Theme {
            updatedModernBlackboardMaterialRelay.accept(
                .init(
                    blackboardMaterial: original.blackboardMaterial.updating(by: theme),
                    appearance: original.appearance.updating(by: theme)
                )
            )
        } else if let alphaLevel = target as? ModernBlackboardAppearance.AlphaLevel {
            updatedModernBlackboardMaterialRelay.accept(
                .init(
                    blackboardMaterial: original.blackboardMaterial,
                    appearance: original.appearance.updating(by: alphaLevel)
                )
            )
        } else {
            assertionFailure("EditableBlackboardDataProtocolに準拠していますが、想定していないデータをキャッチしました")
        }
        loadMiniatureMapImageIfNeeded(miniatureMap: miniatureMap) { [weak self] in
            // （エラー文言をセットするため）setUpdatedItemsする
            self?.setUpdatedItems(miniatureMapImageState: $0)
        }
    }
    
    /// 現在表示している黒板データ、黒板アピアランスを別データに置き換える（ただしinitial時の黒板データ、黒板アピアランスは変えない）
    private func replace(blackboardMaterial: ModernBlackboardMaterial, blackboardViewAppearance: ModernBlackboardAppearance?) {
        updatedModernBlackboardMaterialRelay.accept(
            .init(
                blackboardMaterial: blackboardMaterial,
                appearance: blackboardViewAppearance
                    ?? updatedModernBlackboardMaterialRelay.value?.appearance
                    ?? staticState.initialBlackboardViewAppearance
            )
        )
        loadMiniatureMapImageIfNeeded(miniatureMap: miniatureMap) { [weak self] in
            // （エラー文言をセットするため）setUpdatedItemsする
            self?.setUpdatedItems(miniatureMapImageState: $0)
        }
    }

    private func setItems(
        materialAndAppearance: MaterialAndAppearance,
        miniatureMapImageState: MiniatureMapImageState?
    ) {
        guard let pattern = ModernBlackboardContentView.Pattern(by: materialAndAppearance.blackboardMaterial.layoutTypeID) else {
            fatalError("layout IDを特定できず、画面生成できません。")
        }
        
        // NOTE: cellDatasには必ず全タイプのデータを追加する
        //  -> 表示の必要のないセルについては、heightを0にすることで非表示化しているので注意

        // 黒板項目入力欄用、グレーアウト（非活性）領域の設定
        let disabledCase: ModernBlackboardItemInputsCell.DisabledInputsCase
        switch editableScope {
        case .all: // 撮影黒板編集の場合
            disabledCase = canEditDate
                ? .onlyConstructionItemName    // 工事名（項目名）のみグレーアウト
                : .constructionItemNameAndDate // 工事名（項目名）、撮影日をグレーアウト
        case .onlyBlackboardItems: // 黒板編集の場合
            // 工事名、撮影日、施工者名（項目名および項目内容）3点をグレーアウト
            disabledCase = .constructionNameAndDateAndConstructionPlayer
        }
        
        let cellDatas: [DataSource.CellData?] = [
            // apiエラー表示
            .errors(
                .init(
                    parentType: .editModernBlackboard(editableScope),
                    errorTexts: localValidateErrorData?.strings ?? [],
                    initialPattern: pattern
                )
            ),
            // 黒板項目グループ
            .blackboardItems(
                .init(
                    modernBlackboardMaterial: materialAndAppearance.blackboardMaterial,
                    forceWarningInputsCellDatas: localValidateErrorData?.forceWarningInputsCellDatas ?? [],
                    disabledCase: disabledCase,
                    constructionNameShouldBeEditableSignal: constructionNameShouldBeEditableRelay.asSignal(onErrorJustReturn: (true, false))
                )
            ),
            // 豆図
            .miniatureMap(
                pattern.hasMiniatureMapView
                    ? miniatureMapImageState
                    : nil
            ),
            // 備考書式設定
            .memoStyle(
                .init(
                    initialSelectedValue: .init(
                        adjustableMaxFontSize: materialAndAppearance.appearance.memoStyleArguments.adjustableMaxFontSize,
                        verticalAlignment: materialAndAppearance.appearance.memoStyleArguments.verticalAlignment,
                        horizontalAlignment: materialAndAppearance.appearance.memoStyleArguments.horizontalAlignment
                    ),
                    canEditBlackboardStyle: canEditBlackboardStyle
                )
            ),
            // 黒板色（権限を保持してる場合に限りセル表示）
            .theme(
                .init(
                    theme: materialAndAppearance.appearance.theme,
                    canEditBlackboardStyle: canEditBlackboardStyle
                )
            ),
            // 透過度
            .alpha(.init(
                alphaLevel: materialAndAppearance.appearance.alphaLevel,
                canEditBlackboardStyle: canEditBlackboardStyle
            ))
        ]
        
        items.accept([.init(items: cellDatas.compactMap { $0 })])
    }
    
    private func setUpdatedItems(miniatureMapImageState: MiniatureMapImageState?) {
        guard let materialAndAppearance = updatedModernBlackboardMaterialRelay.value else {
            assertionFailure()
            return
        }
        setItems(
            materialAndAppearance: materialAndAppearance,
            miniatureMapImageState: miniatureMapImageState
        )
    }
    
    /// 黒板WebViewをロードするためのクエリを生成する。
    private func makeBlackboardWebViewQuery(
        blackboardMaterial: ModernBlackboardMaterial,
        blackboardAppearance: ModernBlackboardAppearance
    ) async throws -> String {
        let blackboardContent = try ModernBlackboardContent(
            material: blackboardMaterial,
            theme: blackboardMaterial.blackboardTheme,
            memoStyleArguments: blackboardAppearance.memoStyleArguments,
            dateFormatType: blackboardAppearance.dateFormatType,
            alphaLevel: blackboardAppearance.alphaLevel,
            miniatureMapImageState: nil,
            displayStyle: .normal(shouldSetCornerRounder: false),
            shouldBeReflectedNewLine: blackboardAppearance.shouldBeReflectedNewLine
        )
        let blackboardProps = await BlackboardProps(
            blackboardContent: blackboardContent,
            size: previewWebViewSize,
            // 黒板詳細では豆図画像を実際のサイズで表示する
            miniatureMapImageType: .rawImage,
            shouldShowMiniatureMapFromLocal: isOfflineMode.value,
            isShowEmptyMiniatureMap: false,
            // 黒板詳細では、豆図の部分が、豆図画像ロード前の画像か豆図登録なしの画像の場合、非表示にしない。
            isHiddenNoneAndEmptyMiniatureMap: false,
            shouldShowPlaceholder: true
        )
        return try blackboardProps.makeQueryParameter()
    }

    func updatePreviewWebViewSize(_ size: CGSize) {
        self.previewWebViewSize = size
    }

    func makeInitialBlackboardWebViewQuery() async -> String? {
        do {
            return try await makeBlackboardWebViewQuery(
                blackboardMaterial: initialModernBlackboardMaterial,
                blackboardAppearance: initialBlackboardViewAppearance
            )
        } catch {
            outputRelay.accept(.showErrorMessage(error: .operationCouldNotBeCompleted))
            return nil
        }
    }
}

// MARK: - for Miniature Map（豆図）
extension ModernEditBlackboardViewModel {
    private var miniatureMap: ModernBlackboardMaterial.MiniatureMap? {
        if let updatedBlackboardMaterial = updatedModernBlackboardMaterialRelay.value?.blackboardMaterial {
            return updatedBlackboardMaterial.miniatureMap
        } else {
            return staticState.initialModernBlackboardMaterial.miniatureMap
        }
    }

    /// 豆図画像のロード処理。
    ///
    /// - Note: オフラインモード時はローカルから取得します。
    private func loadMiniatureMapImageIfNeeded(miniatureMap: ModernBlackboardMaterial.MiniatureMap?, completion: @escaping (MiniatureMapImageState?) -> Void) {
        guard let miniatureMap else {
            miniatureMapImageStateRelay.accept(.noURL(useCameraView: false))
            completion(.noURL(useCameraView: false))
            return
        }

        guard isOfflineMode.value else {
            // オンライン用の処理
            loadMiniatureMapImageFromAPI(imageUrl: miniatureMap.imageURL, completion: completion)
            return
        }

        let currentMiniatureMapImageState = miniatureMapImageStateRelay.value

        Task { @MainActor in
            switch currentMiniatureMapImageState {
            case .loadSuccessful, .loadFailed, .noURL:
                // ロード成功、失敗、またurlが無い場合は再リクエストしない
                // （現状、この画面内で豆図のurlが変わることはないため）
                completion(currentMiniatureMapImageState)
            case .none, .beforeLoading:
                let miniatureMapID = miniatureMap.id
                guard let image = OfflineStorageHandler.shared.blackboard.fetchMiniatureMap(withID: miniatureMapID, imageType: .rawImage) else {
                    completion(.loadFailed)
                    return
                }
                self.miniatureMapImageStateRelay.accept(.loadSuccessful(image))
                completion(.loadSuccessful(image))
            }
        }
    }
    
    /// APIから豆図画像をロードする。
    private func loadMiniatureMapImageFromAPI(imageUrl: URL?, completion: @escaping (MiniatureMapImageState?) -> Void) {
        guard let imageUrl else {
            miniatureMapImageStateRelay.accept(.noURL(useCameraView: false))
            completion(.noURL(useCameraView: false))
            return
        }
        
        let currentMiniatureMapImageState = miniatureMapImageStateRelay.value
        
        switch currentMiniatureMapImageState {
        case .loadSuccessful, .loadFailed, .noURL:
            // ロード成功、失敗、またurlが無い場合は再リクエストしない
            // （現状、この画面内で豆図のurlが変わることはないため）
            completion(currentMiniatureMapImageState)
        case .none, .beforeLoading:
            MiniatureMapImageLoader.load(
                imageUrl: imageUrl,
                // ネットワークの状態を確認（オフライン時は失敗扱いとする）
                shouldCheckNetworkStatusBeforeLoading: true,
                completion: { [weak self] in
                    self?.miniatureMapImageStateRelay.accept($0)
                    completion($0)
                }
            )
        }
    }
}

private extension ModernEditBlackboardViewModel {
    /// 重複アラートを表示する
    func showDuplicateAlert(
        editableScope: ModernEditBlackboardViewController.EditableScope,
        confirmBlackboardHandler: @escaping (UIAlertAction) -> Void
    ) {
        let viewType: UIAlertController.DuplicateBlackboardAlertViewType
        switch editableScope {
        case .all:
            viewType = .editModernBlackboardByCamera
        case .onlyBlackboardItems:
            viewType = .editModernBlackboard
        }

        outputRelay.accept(
            .showDuplicateBlackboardAlert(
                viewType: viewType,
                confirmBlackboardHandler: confirmBlackboardHandler
            )
        )
    }
}

// MARK: - LocalValidateErrorData
struct LocalValidateErrorData {
    let strings: [String]
    let forceWarningInputsCellDatas: [ForceWarningInputsCellData]
}

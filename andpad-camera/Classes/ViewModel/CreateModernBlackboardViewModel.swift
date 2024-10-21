//
//  CreateModernBlackboardViewModel.swift
//  andpad-camera
//
//  Created by msano on 2022/04/06.
//

import RxCocoa
import RxSwift

public final class CreateModernBlackboardViewModel {
    typealias DataSource = CreateModernBlackboardDataSource
    
    // MARK: - define Inputs, Outputs
    enum Input {
        case viewDidLoad
        case updateBlackboardItems([ModernBlackboardMaterial.Item])
        case didTapArrowButton
        case didTapCancelButton
        case didTapSaveButton
        case didTapCell
        case didTapSelectLayoutButton
        case didTapDestroyEditingBlackboardButton(fromCancelButton: Bool)
        case receiveNewLayoutPattern(ModernBlackboardContentView.Pattern)
    }
    
    enum Output {
        case changeSaveButtonState(isEnabled: Bool)
        case updatePreview(MaterialAndAppearance)
        case updateWebPreview(query: String)
        case dismiss(CreateModernBlackboardViewController.CompletedHandlerData?)
        case endEditing
        case presentBlackboardLayoutListViewController  // swiftlint:disable:this identifier_name
        case showErrorMessage
        case showPostBlackboardErrorMessage
        case showLoadingView
        case hideLoadingView
        case showValidateErrorAlert
        case showDuplicateBlackboardAlert(confirmBlackboardHandler: (UIAlertAction) -> Void)
        case showDestoryEditingBlackboardAlert(fromCancelButton: Bool, okHandler: (UIAlertAction) -> Void)
        case updateSaveButtonState(isEnabled: Bool)
    }

    private struct StaticState {
        let orderID: Int
        let title: String = L10n.Blackboard.Create.title
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
    }
    
    let inputPort: RxCocoa.PublishRelay<Input> = .init()
    let outputPort: RxCocoa.ControlEvent<Output>
    let dataSource = DataSource()
    let items = BehaviorRelay<[DataSource.Section]>(value: [])

    /// Remote Config で取得した設定情報
    private let remoteConfig: (any AndpadCameraDependenciesRemoteConfigProtocol)?

    /// 黒板レイアウトのサイズ
    ///
    /// - Note: ここで保持した黒板サイズ情報は WebView の表示に使用されます。
    private var blackboardLayoutSize: CGSize?

    /// 表示統一対応用の黒板レイアウトを利用するかどうか
    ///
    /// - Note: 従来式のレイアウトを利用しなくなった場合は本フラグは利用しなくなる。
    var useBlackboardGeneratedWithSVG: Bool {
        remoteConfig?.fetchUseBlackboardGeneratedWithSVG() ?? false
    }

    private let networkService: ModernBlackboardNetworkServiceProtocol
    private let staticState: StaticState
    private let updatedModernBlackboardMaterialRelay = BehaviorRelay<MaterialAndAppearance?>(value: nil)
    private let disposeBag = DisposeBag()
    private let outputRelay: PublishRelay<Output>
    
    private var snapshotData: SnapshotData
    private var _originalModernBlackboardMaterial: ModernBlackboardMaterial {
        didSet {
            updatedModernBlackboardMaterialRelay.accept(
                .init(
                    blackboardMaterial: _originalModernBlackboardMaterial,
                    appearance: _originalBlackboardViewAppearance
                )
            )
        }
    }
    private var _originalBlackboardViewAppearance: ModernBlackboardAppearance {
        didSet {
            updatedModernBlackboardMaterialRelay.accept(
                .init(
                    blackboardMaterial: _originalModernBlackboardMaterial,
                    appearance: _originalBlackboardViewAppearance
                )
            )
        }
    }
    
    struct MaterialAndAppearance {
        let blackboardMaterial: ModernBlackboardMaterial
        let appearance: ModernBlackboardAppearance
    }
    
    private var beforeEditing: Bool {
        guard let updatedModernBlackboardMaterial = updatedModernBlackboardMaterialRelay.value?.blackboardMaterial,
              let updatedAppearance = updatedModernBlackboardMaterialRelay.value?.appearance else { return true }
        return updatedModernBlackboardMaterial == _originalModernBlackboardMaterial
            && updatedAppearance == _originalBlackboardViewAppearance
    }
    
    private var canEditBlackboardStyle = false
    private var localValidateErrorData: LocalValidateErrorData?
    
    init(
        networkService: ModernBlackboardNetworkServiceProtocol,
        orderID: Int,
        snapshotData: SnapshotData,
        advancedOptions: [ModernBlackboardConfiguration.AdvancedOption],
        blackboardViewAppearance: ModernBlackboardAppearance,
        shouldResetBlackboardEditLoggingHandler: Bool,
        remoteConfig: (any AndpadCameraDependenciesRemoteConfigProtocol)? = AndpadCameraDependencies.shared.remoteConfigHandler
    ) {
        // MARK: - configure Outputs
        let relay = PublishRelay<Output>()
        self.outputPort = .init(events: relay)
        self.outputRelay = relay
        self.networkService = networkService
        self.snapshotData = snapshotData
        self._originalBlackboardViewAppearance = blackboardViewAppearance
        self.remoteConfig = remoteConfig

        self.staticState = .init(
            orderID: orderID,
            advancedOptions: advancedOptions
        )
        
        // NOTE: 新規作成の場合、init時はpattern1の黒板レイアウトをセットする
        self._originalModernBlackboardMaterial = .init(
            layout: .init(
                pattern: .pattern1,
                theme: _originalBlackboardViewAppearance.theme
            )
        )
        .updating(
            by: self.snapshotData,
            shouldForceUpdateConstructionName: false
        )
        
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
                case .didTapArrowButton:
                    self?.didTapArrowButtonEvent()
                case .didTapCancelButton:
                    self?.didTapCancelButtonEvent()
                case .didTapSaveButton:
                    self?.didTapSaveButtonEvent()
                case .didTapCell:
                    self?.didTapCellEvent()
                case .didTapSelectLayoutButton:
                    self?.didTapSelectLayoutButtonEvent()
                case .didTapDestroyEditingBlackboardButton(let fromCancelButton):
                    self?.didTapDestroyEditingBlackboardButtonEvent(fromCancelButton: fromCancelButton)
                case .receiveNewLayoutPattern(let pattern):
                    self?.receiveNewLayoutPatternEvent(pattern: pattern)
                }
            })
            .disposed(by: disposeBag)

        updatedModernBlackboardMaterialRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] materialAndAppearance in
                guard let self else { return }

                // materialAndAppearance の有無に関わらず実行する
                outputRelay.accept(.changeSaveButtonState(isEnabled: !beforeEditing))

                guard let materialAndAppearance else { return }

                if useBlackboardGeneratedWithSVG {
                    Task {
                        do {
                            self.outputRelay.accept(.updateWebPreview(query: try await self.svgQueryParameter(
                                blackboardMaterial: materialAndAppearance.blackboardMaterial,
                                blackboardAppearance: materialAndAppearance.appearance,
                                blackboardLayoutSize: self.blackboardLayoutSize
                            )))
                        } catch {
                            // Note: 初期表示される黒板レイアウトがレイアウト1固定のため、未定義黒板起因でエラーになることは無い。
                            // また、組み込んだ Javascript に問題が有る場合もここに来る可能性があるが、静的ファイルで開発時点で対処済みなので、やはりここに来ることは無い。
                            assertionFailure("黒板レイアウトの表示に必要なクエリデータの生成に失敗しました。error: \(error.localizedDescription)")
                        }
                    }
                } else {
                    outputRelay.accept(.updatePreview(materialAndAppearance))
                }
            })
            .disposed(by: disposeBag)

        networkService.postBlackboardObservable
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.doEnableSaveButton()
                guard let blackboardMatarial = $0.data.object else { return }
                blackboardMatarial.prettyDebug(with: "新規作成postに成功した黒板データ")
                
                let isDuplicatedBlackboard = blackboardMatarial.isDuplicated

                // dismiss時に行う諸処理をまとめたもの
                let dismissHandler = { [weak self] in
                    guard let self else { return }
                    let resetBlackboardMaterial = blackboardMatarial.resetDuplicateFlag()

                    // dismiss前に、黒板IDのみ更新した上で黒板データを渡しておく
                    self.updateBlackboardMaterial(by: resetBlackboardMaterial.id)

                    // post操作のログを追加（ただし黒板が重複していないケースに限る）
                    if !isDuplicatedBlackboard {
                        BlackboardEditLoggingHandler.add(type: .posted(.new, blackboardID: resetBlackboardMaterial.id))
                    }
                    
                    if let materialAndAppearance = self.updatedModernBlackboardMaterialRelay.value {
                        self.outputRelay.accept(
                            .dismiss(
                                .init(
                                    modernBlackboardMaterial: materialAndAppearance.blackboardMaterial,
                                    modernBlackboardAppearance: materialAndAppearance.appearance,
                                    blackboardEditLogs: BlackboardEditLoggingHandler.blackboardTypes,
                                    shouldShowToastView: !isDuplicatedBlackboard
                                )
                            )
                        )
                    } else {
                        self.outputRelay.accept(.dismiss(nil))
                    }
                }
                
                // （送信した黒板データに対し）重複する黒板があるかチェック
                guard !isDuplicatedBlackboard else {
                    // 重複時は、アラートをかましてからdismiss処理を行う
                    self.outputRelay.accept(
                        .showDuplicateBlackboardAlert(
                            confirmBlackboardHandler: { _ in dismissHandler() }
                        )
                    )
                    return
                }
                dismissHandler()
            })
            .disposed(by: disposeBag)
        
        networkService.getBlackboardCommonSettingObservable
            .subscribe(onNext: { [weak self] in
                if let commonSetting = $0.data.object {
                    self?.updateOriginalBlackboardMaterial(by: commonSetting)
                }
                self?.setUpdatedItems()
            })
            .disposed(by: disposeBag)
        
        // receive error
        networkService.catchErrorDriver
            .drive(onNext: { [weak self] in
                self?.doEnableSaveButton()
                guard $0.requestType == ApiRouter.PostBlackboardRequest.self else {
                    self?.outputRelay.accept(.showErrorMessage)
                    return
                }
                // NOTE: 黒板新規作成失敗時は、専用のエラーメッセージを表示する
                self?.outputRelay.accept(.showPostBlackboardErrorMessage)
            })
            .disposed(by: disposeBag)

        // receive sidekicks
        networkService.showLoadingDriver
            .drive(onNext: { [weak self] in self?.outputRelay.accept(.showLoadingView) })
            .disposed(by: disposeBag)

        networkService.hideLoadingDriver
            .drive(onNext: { [weak self] in self?.outputRelay.accept(.hideLoadingView) })
            .disposed(by: disposeBag)
    }

    /// 黒板レイアウト (WebView) のサイズを保持する。
    ///
    /// - Note: 制約などのレイアウトが確定してからセットするようにしてください。
    func setBlackboardLayoutSize(_ size: CGSize) {
        blackboardLayoutSize = size
    }
}

extension CreateModernBlackboardViewModel {
    var title: String {
        staticState.title
    }
    
    var originalBlackboardViewAppearance: ModernBlackboardAppearance {
        _originalBlackboardViewAppearance
    }
    
    var originalModernBlackboardMaterial: ModernBlackboardMaterial {
        _originalModernBlackboardMaterial
    }
}

// MARK: - private (event)
extension CreateModernBlackboardViewModel {
    private func viewDidLoadEvent() {
        localValidateErrorData = nil
        // 黒板レイアウト1（init時にセット済み）から直接画面を表示させる
        updateOriginalBlackboardMaterial(pattern: .pattern1)
        networkService.getBlackboardCommonSetting(orderID: staticState.orderID)
    }
    
    private func didTapArrowButtonEvent() {
        outputRelay.accept(.endEditing)
    }
    
    private func didTapCancelButtonEvent() {
        outputRelay.accept(
            beforeEditing
                ? .dismiss(nil)
                : .showDestoryEditingBlackboardAlert(
                    fromCancelButton: true,
                    okHandler: { [weak self] _ in self?.inputPort.accept(.didTapDestroyEditingBlackboardButton(fromCancelButton: true)) }
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
        guard let blackboardMaterial = updatedModernBlackboardMaterialRelay.value?.blackboardMaterial else {
            outputRelay.accept(.dismiss(nil))
            doEnableSaveButton()
            return
        }
        
        // 黒板データをPOST
        networkService.postNewBlackboard(
            blackboardMaterial: blackboardMaterial,
            type: .new, // NOTE: 新規作成 = .new
            orderID: staticState.orderID
        )
        
        // 元々は、上記APIリクエストの成否に関わらず閉じさせる...仕様ではあったが、問題がありそう
        //
        // -> いったんは、上記APIリクエストが成功した際は、黒板idのみ更新した上でカメラに戻る形にする
    }
    
    private func didTapCellEvent() {
        outputRelay.accept(.endEditing)
    }
    
    private func didTapSelectLayoutButtonEvent() {
        outputRelay.accept(.endEditing)
        outputRelay.accept(
            beforeEditing
                ? .presentBlackboardLayoutListViewController
                : .showDestoryEditingBlackboardAlert(
                    fromCancelButton: false,
                    okHandler: { [weak self] _ in self?.inputPort.accept(.didTapDestroyEditingBlackboardButton(fromCancelButton: false)) }
                )
        )
    }
    
    private func receiveNewLayoutPatternEvent(pattern: ModernBlackboardContentView.Pattern) {
        localValidateErrorData = nil
        updateOriginalBlackboardMaterial(pattern: pattern)
        networkService.getBlackboardCommonSetting(orderID: staticState.orderID)
    }
    
    private func didTapDestroyEditingBlackboardButtonEvent(fromCancelButton: Bool) {
        outputRelay.accept(
            fromCancelButton
            ? .dismiss(nil)
            
            // NOTE: 実際に現状の編集データを破棄するかどうかは、遷移後のユーザーアクションに依存する
            // （ユーザーが別の黒板レイアウトを選んだら破棄するし、そうでなければ何もしない）
            : .presentBlackboardLayoutListViewController
        )
    }
}

// MARK: - private (validation)
extension CreateModernBlackboardViewModel {
    private func hasLocalValidateError() -> Bool {
        
        var errorTexts: [String] = []
        var errorItems: [ModernBlackboardMaterial.Item] = []

        guard let items = updatedModernBlackboardMaterialRelay.value?.blackboardMaterial.items,
              let layoutTypeID = updatedModernBlackboardMaterialRelay.value?.blackboardMaterial.layoutTypeID,
              let pattern = ModernBlackboardContentView.Pattern(by: layoutTypeID) else { return false }

        // NOTE: バリデーションチェック処理
        
        // 1：未入力チェック（項目名のみ）
        // 「すべての項目名を入力してください」
        
        let emptyNameItems = items.filter { $0.itemName.isEmpty }
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
        
        items.forEach { item in
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
        setUpdatedItems() // （エラー文言をセットするため）setUpdatedItemsする
    }
}

// MARK: - private (sidekick)
extension CreateModernBlackboardViewModel {
    private func doEnableSaveButton() {
        outputRelay.accept(.updateSaveButtonState(isEnabled: true))
    }
    
    private func doDisableSaveButton() {
        outputRelay.accept(.updateSaveButtonState(isEnabled: false))
    }
}

// MARK: - private (etc)
extension CreateModernBlackboardViewModel {
    /// 起点となる黒板情報（ = 編集中か判定するための、元のデータとなる）を黒板レイアウトパターンによって更新
    private func updateOriginalBlackboardMaterial(pattern: ModernBlackboardContentView.Pattern) {
        // 新しいレイアウト情報を元に画面を更新する
        let newModernBlackboardMaterial = ModernBlackboardMaterial(
            layout: .init(
                pattern: pattern,
                theme: _originalBlackboardViewAppearance.theme
            )
        )
        _originalModernBlackboardMaterial = newModernBlackboardMaterial.updating(
            by: snapshotData,
            shouldForceUpdateConstructionName: false
        )
    }
    
    /// 起点となる黒板情報（ = 編集中か判定するための、元のデータとなる）を黒板設定情報によって更新
    private func updateOriginalBlackboardMaterial(by commonSetting: ModernBlackboardCommonSetting) {
        snapshotData = .init(
            userID: snapshotData.userID,
            orderName: commonSetting.constructionNameConsideringDisplayType ?? snapshotData.orderName,
            clientName: commonSetting.selectedConstructionPlayerName,
            startDate: snapshotData.startDate
        )

        let theme = commonSetting.defaultTheme
        let memoStyleArguments = commonSetting.memoStyleArguments ?? .defaultSetting(with: theme)
        
        // 更新した黒板アピアランスをセット
        _originalBlackboardViewAppearance = _originalBlackboardViewAppearance
            .updating(by: theme)
            .updating(by: memoStyleArguments)
            .updating(by: commonSetting.dateFormatType)
        
        _originalModernBlackboardMaterial = _originalModernBlackboardMaterial
            .updating(
                by: snapshotData,
                shouldForceUpdateConstructionName: true
            )
            // 工事名のタイトル部分のテキストを更新
            .updating(constructionNameTitle: commonSetting.constructionNameTitle)
    }
    
    /// 黒板情報の黒板idを更新（編集中のデータであれば、そちらを元に更新する）
    private func updateBlackboardMaterial(by blackboardID: Int) {
        let original = updatedModernBlackboardMaterialRelay.value
            ?? .init(
                blackboardMaterial: _originalModernBlackboardMaterial,
                appearance: _originalBlackboardViewAppearance
            )
        
        updatedModernBlackboardMaterialRelay.accept(
            .init(
                blackboardMaterial: original.blackboardMaterial.updating(by: blackboardID),
                appearance: original.appearance
            )
        )
    }
    
    /// 黒板情報の黒板項目データを更新（編集中のデータであれば、そちらを元に更新する）
    private func updateBlackboardMaterial(by blackboardItems: [ModernBlackboardMaterial.Item]) {
        let original = updatedModernBlackboardMaterialRelay.value
            ?? .init(
                blackboardMaterial: _originalModernBlackboardMaterial,
                appearance: _originalBlackboardViewAppearance
            )
        
        updatedModernBlackboardMaterialRelay.accept(
            .init(
                blackboardMaterial: original.blackboardMaterial.updating(by: blackboardItems),
                appearance: original.appearance
            )
        )
    }
    
    private func setItems(materialAndAppearance: MaterialAndAppearance) {
        guard let pattern = ModernBlackboardContentView.Pattern(by: materialAndAppearance.blackboardMaterial.layoutTypeID) else {
            fatalError("layout IDを特定できず、画面生成できません。")
        }
        
        // NOTE: cellDatasには必ず全タイプのデータを追加する
        //  -> 表示の必要のないセルについては、heightを0にすることで非表示化しているので注意
        
        let cellDatas: [DataSource.CellData] = [
            // apiエラー表示
            .errors(
                .init(
                    parentType: .createModernBlackboard,
                    errorTexts: localValidateErrorData?.strings ?? [],
                    initialPattern: pattern
                )
            ),
            // 黒板項目グループ
            .blackboardItems(
                .init(
                    modernBlackboardMaterial: materialAndAppearance.blackboardMaterial,
                    forceWarningInputsCellDatas: localValidateErrorData?.forceWarningInputsCellDatas ?? [],
                    // 新規作成の場合、工事名、施工日、施工者はdisable状態とする
                    disabledCase: .constructionNameAndDateAndConstructionPlayer,
                    // 新規作成時は工事名の変更は発生しない
                    constructionNameShouldBeEditableSignal: Signal.empty()
                )
            )
        ]
        
        items.accept([.init(items: cellDatas)])
    }
    
    private func setUpdatedItems() {
        guard let materialAndAppearance = updatedModernBlackboardMaterialRelay.value else {
            assertionFailure()
            return
        }
        setItems(materialAndAppearance: materialAndAppearance)
    }

    func svgQueryParameter(
        blackboardMaterial: ModernBlackboardMaterial,
        blackboardAppearance: ModernBlackboardAppearance,
        blackboardLayoutSize: CGSize?
    ) async throws -> String {
        // ここで error が throw されるのは未定義黒板だった場合のみ。
        let blackboardContent = try ModernBlackboardContent(
            material: blackboardMaterial,
            theme: blackboardMaterial.blackboardTheme,
            memoStyleArguments: blackboardAppearance.memoStyleArguments,
            dateFormatType: blackboardAppearance.dateFormatType,
            alphaLevel: blackboardAppearance.alphaLevel,
            // 黒板新規作成画面では豆図は表示しない
            miniatureMapImageState: .noURL(useCameraView: false),
            // 黒板新規作成画面では「自動入力値についての情報」を表記する
            displayStyle: .normal(shouldSetCornerRounder: false),
            // 黒板新規作成画面では案件名の表示あり(黒板設定の自由入力設定を反映する)
            shouldBeReflectedNewLine: blackboardAppearance.shouldBeReflectedNewLine
        )

        let blackboardProp = await BlackboardProps(
            blackboardContent: blackboardContent,
            size: blackboardLayoutSize ?? .zero,
            miniatureMapImageType: .rawImage,
            // この画面はオフラインで使用されない
            shouldShowMiniatureMapFromLocal: false,
            isShowEmptyMiniatureMap: false,
            // 豆図の部分が、豆図画像ロード前の画像か豆図登録なしの画像の場合、非表示にしない
            // (黒板新規作成画面では豆図付き黒板は選択できない)
            isHiddenNoneAndEmptyMiniatureMap: false,
            shouldShowPlaceholder: true
        )

        // ここで error が throw されるのは組み込んだ Javascript に問題があった場合のみ(開発時に検出可能)。
        return try blackboardProp.makeQueryParameter()
    }
}

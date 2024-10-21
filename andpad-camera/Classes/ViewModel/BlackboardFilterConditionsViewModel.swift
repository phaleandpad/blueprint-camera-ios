//
//  BlackboardFilterConditionsViewModel.swift
//  andpad
//
//  Created by msano on 2021/04/15.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import RxCocoa
import RxSwift

public final class BlackboardFilterConditionsViewModel {
    typealias DataSource = BlackboardFilterConditionsDataSource
    typealias SearchQuery = ModernBlackboardSearchQuery

    // MARK: - define Inputs, Outputs
    enum Input {
        case viewDidLoad
        case didTapCell(DataSource.Section.Item)
        case didTapDismissButton
        case didTapFilterButton
        case didTapClearButton
        case didTapSearchHistoryButton
        case didTapAcceptButtonInClearAlert
        case updateFreeword(String)
        case didTapShowAllBlackboardItemsButton
    }

    enum Output {
        case dismiss(ModernBlackboardSearchQuery?)
        case dismissByCancelButton
        case pushSingleSelectViewController(arguments: AppDependencies.BlackboardFilterSingleSingleArguments)
        case pushMultiSelectViewController(arguments: AppDependencies.BlackboardFilterMultiSelectArguments)
        case pushHistoryViewController(arguments: AppDependencies.BlackboardFilterConditionsHistoryViewArguments)
        case showClearAlert((UIAlertAction) -> Void)
        case showDiscardConditionAlert((UIAlertAction) -> Void)
        case showLoadingView
        case hideLoadingView
        case showErrorMessage(error: AndpadCameraError)
        case showZeroResponseMessage
        case updateCounter(Int)
        case changeClearButtonState(isEnable: Bool)
        case showEmptyAlert
    }

    private enum UpdateItemsTarget {
        case initial(searchQuery: SearchQuery?)
        case clear
        case photo(photoCondition: PhotoCondition)
        case condition(itemName: String, selectedCondition: [String])
        case freewordCondition(String)
        case showAllBlackboardItems
    }

    // MARK: - StaticState
    private struct StaticState {
        let orderID: Int
        let title: String = L10n.Blackboard.Filter.title
        let previousSearchQuery: SearchQuery? // 前画面で使用していた検索クエリ（差分比較に使用）
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
    }

    let inputPort: PublishRelay<Input> = .init()
    let outputPort: ControlEvent<Output>
    let dataSource = DataSource()
    let items = BehaviorRelay<[DataSource.Section]>(value: [])

    private var conditionsSnapShot = ConditionsSnapShot()

    private var currentSearchQuery: SearchQuery? {
        didSet {
            guard let currentSearchQuery else {
                outputRelay.accept(.changeClearButtonState(isEnable: false))
                return
            }
            outputRelay.accept(.changeClearButtonState(isEnable: !currentSearchQuery.defaultConditions))
        }
    }

    private let networkService: ModernBlackboardNetworkServiceProtocol

    private let staticState: StaticState
    private let disposeBag = DisposeBag()
    private let outputRelay: PublishRelay<Output>
    private var isChangedSearchQuery: Bool {
        staticState.previousSearchQuery != currentSearchQuery
    }

    private let isOfflineMode: Bool
    private let userID: Int
    
    // --------------------------------------------------------------
    // NOTE:
    // 【検索クエリ生成の流れ】
    // 以下の変換をへて、検索クエリを生成、黒板検索のAPIリクエストに渡しています：
    //
    // ConditionsSnapShot　-> [DataSource.Section] -> SearchQuery
    //
    // 【ConditionsSnapShot】
    // 絞り込み条件を用途別に分け、一時poolするstruct
    //
    // 【[DataSource.Section]】
    // itemsのvalueに相当、各cellのデータを格納
    //
    // 【SearchQuery】
    // 検索クエリ、
    // 絞り込み条件をAPIリクエストできるよう整形したstruct
    // （なお、itemsを監視しているため、itemsに変更があった場合は逐次生成するようにしている）
    //
    // --------------------------------------------------------------
    
    init(
        networkService: ModernBlackboardNetworkServiceProtocol,
        userID: Int,
        orderID: Int,
        searchQuery: SearchQuery?,
        advancedOptions: [ModernBlackboardConfiguration.AdvancedOption],
        isOfflineMode: Bool
    ) {
        // MARK: - configure Outputs
        let relay = PublishRelay<Output>()
        self.outputPort = .init(events: relay)
        self.outputRelay = relay
        self.networkService = networkService
        self.staticState = .init(
            orderID: orderID,
            previousSearchQuery: searchQuery,
            advancedOptions: advancedOptions
        )
        self.userID = userID
        self.isOfflineMode = isOfflineMode

        if currentSearchQuery == nil {
            outputRelay.accept(.changeClearButtonState(isEnable: false))
        }

        inputPort
            .bind(onNext: { [weak self] event in
                switch event {
                case .viewDidLoad:
                    self?.viewDidLoadEvent()
                case .didTapCell(let item):
                    self?.didTapCellEvent(with: item)
                case .didTapDismissButton:
                    self?.didTapDismissButtonEvent()
                case .didTapFilterButton:
                    self?.didTapFilterButtonEvent()
                case .didTapClearButton:
                    self?.didTapClearButtonEvent()
                case .didTapSearchHistoryButton:
                    self?.didTapSearchHistoryButtonEvent()
                case .didTapAcceptButtonInClearAlert:
                    self?.updateState(by: .clear)
                case .updateFreeword(let text):
                    self?.updateState(by: .freewordCondition(text))
                case .didTapShowAllBlackboardItemsButton:
                    self?.didTapShowAllBlackboardItemsButtonEvent()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: variable (included private static state)
extension BlackboardFilterConditionsViewModel {
    var title: String {
        staticState.title
    }
}

// MARK: - private (event)
extension BlackboardFilterConditionsViewModel {
    private func viewDidLoadEvent() {
        updateState(by: .initial(searchQuery: staticState.previousSearchQuery))
    }

    private func didTapCellEvent(with conditionModelType: DataSource.Section.Item) {
        switch conditionModelType {
        case .pinnedBlackboardItem(let itemName, let selectedConditions, _),
             .unpinnedBlackboardItem(let itemName, let selectedConditions, _, _):
            outputRelay.accept(
                .pushMultiSelectViewController(
                    arguments: .init(
                        userID: userID,
                        orderID: staticState.orderID,
                        blackboardItemBody: itemName,
                        initialSelectedContents: selectedConditions,
                        appBaseRequestData: networkService.appBaseRequestData,
                        filterDoneHandler: { [weak self] in
                            self?.updateState(
                                by: .condition(itemName: $0, selectedCondition: $1)
                            )
                        },
                        isOfflineMode: isOfflineMode,
                        filteringByPhoto: conditionsSnapShot.photoCondition.condition.filteringByPhotoType,
                        searchQuery: currentSearchQuery
                    )
                )
            )
        case .photo(let text):
            outputRelay.accept(
                .pushSingleSelectViewController(
                    arguments: .init(
                        currentContent: text,
                        filterDoneHandler: { [weak self] in
                            if let conditionText = $0,
                               let photoCondition = ModernBlackboardSearchQuery.PhotoCondition(with: conditionText) {
                                self?.updateState(by: .photo(photoCondition: .init(condition: photoCondition)))
                            }
                        }
                    )
                )
            )
        case .blackboardItemsSeparator, .freeword:
            break
        case .showAllBlackboardItemsButton:
            // Note: セルタップ時ではなくセル内部のボタンタップ時の処理が別のイベントで実装されている
            break
        }
    }

    private func didTapDismissButtonEvent() {
        guard isChangedSearchQuery else {
            outputRelay.accept(.dismissByCancelButton)
            return
        }
        // NOTE: 差分がある場合はアラートを表示
        outputRelay.accept(
            .showDiscardConditionAlert({ [weak self] _ in
                self?.outputRelay.accept(.dismissByCancelButton)
            })
        )
    }

    private func didTapFilterButtonEvent() {
        guard let currentSearchQuery else {
            // 絞り込み条件がリセットされている場合も、最新履歴として保存する
            
            blackboardHistoryHandler?.save(latestHistory: nil, orderID: staticState.orderID)
            outputRelay.accept(.dismiss(nil))
            return
        }
        // NOTE: ローカルに絞り込み条件を保存
        let history = BlackboardFilterConditionsHistory(
            orderID: staticState.orderID,
            updatedAt: Date(),
            query: currentSearchQuery
        )
        outputRelay.accept(.showLoadingView)
        
        guard let blackboardHistoryHandler else {
            outputRelay.accept(.dismiss(currentSearchQuery))
            return
        }
        
        // （検索に使用する）絞り込み履歴データを保存
        blackboardHistoryHandler.save(latestHistory: history, orderID: staticState.orderID)
        blackboardHistoryHandler.save(history: history)
            .do(onDispose: { [weak self] in self?.outputRelay.accept(.hideLoadingView) })
            .subscribe(
                onCompleted: { [weak self] in self?.outputRelay.accept(.dismiss(currentSearchQuery)) },
                onError: { assertionFailure($0.localizedDescription) }
            )
            .disposed(by: disposeBag)
    }
    
    private func didTapClearButtonEvent() {
        let clearHandler: (UIAlertAction) -> Void = { [weak self] _ in
            self?.inputPort.accept(.didTapAcceptButtonInClearAlert)
        }
        outputRelay.accept(.showClearAlert(clearHandler))
    }
    
    private func didTapSearchHistoryButtonEvent() {
        let useHistoryViewOption = staticState.advancedOptions.first(where: {
            guard case .useHistoryView = $0 else { return false }
            return true
        })

        guard useHistoryViewOption != nil else {
            assertionFailure("[failure] 必要なオプションがセットされていないため、黒板履歴画面を生成できません。 \n[failure] オプション 'useHistoryView' をセットしてください。")
            return
        }
        
        outputRelay.accept(
            .pushHistoryViewController(
                arguments: .init(
                    orderID: staticState.orderID,
                    advancedOptions: staticState.advancedOptions
                )
            )
        )
    }

    /// target に基づいて各種状態更新を行う。
    private func updateState(by target: UpdateItemsTarget) {
        switch target {
        case .initial(let searchQuery):
            updateSnapShotAndItemsByInitialize(searchQuery: searchQuery)
        case .clear:
            updateSnapShotAndItemsByClearCondition()
        case .photo(let photoCondition):
            updateSnapShotAndItemsByPhoto(photoCondition: photoCondition)
        case .condition(let targetItemName, let selectedCondition):
            updatedSnapShotAndItemsByCondition(
                targetItemName: targetItemName,
                selectedCondition: selectedCondition
            )
        case .freewordCondition(let text):
            updateSnapShotAndItemsByFreeword(text: text)
        case .showAllBlackboardItems:
            updateSnapShotAndItemsByShowingAllItems()
        }
    }

    /// 「すべての項目を表示する」ボタンがタップされたときのイベント
    private func didTapShowAllBlackboardItemsButtonEvent() {
        updateState(by: .showAllBlackboardItems)
    }
}

// MARK: - private (update snapshot and items by UpdateItemsTarget)
private extension BlackboardFilterConditionsViewModel {
    /// UpdateItemsTarget が initial (初回ローディング) の場合のデータ取得・更新処理
    func updateSnapShotAndItemsByInitialize(searchQuery: SearchQuery?) {
        Task<_, Never> { @MainActor in
            do {
                outputRelay.accept(.showLoadingView)
                let response = try await networkService.fetchFilteredBlackboardItems(
                    orderID: staticState.orderID,
                    filteringByPhoto: searchQuery?.photoCondition.filteringByPhotoType ?? .all,
                    miniatureMapLayout: nil,
                    searchQuery: searchQuery
                )
                outputRelay.accept(.hideLoadingView)

                let filteredItems = response.data.items
                guard !filteredItems.isEmpty else {
                    self.outputRelay.accept(.showZeroResponseMessage)
                    return
                }

                let initialConditionsSnapShot = initialConditionsSnapShot(filteredItems: filteredItems, searchQuery: searchQuery)

                if let searchQuery {
                    // NOTE: 前画面から検索クエリ（ = 絞り込み条件）を取得している場合は、そちらもcellに反映させる
                    conditionsSnapShot = .init(
                        searchQuery: searchQuery,
                        initialSnapShot: initialConditionsSnapShot
                    )
                } else {
                    conditionsSnapShot = initialConditionsSnapShot
                }
                items.accept(conditionsSnapShot.dataSourceItems)

                let blackboardCount = response.data.blackboardCount
                outputRelay.accept(.updateCounter(blackboardCount))
                currentSearchQuery = searchQuery

                if blackboardCount <= 0 {
                    outputRelay.accept(.showEmptyAlert)
                }
            } catch {
                outputRelay.accept(.hideLoadingView)
                outputRelay.accept(.showErrorMessage(error: isOfflineMode ? .operationCouldNotBeCompleted : .network))
            }
        }
    }

    /// UpdateItemsTarget が clear (絞り込み条件のクリア時) の場合のデータ取得・更新処理
    func  updateSnapShotAndItemsByClearCondition() {
        Task<_, Never> { @MainActor in
            do {
                currentSearchQuery = nil

                outputRelay.accept(.showLoadingView)
                // NOTE: 絞り込み条件をクリアするだけなので、ここでは絞り込み件数の更新のみ行う
                let response = try await networkService.fetchFilteredBlackboardItems(
                    orderID: staticState.orderID,
                    filteringByPhoto: .all,
                    miniatureMapLayout: nil,
                    searchQuery: nil
                )
                outputRelay.accept(.hideLoadingView)

                outputRelay.accept(.updateCounter(response.data.blackboardCount))
                conditionsSnapShot = conditionsSnapShot.clearedSelectedConditions()
                items.accept(conditionsSnapShot.dataSourceItems)
            } catch {
                outputRelay.accept(.hideLoadingView)
                outputRelay.accept(.showErrorMessage(error: isOfflineMode ? .operationCouldNotBeCompleted : .network))
            }
        }
    }

    /// UpdateItemsTarget が photo (写真の有無) の場合のデータ取得・更新処理。
    ///
    /// - Note: 絞り込み条件の変更あり(API呼び出し必要)。
    func updateSnapShotAndItemsByPhoto(photoCondition: PhotoCondition) {
        let updatedConditionsSnapShot = conditionsSnapShot.updating(photoCondition: photoCondition)
        updateConditionsSnapShotAndItems(conditionsSnapShot: updatedConditionsSnapShot)
    }

    /// UpdateItemsTarget が condition (各項目の選択状態変更) の場合のデータ取得・更新処理。
    ///
    /// - Note: 絞り込み条件の変更あり(API呼び出し必要)。
    func updatedSnapShotAndItemsByCondition(targetItemName: String, selectedCondition: [String]) {
        let updatedPinnedBlackboardItemConditions = conditionsSnapShot
            .pinnedBlackboardItemConditions
            .map {
                guard targetItemName == $0.itemName else { return $0 }
                return PinnedBlackboardItemCondition(
                    itemName: targetItemName,
                    selectedConditions: selectedCondition,
                    isActive: true
                )
            }
        let updatedUnpinnedBlackboardItemConditions = conditionsSnapShot
            .unpinnedBlackboardItemConditions
            .map {
                guard targetItemName == $0.itemName else { return $0 }
                return UnPinnedBlackboardItemCondition(
                    itemName: targetItemName,
                    selectedConditions: selectedCondition,
                    isVisible: $0.isVisible,
                    isActive: true
                )
            }
        let updatedConditionsSnapShot = conditionsSnapShot.updating(
            pinnedBlackboardItemConditions: updatedPinnedBlackboardItemConditions,
            unpinnedBlackboardItemConditions: updatedUnpinnedBlackboardItemConditions
        )
        updateConditionsSnapShotAndItems(conditionsSnapShot: updatedConditionsSnapShot)
    }

    /// UpdateItemsTarget が freewordCondition (フリーワードの条件更新時) の場合のデータ取得・更新処理。
    ///
    /// - Note: 絞り込み条件の変更あり(API呼び出し必要)。
    func updateSnapShotAndItemsByFreeword(text: String) {
        let updatedConditionsSnapShot = conditionsSnapShot.updating(freewordCondition: .init(freeword: text))
        updateConditionsSnapShotAndItems(conditionsSnapShot: updatedConditionsSnapShot)
    }

    /// UpdateItemsTarget が showAllBlackboardItems (「すべての項目を表示する」ボタンタップ時) の場合のデータ取得・更新処理
    ///
    /// - Note: 折りたたんだ絞り込み条件をすべて表示するだけなので、絞り込み条件の変更はない(API呼び出し不要)。
    func updateSnapShotAndItemsByShowingAllItems() {
        let updatedUnpinnedBlackboardItemConditions = conditionsSnapShot
            .unpinnedBlackboardItemConditions
            .map {
                UnPinnedBlackboardItemCondition(
                    itemName: $0.itemName,
                    selectedConditions: $0.selectedConditions,
                    // すべての黒板の項目を表示する
                    isVisible: true,
                    isActive: $0.isActive
                )
            }
        let updatedConditionsSnapShot = conditionsSnapShot.updating(unpinnedBlackboardItemConditions: updatedUnpinnedBlackboardItemConditions)
        conditionsSnapShot = updatedConditionsSnapShot
        items.accept(updatedConditionsSnapShot.dataSourceItems)
    }

    /// ConditionsSnapShot を受け取って currentSearchQuery, conditionsSnapShot,  items を更新する
    func updateConditionsSnapShotAndItems(conditionsSnapShot: ConditionsSnapShot) {
        Task<_, Never> { @MainActor in
            do {
                let updatedSearchQuery = convertSearchQuery(by: conditionsSnapShot)

                // NOTE: updatedSearchQuery が前回と同じ場合は更新しない
                guard currentSearchQuery != updatedSearchQuery else {
                    return
                }
                currentSearchQuery = updatedSearchQuery

                outputRelay.accept(.showLoadingView)
                let response = try await networkService.fetchFilteredBlackboardItems(
                    orderID: staticState.orderID,
                    filteringByPhoto: updatedSearchQuery?.photoCondition.filteringByPhotoType ?? .all,
                    miniatureMapLayout: nil,
                    searchQuery: updatedSearchQuery
                )
                outputRelay.accept(.hideLoadingView)

                let blackboardCount = response.data.blackboardCount
                outputRelay.accept(.updateCounter(blackboardCount))

                // APIから取得した情報をもとに isActive 情報を更新する。

                let updatedPinnedBlackboardItemConditions = conditionsSnapShot.pinnedBlackboardItemConditions.map { condition in
                    // NOTE: 二重ループ状態になっており、項目数が多い場合にパフォーマンス懸念がある。
                    // パフォーマンス的に問題が出てきたら、　`response.data.items` を Dictionary に変換して使う方向で修正する。
                    guard let findItem = response.data.items.first(where: { $0.name == condition.itemName }) else {
                        return condition
                    }
                    return PinnedBlackboardItemCondition(
                        itemName: condition.itemName,
                        selectedConditions: condition.selectedConditions,
                        isActive: findItem.blackboardExists
                    )
                }

                let updatedUnPinnedBlackboardItemConditions = conditionsSnapShot.unpinnedBlackboardItemConditions.map { condition in
                    // NOTE: 二重ループ状態になっており、項目数が多い場合にパフォーマンス懸念がある。
                    // パフォーマンス的に問題が出てきたら、　`response.data.items` を Dictionary に変換して使う方向で修正する。
                    guard let findItem = response.data.items.first(where: { $0.name == condition.itemName }) else {
                        return condition
                    }
                    return UnPinnedBlackboardItemCondition(
                        itemName: condition.itemName,
                        selectedConditions: condition.selectedConditions,
                        isVisible: condition.isVisible,
                        isActive: findItem.blackboardExists
                    )
                }

                self.conditionsSnapShot = conditionsSnapShot.updating(
                    pinnedBlackboardItemConditions: updatedPinnedBlackboardItemConditions,
                    unpinnedBlackboardItemConditions: updatedUnPinnedBlackboardItemConditions
                )
                items.accept(self.conditionsSnapShot.dataSourceItems)

                if blackboardCount <= 0 {
                    outputRelay.accept(.showEmptyAlert)
                }
            } catch {
                outputRelay.accept(.hideLoadingView)
                outputRelay.accept(.showErrorMessage(error: isOfflineMode ? .operationCouldNotBeCompleted : .network))
            }
        }
    }
}

// MARK: - private (convert)
private extension BlackboardFilterConditionsViewModel {
    /// ConditionsSnapShot から SearchQuery を生成する。
    func convertSearchQuery(by conditionsSnapShot: ConditionsSnapShot) -> SearchQuery? {
        var conditions: [SearchQuery.ConditionForBlackboardItem] = []

        conditions += conditionsSnapShot.pinnedBlackboardItemConditions.map {
            .init(
                targetItemName: $0.itemName,
                conditions: $0.selectedConditions
            )
        }

        conditions += conditionsSnapShot.unpinnedBlackboardItemConditions.map {
            .init(
                targetItemName: $0.itemName,
                conditions: $0.selectedConditions
            )
        }

        conditions = conditions.filter { !$0.isEmpty }

        // 絞り込み条件が1つもなかったら nil を返す
        if conditionsSnapShot.photoCondition.condition == .all,
           conditions.isEmpty,
           conditionsSnapShot.freewordCondition.freeword.isEmpty {
            return nil
        }

        return .init(
            photoCondition: conditionsSnapShot.photoCondition.condition,
            conditionForBlackboardItems: conditions,
            freewords: conditionsSnapShot.freewordCondition.freeword
        )
    }
}

// MARK: - private (fetch)
extension BlackboardFilterConditionsViewModel {
    /// APIレスポンス、およびクエリから Snap Shot を生成する
    private func initialConditionsSnapShot(
        filteredItems: [FilteredBlackboardItem],
        searchQuery: SearchQuery?
    ) -> ConditionsSnapShot {
        let pinnedBlackboardItemConditions = filteredItems
            .filter { $0.shouldDisplayWithHighPriority }
            .map {
                PinnedBlackboardItemCondition(
                    itemName: $0.name,
                    selectedConditions: [],
                    // 該当する黒板が存在する場合は活性表示
                    isActive: $0.blackboardExists
                )
            }

        let unpinnedBlackboardItemConditions = filteredItems
            .filter { !$0.shouldDisplayWithHighPriority }
            .map {
                UnPinnedBlackboardItemCondition(
                    itemName: $0.name,
                    selectedConditions: [],
                    // ピン留めされた項目が１つもない場合表示し、そうでなければ非表示
                    isVisible: pinnedBlackboardItemConditions.isEmpty,
                    // 該当する黒板が存在する場合は活性表示
                    isActive: $0.blackboardExists
                )
            }

        return .init(
            photoCondition: .init(condition: searchQuery?.photoCondition ?? .all),
            pinnedBlackboardItemConditions: pinnedBlackboardItemConditions,
            unpinnedBlackboardItemConditions: unpinnedBlackboardItemConditions,
            freewordCondition: .init(freeword: searchQuery?.freewords ?? "")
        )
    }
}

// MARK: - private (BlackboardHistoryHandlerProtocol)
extension BlackboardFilterConditionsViewModel {
    private var blackboardHistoryHandler: BlackboardHistoryHandlerProtocol? {
        var useHistoryViewConfigureArguments: ModernBlackboardConfiguration.UseHistoryViewConfigureArguments?
        optionsLoop: for advancedOption in staticState.advancedOptions {
            switch advancedOption {
            case .useHistoryView(let args):
                useHistoryViewConfigureArguments = args
                break optionsLoop
            case .useMiniatureMap:
                break
            }
        }
        guard let useHistoryViewConfigureArguments else { return nil }
        return useHistoryViewConfigureArguments.blackboardHistoryHandler
    }
}

// MARK: - PhotoCondition
extension ModernBlackboardSearchQuery.PhotoCondition {
    init?(with string: String) {
        switch string {
        case Self.all.string:
            self = .all
        case Self.hasPhoto.string:
            self = .hasPhoto
        case Self.hasNoPhoto.string:
            self = .hasNoPhoto
        default:
             return nil
        }
    }
    
    public var string: String {
        switch self {
        case .all:
            return L10n.Blackboard.Filter.Photo.all
        case .hasPhoto:
            return L10n.Blackboard.Filter.Photo.onlyWithPhotos
        case .hasNoPhoto:
            return L10n.Blackboard.Filter.Photo.onlyWithoutPhotos
        }
    }
}

// MARK: - ModernBlackboardSearchQuery
extension ModernBlackboardSearchQuery {
    fileprivate var defaultConditions: Bool {
        return photoCondition == .all
            && conditionForBlackboardItems.isEmpty
            && freewords.isEmpty
    }
}

private extension ModernBlackboardSearchQuery.PhotoCondition {
    var filteringByPhotoType: FilteringByPhotoType {
        switch self {
        case .all:
            return .all
        case .hasPhoto:
            return .hasPhoto
        case .hasNoPhoto:
            return .noPhoto
        }
    }
}

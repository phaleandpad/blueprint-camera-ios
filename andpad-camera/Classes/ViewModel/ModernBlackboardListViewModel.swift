//
//  ModernBlackboardListViewModel.swift
//  andpad-camera
//
//  Created by msano on 2022/01/05.
//

import RxCocoa
import RxSwift
import Foundation

public final class ModernBlackboardListViewModel {
    typealias SearchQuery = ModernBlackboardSearchQuery
    typealias DataSource = ModernBlackboardListDataSource

    // MARK: - define Inputs, Outputs
    enum Input {
        case viewDidLoad
        case didTapFilterButton
        case didTapRetryRequestButton
        case didTapDestructiveButton
        case didTapCancelButton
        case didTapAppUpdateButton
        case receiveSortState(ModernBlackboardListSortView.SortState)
        case scrolledDown
        case pullToRefresh
        case prefetchRows([IndexPath])
        case cancelPrefetchingForRows([IndexPath])
        case updateSearchQuery(SearchQuery?)
    }

    enum Output {
        case doneFetching
        case pop
        case dismiss(CancelResult?)
        case presentFilterConditions(AppDependencies.ModernBlackboardFilterConditionsViewArguments)
        case push(UIViewController)
        case showLoadingView
        case hideLoadingView
        case showErrorMessage(error: AndpadCameraError)
        case changeFilterButtonState(hasSearchQuery: Bool)
        case startPrefetching([URL])
        case stopPrefetching([URL])
        case changeShowingFilterHeaderContainerView(isHidden: Bool)
        case changeShowingSortHeaderView(isHidden: Bool)
        case updateTotalLabel(Int)
        case updateSearchQuery(SearchQuery?)
        case showAppStoreAlert
        case showAppUpdateView
    }
    
    private enum FetchScene {
        case viewDidLoad
        case retryFetching
        case pullToRefresh
        case scrolledDown
    }

    /// キャンセルボタンがタップされたときに返すデータ
    struct CancelResult {
        /// 黒板のスタイル変更可否
        let canEditBlackboardStyle: Bool
        /// APIから取得した黒板のサイズタイプ
        let blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType
        /// APIから取得した撮影画像形式
        let preferredPhotoFormat: ModernBlackboardCommonSetting.PhotoFormat
    }

    // MARK: - StaticState
    private struct StaticState {
        let orderID: Int
        let title: String = L10n.Blackboard.List.title
        let snapshotData: SnapshotData
        
        // NOTE: 画面仕様によっては、そもそも「選択中の黒板データ」を保持していないシーンがあるためオプショナルとしている
        let selectedBlackboard: ModernBlackboardMaterial?
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
    }

    let inputPort: PublishRelay<Input> = .init()
    let outputPort: ControlEvent<Output>
    let dataSource = DataSource()
    let items = BehaviorRelay<[DataSource.Section]>(value: [])

    private let networkService: ModernBlackboardNetworkServiceProtocol
    private let staticState: StaticState
    private let disposeBag = DisposeBag()
    private let outputRelay: PublishRelay<Output>
    private let throttleMilliseconds = DispatchTimeInterval.milliseconds(
        ThrottleConfiguration.enable.milliseconds
    )
    private var doneGettingLastItems = false
    private var pagingFetchingType: PagingFetchingType = .initialFetch
    private var sortType: ModernBlackboardsSortType = .positionASC
    
    private var itemsCount: Int {
        items.value.first?.items.count ?? 0
    }
    private var hasSomeItems: Bool {
        itemsCount > 0
    }

    private let searchQueryRelay = BehaviorRelay<SearchQuery?>(value: nil)
    private let shouldShowAppUpdateViewRelay = BehaviorRelay<Bool>(value: false)
    private let isEmptyBlackboardsRelay = PublishRelay<DataSource.SectionType?>()

    private let fetchSceneRelay = PublishRelay<FetchScene>()
    private let fetchBlackboardCommonSettingRelay = PublishRelay<Void>()
    private let fetchBlackboardCommonSettingWithThrottleRelay = PublishRelay<Void>() // swiftlint:disable:this identifier_name
    private let blackboardCommonSettingRelay = BehaviorRelay<(ModernBlackboardCommonSetting, FetchScene)?>(value: nil)
    
    /// オフラインモードか否か
    let isOfflineMode: BehaviorRelay<Bool>

    /// 黒板一覧取得中かどうか
    private var isLoadingBlackboardList: Bool = false

    private let remoteConfig: (any AndpadCameraDependenciesRemoteConfigProtocol)?

    public convenience init(
        appBaseRequestData: AppBaseRequestData,
        orderID: Int,
        snapshotData: SnapshotData,
        selectedBlackboard: ModernBlackboardMaterial?,
        advancedOptions: [ModernBlackboardConfiguration.AdvancedOption],
        remoteConfig: (any AndpadCameraDependenciesRemoteConfigProtocol)? = AndpadCameraDependencies.shared.remoteConfigHandler
    ) {
        
        // NOTE:
        // networkServiceはprivateのままとしたいため、別口のpublic initを用意している
        // （またnetworkServiceはDIしたい要素だが、ここは例外的に自身で生成する）
        
        self.init(
            networkService: ModernBlackboardNetworkService(appBaseRequestData: appBaseRequestData),
            orderID: orderID,
            snapshotData: snapshotData,
            selectedBlackboard: selectedBlackboard,
            advancedOptions: advancedOptions,
            remoteConfig: remoteConfig
        )
    }
    
    init(
        networkService: ModernBlackboardNetworkServiceProtocol,
        orderID: Int,
        snapshotData: SnapshotData,
        selectedBlackboard: ModernBlackboardMaterial?,
        advancedOptions: [ModernBlackboardConfiguration.AdvancedOption],
        isOfflineMode: Bool = false,
        remoteConfig: (any AndpadCameraDependenciesRemoteConfigProtocol)? = AndpadCameraDependencies.shared.remoteConfigHandler
    ) {
        // MARK: - configure Outputs
        let relay = PublishRelay<Output>()
        self.outputPort = .init(events: relay)
        self.outputRelay = relay
        self.networkService = networkService
        self.isOfflineMode = .init(value: isOfflineMode)
        self.remoteConfig = remoteConfig

        self.staticState = .init(
            orderID: orderID,
            snapshotData: snapshotData,
            selectedBlackboard: selectedBlackboard,
            advancedOptions: advancedOptions
        )
        
        inputPort
            .bind(onNext: { [weak self] event in
                switch event {
                case .viewDidLoad:
                    self?.viewDidLoadEvent()
                case .pullToRefresh:
                    self?.pullToRefreshEvent()
                case .didTapFilterButton:
                    self?.didTapFilterButtonEvent()
                case .didTapRetryRequestButton:
                    self?.retryFetchingEvent()
                case .didTapDestructiveButton:
                    self?.outputRelay.accept(.pop)
                case .didTapCancelButton:
                    self?.didTapCancelButtonEvent()
                case .didTapAppUpdateButton:
                    self?.outputRelay.accept(.showAppStoreAlert)
                case .receiveSortState(let state):
                    self?.receiveSortStateEvent(state: state)
                case .scrolledDown:
                    self?.scrolledDownEvent()
                case .prefetchRows(let indexPaths):
                    self?.prefetchEvent(
                        indexPaths: indexPaths,
                        isStartPrefetch: true
                    )
                case .cancelPrefetchingForRows(let indexPaths):
                    self?.prefetchEvent(
                        indexPaths: indexPaths,
                        isStartPrefetch: false
                    )
                case .updateSearchQuery(let searchQuery):
                    self?.receiveNewSearchQuery(
                        searchQuery,
                        shouldSaveSearchQuery: true
                    )
                }
            })
            .disposed(by: disposeBag)

        self.networkService.getBlackboardResultObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self,
                      let total = result.data.total,
                      let blackboardMaterials = result.data.objects,
                      let commonSetting = blackboardCommonSettingRelay.value?.0 else { return }

                isLoadingBlackboardList = false
                outputRelay.accept(.updateTotalLabel(total))
                
                guard !blackboardMaterials.isEmpty else {
                    let sectionType: DataSource.SectionType = searchQueryRelay.value == nil
                        ? .empty
                        : .emptyWithFiltering
                    items.accept([
                        .init(
                            sectionType: sectionType,
                            items: []
                        )
                    ])
                    return
                }
                
                if !shouldShowAppUpdateViewRelay.value {
                    // NOTE: 1つでも未定義黒板が存在していたら、アプリアップデートのViewを表示させる
                    let undefinedBlackboardLayout = blackboardMaterials
                        .first { ModernBlackboardContentView.Pattern(rawValue: $0.layoutTypeID) == nil }
                    if undefinedBlackboardLayout != nil {
                        shouldShowAppUpdateViewRelay.accept(true)
                    }
                }

                doneGettingLastItems = result.data.lastFlg ?? false
                
                let newItems: [DataSource.Section.Item] = blackboardMaterials
                    .compactMap { [weak self] in
                        guard let self else { return nil }
                        let updatedBlackboard = $0.updating(
                            by: self.staticState.snapshotData,
                            shouldForceUpdateConstructionName: false
                        )
                        
                        let memoStyleArguments = ModernBlackboardMemoStyleArguments(
                            textColor: updatedBlackboard.blackboardTheme.textColor,
                            adjustableMaxFontSize: commonSetting.adjustableMaxFontSize,
                            verticalAlignment: commonSetting.verticalAlignment,
                            horizontalAlignment: commonSetting.horizontalAlignment
                        )
                        guard let selectedBlackboard = self.staticState.selectedBlackboard else {
                            return .init(
                                blackboardMaterial: updatedBlackboard,
                                memoStyleArguments: memoStyleArguments,
                                isSelectedBlackboard: false,
                                shouldShowMiniatureMapFromLocal: isOfflineMode,
                                useBlackboardGeneratedWithSVG: remoteConfig?.fetchUseBlackboardGeneratedWithSVG() ?? false
                            )
                        }
                        // 黒板の比較は黒板idのみで行う
                        return .init(
                            blackboardMaterial: updatedBlackboard,
                            memoStyleArguments: memoStyleArguments,
                            isSelectedBlackboard: updatedBlackboard.id == selectedBlackboard.id,
                            shouldShowMiniatureMapFromLocal: isOfflineMode,
                            useBlackboardGeneratedWithSVG: remoteConfig?.fetchUseBlackboardGeneratedWithSVG() ?? false
                        )
                    }
                
                switch pagingFetchingType {
                case .initialFetch:
                    items.accept([.init(items: newItems)])
                case .paging:
                    let oldCellModels = items.value.flatMap { $0.items }
                    items.accept([.init(items: oldCellModels + newItems)])
                }
            })
            .disposed(by: disposeBag)
        
        Observable.of(
                fetchBlackboardCommonSettingRelay
                    .asObservable(),
                fetchBlackboardCommonSettingWithThrottleRelay
                    .throttle(
                        throttleMilliseconds,
                        latest: false,
                        scheduler: MainScheduler.instance
                    )
            )
            .merge()
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.networkService.getBlackboardCommonSetting(orderID: self.staticState.orderID)
            })
            .disposed(by: disposeBag)
        
        Observable.zip(
                networkService.getBlackboardCommonSettingObservable,
                fetchSceneRelay
            )
            .compactMap { result, scene -> (ModernBlackboardCommonSetting, FetchScene)? in
                guard let commonSetting = result.data.object else { return nil }
                return (commonSetting, scene)
            }
            .bind(to: blackboardCommonSettingRelay)
            .disposed(by: disposeBag)

        blackboardCommonSettingRelay
            .compactMap { $0?.1 }
            .subscribe(onNext: { [weak self] scene in
                guard let self else { return }
                switch scene {
                case .viewDidLoad:
                    guard let historyHandler = self.blackboardhistoryHandler else {
                        self.outputRelay.accept(.updateSearchQuery(self.searchQueryRelay.value))
                        self.fetch(
                            pagingFetchingType: .initialFetch,
                            searchQuery: self.searchQueryRelay.value
                        )
                        return
                    }
                    self.willInitialFetch(with: historyHandler)
                case .pullToRefresh, .retryFetching:
                    self.fetch(
                        pagingFetchingType: .initialFetch,
                        searchQuery: self.searchQueryRelay.value
                    )
                case .scrolledDown:
                    self.fetch(
                        pagingFetchingType: .paging(offset: self.itemsCount),
                        searchQuery: self.searchQueryRelay.value
                    )
                }
            })
            .disposed(by: disposeBag)
            
        self.networkService.catchErrorDriver
            .drive(onNext: { [weak self] _ in
                self?.outputRelay.accept(.showErrorMessage(error: isOfflineMode ? .operationCouldNotBeCompleted : .network))
                self?.outputRelay.accept(.doneFetching)

                // エラー発生時も isLoadingBlackboardList フラグをオフにする。
                // NOTE: 全ての API について、エラーが発生した場合は全て catchErrorDriver に入ってくる。
                // そのため、厳密にはどの API からのレスポンスかを見た上で処理を出し分ける必要があるが、
                // catchErrorDriver にどの API のエラーか識別する仕組みがなく、かつ、
                // API の種類に関わらず一律アラートが表示されたり fetch 終了扱いとなるため、
                // ここで一律フラグを戻すようにした。
                self?.isLoadingBlackboardList = false

            })
            .disposed(by: disposeBag)
        
        self.networkService.showLoadingDriver
            .drive(onNext: { [weak self] _ in self?.outputRelay.accept(.showLoadingView) })
            .disposed(by: disposeBag)

        self.networkService.hideLoadingDriver
            .drive(onNext: { [weak self] _ in self?.outputRelay.accept(.hideLoadingView) })
            .disposed(by: disposeBag)
        
        // bind SearchQuery
        searchQueryRelay
            .asDriver()
            .distinctUntilChanged()
            .skip(1)
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.outputRelay.accept(
                    .changeFilterButtonState(hasSearchQuery: $0 != nil)
                )
                self.retryFetchingEvent()
            })
            .disposed(by: disposeBag)
        
        items
            .asSignal(onErrorJustReturn: [])
            .filter { !$0.isEmpty }
            .map { items in items.map { $0.sectionType }.first }
            .emit(to: isEmptyBlackboardsRelay)
            .disposed(by: disposeBag)
        
        items
            .asSignal(onErrorJustReturn: [])
            .map { _ in Output.doneFetching }
            .emit(to: outputRelay)
            .disposed(by: disposeBag)
        
        shouldShowAppUpdateViewRelay
            .asSignal(onErrorJustReturn: false)
            .distinctUntilChanged()
            .compactMap { $0 ? Output.showAppUpdateView : nil }
            .emit(to: outputRelay)
            .disposed(by: disposeBag)
        
        isEmptyBlackboardsRelay
            .asSignal()
            .map { sectionType -> [Output] in
                var outputs: [Output] = []
                guard let sectionType else {
                    outputs.append(.changeShowingFilterHeaderContainerView(isHidden: false))
                    outputs.append(.changeShowingSortHeaderView(isHidden: false))
                    return outputs
                }
                switch sectionType {
                case .empty:
                    outputs.append(.changeShowingFilterHeaderContainerView(isHidden: true))
                    outputs.append(.changeShowingSortHeaderView(isHidden: true))
                case .emptyWithFiltering:
                    outputs.append(.changeShowingFilterHeaderContainerView(isHidden: false))
                    outputs.append(.changeShowingSortHeaderView(isHidden: true))
                case .none:
                    outputs.append(.changeShowingFilterHeaderContainerView(isHidden: false))
                    outputs.append(.changeShowingSortHeaderView(isHidden: false))
                }
                return outputs
            }
            .emit(onNext: { outputs in
                outputs.forEach { [weak self] in self?.outputRelay.accept($0) }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: variable (included private static state)
extension ModernBlackboardListViewModel {
    var title: String {
        staticState.title
    }
}

// MARK: - private (event)
extension ModernBlackboardListViewModel {
    private func viewDidLoadEvent() {
        fetchBlackboardCommonSetting(.viewDidLoad, shouldThrottle: false)
    }
    
    private func pullToRefreshEvent() {
        fetchBlackboardCommonSetting(.pullToRefresh, shouldThrottle: false)
    }

    private func retryFetchingEvent() {
        retryFetchingBlackboardCommonSetting()
    }
    
    private func scrolledDownEvent() {
        guard !doneGettingLastItems,
              hasSomeItems else { return }
        fetchBlackboardCommonSetting(.scrolledDown, shouldThrottle: true)
    }
    
    private func didTapFilterButtonEvent() {
        outputRelay.accept(
            .presentFilterConditions(
                .init(
                    orderID: staticState.orderID,
                    searchQuery: searchQueryRelay.value,
                    willDismissHandler: { [weak self] in self?.receiveNewSearchQueryByFilterViewController($0) },
                    willDismissByCancelButtonHandler: {}, // NOTE: 現状は特に何も制御しない
                    willDismissByHistoryHandler: { [weak self] in self?.receiveNewSearchQueryByFilterViewController($0) },
                    appBaseRequestData: networkService.appBaseRequestData,
                    snapshotData: staticState.snapshotData,
                    advancedOptions: staticState.advancedOptions,
                    isOfflineMode: isOfflineMode.value
                )
            )
        )
    }
    
    private func receiveSortStateEvent(state: ModernBlackboardListSortView.SortState) {
        switch state {
        case .idASC:
            sortType = .positionASC
        case .idDESC:
            sortType = .positionDESC
        }
        retryFetchingBlackboardCommonSetting()
    }
    
    private func prefetchEvent(indexPaths: [IndexPath], isStartPrefetch: Bool) {
        let urls = indexPaths.compactMap { [weak self] in
            self?.items.value.first?
                .items[$0.row]
                .blackboardMaterial
                .miniatureMap?
                .imageThumbnailURL
        }
        guard !urls.isEmpty else { return }
        
        let output: Output = isStartPrefetch
            ? .startPrefetching(urls)
            : .stopPrefetching(urls)
        outputRelay.accept(output)
    }
    
    // test用にinternal化
    /// 別の箇所から検索クエリを受け取ったときの処理
    func receiveNewSearchQuery(
        _ searchQuery: SearchQuery?,
        shouldSaveSearchQuery: Bool,
        shouldUpdateFilterHeaderView: Bool = false
    ) {
        guard searchQueryRelay.value != searchQuery else { return }
        
        if shouldSaveSearchQuery,
           let historyHandler = blackboardhistoryHandler {
            if let unwrappedSearchQuery = searchQuery,
              !unwrappedSearchQuery.isDefaultCondition {
                let history = BlackboardFilterConditionsHistory(
                    orderID: staticState.orderID,
                    updatedAt: Date(),
                    query: unwrappedSearchQuery
                )

                // （検索に使用する）絞り込み履歴データを保存
                historyHandler.save(latestHistory: history, orderID: staticState.orderID)
                historyHandler.save(history: history)
                    .do(onDispose: { [weak self] in self?.outputRelay.accept(.hideLoadingView) })
                    .subscribe(onError: { assertionFailure($0.localizedDescription) })
                    .disposed(by: disposeBag)
            } else {
                // 絞り込み条件がリセットされている場合も、最新履歴として保存する
                historyHandler.save(latestHistory: nil, orderID: staticState.orderID)
            }
        }
        
        searchQueryRelay.accept(searchQuery)
        if shouldUpdateFilterHeaderView {
            outputRelay.accept(.updateSearchQuery(searchQuery))
        }
    }
    
    /// 絞り込み画面経由で検索クエリを受け取ったときの処理
    private func receiveNewSearchQueryByFilterViewController(_ searchQuery: SearchQuery?) {
        receiveNewSearchQuery(searchQuery, shouldSaveSearchQuery: false, shouldUpdateFilterHeaderView: true)
    }

    private func didTapCancelButtonEvent() {
        guard let blackboardSetting = blackboardCommonSettingRelay.value?.0 else {
            // 黒板設定APIを取得完了していない場合、取得完了まで待たずに閉じる操作を優先する
            outputRelay.accept(.dismiss(nil))
            return
        }
        outputRelay.accept(
            .dismiss(
                .init(
                    canEditBlackboardStyle: blackboardSetting.canEditBlackboardStyle,
                    blackboardSizeTypeOnServer: .init(sizeRate: blackboardSetting.blackboardDefaultSizeRate),
                    preferredPhotoFormat: blackboardSetting.preferredPhotoFormat
                )
            )
        )
    }
}

// MARK: - private (fetch)
extension ModernBlackboardListViewModel {
    private func fetchBlackboardCommonSetting(
        _ scene: FetchScene,
        shouldThrottle: Bool
    ) {
        fetchSceneRelay.accept(scene)
        if shouldThrottle {
            fetchBlackboardCommonSettingWithThrottleRelay.accept(())
        } else {
            fetchBlackboardCommonSettingRelay.accept(())
        }
    }
    
    private func retryFetchingBlackboardCommonSetting() {
        fetchBlackboardCommonSetting(.retryFetching, shouldThrottle: false)
    }
    
    private func willInitialFetch(with historyHandler: BlackboardHistoryHandlerProtocol) {
        historyHandler.getLatestHistory(orderID: staticState.orderID)
            .do(onDispose: { [weak self] in self?.outputRelay.accept(.hideLoadingView) })
            .subscribe(
                onSuccess: { [weak self] in
                    guard let self else { return }
                    guard let latestHistory = $0 else {
                        self.fetch(
                            pagingFetchingType: .initialFetch,
                            searchQuery: nil
                        )
                        return
                    }
                    // 直近の検索条件をセット
                    self.searchQueryRelay.accept(latestHistory.query)
                    self.outputRelay.accept(.updateSearchQuery(latestHistory.query))
                },
                onFailure: { [weak self] _ in
                    guard let self else { return }
                    self.fetch(
                        pagingFetchingType: .initialFetch,
                        searchQuery: self.searchQueryRelay.value
                    )
                    self.outputRelay.accept(.updateSearchQuery(self.searchQueryRelay.value))
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func fetch(
        pagingFetchingType: PagingFetchingType,
        searchQuery: ModernBlackboardSearchQuery?
    ) {
        self.pagingFetchingType = pagingFetchingType

        // NOTE: ページネーション時にこのメソッドが重複して呼ばれる問題があるため、
        // フラグを使って黒板情報取得中に再取得が走らないようにした。
        guard !isLoadingBlackboardList else { return }
        isLoadingBlackboardList = true

        networkService.getBlackboardResult(
            with: self.pagingFetchingType,
            orderID: staticState.orderID,
            searchQuery: searchQuery,
            sortType: sortType
        )
    }
}

// MARK: - private (BlackboardHistoryHandlerProtocol)
extension ModernBlackboardListViewModel {
    private var blackboardhistoryHandler: BlackboardHistoryHandlerProtocol? {
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

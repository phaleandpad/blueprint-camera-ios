//
//  ModernBlackboardNetworkService.swift
//  andpad-camera
//
//  Created by msano on 2021/01/11.
//

import RxCocoa
import RxSwift

enum ModernBlackboardsSortType: String {
    // NOTE: position == 黒板の並び順
    // （「黒板の並び順」とは、原則黒板の作成日順に並ぶが、ユーザー操作により任意に並び替えができる並びを表す）
    case positionASC = "position asc"
    case positionDESC = "position desc"
    
    var string: String {
        rawValue
    }
}

protocol ModernBlackboardNetworkServiceProtocol {
    func getBlackboardResult(
        with fetchingType: PagingFetchingType,
        orderID: Int,
        searchQuery: ModernBlackboardSearchQuery?,
        sortType: ModernBlackboardsSortType
    )
    func getBlackboardConditionItems(orderID: Int)
    func getBlackboardConditionItemContents(params: BlackboardConditionItemContentsParams, orderID: Int)
    func getBlackboardCommonSetting(orderID: Int)
    func postNewBlackboard(
        blackboardMaterial: ModernBlackboardMaterial,
        type: PostBlackboardType,
        orderID: Int
    )
    func putBlackboard(
        blackboardMaterial: ModernBlackboardMaterial,
        orderID: Int
    )
    func getBlackboardDetail(
        throttleConfiguration: ThrottleConfiguration,
        orderID: Int,
        blackboardID: Int
    )
    func getOrderPermissions(orderID: Int)

    var appBaseRequestData: AppBaseRequestData { get }
    var showLoadingDriver: Driver<Void> { get }
    var hideLoadingDriver: Driver<Void> { get }
    var catchErrorDriver: Driver<ErrorInformation> { get }

    var getBlackboardResultObservable: Observable<ResponseData<ModernBlackboardMaterial>> { get }
    var getBlackboardConditionItemsObservable: Observable<ResponseData<ModernBlackboardConditionItem>> { get }
    var getBlackboardConditionItemContentObservable: Observable<ResponseData<ModernBlackboardConditionItemContent>> { get }
    var getBlackboardCommonSettingObservable: Observable<ResponseData<ModernBlackboardCommonSetting>> { get }
    var getBlackboardDetailObservable: Observable<ResponseData<ModernBlackboardMaterial>> { get }
    var getOrderPermissionObservable: Observable<ResponseData<OrderAndPermissions>> { get }
    var postBlackboardObservable: Observable<ResponseData<ModernBlackboardMaterial>> { get }
    var putBlackboardObservable: Observable<ResponseData<ModernBlackboardMaterial>> { get }

    /// 絞り込み条件に該当する黒板の各項目名と状態を取得する。
    ///
    ///  - Returns: 絞り込んだ黒板の項目名のリスト。
    ///  - Note: 本メソッドを使用した場合は catchErrorRelay, willStartAPIRequestRelay, finishAPIRequestRelay に値は流れてきません。
    func fetchFilteredBlackboardItems(
        orderID: Int,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?
    ) async throws -> FetchFilteredBlackboardItemsResponse
    /// 絞り込んだ項目内容を取得する。
    ///
    ///  - Returns: 絞り込んだ黒板に対する選択可能な項目内容のリスト。
    ///  - Note: 本メソッドを使用した場合は catchErrorRelay, willStartAPIRequestRelay, finishAPIRequestRelay に値は流れてきません。
    func fetchFilteredBlackboardItemContents(
        orderID: Int,
        offset: Int?,
        limit: Int?,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?,
        blackboardItemBody: String,
        keyword: String?
    ) async throws -> ResponseData<FilteredBlackboardItemContent>
}

enum ThrottleConfiguration: Int {
    case enable = 1200
    case disable = 0

    var milliseconds: Int {
        rawValue
    }
}

struct ErrorInformation {
    let error: Error
    let requestType: ApiRequest.Type?
    
    init(error: Error, requestType: ApiRequest.Type? = nil) {
        self.error = error
        self.requestType = requestType
    }
}

final class ModernBlackboardNetworkService: ModernBlackboardNetworkServiceProtocol {
    typealias OrderID = Int
    typealias ParentID = Int
    typealias BlackboardID = Int
    typealias OffSet = Int

    private let apiManager: ApiManager
    private let willStartAPIRequestRelay = PublishRelay<Void>()
    private let finishAPIRequestRelay = PublishRelay<Void>()
    private let catchErrorRelay = PublishRelay<ErrorInformation>()
    private let throttleDueTimeMillisecondsRelay = BehaviorRelay<ThrottleConfiguration>(value: .enable)
    private let getBlackboardLayoutsRelay = BehaviorRelay<(PagingFetchingType, OrderID, AppBaseRequestData)?>(value: nil)
    private let getBlackboardResultRelay = BehaviorRelay<(PagingFetchingType, OrderID, ParentID?, ModernBlackboardSearchQuery?, ModernBlackboardsSortType, AppBaseRequestData)?>(value: nil)
    
    private let postBlackboardRelay = BehaviorRelay<(PostBlackboardParams, OrderID, AppBaseRequestData)?>(value: nil)
    private let putBlackboardRelay = BehaviorRelay<(PutBlackboardParams, OrderID, BlackboardID, AppBaseRequestData)?>(value: nil)
    
    private let getBlackboardDetailRelay = BehaviorRelay<(OrderID, BlackboardID, AppBaseRequestData)?>(value: nil)
    private let getBlackboardConditionItemsRelay = PublishRelay<(OrderID, AppBaseRequestData)>()
    private let getBlackboardConditionItemContentRelay = PublishRelay<(BlackboardConditionItemContentsParams, OrderID, AppBaseRequestData)>()
    private let getBlackboardCommonSettingRelay = PublishRelay<(OrderID, AppBaseRequestData)>()
    private let getOrderPermissionsRelay = PublishRelay<(OrderID, AppBaseRequestData)>()

    private let _appBaseRequestData: AppBaseRequestData
    
    var appBaseRequestData: AppBaseRequestData {
        _appBaseRequestData
    }

    init(
        appBaseRequestData: AppBaseRequestData,
        apiManager: ApiManager = ApiManager(client: AlamofireClient())
    ) {
        self._appBaseRequestData = appBaseRequestData
        self.apiManager = apiManager
    }
}

// MARK: - request API
extension ModernBlackboardNetworkService {
    func getBlackboardLayouts(
        with fetchingType: PagingFetchingType,
        throttleConfiguration: ThrottleConfiguration,
        orderID: Int
    ) {
        throttleDueTimeMillisecondsRelay.accept(throttleConfiguration)
        getBlackboardLayoutsRelay.accept(
            (
                fetchingType,
                orderID,
                _appBaseRequestData
            )
        )
    }
    
    func getBlackboardResult(
        with fetchingType: PagingFetchingType,
        orderID: Int,
        searchQuery: ModernBlackboardSearchQuery?,
        sortType: ModernBlackboardsSortType
    ) {
        getBlackboardResult(
            with: fetchingType,
            orderID: orderID,
            parentID: nil,
            searchQuery: searchQuery,
            sortType: sortType
        )
    }
    
    func getBlackboardResult(
        with fetchingType: PagingFetchingType,
        orderID: Int,
        parentID: Int? = nil,
        searchQuery: ModernBlackboardSearchQuery? = nil,
        sortType: ModernBlackboardsSortType
    ) {
        getBlackboardResultRelay.accept(
            (
                fetchingType,
                orderID,
                parentID,
                searchQuery,
                sortType,
                _appBaseRequestData
            )
        )
    }
    
    func postNewBlackboard(
        blackboardMaterial: ModernBlackboardMaterial,
        type: PostBlackboardType,
        orderID: Int
    ) {
        let params = PostBlackboardParams(
            // 黒板データ全体は渡さず、items部分のみを渡す
            blackboardData: blackboardMaterial.toPostableBlackboardItemData(),
            layoutTypeID: blackboardMaterial.layoutTypeID,
            miniatureMapID: blackboardMaterial.miniatureMap?.id,
            type: type,
            originalBlackboardID: {
                switch type {
                case .new:
                    // 新規の場合、nilでリクエストする
                    nil
                case .copy:
                    // コピー新規の場合、コピー元黒板のIDでリクエストする
                    // 未アップロード写真のアップロード時にはここを通らない
                    blackboardMaterial.id
                }
            }()
        )
        
        postBlackboardRelay.accept(
            (
                params,
                orderID,
                _appBaseRequestData
            )
        )
    }
    
    func putBlackboard(
        blackboardMaterial: ModernBlackboardMaterial,
        orderID: Int
    ) {
        let params = PutBlackboardParams(
            blackboardData: blackboardMaterial.toPostableBlackboardItemData(),
            layoutTypeID: blackboardMaterial.layoutTypeID
        )
        putBlackboardRelay.accept(
            (
                params,
                orderID,
                blackboardMaterial.id,
                _appBaseRequestData
            )
        )
    }
    
    func getBlackboardDetail(
        throttleConfiguration: ThrottleConfiguration,
        orderID: Int,
        blackboardID: Int
    ) {
        throttleDueTimeMillisecondsRelay.accept(throttleConfiguration)
        getBlackboardDetailRelay.accept(
            (orderID, blackboardID, _appBaseRequestData)
        )
    }
    
    func getBlackboardConditionItems(orderID: Int) {
        getBlackboardConditionItemsRelay.accept((orderID, _appBaseRequestData))
    }
    
    func getBlackboardConditionItemContents(params: BlackboardConditionItemContentsParams, orderID: OrderID) {
        getBlackboardConditionItemContentRelay.accept((params, orderID, _appBaseRequestData))
    }

    func getBlackboardCommonSetting(orderID: Int) {
        getBlackboardCommonSettingRelay.accept((orderID, _appBaseRequestData))
    }
    
    func getOrderPermissions(orderID: Int) {
        getOrderPermissionsRelay.accept((orderID, _appBaseRequestData))
    }

    func fetchFilteredBlackboardItems(
        orderID: Int,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?
    ) async throws -> FetchFilteredBlackboardItemsResponse {
        return try await apiManager.fetchFilteredBlackboardItems(
            orderID: orderID,
            filteringByPhoto: filteringByPhoto,
            miniatureMapLayout: miniatureMapLayout,
            searchQuery: searchQuery,
            appBaseRequestData: appBaseRequestData
        )
    }

    func fetchFilteredBlackboardItemContents(
        orderID: Int,
        offset: Int?,
        limit: Int?,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?,
        blackboardItemBody: String,
        keyword: String?
    ) async throws -> ResponseData<FilteredBlackboardItemContent> {
        return try await apiManager.fetchFilteredBlackboardItemContents(
            orderID: orderID,
            offset: offset,
            limit: limit,
            filteringByPhoto: filteringByPhoto,
            miniatureMapLayout: miniatureMapLayout,
            searchQuery: searchQuery,
            blackboardItemBody: blackboardItemBody,
            keyword: keyword,
            appBaseRequestData: appBaseRequestData
        )
    }
}

// MARK: - subscribe resposes
extension ModernBlackboardNetworkService {
    var showLoadingDriver: Driver<Void> {
        willStartAPIRequestRelay.asDriver(onErrorJustReturn: ())
    }

    var hideLoadingDriver: Driver<Void> {
        finishAPIRequestRelay.asDriver(onErrorJustReturn: ())
    }

    var catchErrorDriver: Driver<ErrorInformation> {
        apiManager.catchErrorDriver
    }

    var getBlackboardLayoutsObservable: Observable<ResponseData<ModernBlackboardLayout>> {
        getBlackboardLayoutsRelay
            .compactMap { $0 }
            .throttle(
                .milliseconds(throttleDueTimeMillisecondsRelay.value.milliseconds),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .do(onNext: { [weak self] _, _, _ in self?.willStartAPIRequestRelay.accept(()) })
            .map { type, orderID, appBaseRequestData -> (OffSet, OrderID, AppBaseRequestData) in
                switch type {
                case .initialFetch:
                    return (0, orderID, appBaseRequestData)
                case .paging(let offset):
                    return (offset, orderID, appBaseRequestData)
                }
            }
            .flatMap { [weak self] offset, orderID, appBaseRequestData -> Observable<ResponseData<ModernBlackboardLayout>> in
                guard let self else {
                    return .empty()
                }

                return self.apiManager
                    .getBlackboardLayouts(
                        .init(offset: offset),
                        orderID: orderID,
                        appBaseRequestData: appBaseRequestData
                    )
                    .asObservable()
            }
            .do(onNext: { [weak self] _ in self?.finishAPIRequestRelay.accept(()) })
    }

    var getBlackboardResultObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        getBlackboardResultRelay
            .compactMap { $0 }
            .throttle(
                .milliseconds(getBlackboardResultRelay.value?.0.throttleMilliseconds ?? 0),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .do(onNext: { [weak self] _, _, _, _, _, _ in self?.willStartAPIRequestRelay.accept(()) })
            .map { type, orderID, parentID, searchQuery, sortType, appBaseRequestData -> (OffSet, OrderID, ParentID?, ModernBlackboardSearchQuery?, ModernBlackboardsSortType, AppBaseRequestData) in
                switch type {
                case .initialFetch:
                    return (0, orderID, parentID, searchQuery, sortType, appBaseRequestData)
                case .paging(let offset):
                    return (offset, orderID, parentID, searchQuery, sortType, appBaseRequestData)
                }
            }
            .flatMap { [weak self] offset, orderID, parentID, searchQuery, sortType, appBaseRequestData -> Observable<ResponseData<ModernBlackboardMaterial>> in
                guard let self else {
                    return .empty()
                }

                return self.apiManager
                    .getBlackboardResults(
                        // 現状、ノードで取得した最後のparentIDを渡す
                        .init(
                            offset: offset,
                            blackboardTreeID: parentID,
                            photo: searchQuery?.photoCondition.value,
                            searchQuery: searchQuery,
                            sortTypeString: sortType.string
                        ),
                        orderID: orderID,
                        appBaseRequestData: appBaseRequestData
                    )
                    .asObservable()
            }
            .do(onNext: { [weak self] _ in self?.finishAPIRequestRelay.accept(()) })
    }
    
    var postBlackboardObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        postBlackboardRelay
            .compactMap { $0 }
            .throttle(
                .milliseconds(throttleDueTimeMillisecondsRelay.value.milliseconds),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .do(onNext: { [weak self] _, _, _ in self?.willStartAPIRequestRelay.accept(()) })
            .flatMap { [weak self] params, orderID, appBaseRequestData -> Observable<ResponseData<ModernBlackboardMaterial>> in
                guard let self else {
                    return .empty()
                }
                return self.apiManager.postBlackboard(
                    params,
                    orderID: orderID,
                    appBaseRequestData: appBaseRequestData
                )
                .asObservable()
            }
            .do(onNext: { [weak self] _ in self?.finishAPIRequestRelay.accept(()) })
    }
    
    var putBlackboardObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        putBlackboardRelay
            .compactMap { $0 }
            .throttle(
                .milliseconds(throttleDueTimeMillisecondsRelay.value.milliseconds),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .do(onNext: { [weak self] _, _, _, _ in self?.willStartAPIRequestRelay.accept(()) })
            .flatMap { [weak self] params, orderID, blackboardID, appBaseRequestData -> Observable<ResponseData<ModernBlackboardMaterial>> in
                guard let self else {
                    return .empty()
                }
                return self.apiManager.putBlackboard(
                    params,
                    orderID: orderID,
                    blackboardID: blackboardID,
                    appBaseRequestData: appBaseRequestData
                )
                .asObservable()
            }
            .do(onNext: { [weak self] _ in self?.finishAPIRequestRelay.accept(()) })
    }

    var getBlackboardDetailObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        getBlackboardDetailRelay
            .compactMap { $0 }
            .throttle(
                .milliseconds(throttleDueTimeMillisecondsRelay.value.milliseconds),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .do(onNext: { [weak self] _, _, _ in self?.willStartAPIRequestRelay.accept(()) })
            .flatMap { [weak self] orderID, blackboardID, appBaseRequestData -> Observable<ResponseData<ModernBlackboardMaterial>> in
                guard let self else {
                    return .empty()
                }
                return self.apiManager.getBlackboardDetail(
                    orderID: orderID,
                    blackboardID: blackboardID,
                    appBaseRequestData: appBaseRequestData
                )
                .asObservable()
            }
            .do(onNext: { [weak self] _ in self?.finishAPIRequestRelay.accept(()) })
    }
    
    var getBlackboardConditionItemsObservable: Observable<ResponseData<ModernBlackboardConditionItem>> {
        getBlackboardConditionItemsRelay
            .do(onNext: { [weak self] _, _ in self?.willStartAPIRequestRelay.accept(()) })
            .flatMap { [weak self] orderID, appBaseRequestData -> Observable<ResponseData<ModernBlackboardConditionItem>> in
                guard let self else {
                    return .empty()
                }
                return self.apiManager.getBlackboardConditionItems(
                    .init(contentType: .search, pagingType: .disable),
                    orderID: orderID,
                    appBaseRequestData: appBaseRequestData
                )
                .asObservable()
            }
            .do(onNext: { [weak self] _ in self?.finishAPIRequestRelay.accept(()) })
    }
    
    var getBlackboardConditionItemContentObservable: Observable<ResponseData<ModernBlackboardConditionItemContent>> {
        getBlackboardConditionItemContentRelay
            .do(onNext: { [weak self] _, _, _ in self?.willStartAPIRequestRelay.accept(()) })
            .flatMap { [weak self] params, orderID, appBaseRequestData -> Observable<ResponseData<ModernBlackboardConditionItemContent>> in
                guard let self else { return .empty() }
                return self.apiManager.getBlackboardConditionItemContents(
                    params,
                    orderID: orderID,
                    appBaseRequestData: appBaseRequestData
                )
                .asObservable()
            }
            .do(onNext: { [weak self] _ in self?.finishAPIRequestRelay.accept(()) })
    }

    var getBlackboardCommonSettingObservable: Observable<ResponseData<ModernBlackboardCommonSetting>> {
        getBlackboardCommonSettingRelay
            .do(onNext: { [weak self] _, _ in self?.willStartAPIRequestRelay.accept(()) })
            .flatMap { [weak self] orderID, appBaseRequestData -> Observable<ResponseData<ModernBlackboardCommonSetting>> in
                guard let self else {
                    return .empty()
                }
                return self.apiManager.getBlackboardCommonSetting(
                    orderID: orderID,
                    appBaseRequestData: appBaseRequestData
                )
                .asObservable()
            }
            .do(onNext: { [weak self] _ in self?.finishAPIRequestRelay.accept(()) })
    }
    
    var getOrderPermissionObservable: Observable<ResponseData<OrderAndPermissions>> {
        getOrderPermissionsRelay
            .do(onNext: { [weak self] _, _ in self?.willStartAPIRequestRelay.accept(()) })
            .flatMap { [weak self] orderID, appBaseRequestData -> Observable<ResponseData<OrderAndPermissions>> in
                guard let self else {
                    return .empty()
                }
                return self.apiManager.getOrderPermissions(
                    orderID: orderID,
                    appBaseRequestData: appBaseRequestData
                )
                .asObservable()
            }
            .do(onNext: { [weak self] _ in self?.finishAPIRequestRelay.accept(()) })
    }
}

// MARK: - fetching types
extension ModernBlackboardNetworkService {
    var getBlackboardLayoutsFetchingType: PagingFetchingType? {
        getBlackboardLayoutsRelay.value?.0
    }

    var getBlackboardResultFetchingType: PagingFetchingType? {
        getBlackboardResultRelay.value?.0
    }
}

// MARK: - PagingFetchingType
extension PagingFetchingType {
    
    // NOTE:
    // 黒板一覧取得における、throttleDueTimeMillisecondsRelayの挙動がおかしいため、
    // PagingFetchingTypeからthrottleするミリ秒を取得できるようにした
    // （他のAPIもこの方式に変えた方がよさそうだが、対応時期未定のためメモのみ残している）
    
    var throttleMilliseconds: Int {
        switch self {
        case .initialFetch:
            return 0
        case .paging:
            return 1200
        }
    }
}

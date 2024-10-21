//
//  ApiManager.swift
//  andpad-camera
//
//  Created by msano on 2020/11/05.
//

import RxCocoa
import RxSwift

struct ApiManager {
    /**  alamofireの通信clientを設定する */
    private let client: ClientProtocol
    private let catchErrorRelay = PublishRelay<ErrorInformation>()

    init(client: ClientProtocol) {
        self.client = client
    }
}

extension ApiManager {
    func getBlackboardLayouts(
        _ params: BlackboardLayoutParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<ResponseData<ModernBlackboardLayout>> {
        client.getBlackboardLayouts(
            params,
            orderID: orderID,
            appBaseRequestData: appBaseRequestData
        )
        .materialize()
        .compactMap { event -> Event<ResponseData<ModernBlackboardLayout>>? in
            guard case .error(let error) = event else { return event }
            catchErrorRelay.accept(.init(error: error))
            return .next(Self.emptyResponseData())
        }
        .dematerialize()
        .asSingle()
    }

    func getBlackboardResults(
        _ params: BlackboardResultParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<ResponseData<ModernBlackboardMaterial>> {
        client.getBlackboardResults(
            params,
            orderID: orderID,
            appBaseRequestData: appBaseRequestData
        )
        .materialize()
        .compactMap { event -> Event<ResponseData<ModernBlackboardMaterial>>? in
            guard case .error(let error) = event else { return event }
            catchErrorRelay.accept(.init(error: error))
            return .next(Self.emptyResponseData())
        }
        .dematerialize()
        .asSingle()
    }
    
    func postBlackboard(
        _ params: PostBlackboardParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<ResponseData<ModernBlackboardMaterial>> {
        client.postBlackboard(
            params,
            orderID: orderID,
            appBaseRequestData: appBaseRequestData
        )
        .materialize()
        .compactMap { event -> Event<ResponseData<ModernBlackboardMaterial>>? in
            guard case .error(let error) = event else { return event }
            catchErrorRelay.accept(
                .init(
                    error: error,
                    requestType: ApiRouter.PostBlackboardRequest.self
                )
            )
            return .next(Self.emptyResponseData())
        }
        .dematerialize()
        .asSingle()
    }
    
    func putBlackboard(
        _ params: PutBlackboardParams,
        orderID: Int,
        blackboardID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<ResponseData<ModernBlackboardMaterial>> {
        client.putBlackboard(
            params,
            orderID: orderID,
            blackboardID: blackboardID,
            appBaseRequestData: appBaseRequestData
        )
        .materialize()
        .compactMap { event -> Event<ResponseData<ModernBlackboardMaterial>>? in
            guard case .error(let error) = event else { return event }
            catchErrorRelay.accept(
                .init(
                    error: error,
                    requestType: ApiRouter.PutBlackboardRequest.self
                )
            )
            return .next(Self.emptyResponseData())
        }
        .dematerialize()
        .asSingle()
    }

    func getBlackboardDetail(
        orderID: Int,
        blackboardID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<ResponseData<ModernBlackboardMaterial>> {
        client.getBlackboardDetail(
            orderID: orderID,
            blackboardID: blackboardID,
            appBaseRequestData: appBaseRequestData
        )
        .materialize()
        .compactMap { event -> Event<ResponseData<ModernBlackboardMaterial>>? in
            guard case .error(let error) = event else { return event }
            catchErrorRelay.accept(.init(error: error))
            return .next(Self.emptyResponseData())
        }
        .dematerialize()
        .asSingle()
    }
    
    func getBlackboardConditionItems(
        _ params: BlackboardConditionItemsParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<ResponseData<ModernBlackboardConditionItem>> {
        client.getBlackboardConditionItems(
            params,
            orderID: orderID,
            appBaseRequestData: appBaseRequestData
        )
        .materialize()
        .compactMap { event -> Event<ResponseData<ModernBlackboardConditionItem>>? in
            guard case .error(let error) = event else { return event }
            catchErrorRelay.accept(.init(error: error))
            return .next(Self.emptyResponseData())
        }
        .dematerialize()
        .asSingle()
    }
    
    func getBlackboardConditionItemContents(
        _ params: BlackboardConditionItemContentsParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<ResponseData<ModernBlackboardConditionItemContent>> {
        client.getBlackboardConditionItemContents(
            params,
            orderID: orderID,
            appBaseRequestData: appBaseRequestData
        )
        .materialize()
        .compactMap { event -> Event<ResponseData<ModernBlackboardConditionItemContent>>? in
            guard case .error(let error) = event else { return event }
            catchErrorRelay.accept(.init(error: error))
            return .next(Self.emptyResponseData())
        }
        .dematerialize()
        .asSingle()
    }
    
    func getBlackboardCommonSetting(
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<ResponseData<ModernBlackboardCommonSetting>> {
        client.getBlackboardCommonSetting(
            orderID: orderID,
            appBaseRequestData: appBaseRequestData
        )
        .materialize()
        .compactMap { event -> Event<ResponseData<ModernBlackboardCommonSetting>>? in
            guard case .error(let error) = event else { return event }
            catchErrorRelay.accept(
                .init(
                    error: error,
                    requestType: ApiRouter.BlackboardCommonSettingRequest.self
                )
            )
            return .next(Self.emptyResponseData())
        }
        .dematerialize()
        .asSingle()
    }
    
    func getOrderPermissions(
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<ResponseData<OrderAndPermissions>> {
        client.getOrderPermissions(
            orderID: orderID,
            appBaseRequestData: appBaseRequestData
        )
        .materialize()
        .compactMap { event -> Event<ResponseData<OrderAndPermissions>>? in
            guard case .error(let error) = event else { return event }
            catchErrorRelay.accept(.init(error: error))
            return .next(Self.emptyResponseData())
        }
        .dematerialize()
        .asSingle()
    }

    func fetchFilteredBlackboardItems(
        orderID: Int,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?,
        appBaseRequestData: AppBaseRequestData
    ) async throws -> FetchFilteredBlackboardItemsResponse {
        try await withCheckedThrowingContinuation { continuation in
            // NOTE: Single は値が流れた後は自動でdisposeされるため、disposeBagをもたせる必要がない。
            _ = client.fetchFilteredBlackboardItems(
                orderID: orderID,
                filteringByPhoto: filteringByPhoto,
                miniatureMapLayout: miniatureMapLayout,
                searchQuery: searchQuery,
                appBaseRequestData: appBaseRequestData
            )
            .subscribe(
                onSuccess: { result in
                    continuation.resume(returning: result)
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }

    func fetchFilteredBlackboardItemContents(
        orderID: Int,
        offset: Int?,
        limit: Int?,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?,
        blackboardItemBody: String,
        keyword: String?,
        appBaseRequestData: AppBaseRequestData
    ) async throws -> ResponseData<FilteredBlackboardItemContent> {
        try await withCheckedThrowingContinuation { continuation in
            // NOTE: Single は値が流れた後は自動でdisposeされるため、disposeBagをもたせる必要がない。
            _ = client.fetchFilteredBlackboardItemContents(
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
            .subscribe(
                onSuccess: { result in
                    continuation.resume(returning: result)
                },
                onError: { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }
}

// MARK: - private
extension ApiManager {
    private static func emptyResponseData<T: Codable>() -> ResponseData<T> {
        ResponseData<T>(
            data: ResponsePeelData<T>(
                object: nil,
                objects: nil,
                lastFlg: nil,
                total: nil,
                permissions: nil
            )
        )
    }
}

// MARK: - error
extension ApiManager {
    var catchErrorDriver: Driver<ErrorInformation> {
        catchErrorRelay.asDriver(onErrorDriveWith: Driver.empty())
    }
}

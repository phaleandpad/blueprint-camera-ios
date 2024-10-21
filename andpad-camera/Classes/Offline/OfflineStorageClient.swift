//
//  OfflineClient.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/01/08.
//

import Foundation
import RxSwift

/// - Note: 本クラスはオフラインモード時に既存のAPIのI/Fを使って、ローカルDBの読み書きを行うためのクラスです。
/// 使用している I/F の都合上、オフラインモードで利用する I/F についてのみ実装し、使用しない I/F については既存と同じ API 呼び出しを仮実装しています。
final class OfflineStorageClient: ClientProtocol {
    enum OfflineStorageClientError: Error {
        case alreadyDeinit
    }

    private let userID: Int
    // オフラインモード時に使用しないAPI、およびオフラインモード時にもAPIから呼び出す処理がある場合はこれまで通りAPIから取得するようにする
    private let apiClient: ClientProtocol

    init(userID: Int, apiClient: ClientProtocol = AlamofireClient()) {
        self.userID = userID
        self.apiClient = apiClient
    }

    func getBlackboardLayouts(_ params: BlackboardLayoutParams, orderID: Int, appBaseRequestData: AppBaseRequestData) -> Observable<ResponseData<ModernBlackboardLayout>> {
        apiClient.getBlackboardLayouts(params, orderID: orderID, appBaseRequestData: appBaseRequestData)
    }

    func getBlackboardResults(_ params: BlackboardResultParams, orderID: Int, appBaseRequestData: AppBaseRequestData) -> Observable<ResponseData<ModernBlackboardMaterial>> {
        Single<ResponseData<ModernBlackboardMaterial>>.fromAwait { [weak self] in
            guard let self else { throw OfflineStorageClientError.alreadyDeinit }
            let blackboards = try await OfflineStorageHandler.shared.blackboard.fetchFilteredBlackboards(userID: self.userID, orderID: orderID, param: params)
            return ResponseData<ModernBlackboardMaterial>(data: .init(
                object: nil,
                objects: blackboards,
                lastFlg: true,
                total: blackboards.count,
                permissions: nil
            ))
        }
        .observe(on: MainScheduler.instance)
        .asObservable()
    }

    func postBlackboard(_ params: PostBlackboardParams, orderID: Int, appBaseRequestData: AppBaseRequestData) -> Observable<ResponseData<ModernBlackboardMaterial>> {
        apiClient.postBlackboard(params, orderID: orderID, appBaseRequestData: appBaseRequestData)
    }

    func putBlackboard(_ params: PutBlackboardParams, orderID: Int, blackboardID: Int, appBaseRequestData: AppBaseRequestData) -> Observable<ResponseData<ModernBlackboardMaterial>> {
        apiClient.putBlackboard(params, orderID: orderID, blackboardID: blackboardID, appBaseRequestData: appBaseRequestData)
    }

    func getBlackboardDetail(orderID: Int, blackboardID: Int, appBaseRequestData: AppBaseRequestData) -> Observable<ResponseData<ModernBlackboardMaterial>> {
        apiClient.getBlackboardDetail(orderID: orderID, blackboardID: blackboardID, appBaseRequestData: appBaseRequestData)
    }

    func getBlackboardConditionItems(_ params: BlackboardConditionItemsParams, orderID: Int, appBaseRequestData: AppBaseRequestData) -> Observable<ResponseData<ModernBlackboardConditionItem>> {
        Single<ResponseData<ModernBlackboardConditionItem>>.fromAwait { [weak self] in
            guard let self else { throw OfflineStorageClientError.alreadyDeinit }
            let conditionItems = try await OfflineStorageHandler.shared.blackboard.fetchBlackboardConditionItems(userID: self.userID, orderID: orderID, param: params)
            return ResponseData<ModernBlackboardConditionItem>(data: .init(
                object: nil,
                objects: conditionItems,
                lastFlg: true,
                total: conditionItems.count,
                permissions: nil
            ))
        }
        .observe(on: MainScheduler.instance)
        .asObservable()
    }

    func getBlackboardConditionItemContents(
        _ params: BlackboardConditionItemContentsParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardConditionItemContent>> {
        Single<ResponseData<ModernBlackboardConditionItemContent>>.fromAwait { [weak self] in
            guard let self else { throw OfflineStorageClientError.alreadyDeinit }
            let conditionItemContents = try await OfflineStorageHandler.shared.blackboard.fetchBlackboardConditionItemContents(userID: self.userID, orderID: orderID, param: params)
            return ResponseData<ModernBlackboardConditionItemContent>(data: .init(
                object: nil,
                objects: conditionItemContents,
                lastFlg: true,
                total: conditionItemContents.count,
                permissions: nil
            ))
        }
        .observe(on: MainScheduler.instance)
        .asObservable()
    }

    func getBlackboardCommonSetting(orderID: Int, appBaseRequestData: AppBaseRequestData) -> Observable<ResponseData<ModernBlackboardCommonSetting>> {
        Single<ResponseData<ModernBlackboardCommonSetting>>.fromAwait { [weak self] in
            guard let self else { throw OfflineStorageClientError.alreadyDeinit }
            let setting = try await OfflineStorageHandler.shared.blackboard.fetchBlackboardSetting(userID: self.userID, orderID: orderID)
            return ResponseData<ModernBlackboardCommonSetting>(data: .init(
                object: setting,
                objects: nil,
                lastFlg: nil,
                total: nil,
                permissions: nil
            ))
        }
        // NOTE: 呼び出し側で本メソッドが戻ってくる際にメインスレッドで戻ってくる前提で実装されている箇所があることから、戻す際にメインスレッドに戻すようにする。
        .observe(on: MainScheduler.instance)
        .asObservable()
    }

    func getOrderPermissions(orderID: Int, appBaseRequestData: AppBaseRequestData) -> Observable<ResponseData<OrderAndPermissions>> {
        apiClient.getOrderPermissions(orderID: orderID, appBaseRequestData: appBaseRequestData)
    }

    /// 絞り込み条件に該当する黒板の各項目名と状態を取得する。
    ///
    /// - Note: オフラインモード時は絞り込み結果に基づいた項目の活性・非活性制御は行わない。
    /// そのため、本処理で返すデータは項目については getBlackboardConditionItems と同じ挙動となり、黒板件数は getBlackboardResults と同じ挙動となる。
    func fetchFilteredBlackboardItems(
        orderID: Int,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<FetchFilteredBlackboardItemsResponse> {
        return Single<FetchFilteredBlackboardItemsResponse>.fromAwait { [weak self] in
            guard let self else { throw OfflineStorageClientError.alreadyDeinit }

            // 黒板件数の取得(全件取得)
            let blackboardResultParams = BlackboardResultParams(
                offset: 0,
                limit: 0,
                searchQuery: searchQuery,
                sortTypeString: ModernBlackboardsSortType.positionASC.rawValue  // 表示には使用しないので、 sortType は固定で問題なし。
            )
            let blackboards = try await OfflineStorageHandler.shared.blackboard.fetchFilteredBlackboards(
                userID: userID,
                orderID: orderID,
                param: blackboardResultParams
            )

            // 項目情報の取得
            let items = try await OfflineStorageHandler.shared.blackboard.fetchBlackboardConditionItems(
                userID: userID,
                orderID: orderID,
                param: .init(contentType: .search, pagingType: .disable)    // OfflineStorageHandler 側で param は使っていないので、固定値設定で問題なし。
            )
                .map {
                    FilteredBlackboardItem(
                        name: $0.body,
                        shouldDisplayWithHighPriority: $0.priorityDisplay,
                        blackboardExists: true  // オフラインモード時には考慮しないため、true固定で問題なし。
                    )
                }

            return .init(data: .init(
                blackboardCount: blackboards.count,
                items: items
            ))
        }
        .observeOn(MainScheduler.instance)
    }

    /// 絞り込んだ項目内容を取得する。
    ///
    /// - Note: offset, limit にかかわらず、全件返す実装になっています。
    /// - Note: オフラインモード時は絞り込み結果に基づいた項目内容の表示分けはサポートされません。そのため、filteringByPhoto, miniatureMapLayout, searchQuery は使用していません。
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
    ) -> Single<ResponseData<FilteredBlackboardItemContent>> {
        return Single<ResponseData<FilteredBlackboardItemContent>>.fromAwait { [weak self] in
            guard let self else { throw OfflineStorageClientError.alreadyDeinit }

            // オフラインモード時は1度に全件まとめて取得する
            let blackboardConditionItemContentsParams = BlackboardConditionItemContentsParams(
                offset: 0,
                limit: 0,
                type: .search,
                blackboardItemBody: blackboardItemBody,
                keyword: keyword
            )
            let contents = try await OfflineStorageHandler.shared.blackboard.fetchBlackboardConditionItemContents(
                userID: userID,
                orderID: orderID,
                param: blackboardConditionItemContentsParams
            )
                .map { FilteredBlackboardItemContent(content: $0.body) }

            // offset, limit の値にかかわらず、項目内容は全件返すようにする
            return .init(data: .init(
                object: nil,
                objects: contents,
                lastFlg: true,
                total: contents.count,
                permissions: nil
            ))
        }
        .observeOn(MainScheduler.instance)
    }
}

//
//  ClientProtocol.swift
//  andpad-camera
//
//  Created by msano on 2020/11/02.
//

import RxSwift

protocol ClientProtocol {
    func getBlackboardLayouts(
        _ params: BlackboardLayoutParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardLayout>>
    func getBlackboardResults(
        _ params: BlackboardResultParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardMaterial>>
    func postBlackboard(
        _ params: PostBlackboardParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardMaterial>>
    func putBlackboard(
        _ params: PutBlackboardParams,
        orderID: Int,
        blackboardID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardMaterial>>
    func getBlackboardDetail(
        orderID: Int,
        blackboardID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardMaterial>>
    func getBlackboardConditionItems(
        _ params: BlackboardConditionItemsParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardConditionItem>>
    func getBlackboardConditionItemContents(
        _ params: BlackboardConditionItemContentsParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardConditionItemContent>>
    func getBlackboardCommonSetting(
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardCommonSetting>>
    func getOrderPermissions(
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<OrderAndPermissions>>
    func fetchFilteredBlackboardItems(
        orderID: Int,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<FetchFilteredBlackboardItemsResponse>
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
    ) -> Single<ResponseData<FilteredBlackboardItemContent>>
}

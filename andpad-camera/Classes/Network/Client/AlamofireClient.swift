//
//  AlamofireClient.swift
//  andpad-camera
//
//  Created by msano on 2020/11/02.
//

import Alamofire
import Foundation
import Photos
import RxSwift
import UIImage_ResizeMagick

enum ApiError: Error {
    case generalError(message: String, cause: Error?)

    var message: String {
        switch self {
        case let .generalError(message: msg, cause: _):
            return msg
        }
    }
}

/** Apiサーバーからデータ取得を行うclient */
final class AlamofireClient: ClientProtocol {

    let alamofire: Session

    //    weak var delegate: AlamofireClientDelegate?
    private var _tempAccessToken: String?

    //    func setDelegate(_ clientDelagate: AlamofireClientDelegate) {
    //        self.delegate = clientDelagate
    //    }

    func setTempAccessToken(_ tempAccessToken: String?) {
        self._tempAccessToken = tempAccessToken
    }

    func tempAccessToken() -> String? {
        return _tempAccessToken
    }

    init () {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = TimeInterval(30)
        alamofire = Session(configuration: config)
    }

    func requestJSON<T> (_ request: T) -> Observable<T.ResponseType> where T: ApiRequest, T: URLRequestConvertible, T: ConvertRequest {
        request.tempAccessToken = _tempAccessToken
        return Observable.create { observer in
            self.alamofire.request(request).validate().responseJSON(options: .allowFragments, completionHandler: {response -> Void in
                guard let statusCode = response.response?.statusCode else {
                    observer.onError(NSError(domain: "", code: 0, userInfo: nil))
                    observer.onCompleted()
                    return
                }
                #if DEBUG
                print("🤡 receive response (statusCode): \(statusCode)")
                #endif

                switch response.result {
                case .success(let json):
                    #if DEBUG
                    print("🤡 json: ", json)
                    #endif

                    if statusCode >= 200 && statusCode < 300 {
                        let res = ApiResponse(responseObject: json as AnyObject?)
                        if let result = request.convertDataObject(response.data) {
                            observer.onNext(result)
                        } else if let result = request.convertJSONObject(res.data) {
                            observer.onNext(result)
                        } else {
                            let error = NSError(domain: "", code: 0, userInfo: nil)
                            observer.onError(error)
                        }
                    } else {
                        let message = "statusCodeが200番台以外です"

                        let error = ApiError.generalError(message: message, cause: nil)
                        observer.onError(error)
                    }
                case .failure(let error):
                    let message = "レスポンスパースに失敗しています"

                    let genralError = ApiError.generalError(message: message, cause: error)
                    observer.onError(genralError)
                }
                observer.onCompleted()
            })
            return Disposables.create() // AnonymousDisposable {}
        }
    }
}

extension AlamofireClient {
    func getBlackboardLayouts(
        _ params: BlackboardLayoutParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardLayout>> {
        requestJSON(
            ApiRouter.BlackboardLayoutsRequest(
                params: params,
                orderID: orderID,
                appBaseRequestData: appBaseRequestData
            )
        )
    }

    func getBlackboardResults(
        _ params: BlackboardResultParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardMaterial>> {
        requestJSON(
            ApiRouter.BlackboardResultsRequest(
                params: params,
                orderID: orderID,
                appBaseRequestData: appBaseRequestData
            )
        )
    }
    
    func postBlackboard(
        _ params: PostBlackboardParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardMaterial>> {
        requestJSON(
            ApiRouter.PostBlackboardRequest(
                params: params,
                orderID: orderID,
                appBaseRequestData: appBaseRequestData
            )
        )
    }
    
    func putBlackboard(
        _ params: PutBlackboardParams,
        orderID: Int,
        blackboardID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardMaterial>> {
        requestJSON(
            ApiRouter.PutBlackboardRequest(
                params: params,
                orderID: orderID,
                blackboardID: blackboardID,
                appBaseRequestData: appBaseRequestData
            )
        )
    }

    func getBlackboardDetail(
        orderID: Int,
        blackboardID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardMaterial>> {
        requestJSON(
            ApiRouter.BlackboardDetailRequest(
                orderID: orderID,
                blackboardID: blackboardID,
                appBaseRequestData: appBaseRequestData
            )
        )
    }
    
    func getBlackboardConditionItems(
        _ params: BlackboardConditionItemsParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardConditionItem>> {
        requestJSON(
            ApiRouter.BlackboardConditionItemsRequest(
                params,
                orderID: orderID,
                appBaseRequestData: appBaseRequestData
            )
        )
    }
    
    func getBlackboardConditionItemContents(
        _ params: BlackboardConditionItemContentsParams,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardConditionItemContent>> {
        requestJSON(
            ApiRouter.BlackboardConditionItemContentsRequest(
                params,
                orderID: orderID,
                appBaseRequestData: appBaseRequestData
            )
        )
    }

    func getBlackboardCommonSetting(
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<ModernBlackboardCommonSetting>> {
        requestJSON(
            ApiRouter.BlackboardCommonSettingRequest(
                orderID: orderID,
                appBaseRequestData: appBaseRequestData
            )
        )
    }
    
    func getOrderPermissions(
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) -> Observable<ResponseData<OrderAndPermissions>> {
        requestJSON(
            ApiRouter.OrderAndPermissionsRequest(
                orderID: orderID,
                appBaseRequestData: appBaseRequestData
            )
        )
    }

    func fetchFilteredBlackboardItems(
        orderID: Int,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?,
        appBaseRequestData: AppBaseRequestData
    ) -> Single<FetchFilteredBlackboardItemsResponse> {
        requestJSON(
            ApiRouter.FilteredBlackboardItemsRequest(
                orderID: orderID,
                filteringByPhoto: filteringByPhoto,
                miniatureMapLayout: miniatureMapLayout,
                searchQuery: searchQuery,
                appBaseRequestData: appBaseRequestData
            )
        )
        .asSingle()
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
    ) -> Single<ResponseData<FilteredBlackboardItemContent>> {
        requestJSON(
            ApiRouter.FilteredBlackboardItemContentsRequest(
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
        )
        .asSingle()
    }
}

struct ApiResponse {
    let data: AnyObject?
    var errorMessage = L10n.Common.error
    let app_badge: Int
    let chat_badge: Int

    init(responseObject: AnyObject?) {
        data = (responseObject as? NSDictionary)?.value(forKeyPath: "data") as? NSDictionary
        app_badge = 0
        chat_badge = 0
    }
}

extension AlamofireClient {
    struct MultipartConfiguringParameter {
        let photoSizeType: PhotoSizeType
        let photoResolutionType: ResolutionType
    }
}

//
//  ApiRouter.swift
//  andpad-camera
//
//  Created by msano on 2020/11/02.
//

import Alamofire
import Foundation

// MARK: - ConvertRequest
protocol ConvertRequest {
    associatedtype ResponseType: Any
    func convertJSONObject(_ object: AnyObject?) -> ResponseType?
    func convertDataObject(_ data: Data?) -> ResponseType?
}

extension ConvertRequest {
    func convertJSONObject(_ object: AnyObject?) -> ResponseType? {
        return nil
    }
    func convertDataObject(_ data: Data?) -> ResponseType? {
        return nil
    }
}

// MARK: - ApiRouter
enum ApiRouter {
    case blackboardLayouts(orderID: Int)
    case blackboardResults(orderID: Int)
    case postBlackboard(orderID: Int)
    case putBlackboard(orderID: Int, blackboardID: Int)
    case blackboardDetail(orderID: Int, blackboardID: Int)
    case blackboardConditionItems(orderID: Int)
    case blackboardConditionItemContents(orderID: Int)
    case blackboardCommonSetting(orderID: Int)
    case orderDetails(orderID: Int)
    case filteredBlackboardItems(orderID: Int)
    case filteredBlackboardItemContents(orderID: Int)
}

// MARK: - ApiRouter (path)
extension ApiRouter {
    var path: String {
        switch self {
        case .blackboardLayouts(let orderID):
            return "/my/orders/\(orderID)/blackboard_templates"
        case .blackboardResults(let orderID):
            return "/my/orders/\(orderID)/blackboards"
        case .postBlackboard(let orderID):
            return "/my/orders/\(orderID)/blackboards"
        case .putBlackboard(let orderID, let blackboardID):
            return "/my/orders/\(orderID)/blackboards/\(blackboardID)"
        case .blackboardDetail(let orderID, let blackboardID):
            return "/my/orders/\(orderID)/blackboards/\(blackboardID)"
        case .blackboardConditionItems(let orderID):
            return "/my/orders/\(orderID)/blackboards/blackboard_items"
        case .blackboardConditionItemContents(let orderID):
            return "/my/orders/\(orderID)/blackboards/blackboard_contents"
        case .blackboardCommonSetting(let orderID):
            return "/my/orders/\(orderID)/blackboard_setting"
        case .orderDetails(let orderID):
            return "/my/orders/\(orderID)"
        case .filteredBlackboardItems(let orderID):
            return "/my/orders/\(orderID)/blackboards/filter_items"
        case .filteredBlackboardItemContents(let orderID):
            return "/my/orders/\(orderID)/blackboards/filter_contents"
        }
    }
}

// MARK: - ApiRouter (request class)
extension ApiRouter {
    class BlackboardLayoutsRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<ModernBlackboardLayout>

        init(
            params: BlackboardLayoutParams,
            orderID: Int,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                params: params,
                router: .blackboardLayouts(orderID: orderID),
                method: .get,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }

    class BlackboardResultsRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<ModernBlackboardMaterial>

        init(
            params: BlackboardResultParams,
            orderID: Int,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                params: params,
                router: .blackboardResults(orderID: orderID),
                method: .get,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }
    
    class PostBlackboardRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<ModernBlackboardMaterial>

        init(
            params: ApiParams,
            orderID: Int,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                params: params,
                router: .postBlackboard(orderID: orderID),
                method: .post,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }
    
    class PutBlackboardRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<ModernBlackboardMaterial>

        init(
            params: ApiParams,
            orderID: Int,
            blackboardID: Int,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                params: params,
                router: .putBlackboard(orderID: orderID, blackboardID: blackboardID),
                method: .put,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }
    
    class BlackboardDetailRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<ModernBlackboardMaterial>

        init(
            orderID: Int,
            blackboardID: Int,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                router: .blackboardDetail(
                    orderID: orderID,
                    blackboardID: blackboardID
                ),
                method: .get,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }
    
    class BlackboardConditionItemsRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<ModernBlackboardConditionItem>

        init(
            _ params: BlackboardConditionItemsParams,
            orderID: Int,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                params: params,
                router: ApiRouter.blackboardConditionItems(orderID: orderID),
                method: .get,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }
    
    class BlackboardConditionItemContentsRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<ModernBlackboardConditionItemContent>

        init(
            _ params: ApiParams?,
            orderID: Int,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                params: params,
                router: ApiRouter.blackboardConditionItemContents(orderID: orderID),
                method: .get,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }

    class BlackboardCommonSettingRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<ModernBlackboardCommonSetting>

        init(
            orderID: Int,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                router: .blackboardCommonSetting(orderID: orderID),
                method: .get,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }
    
    class OrderAndPermissionsRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<OrderAndPermissions>
        typealias InnerResponseType = ResponseData<Order>

        init(
            orderID: Int,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                router: .orderDetails(orderID: orderID),
                method: .get,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        // 実際にとりたい値はResponsePeelData.permissionsにある
        // が、取り回しずらいのでResponseDataのジェネリクスモデルになるよう手動操作している
        func convertDataObject(_ data: Data?) -> ResponseType? {
            guard let data else { return nil }
            do {
                let responseData = try JSONDecoder().decode(InnerResponseType.self, from: data)
                let permissions = Permissions(list: responseData.data.permissions ?? [])
                let order = responseData.data.object
                return ResponseType(
                    data: .init(
                        object: OrderAndPermissions(order: order, permissions: permissions),
                        objects: nil,
                        lastFlg: responseData.data.lastFlg,
                        total: responseData.data.total,
                        permissions: responseData.data.permissions
                    )
                )
            } catch {
                catchError(error)
                return nil
            }
        }
    }

    final class FilteredBlackboardItemsRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = FetchFilteredBlackboardItemsResponse

        init(
            orderID: Int,
            filteringByPhoto: FilteringByPhotoType,
            miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
            searchQuery: ModernBlackboardSearchQuery?,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                params: FetchFilteredBlackboardItemsParam(
                    filteringByPhoto: filteringByPhoto,
                    miniatureMapLayout: miniatureMapLayout,
                    searchQuery: searchQuery
                ),
                router: .filteredBlackboardItems(orderID: orderID),
                method: .get,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }

    final class FilteredBlackboardItemContentsRequest: ApiRequest, URLRequestConvertible, ConvertRequest {
        typealias ResponseType = ResponseData<FilteredBlackboardItemContent>

        init(
            orderID: Int,
            offset: Int?,
            limit: Int?,
            filteringByPhoto: FilteringByPhotoType,
            miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
            searchQuery: ModernBlackboardSearchQuery?,
            blackboardItemBody: String,
            keyword: String?,
            appBaseRequestData: AppBaseRequestData
        ) {
            super.init(
                params: FetchFilteredBlackboardItemContentsParam(
                    offset: offset,
                    limit: limit,
                    filteringByPhoto: filteringByPhoto,
                    miniatureMapLayout: miniatureMapLayout,
                    searchQuery: searchQuery,
                    blackboardItemBody: blackboardItemBody,
                    keyword: keyword
                ),
                router: .filteredBlackboardItemContents(orderID: orderID),
                method: .get,
                appBaseData: appBaseRequestData
            )
        }

        func asURLRequest() throws -> URLRequest {
            return self.URLRequest as URLRequest
        }

        func convertDataObject(_ data: Data?) -> ResponseType? {
            ApiRouter.convertDataObject(with: data)
        }
    }
}

// MARK: - private
extension ApiRouter {
    // NOTE: ResponseTypeの通りにパースしたい場合はこちらを利用する
    private static func convertDataObject<ResponseType: Decodable>(with data: Data?) -> ResponseType? {
        guard let data else { return nil }
        do {
            return try JSONDecoder().decode(ResponseType.self, from: data)
        } catch {
            catchError(error)
            return nil
        }
    }
    
    private static func catchError(_ error: Error) {
        print("json convert failed in JSONDecoder \(error)")
    }
}

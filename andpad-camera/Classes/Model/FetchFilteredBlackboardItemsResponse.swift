//
//  FetchFilteredBlackboardItemsResponse.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/03/26.
//

import Foundation

/// `GET /my/orders/\(orderID)/blackboards/filter_items` のリクエストレスポンス。
///
/// - Note: ResponseData だと blackboardCount が取得できないことから、別途モデルを定義した。
public struct FetchFilteredBlackboardItemsResponse: Decodable {
    public let data: DataAndBlackboardCount

    public struct DataAndBlackboardCount: Decodable {
        public let blackboardCount: Int
        public let items: [FilteredBlackboardItem]

        private enum CodingKeys: String, CodingKey {
            case items = "objects"
            case blackboardCount = "blackboard_count"
        }
    }
}

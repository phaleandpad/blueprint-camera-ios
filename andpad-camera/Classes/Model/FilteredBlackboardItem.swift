//
//  FilteredBlackboardItem.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/03/11.
//

import Foundation

/// 絞り込み画面で表示する黒板項目情報。
///
/// - Note: `GET /my/orders/\(orderID)/blackboards/filter_items` のリクエストレスポンスの一部としても使用する。
public struct FilteredBlackboardItem: Decodable, Sendable {
    /// 項目名。
    public let name: String
    /// 優先表示するかどうか。
    public let shouldDisplayWithHighPriority: Bool
    /// 該当する黒板が1件以上存在するかどうか。
    public let blackboardExists: Bool

    private enum CodingKeys: String, CodingKey {
        case name = "body"
        case shouldDisplayWithHighPriority = "priority_display"
        case blackboardExists = "is_blackboard_exists"
    }
}

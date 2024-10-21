//
//  FilteredBlackboardItemContent.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/03/11.
//

import Foundation

/// 絞り込み小画面で表示する項目内容情報。
///
/// - Note: `GET /my/orders/\(orderID)/blackboards/filter_contents` のレスポンスモデルとして使用する。
public struct FilteredBlackboardItemContent: Codable, Sendable {
    public let content: String

    private enum CodingKeys: String, CodingKey {
        case content = "body"
    }
}

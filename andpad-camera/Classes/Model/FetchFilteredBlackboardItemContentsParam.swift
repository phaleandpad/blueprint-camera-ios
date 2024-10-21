//
//  FetchFilteredBlackboardItemContentsParam.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/03/11.
//

import Foundation

/// `GET /my/orders/\(orderID)/blackboards/filter_contents` のリクエストパラメータ生成を行うクラス。
public struct FetchFilteredBlackboardItemContentsParam: ApiParams {
    /// ページ。
    /// - NOTE: アプリでは利用していないのでnilを決め打ちします。必要になったらnil決め打ちを解除してください。
    let page: Int? = nil
    /// オフセット。
    let offset: Int?
    /// 一度に取得する最大数。
    let limit: Int?
    /// 写真有無による絞り込み指定。
    let filteringByPhoto: FilteringByPhotoType
    /// 豆図レイアウト黒板の豆図有無による絞り込み。
    let miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?
    /// 絞り込みクエリ。
    let searchQuery: ModernBlackboardSearchQuery?
    /// 黒板項目名。
    let blackboardItemBody: String
    /// 項目内容絞り込みのために使用するキーワード。
    let keyword: String?

    func toDict() -> [String: Any] {
        var params: [String: Any] = [:]

        if let page {
            params["page"] = page
        }

        if let offset {
            params["offset"] = offset
        }

        if let limit {
            params["limit"] = limit
        }

        params["photo"] = filteringByPhoto.photoParameter

        if let miniatureMapLayout {
            params["miniature_map_layout"] = miniatureMapLayout.rawValue
        }

        if let searchQueryJSON = searchQuery?.jsonString {
            params["query"] = searchQueryJSON
        }

        params["blackboard_item_body"] = blackboardItemBody

        if let keyword {
            params["keyword"] = keyword
        }

        return params
    }
}

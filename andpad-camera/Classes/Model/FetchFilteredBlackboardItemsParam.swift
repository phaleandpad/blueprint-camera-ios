//
//  FetchFilteredBlackboardItemsParam.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/03/11.
//

import Foundation

/// `GET /my/orders/\(orderID)/blackboards/filter_items` のリクエストパラメータ生成を行うクラス。
public struct FetchFilteredBlackboardItemsParam: ApiParams {

    /// 写真有無による絞り込み指定。
    let filteringByPhoto: FilteringByPhotoType
    /// 豆図レイアウト黒板の豆図有無による絞り込み。
    let miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?
    /// 絞り込みクエリ。
    let searchQuery: ModernBlackboardSearchQuery?

    func toDict() -> [String: Any] {
        var params: [String: Any] = [:]

        params["photo"] = filteringByPhoto.photoParameter

        if let miniatureMapLayout {
            params["miniature_map_layout"] = miniatureMapLayout.rawValue
        }

        if let searchQueryJSON = searchQuery?.jsonString {
            params["query"] = searchQueryJSON
        }

        return params
    }
}

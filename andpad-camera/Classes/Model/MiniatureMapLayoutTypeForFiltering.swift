//
//  MiniatureMapLayoutTypeForFiltering.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/03/13.
//

import Foundation

/// 絞り込む際の豆図レイアウト種別
public enum MiniatureMapLayoutTypeForFiltering: String {
    /// 豆図レイアウト黒板全て
    case all = "all"
    /// 豆図レイアウト黒板で豆図画像を保持
    case hasMiniatureMap = "miniature_map_exist"
    /// 豆図レイアウト黒板で豆図画像を未所持
    case noMiniatureMap = "miniature_map_none"
}

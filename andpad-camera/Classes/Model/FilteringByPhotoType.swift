//
//  FilteringByPhotoType.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/03/13.
//

import Foundation

/// 黒板絞り込み時の写真有無の指定で指定可能な種別。
public enum FilteringByPhotoType {
    /// 全ての黒板
    case all
    /// 写真が紐づいている黒板
    case hasPhoto
    /// 写真が紐づいていない黒板
    case noPhoto

    /// リクエストパラメータで指定する値へ変換したものを返す。
    var photoParameter: Bool? { // swiftlint:disable:this discouraged_optional_boolean
        switch self {
        case .all:
            return nil
        case .hasPhoto:
            return true
        case .noPhoto:
            return false
        }
    }
}

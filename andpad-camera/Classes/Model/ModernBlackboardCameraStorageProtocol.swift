//
//  ModernBlackboardCameraStorageProtocol.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/05/09.
//

import Foundation

/// 新黒板付き撮影画面のストレージに関するプロトコル
public protocol ModernBlackboardCameraStorageProtocol {
    // MARK: 案件ごとの黒板設定既読フラグの管理

    /// 指定した案件IDの黒板設定既読フラグの値を取得する
    /// - Parameter orderID: 案件ID
    /// - Returns: 既読フラグの値
    func getBlackboardSettingsReadFlag(for orderID: Int) -> Bool
    /// 指定した案件IDの黒板設定既読フラグの値を設定する
    /// - Parameters:
    ///  - orderID: 案件ID
    ///  - isRead: 既読かどうか。 `true` なら既読、`false` なら未読
    func setBlackboardSettingsReadFlag(for orderID: Int, isRead: Bool)
    /// すべての案件の黒板設定既読フラグの値を全削除する
    func deleteBlackboardSettingsReadFlags()
}

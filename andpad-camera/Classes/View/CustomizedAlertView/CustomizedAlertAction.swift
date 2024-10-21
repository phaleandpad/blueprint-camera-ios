//
//  CustomizedAlertAction.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2023/11/08.
//

import SnapKit
import UIKit

// MARK: - CustomizedAlertAction

/// カスタマイズされたアラートビューのためのカスタムアクションクラス
final class CustomizedAlertAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((CustomizedAlertAction) -> Void)?

    /// 初期化
    /// - Parameters:
    ///   - title: タイトル
    ///   - style: スタイル
    ///   - handler: 完了ハンドラー
    init(title: String, style: UIAlertAction.Style, handler: ((CustomizedAlertAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

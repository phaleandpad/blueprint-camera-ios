//
//  ImageLazyLoading.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/09/24.
//

import UIKit

/// View 内で画像を表示する際に読み込みタイミングを遅延させたい場合に使用する protocol。
///
/// - Note: 例えば、 Cell などで動的に生成した画像を読み込む際に生成タイミングを Cell 表示タイミングまでずらしたい場合に使用します。
protocol ImageLazyLoading {
    /// 画像の読み込みを行う。
    ///
    /// - Note: 実際に画像の読み込み処理を行うタイミングで本メソッドを呼出してください。
    func load() -> UIImage?
}

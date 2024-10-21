//
//  TakeCameraGridLineView.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/04/01.
//

import AndpadUIComponent
import SnapKit
import UIKit

// MARK: - TakeCameraGridLineView

/// 撮影画面のカメラのキャプチャエリアに表示するグリッド線を描画するビュー
///
/// ユーザーが黒板の位置を決めるためのガイドラインの役割を果たす。
///
/// - Note: グリッド線への吸着は実装しない。
final class TakeCameraGridLineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        // タッチイベントがこのViewを通過して下層のビューに到達するようにする
        isUserInteractionEnabled = false

        // 水平セパレーターの設定
        setUpSeparators(count: 2, isHorizontal: true)
        // 垂直セパレーターの設定
        setUpSeparators(count: 2, isHorizontal: false)
    }

    /// セパレーターを設定する
    /// - Parameters:
    ///   - count: セパレーターの数
    ///   - isHorizontal: セパレーターの方向
    private func setUpSeparators(count: Int, isHorizontal: Bool) {
        for index in 1 ... count {
            let separator = UIView()
            separator.backgroundColor = .tsukuri.system.extraLightBorder
            separator.alpha = 0.5
            addSubview(separator)

            // セパレーターの太さとして、1物理ピクセルを計算
            let thickness = 1 / traitCollection.displayScale

            if isHorizontal {
                separator.snp.makeConstraints { make in
                    make.height.equalTo(thickness)
                    make.horizontalEdges.equalToSuperview()
                    // 親ビューの高さを等分する位置にセパレーターを配置。計算上は親ビューのcenterYを基準にしている。
                    make.centerY.equalToSuperview().multipliedBy(CGFloat(index) / CGFloat(count + 1) * 2.0)
                }
            } else {
                separator.snp.makeConstraints { make in
                    make.width.equalTo(thickness)
                    make.verticalEdges.equalToSuperview()
                    // 親ビューの幅を等分する位置にセパレーターを配置。計算上は親ビューのcenterXを基準にしている。
                    make.centerX.equalToSuperview().multipliedBy(CGFloat(index) / CGFloat(count + 1) * 2.0)
                }
            }
        }
    }
}

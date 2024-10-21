//
//  RoundGrayButton.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2023/08/16.
//

import AndpadUIComponent
import UIKit

// MARK: - RoundGrayButton

/// 角丸のグレー背景のボタン
///
/// 黒板の絞り込み画面で使用される。
final class RoundGrayButton: UIButton {
    /// 通常状態の背景色
    private let normalBackgroundColor: UIColor = .tsukuri.system.surface2()
    // NOTE: ボタンのハイライトおよび選択状態の背景色はデザインガイドラインが策定されたら反映すること
    /// ハイライトおよび選択状態の背景色
    private let highlightedBackgroundColor: UIColor = .tsukuri.system.surface2()
    /// 通常状態のテキストの色
    private let normalTextColor: UIColor = .tsukuri.system.primaryTextOnSurface2
    // NOTE: ボタンテキストのハイライトおよび選択状態の背景色はデザインガイドラインが策定されたら反映すること
    /// ハイライトおよび選択状態のテキストの色
    private let highlightedTextColor: UIColor = .tsukuri.system.primaryTextOnSurface2

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 初期化時の共通設定
    func commonInit() {
        setTitleColor(normalTextColor, for: .normal)
        setTitleColor(highlightedTextColor, for: .highlighted)
        setTitleColor(highlightedTextColor, for: .selected)
        backgroundColor = .tsukuri.system.surface2()

        layer.cornerRadius = 14
        layer.masksToBounds = true

        titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel?.adjustsFontForContentSizeCategory = true
        contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        sizeToFit()

        self.snp.makeConstraints { make in
            // ダイナミックフォントに対応させるため大きい方の高さを設定
            make.height.greaterThanOrEqualTo(28)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightedBackgroundColor : normalBackgroundColor
        }
    }

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? highlightedBackgroundColor : normalBackgroundColor
        }
    }
}

//
//  TakeCameraIconAndTitleButton.swift
//  andpad-camera
//
//  Created by 吉田範之@andpad on 2023/03/10.
//

import UIKit

final class TakeCameraIconAndTitleButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }

    private func setUpViews() {
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5

        setTitleColor(.tsukuri.system.primaryTextOnInverseSurface, for: .normal)
        setTitleColor(.tsukuri.system.disabledTextOnInverseSurface, for: .disabled)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        alignVerticallyAndCenterHorizontally()
    }

    /// アイコンとタイトルを垂直方向に並べて、水平方向は中央寄せにする
    private func alignVerticallyAndCenterHorizontally() {
        let spacing: CGFloat = 2.0

        let imageSize = imageView?.frame.size ?? .zero

        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -(frame.size.width) / 2,
            bottom: -(imageSize.height + spacing),
            right: 0
        )

        let titleSize = titleLabel?.intrinsicContentSize ?? .zero

        imageEdgeInsets = UIEdgeInsets(
            top: -(titleSize.height + spacing),
            left: 0,
            bottom: 0,
            right: -(titleSize.width)
        )
    }
}

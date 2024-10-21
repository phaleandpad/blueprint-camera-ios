//
//  BlackboardHandleView.swift
//  andpad-camera
//
//  Created by msano on 2021/06/14.
//

import UIKit

// NOTE:
// カメラ画面で黒板の4隅にある白丸（ = ハンドル）のためのView
final class BlackboardHandleView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCircleStyle()
        configureShadow()
    }
}

// MARK: - private
extension BlackboardHandleView {
    private func configureCircleStyle() {
        circleStyle = true
    }

    private func configureShadow() {
        clipsToBounds = false
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowRadius = self.frame.size.width / 2.0
    }
}

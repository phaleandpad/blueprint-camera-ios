//
//  UIImageView+MiniatureMap.swift
//  andpad-camera
//
//  Created by msano on 2022/09/01.
//

extension UIImageView {
    /// 豆図画像表示用の外観を整える
    func apply(_ appearance: MiniatureMapImageViewAppearance) {
        contentMode = appearance.contentMode
        backgroundColor = appearance.backgroundColor
        
        if let tintColor = appearance.tintColor {
            image = appearance.image.withRenderingMode(.alwaysTemplate)
            self.tintColor = tintColor
        } else {
            image = appearance.image
        }
    }
}

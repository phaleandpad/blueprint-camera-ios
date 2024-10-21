//
//  UIButton+IBDesignable.swift
//  andpad-camera
//
//  Created by msano on 2020/11/16.
//

import UIKit

extension UIButton {
    @IBInspectable
    var buttonBorderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
}

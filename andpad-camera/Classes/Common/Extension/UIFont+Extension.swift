//
//  UIFont+Extension.swift
//  andpad-camera
//
//  Created by msano on 2020/12/10.
//

extension UIFont {
    enum Andpad: String {
        case hiraginoW3 = "HiraginoSans-W3"
        case hiraginoW6 = "HiraginoSans-W6"

        var name: String {
            rawValue
        }
    }

    class func appFont(_ weight: FontWeight, size: CGFloat) -> UIFont {
        switch weight {
        case .w3:
            return UIFont.systemFont(ofSize: size)
        case .w6:
            return UIFont.boldSystemFont(ofSize: size)
        }
    }

    enum FontWeight {
        case w3
        case w6
    }
}

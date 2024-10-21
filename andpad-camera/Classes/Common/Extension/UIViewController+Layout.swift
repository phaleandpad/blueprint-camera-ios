//
//  UIViewController+Layout.swift
//  andpad-camera
//
//  Created by msano on 2022/01/12.
//

extension UIViewController {
    var FOOTER_HEIGHT: CGFloat {
        let defaultHeight: CGFloat = 44
        guard let window = UIApplication.shared.keyWindow else {
            return defaultHeight
        }
        return defaultHeight + window.safeAreaInsets.bottom + 2
    }
    
    static let DEFAULT_NAVIGATIONBAR_HEIGHT: CGFloat = 44
}

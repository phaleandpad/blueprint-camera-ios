//
//  UIViewController+Find.swift
//  andpad-camera
//
//  Created by msano on 2022/02/09.
//

import UIKit

extension UIViewController {
    enum FindType {
        /// 「自身のVCより前にスタックしているか」確認する際に使用
        case presenting
        
        /// 「自身のVCより後にスタックしているか」確認する際に使用
        case presented
    }
    
    func hasAlreadyStacked<T: UIViewController>(vcType: T.Type, findType: FindType) -> Bool {
        switch findType {
        case .presenting:
            guard let navigationController = self.presentingViewController as? UINavigationController else { return false }
            return navigationController.topViewController is T
        case .presented:
            guard let navigationController = self.presentedViewController as? UINavigationController else { return false }
            return navigationController.topViewController is T
        }
    }
}

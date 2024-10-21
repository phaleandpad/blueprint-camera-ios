//
//  UIView+Find.swift
//  andpad-camera_Tests
//
//  Created by Yuka Kobayashi on 2021/06/29.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import UIKit

// MARK: - has
extension UIView {
    func hasLabel(with text: String) -> Bool {
        return hasSubview { (label: UILabel) -> Bool in
            return label.text == text
        }
    }

    func hasButton(with text: String) -> Bool {
        return hasSubview { (button: UIButton) -> Bool in
            return button.title(for: .normal) == text
        }
    }
    
    func hasSubview<T: UIView>(with _: T.Type) -> Bool {
        return hasSubview { (view: UIView) -> Bool in
            return view is T
        }
    }

    func hasSubview<T: UIView>(withCondition condition: (T) -> Bool) -> Bool {
        for view in subviews {
            if let viewAsT = view as? T, condition(viewAsT) {
                return true
            }

            if view.hasSubview(withCondition: condition) {
                return true
            }
        }

        return false
    }
}

// MARK: - find
extension UIView {
    func findButton(with text: String) -> [UIButton] {
        return findSubviews { (button: UIButton) -> Bool in
            return button.currentTitle == text
        }
    }
    
    func findSubviews<T: UIView>(with _: T.Type) -> [T] {
        return findSubviews { (view: UIView) -> Bool in
            return view is T
        }
    }

    func findSubviews<T: UIView>(withCondition condition: (T) -> Bool) -> [T] {
        var views: [T] = []

        subviews.forEach {
            if let view = $0 as? T, condition(view) {
                views.append(view)
            }

            views += $0.findSubviews(withCondition: condition)
        }

        return views
    }
}

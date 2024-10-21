//
//  UIAccessibilityIdentification+Identifier.swift
//  andpad-camera
//
//  Created by msano on 2021/10/28.
//

// ref: https://www.lordcodes.com/tips/sharing-accessibility-ids-app-and-tests

public extension UIAccessibilityIdentification {
    var viewAccessibilityIdentifier: ViewAccessibilityIdentifier? {
        get { fatalError("Not implemented") }
        set {
            accessibilityIdentifier = newValue?.rawValue
        }
    }
}

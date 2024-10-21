//
//  XCUIElementQuery+Identifier.swift
//  UITests
//
//  Created by msano on 2021/10/29.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import XCTest

extension XCUIElementQuery {
    subscript(key: ViewAccessibilityIdentifier) -> XCUIElement {
        self[key.rawValue]
    }
}

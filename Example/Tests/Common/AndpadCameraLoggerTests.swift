//
//  AndpadCameraLoggerTests.swift
//  andpad-camera_Tests
//
//  Created by 成瀬 未春 on 2023/10/02.
//  Copyright © 2023 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick
import XCTest

final class AndpadCameraLoggerTests: QuickSpec {
    override class func spec() {
        describe("AndpadCameraLogger test") {
            context("nonFatalError method") {
                it("nonFatalErrorActionが実行される") {
                    // Arrange
                    let logger = AndpadCameraLogger()
                    var flag = false
                    logger.nonFatalErrorAction = { error in
                        flag = true
                    }

                    // Act
                    let error = NSError(domain: "test", code: 0)
                    logger.nonFatalError(error)

                    // Assert
                    expect(flag).to(beTrue())
                }
            }
        }
    }
}

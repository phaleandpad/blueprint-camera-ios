//
//  UIView+ExtensionTests.swift
//  andpad-camera_Tests
//
//  Created by 佐藤俊輔 on 2021/03/23.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import XCTest

class UIView_ExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRotateWhenDeviceOrientationIsLandscape() throws {
        var orientation: UIDeviceOrientation!

        XCTContext.runActivity(named: "orientation is portrait") { _ in
            orientation = .portrait

            let somePortraitView = generatePortraitView()
            somePortraitView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
            XCTAssertEqual(somePortraitView.frame, .init(x: 100.0, y: 200.0, width: 400.0, height: 300.0))

            let someLandscapeView = generateLandscapeView()
            someLandscapeView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
            XCTAssertEqual(someLandscapeView.frame, .init(x: 100.0, y: 200.0, width: 400.0, height: 300.0))
        }

        XCTContext.runActivity(named: "orientation is portraitUpsideDown") { _ in
            orientation = .portraitUpsideDown

            let somePortraitView = generatePortraitView()
            somePortraitView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
            XCTAssertEqual(somePortraitView.frame, .init(x: 100.0, y: 200.0, width: 400.0, height: 300.0))

            let someLandscapeView = generateLandscapeView()
            someLandscapeView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
            XCTAssertEqual(someLandscapeView.frame, .init(x: 100.0, y: 200.0, width: 400.0, height: 300.0))
        }

        XCTContext.runActivity(named: "orientation is landscapeLeft") { _ in
            orientation = .landscapeLeft

            let somePortraitView = generatePortraitView()
            somePortraitView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
            XCTAssertEqual(somePortraitView.frame, .init(x: 100.0, y: 200.0, width: 300.0, height: 400.0))

            let someLandscapeView = generateLandscapeView()
            someLandscapeView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
            XCTAssertEqual(someLandscapeView.frame, .init(x: 100.0, y: 200.0, width: 300.0, height: 400.0))
        }

        XCTContext.runActivity(named: "orientation is landscapeRight") { _ in
            orientation = .landscapeRight

            let somePortraitView = generatePortraitView()
            somePortraitView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
            XCTAssertEqual(somePortraitView.frame, .init(x: 100.0, y: 200.0, width: 300.0, height: 400.0))

            let someLandscapeView = generateLandscapeView()
            someLandscapeView.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)
            XCTAssertEqual(someLandscapeView.frame, .init(x: 100.0, y: 200.0, width: 300.0, height: 400.0))
        }
    }

    private func generatePortraitView() -> UIView {
        return UIView(frame: .init(x: 100.0, y: 200.0, width: 300.0, height: 400.0))
    }

    private func generateLandscapeView() -> UIView {
        return UIView(frame: .init(x: 100.0, y: 200.0, width: 400.0, height: 300.0))
    }
}

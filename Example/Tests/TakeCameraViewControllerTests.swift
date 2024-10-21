//
//  TakeCameraViewControllerTests.swift
//  andpad-camera_Tests
//
//  Created by 佐藤俊輔 on 2021/03/25.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import XCTest

final class TakeCameraViewControllerTests: XCTestCase {
    func testCalcBlackboardFrame() throws {

        let parentFrame: CGRect = .init(x: 0, y: 0, width: 1200, height: 1600)
        let blackBoardViewWidth: CGFloat = 400
        let blackBoardViewHeight: CGFloat = 300
        let somePrioritizeFrame: CGRect = .init(x: 1000, y: 2000, width: 3000, height: 4000)
        
        var orientation: UIDeviceOrientation!
        var prioritizeFrame: CGRect?
        
        let subject: (() -> CGRect) = {
            TakeCameraViewController.calcBlackboardFrame(
                parentFrame: parentFrame,
                deviceOrientation: orientation,
                targetViewFrame: .init(
                    x: 0,
                    y: 0,
                    width: blackBoardViewWidth,
                    height: blackBoardViewHeight
                ),
                prioritizeFrame: prioritizeFrame
            )
        }
        
        // width: {親の幅 1200pt} * 45% = 540pt
        // height: {width 540pt} * {ターゲットの縦横比 300/400} = 405pt

        XCTContext.runActivity(named: "orientation is portrait, prioritizeFrame is nil") { _ in
            orientation = .portrait
            prioritizeFrame = nil
            // x: {親の幅 1200pt} - {width 540pt} = 660pt
            // y: {親の高さ 1600pt} - {height 405pt} = 1195pt
            XCTAssertEqual(subject(), CGRect(x: 660, y: 1195, width: 540, height: 405))
        }
        
        XCTContext.runActivity(named: "orientation is landscapeLeft, prioritizeFrame is nil") { _ in
            orientation = .landscapeLeft
            prioritizeFrame = nil
            // x: {親の幅 1200pt} - {height 405pt} = 795pt
            // y: {親の高さ 1600pt} - {width 540pt} = 1060pt
            XCTAssertEqual(subject(), CGRect(x: 795, y: 1060, width: 540, height: 405))
        }

        XCTContext.runActivity(named: "orientation is landscapeRight, prioritizeFrame is nil") { _ in
            orientation = .landscapeRight
            prioritizeFrame = nil
            // landscapeLeftと同様
            XCTAssertEqual(subject(), CGRect(x: 795, y: 1060, width: 540, height: 405))
        }

        XCTContext.runActivity(named: "orientation is portraitUpsideDown, prioritizeFrame is nil") { _ in
            orientation = .portraitUpsideDown
            prioritizeFrame = nil
            // portraitと同様
            XCTAssertEqual(subject(), CGRect(x: 660, y: 1195, width: 540, height: 405))
        }

        XCTContext.runActivity(named: "orientation is faceUp, prioritizeFrame is nil") { _ in
            orientation = .faceUp
            prioritizeFrame = nil
            // portraitと同様
            XCTAssertEqual(subject(), CGRect(x: 660, y: 1195, width: 540, height: 405))
        }

        XCTContext.runActivity(named: "orientation is faceDown, prioritizeFrame is nil") { _ in
            orientation = .faceDown
            prioritizeFrame = nil
            // faceUpと同様
            XCTAssertEqual(subject(), CGRect(x: 660, y: 1195, width: 540, height: 405))
        }

        XCTContext.runActivity(named: "orientation is portrait, prioritizeFrame is NOT nil") { _ in
            orientation = .portrait
            prioritizeFrame = somePrioritizeFrame
            XCTAssertEqual(subject(), somePrioritizeFrame)
        }
    }
}

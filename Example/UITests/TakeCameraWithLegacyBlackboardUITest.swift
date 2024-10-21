//
//  TakeCameraWithLegacyBlackboardUITest.swift
//  UITests
//
//  Created by msano on 2021/10/29.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import XCTest

// MARK: - TakeCameraWithLegacyBlackboardUITest

final class TakeCameraWithLegacyBlackboardUITest: XCTestCase {
    let app = XCUIApplication()
    let timeoutDuration: TimeInterval = 8.0

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app.launch()

        // 共通のセットアップを実行
        enableModernBlackboardSwitch.tap()
        XCTAssertEqual(enableModernBlackboardSwitch.value as! String, "0", "新黒板スイッチがOFFになっていることを確認")
        enableInspectionLegacyBlackboardSwitch.tap()
        XCTAssertEqual(enableInspectionLegacyBlackboardSwitch.value as! String, "0", "検査用旧黒板スイッチがOFFになっていることを確認")
        XCTAssertEqual(enableLegacyBlackboardSwitch.value as! String, "1", "旧黒板スイッチがONになっていることを確認")
        // 旧黒板はHTMLで表示しない。
        XCTAssertEqual(useBlackboardGeneratedWithSVGSwitch.value as! String, "0", "黒板をHTMLで表示するスイッチがOFFになっていることを確認")
    }

    override func tearDownWithError() throws {
        // テストの後処理（必要に応じて）
    }
}

// MARK: - UI要素

extension TakeCameraWithLegacyBlackboardUITest {
    // MARK: ViewController

    var launchCameraButton: XCUIElement {
        app.buttons[.launchCameraButton].firstMatch
    }

    var enableModernBlackboardSwitch: XCUIElement {
        app.switches[.enableModernBlackboardSwitch].firstMatch
    }

    var enableLegacyBlackboardSwitch: XCUIElement {
        app.switches[.enableLegacyBlackboardSwitch].firstMatch
    }

    var enableInspectionLegacyBlackboardSwitch: XCUIElement {
        app.switches[.enableInspectionLegacyBlackboardSwitch].firstMatch
    }

    var enableShootingGuideImageSwitch: XCUIElement {
        app.switches[.enableShootingGuideImageSwitch].firstMatch
    }

    var useBlackboardGeneratedWithSVGSwitch: XCUIElement {
        app.switches[.useBlackboardGeneratedWithSVGSwitch].firstMatch
    }

    // MARK: 撮影画面

    var shutterButton: XCUIElement {
        app.buttons[.shutterButton].firstMatch
    }

    var nextButton: XCUIElement {
        app.buttons[.takeCameraNextButton].firstMatch
    }

    var cancelButton: XCUIElement {
        app.buttons[.takeCameraCancelButton].firstMatch
    }

    var blackboardSettingsButton: XCUIElement {
        app.buttons[.blackboardSettingsButton].firstMatch
    }

    var photoCountLabel: XCUIElement {
        app.staticTexts[.photoCountLabel].firstMatch
    }

    var thumbnailImageButton: XCUIElement {
        app.buttons[.thumbnailImageButton].firstMatch
    }

    var blackboardDragHandle: XCUIElement {
        app.otherElements[.blackboardDragHandle].firstMatch
    }

    var shootingGuideButton: XCUIElement {
        app.buttons[.shootingGuideButton].firstMatch
    }

    var shootingGuideImage: XCUIElement {
        app.images[.shootingGuideImage].firstMatch
    }

    var legacyBlackboardView: XCUIElement {
        app.otherElements[.legacyBlackboardView].firstMatch
    }

    var blackboardSettingsView: XCUIElement {
        app.otherElements[.blackboardSettingsView].firstMatch
    }

    // MARK: 黒板設定モーダル

    var blackboardVisibilityShow: XCUIElement {
        app.otherElements[.blackboardVisibilityShow].firstMatch
    }

    var blackboardVisibilityHide: XCUIElement {
        app.otherElements[.blackboardVisibilityHide].firstMatch
    }

    var blackboardSettingsSheetViewCloseButton: XCUIElement {
        app.buttons[.blackboardSettingsSheetViewCloseButton].firstMatch
    }

    // MARK: 写真プレビュー画面

    var photoDeleteButton: XCUIElement {
        app.buttons[.photoDeleteButton].firstMatch
    }

    var photoPreviewViewCloseButton: XCUIElement {
        app.buttons[.photoPreviewViewCloseButton].firstMatch
    }

    // MARK: 旧黒板編集画面

    var editLegacyBlackboardViewCloseButton: XCUIElement {
        app.buttons[.editLegacyBlackboardViewCloseButton].firstMatch
    }
}

// MARK: - カメラ画面のテスト

extension TakeCameraWithLegacyBlackboardUITest {
    func test旧黒板で写真を撮る場合の撮影画面() {
        XCTContext.runActivity(named: "カメラ画面が表示されること") { _ in
            // action
            launchCameraButton.tap()

            // assert
            XCTAssert(shutterButton.exists, "シャッターボタンが表示されることを確認")
        }

        XCTContext.runActivity(named: "撮影ガイドボタンをタップすると撮影ガイド画像の表示非表示が切り替わるこ") { _ in
            // arrange
            cancelButton.tap()
            XCTAssertEqual(enableShootingGuideImageSwitch.value as! String, "1", "撮影ガイドスイッチがONになっていることを確認")

            // action
            launchCameraButton.tap()

            // pre-condition
            XCTAssert(shootingGuideButton.exists)
            // 撮影ガイドボタンは選択状態がONと定義されている
            XCTAssert(shootingGuideButton.isSelected)
            XCTAssert(shootingGuideImage.exists)

            XCTContext.runActivity(named: "撮影ガイドボタンをタップすると(1回目)撮影ガイド画像が非表示になること") { _ in
                // action
                shootingGuideButton.tap()

                // assert
                XCTAssertFalse(shootingGuideButton.isSelected)
                XCTAssertFalse(shootingGuideImage.exists)
            }

            XCTContext.runActivity(named: "撮影ガイドボタンをタップすると(2回目)撮影ガイド画像が表示されること") { _ in
                // action
                shootingGuideButton.tap()

                // assert
                XCTAssert(shootingGuideButton.isSelected)
                XCTAssert(shootingGuideImage.exists)
            }
        }

        XCTContext.runActivity(named: "旧黒板が表示されていること") { _ in
            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
        }

        XCTContext.runActivity(named: "旧黒板にドラッグハンドルが表示されていること") { _ in
            XCTAssert(blackboardDragHandle.exists)
        }

        XCTContext.runActivity(named: "黒板設定ボタンをタップすると黒板設定モーダルが表示されること") { _ in
            // pre-condition
            XCTAssertFalse(blackboardSettingsView.exists)
            XCTAssert(blackboardSettingsButton.waitForExistence(timeout: timeoutDuration))
            XCTAssert(blackboardSettingsButton.isEnabled)

            // action
            blackboardSettingsButton.tap()

            // assert
            XCTAssertTrue(blackboardSettingsView.waitForExistence(timeout: timeoutDuration))

            XCTContext.runActivity(named: "黒板表示OFFボタンをタップすると黒板が非表示になること") { _ in
                // pre-condition
                XCTAssertFalse(blackboardVisibilityHide.isSelected)

                // action
                blackboardVisibilityHide.tap()

                // assert
                XCTAssert(blackboardVisibilityHide.isSelected)
                XCTAssertFalse(legacyBlackboardView.exists)
            }

            XCTContext.runActivity(named: "黒板表示ONボタンをタップすると黒板が表示されること") { _ in
                // pre-condition
                XCTAssertFalse(blackboardVisibilityShow.isSelected)

                // action
                blackboardVisibilityShow.tap()

                // assert
                XCTAssert(blackboardVisibilityShow.isSelected)
                XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
            }

            XCTContext.runActivity(named: "閉じるボタンをタップすると黒板設定モーダルが閉じられること") { _ in
                // action
                blackboardSettingsSheetViewCloseButton.tap()

                // assert
                XCTAssertFalse(blackboardSettingsView.exists)
            }
        }

        XCTContext.runActivity(named: "黒板の中心をドラッグすると黒板を移動できること") { _ in
            let originalFrameOrigin = legacyBlackboardView.frame.origin

            // action & assert
            legacyBlackboardView.swipe(fromCenter: .left)
            let movedFrameOrigin1 = legacyBlackboardView.frame.origin
            XCTAssertLessThan(movedFrameOrigin1.x, originalFrameOrigin.x)

            legacyBlackboardView.swipe(fromCenter: .up)
            let movedFrameOrigin2 = legacyBlackboardView.frame.origin
            XCTAssertLessThan(movedFrameOrigin2.y, movedFrameOrigin1.y)

            legacyBlackboardView.swipe(fromCenter: .right)
            let movedFrameOrigin3 = legacyBlackboardView.frame.origin
            XCTAssertGreaterThan(movedFrameOrigin3.x, movedFrameOrigin2.x)

            legacyBlackboardView.swipe(fromCenter: .down)
            let movedFrameOrigin4 = legacyBlackboardView.frame.origin
            XCTAssertGreaterThan(movedFrameOrigin4.y, movedFrameOrigin3.y)
        }

        XCTContext.runActivity(named: "黒板の四隅をドラッグすると黒板を拡大縮小できること") { _ in
            // arrange
            // 画面の中央に移動させる
            let window = app.windows.element(boundBy: 0)
            legacyBlackboardView.moveToCenter(of: window)

            XCTContext.runActivity(named: "左上の角をドラッグして拡大縮小できること") { _ in
                let originalFrameSize = legacyBlackboardView.frame.size

                // action & assert
                // 左上の角をドラッグしてサイズを拡大
                legacyBlackboardView.drag(from: .topLeft, direction: .enlarge, by: 50)
                let enlargedFrameSize = legacyBlackboardView.frame.size
                XCTAssertGreaterThan(enlargedFrameSize.width, originalFrameSize.width)
                XCTAssertGreaterThan(enlargedFrameSize.height, originalFrameSize.height)

                // 左上の角をドラッグしてサイズを縮小
                legacyBlackboardView.drag(from: .topLeft, direction: .shrink, by: 100)
                let shrunkFrameSize = legacyBlackboardView.frame.size
                XCTAssertLessThan(shrunkFrameSize.width, enlargedFrameSize.width)
                XCTAssertLessThan(shrunkFrameSize.height, enlargedFrameSize.height)
            }

            XCTContext.runActivity(named: "左下の角をドラッグして拡大縮小できること") { _ in
                let originalFrameSize = legacyBlackboardView.frame.size

                // action & assert
                // 左下の角をドラッグしてサイズを拡大
                legacyBlackboardView.drag(from: .bottomLeft, direction: .enlarge, by: 100)
                let enlargedFrameSize = legacyBlackboardView.frame.size
                XCTAssertGreaterThan(enlargedFrameSize.width, originalFrameSize.width)
                XCTAssertGreaterThan(enlargedFrameSize.height, originalFrameSize.height)

                // 左下の角をドラッグしてサイズを縮小
                legacyBlackboardView.drag(from: .bottomLeft, direction: .shrink, by: 50)
                let shrunkFrameSize = legacyBlackboardView.frame.size
                XCTAssertLessThan(shrunkFrameSize.width, enlargedFrameSize.width)
                XCTAssertLessThan(shrunkFrameSize.height, enlargedFrameSize.height)
            }

            XCTContext.runActivity(named: "右下の角をドラッグして拡大縮小できること") { _ in
                let originalFrameSize = legacyBlackboardView.frame.size

                // action & assert
                // 右下の角をドラッグしてサイズを拡大
                legacyBlackboardView.drag(from: .bottomRight, direction: .enlarge, by: 50)
                let enlargedFrameSize = legacyBlackboardView.frame.size
                XCTAssertGreaterThan(enlargedFrameSize.width, originalFrameSize.width)
                XCTAssertGreaterThan(enlargedFrameSize.height, originalFrameSize.height)

                // 右下の角をドラッグしてサイズを縮小
                legacyBlackboardView.drag(from: .bottomRight, direction: .shrink, by: 100)
                let shrunkFrameSize = legacyBlackboardView.frame.size
                XCTAssertLessThan(shrunkFrameSize.width, enlargedFrameSize.width)
                XCTAssertLessThan(shrunkFrameSize.height, enlargedFrameSize.height)
            }

            XCTContext.runActivity(named: "右上の角をドラッグして拡大縮小できること") { _ in
                let originalFrameSize = legacyBlackboardView.frame.size

                // action & assert
                // 右上の角をドラッグしてサイズを拡大
                legacyBlackboardView.drag(from: .topRight, direction: .enlarge, by: 100)
                let enlargedFrameSize = legacyBlackboardView.frame.size
                XCTAssertGreaterThan(enlargedFrameSize.width, originalFrameSize.width)
                XCTAssertGreaterThan(enlargedFrameSize.height, originalFrameSize.height)

                // 右上の角をドラッグしてサイズを縮小
                legacyBlackboardView.drag(from: .topRight, direction: .shrink, by: 50)
                let shrunkFrameSize = legacyBlackboardView.frame.size
                XCTAssertLessThan(shrunkFrameSize.width, enlargedFrameSize.width)
                XCTAssertLessThan(shrunkFrameSize.height, enlargedFrameSize.height)
            }
        }

        XCTContext.runActivity(named: "黒板をタップすると黒板編集画面に遷移すること") { _ in
            // arrange
            // 撮影ガイドが上に重なっていると黒板がヒット可能にならないので、非表示にしておく
            shootingGuideButton.tap()
            XCTAssertFalse(shootingGuideImage.exists)

            // action
            XCTAssert(legacyBlackboardView.isHittable)
            legacyBlackboardView.tap()

            // assert
            XCTAssert(editLegacyBlackboardViewCloseButton.exists)

            XCTContext.runActivity(named: "黒板編集画面を閉じるとカメラ画面に戻ること") { _ in
                // action
                editLegacyBlackboardViewCloseButton.tap()

                // assert
                XCTAssertFalse(editLegacyBlackboardViewCloseButton.exists)
            }
        }
    }

    func test旧黒板付きで写真を撮る() throws {
        XCTContext.runActivity(named: "写真を1枚撮れること") { _ in
            // arrange
            launchCameraButton.tap()

            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
            XCTAssertEqual("0", photoCountLabel.label)

            // action
            shutterButton.tap()

            // assert
            XCTAssertEqual("1", photoCountLabel.label)
        }

        XCTContext.runActivity(named: "写真サムネイルボタンをタップすると写真プレビュー画面へ遷移すること") { _ in
            // action
            thumbnailImageButton.tap()

            // assert
            XCTAssert(photoDeleteButton.waitForHittable())
        }

        XCTContext.runActivity(named: "写真プレビュー画面の閉じるボタンタップすると写真プレビュー画面を閉じること") { _ in
            // action
            photoPreviewViewCloseButton.tap()

            // assert
            XCTAssertFalse(photoDeleteButton.exists)
        }

        XCTContext.runActivity(named: "次へボタンをタップするとカメラが終了すること") { _ in
            // arrange
            XCTAssertFalse(launchCameraButton.exists)

            // action
            nextButton.tap()

            // assert
            XCTAssert(launchCameraButton.waitForExistence(timeout: timeoutDuration))
        }

        XCTContext.runActivity(named: "写真を10枚連続で撮れること") { _ in
            // arrange
            launchCameraButton.tap()

            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
            XCTAssertEqual("0", photoCountLabel.label)

            // action
            for _ in 0 ..< 10 {
                shutterButton.tap()
            }

            // assert
            XCTAssertEqual("10", photoCountLabel.label)
        }
    }
}

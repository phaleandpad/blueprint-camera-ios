//
//  PhotoPreviewWithLegacyBlackboardUITests.swift
//  UITests
//
//  Created by 成瀬 未春 on 2024/06/23.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import XCTest

// MARK: - PhotoPreviewWithLegacyBlackboardUITests

final class PhotoPreviewWithLegacyBlackboardUITests: XCTestCase {
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

extension PhotoPreviewWithLegacyBlackboardUITests {
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

    var useBlackboardGeneratedWithSVGSwitch: XCUIElement {
        app.switches[.useBlackboardGeneratedWithSVGSwitch].firstMatch
    }

    // MARK: 撮影画面

    var shutterButton: XCUIElement {
        app.buttons[.shutterButton].firstMatch
    }

    var thumbnailImageButton: XCUIElement {
        app.buttons[.thumbnailImageButton].firstMatch
    }

    var legacyBlackboardView: XCUIElement {
        app.otherElements[.legacyBlackboardView].firstMatch
    }

    // MARK: 写真プレビュー画面

    var photoPreviewNavigationBar: XCUIElement {
        app.navigationBars[.photoPreviewNavigationBar].firstMatch
    }

    var photoDeleteButton: XCUIElement {
        app.buttons[.photoDeleteButton].firstMatch
    }

    var photoDeleteAlertDeleteButton: XCUIElement {
        app.alerts.buttons[.photoDeleteAlertDeleteButton].firstMatch
    }

    var photoPreviewViewCloseButton: XCUIElement {
        app.buttons[.photoPreviewViewCloseButton].firstMatch
    }

    var photoPreviewMainImageScrollView: XCUIElement {
        app.collectionViews[.photoPreviewMainImageScrollView].firstMatch
    }

    var photoPreviewThumbnailImageScrollView: XCUIElement {
        app.collectionViews[.photoPreviewThumbnailImageScrollView].firstMatch
    }
}

// MARK: 写真プレビュー画面のテスト

extension PhotoPreviewWithLegacyBlackboardUITests {
    func test旧黒板で写真を撮る場合の写真プレビュー画面() {
        XCTContext.runActivity(named: "カメラ画面で写真を撮影し写真サムネイルボタンをタップすると写真プレビュー画面へ遷移すること") { _ in
            // arrange
            launchCameraButton.tap()
            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
            for _ in 0 ..< 3 {
                shutterButton.tap()
            }

            // action
            thumbnailImageButton.tap()

            // assert
            XCTAssert(photoPreviewNavigationBar.exists)
        }

        XCTContext.runActivity(named: "MainScrollViewに拡大画像として表示されること") { _ in
            XCTAssert(photoPreviewMainImageScrollView.exists)
        }

        XCTContext.runActivity(named: "ThumbnailScrollViewにサムネイル画像がカルーセルとして表示されること") { _ in
            XCTAssert(photoPreviewThumbnailImageScrollView.exists)
            XCTAssertEqual(photoPreviewThumbnailImageScrollView.images.count, 3)
        }

        XCTContext.runActivity(named: "ThumbnailScrollViewの画像をタップするとMainImageScrollViewの画像が切り替わること") { _ in
            // arrange
            // 1つ目のサムネイルをタップ
            let firstThumbnail = photoPreviewThumbnailImageScrollView.images.element(boundBy: 0)
            firstThumbnail.tap()
            let firstMainScreenshot = photoPreviewMainImageScrollView.images.element(boundBy: 0).screenshot()

            // action
            // 2つ目のサムネイルをタップ
            let secondThumbnail = photoPreviewThumbnailImageScrollView.images.element(boundBy: 1)
            secondThumbnail.tap()
            let secondMainScreenshot = photoPreviewMainImageScrollView.images.element(boundBy: 0).screenshot()

            // assert
            XCTAssertNotEqual(firstMainScreenshot, secondMainScreenshot)
        }

        XCTContext.runActivity(named: "削除ボタンをタップするとThumbnailScrollViewから選択済みのサムネイル画像が削除されること") { _ in
            // arrange
            // 削除前の画像数を取得
            let initialThumbnailCount = photoPreviewThumbnailImageScrollView.images.count
            // 2つ目のサムネイルをタップ
            let secondThumbnail = photoPreviewThumbnailImageScrollView.images.element(boundBy: 1)
            secondThumbnail.tap()
            let beforeSecondThumbnailScreenshot = secondThumbnail.screenshot()

            // action
            // 削除ボタンをタップし、削除を確認
            photoDeleteButton.tap()
            photoDeleteAlertDeleteButton.tap()

            // assert
            // サムネイル画像が1つ減っていることを確認
            XCTAssertEqual(photoPreviewThumbnailImageScrollView.images.count, initialThumbnailCount - 1)

            // 2つ目のサムネイルが削除されていることを確認
            let afterSecondThumbnailScreenshot = photoPreviewThumbnailImageScrollView.images.element(boundBy: 1).screenshot()
            XCTAssertNotEqual(beforeSecondThumbnailScreenshot, afterSecondThumbnailScreenshot)
        }

        XCTContext.runActivity(named: "全ての画像を削除すると写真プレビュー画面が閉じること") { _ in
            // pre-condition
            XCTAssertFalse(shutterButton.isHittable)

            // action
            while photoPreviewThumbnailImageScrollView.images.count > 0 {
                photoDeleteButton.tap()
                photoDeleteAlertDeleteButton.tap()
            }

            // assert
            XCTAssert(shutterButton.waitForHittable(timeout: timeoutDuration))
            XCTAssertFalse(photoPreviewNavigationBar.exists)
        }
    }
}

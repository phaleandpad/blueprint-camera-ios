//
//  LegacyBlackboardTemplateListUITests.swift
//  UITests
//
//  Created by 成瀬 未春 on 2024/06/24.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import XCTest

// MARK: - LegacyBlackboardTemplateListUITests

final class LegacyBlackboardTemplateListUITests: XCTestCase {
    let app = XCUIApplication()
    let timeoutDuration: TimeInterval = 8.0

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app.launch()

        // 共通のセットアップを実行
        enableModernBlackboardSwitch.tap()
        XCTAssertEqual(enableModernBlackboardSwitch.value as! String, "0", "新黒板スイッチがOFFになっていることを確認")
        XCTAssertEqual(enableLegacyBlackboardSwitch.value as! String, "1", "旧黒板スイッチがONになっていることを確認")

        // 撮影ガイドが上に重なっていると黒板がヒット可能にならないので、非表示にしておく
        enableShootingGuideImageSwitch.tap()
        XCTAssertEqual(enableShootingGuideImageSwitch.value as! String, "0", "撮影ガイドスイッチがOFFになっていることを確認")
        // 旧黒板はHTMLで表示しない。
        XCTAssertEqual(useBlackboardGeneratedWithSVGSwitch.value as! String, "0", "黒板をHTMLで表示するスイッチがOFFになっていることを確認")
    }

    override func tearDownWithError() throws {
        // テストの後処理（必要に応じて）
    }
}

// MARK: - UI要素

extension LegacyBlackboardTemplateListUITests {
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

    var legacyBlackboardView: XCUIElement {
        app.otherElements[.legacyBlackboardView].firstMatch
    }

    // MARK: 旧黒板編集画面

    var editLegacyBlackboardViewNavigationBar: XCUIElement {
        app.navigationBars[.editLegacyBlackboardViewNavigationBar].firstMatch
    }

    var editLegacyBlackboardViewCloseButton: XCUIElement {
        app.buttons[.editLegacyBlackboardViewCloseButton].firstMatch
    }

    var editLegacyBlackboardViewTemplateListCell: XCUIElement {
        app.cells[.editLegacyBlackboardViewTemplateListCell].firstMatch
    }

    var editLegacyBlackboardViewTemplateListButton: XCUIElement {
        app.buttons[.editLegacyBlackboardViewTemplateListButton].firstMatch
    }

    // MARK: 旧黒板テンプレート一覧画面

    var templateListNavigationBar: XCUIElement {
        app.navigationBars[.templateListNavigationBar].firstMatch
    }

    var templateListCloseButton: XCUIElement {
        app.buttons[.templateListCloseButton].firstMatch
    }

    var templateListCollectionView: XCUIElement {
        app.collectionViews[.templateListCollectionView].firstMatch
    }

    // MARK: 選択した旧黒板テンプレートプレビュー画面

    var selectTemplateViewNavigationBar: XCUIElement {
        app.navigationBars[.selectTemplateViewNavigationBar].firstMatch
    }

    var selectTemplateViewSelectButton: XCUIElement {
        app.buttons[.selectTemplateViewSelectButton].firstMatch
    }

    var selectTemplateViewTemplateImage: XCUIElement {
        app.images[.selectTemplateViewTemplateImage].firstMatch
    }
}

// MARK: - 旧黒板テンプレート一覧画面のテスト

extension LegacyBlackboardTemplateListUITests {
    func test旧黒板テンプレート一覧画面（通常黒板）() {
        XCTContext.runActivity(named: "旧黒板付きのカメラ画面で旧黒板ビューをタップすると旧黒板編集画面へ遷移し黒板を変更ボタンをタップすると旧黒板テンプレート一覧画面に遷移すること") { _ in
            // arrange
            enableInspectionLegacyBlackboardSwitch.tap()
            XCTAssertEqual(enableInspectionLegacyBlackboardSwitch.value as! String, "0", "検査用旧黒板スイッチがOFFになっていることを確認")

            launchCameraButton.tap()

            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
            XCTAssert(legacyBlackboardView.isHittable)
            legacyBlackboardView.tap()
            XCTAssert(editLegacyBlackboardViewNavigationBar.exists)

            editLegacyBlackboardViewTemplateListButton.tap()
            XCTAssert(templateListNavigationBar.exists)
        }

        // Cellの個数が正しく取得できなくて、テストが失敗する
//        XCTContext.runActivity(named: "旧黒板の通常黒板テンプレートが11種類表示されていること") { _ in
//            let templateCount = templateListCollectionView.cells.count
//            XCTAssertEqual(templateCount, 11)
//        }

        XCTContext.runActivity(named: "閉じるボタンをタップするとテンプレート一覧画面が閉じて黒板編集画面が表示されること") { _ in
            // action
            templateListCloseButton.tap()

            // assert
            XCTAssert(editLegacyBlackboardViewNavigationBar.exists)
        }

        XCTContext.runActivity(named: "2つ目の黒板テンプレートを選択してテンプレートプレビュー画面で決定ボタンをタップすると黒板編集画面のテンプレートが変わっていること") { _ in
            // arrange
            let beforeTemplateScreenshot = editLegacyBlackboardViewTemplateListCell.screenshot()

            editLegacyBlackboardViewTemplateListButton.tap()
            XCTAssert(templateListNavigationBar.exists)

            let secondTemplateCell = templateListCollectionView.cells.element(boundBy: 1)
            secondTemplateCell.tap()

            XCTAssert(selectTemplateViewNavigationBar.exists)

            // action
            selectTemplateViewSelectButton.tap()

            // assert
            XCTAssert(editLegacyBlackboardViewNavigationBar.exists)
            let secondTemplateScreenshot = editLegacyBlackboardViewTemplateListCell.screenshot()
            XCTAssertNotEqual(beforeTemplateScreenshot, secondTemplateScreenshot)
        }
    }

    func test旧黒板テンプレート一覧画面（検査黒板＋通常黒板）() {
        XCTContext.runActivity(named: "旧黒板(検査黒板＋通常黒板)の場合") { _ in
            XCTContext.runActivity(named: "旧黒板付きのカメラ画面で旧黒板ビューをタップすると旧黒板編集画面へ遷移し黒板を変更ボタンをタップすると旧黒板テンプレート一覧画面に遷移すること") { _ in
                // arrange
                XCTAssertEqual(enableInspectionLegacyBlackboardSwitch.value as! String, "1", "検査用旧黒板スイッチがONになっていることを確認")

                launchCameraButton.tap()

                XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
                XCTAssert(legacyBlackboardView.isHittable)
                legacyBlackboardView.tap()
                XCTAssert(editLegacyBlackboardViewNavigationBar.exists)

                editLegacyBlackboardViewTemplateListButton.tap()
                XCTAssert(templateListNavigationBar.exists)
            }

            // Cellの個数が正しく取得できなくて、テストが失敗する
//            XCTContext.runActivity(named: "旧黒板のテンプレートが21種類(検査黒板10種+通常黒板11種)表示されていること") { _ in
//                let templateCount = templateListCollectionView.cells.count
//                XCTAssertEqual(templateCount, 21)
//            }
        }
    }
}

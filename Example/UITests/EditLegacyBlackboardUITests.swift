//
//  EditLegacyBlackboardUITests.swift
//  UITests
//
//  Created by 成瀬 未春 on 2024/06/23.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import XCTest

// MARK: - EditLegacyBlackboardUITests

final class EditLegacyBlackboardUITests: XCTestCase {
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

extension EditLegacyBlackboardUITests {
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

    var editLegacyBlackboardViewTemplateListButton: XCUIElement {
        app.buttons[.editLegacyBlackboardViewTemplateListButton].firstMatch
    }

    var editLegacyBlackboardViewTextFieldCell: XCUIElement {
        app.cells[.editLegacyBlackboardViewTextFieldCell].firstMatch
    }

    var editLegacyBlackboardViewDatePickerCell: XCUIElement {
        app.cells[.editLegacyBlackboardViewDatePickerCell].firstMatch
    }

    var editLegacyBlackboardViewDatePicker: XCUIElement {
        app.datePickers[.editLegacyBlackboardViewDatePicker].firstMatch
    }

    var editLegacyBlackboardAlphaSegmentedControl: XCUIElement {
        app.segmentedControls[.editLegacyBlackboardAlphaSegmentedControl].firstMatch
    }

    var editLegacyBlackboardSaveButton: XCUIElement {
        app.buttons[.editLegacyBlackboardSaveButton].firstMatch
    }

    var editLegacyBlackboardViewNavigationBarSaveButton: XCUIElement {
        app.buttons[.editLegacyBlackboardViewNavigationBarSaveButton].firstMatch
    }

    // MARK: 旧黒板テンプレート一覧画面

    var templateListNavigationBar: XCUIElement {
        app.navigationBars[.templateListNavigationBar].firstMatch
    }

    var templateListCloseButton: XCUIElement {
        app.buttons[.templateListCloseButton].firstMatch
    }
}

// MARK: - 旧黒板編集画面のテスト

extension EditLegacyBlackboardUITests {
    func test旧黒板編集画面() {
        XCTContext.runActivity(named: "旧黒板付きのカメラ画面で旧黒板ビューをタップすると旧黒板編集画面へ遷移すること") { _ in
            // arrange
            launchCameraButton.tap()
            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))

            // action
            XCTAssert(legacyBlackboardView.isHittable)
            legacyBlackboardView.tap()

            // assert
            XCTAssert(editLegacyBlackboardViewNavigationBar.exists)
        }

        XCTContext.runActivity(named: "黒板を変更ボタンをタップするとテンプレート一覧画面に遷移すること") { _ in
            // action
            editLegacyBlackboardViewTemplateListButton.tap()

            // assert
            XCTAssert(templateListNavigationBar.exists)
        }

        XCTContext.runActivity(named: "テンプレート一覧画面の閉じるボタンをタップするとテンプレート一覧を閉じること") { _ in
            // action
            templateListCloseButton.tap()

            // assert
            XCTAssertFalse(templateListNavigationBar.exists)
        }

        XCTContext.runActivity(named: "黒板項目(テキスト)を変更して完了ボタンを押すと変更が反映された状態で撮影画面に遷移すること") { _ in
            // arrange
            editLegacyBlackboardViewCloseButton.tap()
            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
            let beforeLegacyBlackboardViewScreenshot = legacyBlackboardView.images.firstMatch.screenshot()
            legacyBlackboardView.tap()

            // action
            let textField = editLegacyBlackboardViewTextFieldCell.textFields.firstMatch
            textField.tap()
            textField.typeText("テスト")
            editLegacyBlackboardViewNavigationBarSaveButton.tap()

            // assert
            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
            let afterLegacyBlackboardViewScreenshot = legacyBlackboardView.images.firstMatch.screenshot()
            XCTAssertNotEqual(beforeLegacyBlackboardViewScreenshot, afterLegacyBlackboardViewScreenshot)
        }

        XCTContext.runActivity(named: "黒板項目(日付)を変更して完了ボタンを押すと変更が反映された状態で撮影画面に遷移すること") { _ in
            // arrange
            let beforeLegacyBlackboardViewScreenshot = legacyBlackboardView.images.firstMatch.screenshot()
            legacyBlackboardView.tap()

            // action
            editLegacyBlackboardViewDatePickerCell.textFields.firstMatch.tap()

            editLegacyBlackboardViewDatePicker.pickerWheels.element(boundBy: 0).swipeDown()
            editLegacyBlackboardViewDatePicker.pickerWheels.element(boundBy: 1).swipeDown()
            editLegacyBlackboardViewDatePicker.pickerWheels.element(boundBy: 2).swipeDown()

            editLegacyBlackboardViewNavigationBarSaveButton.tap()

            // assert
            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
            let afterLegacyBlackboardViewScreenshot = legacyBlackboardView.images.firstMatch.screenshot()
            XCTAssertNotEqual(beforeLegacyBlackboardViewScreenshot, afterLegacyBlackboardViewScreenshot)
        }

        XCTContext.runActivity(named: "黒板項目(透過設定)を変更して完了ボタンを押すと変更が反映された状態で撮影画面に遷移すること") { _ in
            // arrange
            let beforeLegacyBlackboardViewScreenshot = legacyBlackboardView.images.firstMatch.screenshot()
            legacyBlackboardView.tap()

            // action
            // 透過設定が見えるまでスワイプアップ
            let tableView = app.tables.firstMatch
            while !editLegacyBlackboardAlphaSegmentedControl.isHittable {
                tableView.swipeUp()
            }
            editLegacyBlackboardAlphaSegmentedControl.buttons["半透過"].tap()

            // 保存ボタンが見えるまでスワイプアップ
            while !editLegacyBlackboardSaveButton.isHittable {
                tableView.swipeUp()
            }
            editLegacyBlackboardSaveButton.tap()

            // assert
            XCTAssert(legacyBlackboardView.waitForExistence(timeout: timeoutDuration))
            let afterLegacyBlackboardViewScreenshot = legacyBlackboardView.images.firstMatch.screenshot()
            XCTAssertNotEqual(beforeLegacyBlackboardViewScreenshot, afterLegacyBlackboardViewScreenshot)
        }
    }
}

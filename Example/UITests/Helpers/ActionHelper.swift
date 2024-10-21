//
//  ActionHelper.swift
//  UITests
//
//  Created by msano on 2021/11/04.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import XCTest

class Helper {

    /// 渡したelementの中で条件に一致するものを返す
    /// - Parameters:
    ///   - timeout: Time out
    ///   - elements: Variadic elements
    ///   - condition: Closure that returns a Boolean
    func waitVariadicElements(timeout: TimeInterval = 5.0, elements: XCUIElement..., condition: ((XCUIElement) -> Bool)) -> XCUIElement {

        var tryCount = 0
        for element in elements where Double(tryCount)/2 <= timeout {
            if condition(element) {
                return element
            }
            Thread.sleep(forTimeInterval: 0.5)
            tryCount += 1
        }
        return elements.first!
    }

}

extension XCUIElementQuery {

    /// Returns element with number of text from Query
    /// ElementQueryからStringで絞り込み、その中の指定された番号のElementを返す
    ///
    /// - Parameter num: number of text
    /// - Parameter targetText: StaticText.label
    func element(boundBy num: Int, targetText: String) -> XCUIElement? {

        var targetNumbers: [Int] = []
        for (i, element) in self.allElementsBoundByIndex.enumerated() {
            if element.label == targetText {
                targetNumbers.append(i)
                // 必要なelementが取得できたら抜ける
                if targetNumbers.count - 1 == num {
                    break
                }
            }
        }
        if !targetNumbers.indices.contains(num) {
            return nil
        }
        return self.element(boundBy: targetNumbers[num])
    }

    /// Get element numbers from StaticText
    /// 指定したStringがQueryの何番目にあるかを返す
    ///
    /// - Parameter targetText: StaticText.label
    func elementNumbers(targetText: String) -> [Int] {

        var targetNumbers: [Int] = []
        for (i, element) in self.allElementsBoundByIndex.enumerated() {
            if element.label == targetText {
                targetNumbers.append(i)
            }
        }
        return targetNumbers
    }

    /// elementsの増減を監視し安定するのを待つ
    func waitForMoreElements(timeout: TimeInterval = 5.0) -> Bool {
        var check = self.count
        for _ in 0...Int(timeout*2) {
            Thread.sleep(forTimeInterval: 0.5)
            let latest = self.count
            if check == latest {
                return true
            }
            check = latest
        }
        return false
    }

}

extension XCUIElement {

    /// 指定した秒数まで存在するかを確認してからtap()をする
    /// なおactionは指定のelementが存在しなければ2秒程度は待ってくれる
    func waitTap(timeout: TimeInterval = 5, tapInterval: TimeInterval = 0, message: String? = nil) {
        if self.waitForExistence(timeout: timeout) {
            Thread.sleep(forTimeInterval: tapInterval)
            self.tap()
        } else if let message = message {
            XCTFail("waitTap failed: \(message)")
        }
    }

    /// retry + 1回だけ、条件が成立するまで待機する。
    /// - returns: retry + 1回以内に条件が成立すればtrue
    func waitForCondition(timeout: TimeInterval = 5.0, condition: (XCUIElement) -> Bool) -> Bool {
        var tryCount = 0
        repeat {
            if condition(self) {
                return true
            }
            Thread.sleep(forTimeInterval: 0.5)
            tryCount += 1
        } while Double(tryCount)/2 <= timeout

        return false
    }

    /// 要素の存在が消えるまで待機する
    func waitForNotExistence(timeout: TimeInterval = 5.0) -> Bool {
        return !self.waitForExistence(timeout: timeout)
    }

    /// 要素が画面上に見えるまで待機する
    func waitForHittable(timeout: TimeInterval = 5.0) -> Bool {
        return self.waitForCondition(timeout: timeout) { $0.isHittable }
    }

    /// 要素が画面上から見えなくなるまで待機する
    func waitForNotHittable(timeout: TimeInterval = 5.0) -> Bool {
        return self.waitForCondition(timeout: timeout) { !$0.isHittable }
    }

    /// elementの存在が確認できるまで待機
    /// WebViewなどでメソッドチェーンでの利用も考慮
    /// タイムアウトでXCTFail
    /// - Parameter timeout: タイムアウト
    /// - returns: XCUIElement
    func waitForLoading(timeout: TimeInterval) -> XCUIElement  {
        if !self.waitForExistence(timeout: timeout) {
            XCTFail("waitForLoading() - element is not found")
        }
        return self
    }

    /// dismiss keyboard
    /// UITextField, UITextViewに対応
    /// 端末の言語設定によらず以下で対応可能
    func dismissKeyboard() {

        if self.description.contains("TextView") {
            self.swipeDown()
            return
        }

        if self.description.contains("TextField") {
            let app = XCUIApplication()
            // Visible keyboard
            if !app.keyboards.firstMatch.exists { return }

            if UIDevice.current.userInterfaceIdiom == .pad {
                // Target Device: iPad
                let closeButton = app.keyboards.buttons["閉じる"]
                let hiddenButotn = app.keyboards.buttons["キーボードを非表示"]

                if closeButton.exists {
                    closeButton.tap()
                } else {
                    hiddenButotn.tap()
                }
            } else {
                // Target Device: iPhone
                app.toolbars.buttons["完了"].tap()
            }
        }
    }

    /// Clear TextField for WebView
    func clearWebViewTextFieled() {
        guard let _ = self.value as? String else {
            XCTFail("clearWebViewTextFieled() is only work in TextField")
            return
        }
        // iOS13だとメニュー表示に一手間必要
        self.waitTap()
        XCUIApplication().menuItems.element(boundBy: 1).tap()
        self.typeText(XCUIKeyboardKey.delete.rawValue)
    }

    /// Clear TextField
    func clearTextFieled() {
        guard let value = self.value as? String else {
            XCTFail("clearTextFieled() only work with TextField element")
            return
        }
        if value.isEmpty { return }

        self.press(forDuration: 0.8)
        XCUIApplication().menuItems.element(boundBy: 1).tap()
        self.typeText(XCUIKeyboardKey.delete.rawValue)
    }

    /// UITextField /  UITextViewを選択後、入力し、キーボードを閉じる
    /// - Parameter text: 入力文字列
    func typeTextComplete(text: String) {
        self.tap()
        self.clearTextFieled()
        self.typeText(text)
        self.dismissKeyboard()
    }

    /// 要素の中心から指定された方向にスワイプする。
    ///
    /// このメソッドは、要素の中心から指定された方向にスワイプジェスチャーを実行します。
    ///
    /// - Parameters:
    ///   - direction: スワイプする方向。`UISwipeGestureRecognizer.Direction`のいずれか。
    ///   - offset: スワイプの距離（ポイント）。デフォルトは100ポイントです。
    func swipe(fromCenter direction: UISwipeGestureRecognizer.Direction, by offset: CGFloat = 100) {
        let center = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoordinate: XCUICoordinate = switch direction {
        case .up:
            center.withOffset(CGVector(dx: .zero, dy: -offset))
        case .down:
            center.withOffset(CGVector(dx: .zero, dy: offset))
        case .left:
            center.withOffset(CGVector(dx: -offset, dy: .zero))
        case .right:
            center.withOffset(CGVector(dx: offset, dy: .zero))
        default:
            center
        }

        center.press(forDuration: 0.1, thenDragTo: endCoordinate)
    }

    /// 要素の指定された四隅から指定された方向にドラッグします。
    ///
    /// - Parameters:
    ///   - corner: ドラッグする四隅。
    ///   - direction: ドラッグする方向。
    ///   - distance: ドラッグの距離（ポイント）。
    func drag(from corner: DragCorner, direction: DragDirection, by distance: CGFloat = 50) {
        let startCoordinate: XCUICoordinate
        let offset: CGVector

        switch corner {
        case .topLeft:
            startCoordinate = coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            offset = switch direction {
            case .enlarge:
                .init(dx: -distance, dy: -distance)
            case .shrink:
                .init(dx: distance, dy: distance)
            }
        case .topRight:
            startCoordinate = coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0))
            offset = switch direction {
            case .enlarge:
                .init(dx: distance, dy: -distance)
            case .shrink:
                .init(dx: -distance, dy: distance)
            }
        case .bottomLeft:
            startCoordinate = coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 1))
            offset = switch direction {
            case .enlarge:
                .init(dx: -distance, dy: distance)
            case .shrink:
                .init(dx: distance, dy: -distance)
            }
        case .bottomRight:
            startCoordinate = coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 1))
            offset = switch direction {
            case .enlarge:
                .init(dx: distance, dy: distance)
            case .shrink:
                .init(dx: -distance, dy: -distance)
            }
        }

        let endCoordinate = startCoordinate.withOffset(offset)
        startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
    }

    /// ドラッグする四隅を表す列挙型
    enum DragCorner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    enum DragDirection {
        case enlarge
        case shrink
    }

    /// 要素を画面の中央に移動させる。
    ///
    /// このメソッドは、要素を画面の中央にドラッグして移動させます。
    ///
    /// - Parameters:
    ///   - window: 画面全体を表すXCUIElement。
    func moveToCenter(of window: XCUIElement) {
        let windowCenter = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let elementCenter = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        elementCenter.press(forDuration: 0.1, thenDragTo: windowCenter)
    }
}

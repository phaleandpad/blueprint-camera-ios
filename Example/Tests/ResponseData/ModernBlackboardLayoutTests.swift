//
//  ModernBlackboardLayoutTests.swift
//  andpad-camera_Tests
//
//  Created by 成瀬 未春 on 2023/09/04.
//  Copyright © 2023 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick

final class ModernBlackboardLayoutTests: QuickSpec {
    override class func spec() {
        describe("黒板レイアウトの黒板項目1行目に表示する値") {
            context("パターン１の場合") {
                let item = ModernBlackboardLayout(
                    pattern: .pattern1,
                    theme: .black
                )
                let constructionNameTitle = item.items.first?.itemName
                it("半角カッコつきの固定文言 `(工事名)` が表示される") {
                    expect(constructionNameTitle).to(equal(L10n.Blackboard.AutoInputInformation.constructionNameTitle))
                    expect(constructionNameTitle).toNot(equal(L10n.Blackboard.DefaultName.constractionName))
                    expect(constructionNameTitle).toNot(equal("（\(L10n.Blackboard.DefaultName.constractionName)）"))
                }
            }
        }
    }
}

//
//  ModernBlackboardMaterialStubTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2022/11/04.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick

final class ModernBlackboardMaterialStubTests: QuickSpec {
    override class func spec() {
        describe("スタブデータの存在チェック") {
            context("各黒板項目の最大文字数分の文字埋めをしない場合") {
                it("全ケースとも黒板データを返しているか") {
                    let emptyValueCases = ModernBlackboardMaterialStub
                        .allCases(
                            doFillTexts: false,
                            miniatureMapStubImageType: .portrait
                        )
                        .compactMap {$0.value == nil ? "layout\($0.layoutID)" : nil}
                    
                    guard emptyValueCases.isEmpty else {
                        XCTFail("Cannot get blackboard (stub) data: \(emptyValueCases)")
                        return
                    }
                    
                    XCTAssertTrue(true)
                }
            }
            
            context("各黒板項目の最大文字数分の文字埋めをする場合") {
                it("全ケースとも黒板データを返しているか") {
                    let emptyValueCases = ModernBlackboardMaterialStub
                        .allCases(
                            doFillTexts: true,
                            miniatureMapStubImageType: .portrait
                        )
                        .compactMap {$0.value == nil ? "layout\($0.layoutID)" : nil}
                    
                    guard emptyValueCases.isEmpty else {
                        XCTFail("Cannot get blackboard (stub) data: \(emptyValueCases)")
                        return
                    }
                    
                    XCTAssertTrue(true)
                }
            }
        }
    }
}

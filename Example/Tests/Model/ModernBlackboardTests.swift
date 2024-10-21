//
//  ModernBlackboardTests.swift
//  andpad-camera_Tests
//
//  Created by 西悠作 on 2024/05/08.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import XCTest
import andpad_camera

final class ModernBlackboardTests: XCTestCase {
    
    struct DummyModernBlackboard: ModernBlackboard {
        
        struct Content: ModernBlackBoardContent {
            let itemName: String
            let itemBody: String
            let position: Int
        }
        
        struct MiniatureMap: ModernBlackBoardMiniatureMap {
            let id: Int
        }
        
        let layoutTypeID: Int
        let contents: [Content]
        let miniatureMap: MiniatureMap?
    }
    
    typealias IsEquivalentTestCase = (
        activityName: String,
        blackboard: DummyModernBlackboard,
        otherBlackboard: DummyModernBlackboard,
        line: UInt
    )
    
    // MARK: - Dummy data -
    
    private var layoutType1: ModernBlackboardContentView.Pattern { .pattern1 }
    
    private var contentA: DummyModernBlackboard.Content {
        .init(itemName: "A", itemBody: "a", position: 10)
    }
    private var contentB: DummyModernBlackboard.Content {
        .init(itemName: "B", itemBody: "b", position: 11)
    }
    private var contentC: DummyModernBlackboard.Content {
        .init(itemName: "C", itemBody: "c", position: 12)
    }
    private var contentDate0101: DummyModernBlackboard.Content {
        .init(itemName: "撮影日", itemBody: "2024/01/01", position: 4)
    }
    private var contentDate0102: DummyModernBlackboard.Content {
        .init(itemName: "撮影日", itemBody: "2024/01/02", position: 4)
    }
    private var contentConstructionNameA: DummyModernBlackboard.Content {
        .init(itemName: "工事名", itemBody: "工事名A", position: 1)
    }
    private var contentConstructionNameB: DummyModernBlackboard.Content {
        .init(itemName: "工事名", itemBody: "工事名B", position: 1)
    }
    private var contentConstructionPlayerA: DummyModernBlackboard.Content {
        .init(itemName: "施工者名", itemBody: "施工者A", position: 5)
    }
    private var contentConstructionPlayerB: DummyModernBlackboard.Content {
        .init(itemName: "施工者名", itemBody: "施工者B", position: 5)
    }
    
    private var miniatureMap0: DummyModernBlackboard.MiniatureMap {
        .init(id: 0)
    }
    private var miniatureMap1: DummyModernBlackboard.MiniatureMap {
        .init(id: 1)
    }
    
    // MARK: - Tests
    
    func testDummyContents() {
        // NOTE: testIsEquivalentのためのダミーデータの事前検証であり、これらをテストしたいわけではない。
        XCTAssertEqual(
            contentDate0101.position,
            layoutType1.specifiedPosition(by: .date)
        )
        XCTAssertEqual(
            contentConstructionNameA.position,
            layoutType1.specifiedPosition(by: .constructionName)
        )
        XCTAssertEqual(
            contentConstructionPlayerA.position,
            layoutType1.specifiedPosition(by: .constructionPlayer)
        )
    }
    
    func testIsEquivalent_true() throws {
        // Arrange
        let testCases: [IsEquivalentTestCase] = [
            (
                activityName: "すべての項目が一致する（最小限）",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [],
                    miniatureMap: nil
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [],
                    miniatureMap: nil
                ),
                line: #line
            ),
            (
                activityName: "すべての項目が一致する",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentA, contentB, contentC],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentB, contentC, contentA], // 順不同
                    miniatureMap: miniatureMap0
                ),
                line: #line
            ),
            (
                activityName: "撮影日のみ異なる",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentA, contentB, contentC, contentDate0101],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentB, contentC, contentA, contentDate0102], // 順不同
                    miniatureMap: miniatureMap0
                ),
                line: #line
            ),
            (
                activityName: "撮影日のみ異なる（一方に含まれない）",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentA, contentB, contentC, contentDate0101],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentB, contentC, contentA], // 順不同
                    miniatureMap: miniatureMap0
                ),
                line: #line
            ),
            (
                activityName: "工事名タイトルのみ異なる",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentA, contentB, contentC, contentConstructionNameA],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentB, contentC, contentA, contentConstructionNameB], // 順不同
                    miniatureMap: miniatureMap0
                ),
                line: #line
            ),
            (
                activityName: "工事名タイトルのみ異なる（一方に含まれない）",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentA, contentB, contentC, contentConstructionNameA],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentB, contentC, contentA], // 順不同
                    miniatureMap: miniatureMap0
                ),
                line: #line
            ),
            (
                activityName: "施工者名のみ異なる",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentA, contentB, contentC, contentConstructionPlayerA],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentB, contentC, contentA], // 順不同
                    miniatureMap: miniatureMap0
                ),
                line: #line
            ),
            (
                activityName: "施工者名のみ異なる（一方に含まれない）",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentA, contentB, contentC, contentConstructionPlayerA],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentB, contentC, contentA, contentConstructionPlayerB], // 順不同
                    miniatureMap: miniatureMap0
                ),
                line: #line
            ),
            (
                activityName: "豆図が異なる",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [],
                    miniatureMap: miniatureMap1
                ),
                line: #line
            ),
            (
                activityName: "豆図が異なる（一方に含まれない）",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [],
                    miniatureMap: nil
                ),
                line: #line
            ),
            (
                activityName: "撮影日、工事名タイトル、施工者名、豆図が異なる",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [
                        contentA,
                        contentB,
                        contentC,
                        contentDate0101,
                        contentConstructionNameA,
                        contentConstructionPlayerA
                    ],
                    miniatureMap: miniatureMap0
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [
                        contentB,
                        contentC,
                        contentA,
                        contentDate0102,
                        contentConstructionNameB,
                        contentConstructionPlayerB
                    ], // 順不同
                    miniatureMap: miniatureMap1
                ),
                line: #line
            )
        ]
        
        for testCase in testCases {
            try XCTContext.runActivity(named: testCase.activityName) { _ in
                // Act
                let isEquivalent = try testCase.blackboard.isEquivalent(
                    to: testCase.otherBlackboard
                )
                
                // Assert
                XCTAssertTrue(isEquivalent, line: testCase.line)
            }
        }
    }
    
    func testIsEquivalent_false() throws {
        // Arrange
        let testCases: [IsEquivalentTestCase] = [
            (
                activityName: "layoutTypeIDが異なる",
                blackboard: .init(
                    layoutTypeID: 1,
                    contents: [],
                    miniatureMap: nil
                ),
                otherBlackboard: .init(
                    layoutTypeID: 2,
                    contents: [],
                    miniatureMap: nil
                ),
                line: #line
            ),
            (
                activityName: "共通項目が異なる",
                blackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentA],
                    miniatureMap: nil
                ),
                otherBlackboard: .init(
                    layoutTypeID: layoutType1.rawValue,
                    contents: [contentB],
                    miniatureMap: nil
                ),
                line: #line
            )
        ]
        
        for testCase in testCases {
            try XCTContext.runActivity(named: testCase.activityName) { _ in
                // Act
                let isEquivalent = try testCase.blackboard.isEquivalent(
                    to: testCase.otherBlackboard
                )
                
                // Assert
                XCTAssertFalse(isEquivalent, line: testCase.line)
            }
        }
    }
    
    func testIsEquivalent_throwsError() throws {
        // Arrange
        let undefinedLayoutTypeID = Int.max
        let blackboard = DummyModernBlackboard(
            layoutTypeID: undefinedLayoutTypeID,
            contents: [],
            miniatureMap: nil
        )
        let otherBlackboard = DummyModernBlackboard(
            layoutTypeID: undefinedLayoutTypeID,
            contents: [],
            miniatureMap: nil
        )
        assert(DummyModernBlackboard.Layout(rawValue: undefinedLayoutTypeID) == nil)
        
        // Act, Assert
        XCTAssertThrowsError(try blackboard.isEquivalent(to: otherBlackboard))
    }
}

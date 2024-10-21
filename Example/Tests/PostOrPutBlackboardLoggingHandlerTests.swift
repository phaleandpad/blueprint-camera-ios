//
//  BlackboardEditLoggingHandlerTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2022/06/02.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick
import XCTest

final class BlackboardEditLoggingHandlerTests: QuickSpec {
    override class func spec() {
        
        let someBlackboardID01 = 1
        let someBlackboardID02 = 2
        let someBlackboardID03 = 3
        let someBlackboardID04 = 4
        
        let someTypes: [BlackboardEditLoggingHandler.BlackboardType] = [
            .posted(.copy, blackboardID: someBlackboardID01),
            .put(someModernBlackboardMaterial(blackboardID: someBlackboardID02)),
            .deleted(blackboardID: someBlackboardID03)
        ]
        
        describe("リストの操作（リセット / 追加 / 削除）") {
            beforeEach {
                BlackboardEditLoggingHandler.reset()
            }
            
            // MARK: - リセット操作
            context("リストをリセットしたとき") {
                it("リストが空になること") {
                    expect(BlackboardEditLoggingHandler.blackboardTypes.isEmpty).to(beTrue())
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.isEmpty).to(beFalse())

                    BlackboardEditLoggingHandler.reset()
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.isEmpty).to(beTrue())
                }
            }
            
            // MARK: - 追加操作
            context("黒板idの重複しない .posted を追加したとき") {
                it("リスト数が増えること") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.add(
                        type: .posted(.copy, blackboardID: someBlackboardID04)
                    )
                    
                    // NOTE: postedはデフォルトで重複を許容させてるので、リスト数は増える
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            context("黒板idの重複する .posted を追加したとき") {
                it("リスト数が増えること") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.add(
                        type: .posted(.copy, blackboardID: someBlackboardID01)
                    )
                    
                    // NOTE: postedはデフォルトで重複を許容させてるので、リスト数は増える
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            context("黒板idの重複しない .put を追加したとき") {
                it("リスト数が増えること") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.add(
                        type: .put(someModernBlackboardMaterial(blackboardID: someBlackboardID04))
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            context("黒板idの重複する .put を追加したとき") {
                it("リスト数が変わらないこと") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.add(
                        type: .put(someModernBlackboardMaterial(blackboardID: someBlackboardID02))
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複しない .deleted を追加したとき") {
                it("リスト数が増えること") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.add(
                        type: .deleted(blackboardID: someBlackboardID04)
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            context("黒板idの重複する .deleted を追加したとき") {
                it("リスト数が変わらないこと") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.add(
                        type: .deleted(blackboardID: someBlackboardID03)
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            // MARK: - 削除操作（.posted）
            context("黒板idの重複しない .posted を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が変わらないこと") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: false,
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複しない .posted を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が増えること（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: false,
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            context("黒板idの重複しない .posted を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が変わらないこと") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: true,
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複しない .posted を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が増えること（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: true,
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            // ------
            
            context("黒板idの重複する .posted を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が減ること") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID01,
                        withoutPostedBlackboard: false,
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(2))
                }
            }
            
            context("黒板idの重複する .posted を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が変わらないこと（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID01,
                        withoutPostedBlackboard: false,
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複する .posted を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が変わらないこと") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID01,
                        withoutPostedBlackboard: true,
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複する .posted を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が変わらないこと（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID01,
                        withoutPostedBlackboard: true,
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }

            // MARK: - 削除操作（.put）
            context("黒板idの重複しない .put を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が変わらないこと") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: false, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複しない .put を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が増えること（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: false, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            context("黒板idの重複しない .put を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が変わらないこと") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: true, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複しない .put を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が増えること（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: true, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            // ------
            
            context("黒板idの重複する .put を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が減ること") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID02,
                        withoutPostedBlackboard: false, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(2))
                }
            }
            
            context("黒板idの重複する .put を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が変わらないこと（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID02,
                        withoutPostedBlackboard: false, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複する .put を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が減ること") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID02,
                        withoutPostedBlackboard: true, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(2))
                }
            }
            
            context("黒板idの重複する .put を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が変わらないこと（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID02,
                        withoutPostedBlackboard: true, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            // MARK: - 削除操作（.deleted）
            context("黒板idの重複しない .deleted を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が変わらないこと") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: false, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複しない .deleted を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が増えること（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: false, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            context("黒板idの重複しない .deleted を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が変わらないこと") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: true, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複しない .deleted を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が増えること（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID04,
                        withoutPostedBlackboard: true, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(4))
                }
            }
            
            // ------
            
            context("黒板idの重複する .deleted を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が減ること") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID03,
                        withoutPostedBlackboard: false, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(2))
                }
            }
            
            context("黒板idの重複する .deleted を、「postedを削除対象から除外する」フラグをoff、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が変わらないこと（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID03,
                        withoutPostedBlackboard: false, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
            
            context("黒板idの重複する .deleted を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグoffにした上で、削除したとき") {
                it("リスト数が減ること") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID03,
                        withoutPostedBlackboard: true, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: false
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(2))
                }
            }
            
            context("黒板idの重複する .deleted を、「postedを削除対象から除外する」フラグをon、「deletedを追加する」フラグonにした上で、削除したとき") {
                it("リスト数が変わらないこと（delete型が追加されるため）") {
                    someTypes.forEach { BlackboardEditLoggingHandler.add(type: $0) }
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                    
                    BlackboardEditLoggingHandler.deleteTypeBy(
                        blackboardID: someBlackboardID03,
                        withoutPostedBlackboard: true, // posted用のフラグなので影響しない想定
                        shouldAddDeletedType: true
                    )
                    
                    expect(BlackboardEditLoggingHandler.blackboardTypes.count).to(equal(3))
                }
            }
        }

        func someModernBlackboardMaterial(blackboardID: Int) -> ModernBlackboardMaterial {
            .forTesting(
                id: blackboardID,
                blackboardTemplateID: 1234,
                layoutTypeID: 1,
                photoCount: 4,
                blackboardTheme: .init(themeCode: 1),
                items: [
                    .init(itemName: "工事名", body: "construction name body", position: 1),
                    .init(itemName: "工種", body: "物流調査", position: 2),
                    .init(itemName: "工区", body: "1工区", position: 3),
                ],
                blackboardTrees: [
                    .init(id: 1234, body: "レイアウト1"),
                    .init(id: 1235, body: "物流調査"),
                    .init(id: 1236, body: "1工区"),
                ],
                miniatureMap: nil
            )
        }
    }
}

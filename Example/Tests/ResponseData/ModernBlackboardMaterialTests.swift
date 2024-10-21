//
//  ModernBlackboardMaterialTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2021/04/19.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick

final class ModernBlackboardMaterialTests: QuickSpec {
    override class func spec() {
        let someClientName1 = "ダミーxxx土建会社1"
        let someClientName2 = "ダミーxxx土建会社2"

        describe("ModernBlackboardMaterialのパース") {
            context("正しいjsonを読み込んだとき") {
                let jsonString = """
                {
                  "id": 4842,
                  "layout_type_id": 2,
                  "blackboard_template_id": 250,
                  "photos_count": 16,
                  "contents": [
                    {
                      "item_name": "工種",
                      "body": "物流調査",
                      "display_flg": true,
                      "position": 2
                    },
                    {
                      "item_name": "工区",
                      "body": "1工区",
                      "display_flg": true,
                      "position": 3
                    },
                    {
                      "item_name": "工事名",
                      "body": "construction name body",
                      "display_flg": true,
                      "position": 1
                    }
                  ],
                  "blackboard_trees": [
                    { "id": 2183, "name": "レイアウト1" },
                    { "id": 2187, "name": "物流調査" },
                    { "id": 2193, "name": "1工区" }
                  ]
                }
                """

                guard let subject = try? JSONDecoder().decode(
                    ModernBlackboardMaterial.self,
                    from: jsonString.data(using: .utf8)!
                ) else {
                    XCTFail("Faild to decode json")
                    return
                }

                it("各propertyに正しい値が入っている") {
                    expect(subject.id).to(equal(4842))
                    expect(subject.blackboardTemplateID).to(equal(250))
                    expect(subject.layoutTypeID).to(equal(2))
                    expect(subject.items).to(haveCount(3))
                    expect(subject.blackboardTrees).to(haveCount(3))

                    let item = subject.items.first(where: { $0.position == 1 })!
                    expect(item.itemName).to(equal("工事名"))
                    expect(item.body).to(equal("construction name body"))
                    expect(item.position).to(equal(1))

                    let treeItem = subject.blackboardTrees.first!
                    expect(treeItem.id).to(equal(2183))
                    expect(treeItem.body).to(equal("レイアウト1"))
                }

                it("itemsがpositionの順番に並んでいる") {
                    expect(subject.items[0].position).to(equal(1))
                    expect(subject.items[1].position).to(equal(2))
                    expect(subject.items[2].position).to(equal(3))
                }

                it("blackboardTreesがjsonと同じ順番に並んでいる") {
                    expect(subject.blackboardTrees[0].id).to(equal(2183))
                    expect(subject.blackboardTrees[1].id).to(equal(2187))
                    expect(subject.blackboardTrees[2].id).to(equal(2193))
                }
            }
        }
        
        describe("施工者の「強制上書き保存フラグ」の挙動") {
            context("施工者名を保持しない黒板データに対し、強制上書き保存フラグONで施工者変更アップデートをかけたとき") {
                it("黒板データの施工者名が更新される") {
                    let someSnapshotData =  someSnapshotData(clientName: someClientName1)
                    let blackboardMaterial = makeSomeBlackboardMaterial(snapshotData: nil) // 施工者名なし
                    let pattern = ModernBlackboardContentView.Pattern(by: blackboardMaterial.layoutTypeID)
                    let constructionPlayerPosition = pattern?.specifiedPosition(by: .constructionPlayer)

                    // act
                    let newBlackboardMaterial = blackboardMaterial.updating(
                        by: someSnapshotData,
                        shouldForceUpdateConstructionName: true // フラグON
                    )
                    
                    // （本テスト前にlayoutIdが同一であるかチェック）
                    expect(blackboardMaterial.layoutTypeID).to(equal(newBlackboardMaterial.layoutTypeID))
                    
                    let constructionPlayerItem = blackboardMaterial.items.first { $0.position == constructionPlayerPosition }
                    let newConstructionPlayerItem = newBlackboardMaterial.items.first { $0.position == constructionPlayerPosition }
                    
                    expect(constructionPlayerItem).toNot(beNil())
                    expect(newConstructionPlayerItem).toNot(beNil())
                    expect(constructionPlayerItem?.body).to(equal(""))
                    expect(newConstructionPlayerItem?.body).to(equal(someClientName1))
                }
            }

            context("施工者名を保持する黒板データに対し、強制上書き保存フラグONで施工者変更アップデートをかけたとき") {
                it("黒板データの施工者名が更新される") {
                    let someSnapshotData1 =  someSnapshotData(clientName: someClientName1)
                    let someSnapshotData2 =  someSnapshotData(clientName: someClientName2)
                    let blackboardMaterial = makeSomeBlackboardMaterial(snapshotData: someSnapshotData1) // 施工者名あり
                    let pattern = ModernBlackboardContentView.Pattern(by: blackboardMaterial.layoutTypeID)
                    let constructionPlayerPosition = pattern?.specifiedPosition(by: .constructionPlayer)

                    // act
                    let newBlackboardMaterial = blackboardMaterial.updating(
                        by: someSnapshotData2,
                        shouldForceUpdateConstructionName: true // フラグON
                    )
                    
                    // （本テスト前にlayoutIdが同一であるかチェック）
                    expect(blackboardMaterial.layoutTypeID).to(equal(newBlackboardMaterial.layoutTypeID))
                    
                    let constructionPlayerItem = blackboardMaterial.items.first { $0.position == constructionPlayerPosition }
                    let newConstructionPlayerItem = newBlackboardMaterial.items.first { $0.position == constructionPlayerPosition }
                    
                    expect(constructionPlayerItem).toNot(beNil())
                    expect(newConstructionPlayerItem).toNot(beNil())
                    expect(constructionPlayerItem?.body).to(equal(someClientName1))
                    expect(newConstructionPlayerItem?.body).to(equal(someClientName2))
                }
            }
            
            context("施工者名を保持しない黒板データに対し、強制上書き保存フラグOFFで施工者変更アップデートをかけたとき") {
                it("黒板データの施工者名が更新される") {
                    let someSnapshotData =  someSnapshotData(clientName: someClientName1)
                    let blackboardMaterial = makeSomeBlackboardMaterial(snapshotData: nil) // 施工者名なし
                    let pattern = ModernBlackboardContentView.Pattern(by: blackboardMaterial.layoutTypeID)
                    let constructionPlayerPosition = pattern?.specifiedPosition(by: .constructionPlayer)

                    // act
                    let newBlackboardMaterial = blackboardMaterial.updating(
                        by: someSnapshotData,
                        shouldForceUpdateConstructionName: false  // フラグOFF
                    )
                    
                    // （本テスト前にlayoutIdが同一であるかチェック）
                    expect(blackboardMaterial.layoutTypeID).to(equal(newBlackboardMaterial.layoutTypeID))
                    
                    let constructionPlayerItem = blackboardMaterial.items.first { $0.position == constructionPlayerPosition }
                    let newConstructionPlayerItem = newBlackboardMaterial.items.first { $0.position == constructionPlayerPosition }
                    
                    expect(constructionPlayerItem).toNot(beNil())
                    expect(newConstructionPlayerItem).toNot(beNil())
                    expect(constructionPlayerItem?.body).to(equal(""))
                    expect(newConstructionPlayerItem?.body).to(equal(someClientName1))
                }
            }
            
            context("施工者名を保持する黒板データに対し、強制上書き保存フラグOFFで施工者変更アップデートをかけたとき") {
                it("黒板データの施工者名が更新されない") {
                    let someSnapshotData1 =  someSnapshotData(clientName: someClientName1)
                    let someSnapshotData2 =  someSnapshotData(clientName: someClientName2)
                    let blackboardMaterial = makeSomeBlackboardMaterial(snapshotData: someSnapshotData1) // 施工者名あり
                    let pattern = ModernBlackboardContentView.Pattern(by: blackboardMaterial.layoutTypeID)
                    let constructionPlayerPosition = pattern?.specifiedPosition(by: .constructionPlayer)

                    // act
                    let newBlackboardMaterial = blackboardMaterial.updating(
                        by: someSnapshotData2,
                        shouldForceUpdateConstructionName: false // フラグOFF
                    )
                    
                    // （本テスト前にlayoutIdが同一であるかチェック）
                    expect(blackboardMaterial.layoutTypeID).to(equal(newBlackboardMaterial.layoutTypeID))
                    
                    let constructionPlayerItem = blackboardMaterial.items.first { $0.position == constructionPlayerPosition }
                    let newConstructionPlayerItem = newBlackboardMaterial.items.first { $0.position == constructionPlayerPosition }
                    
                    expect(constructionPlayerItem).toNot(beNil())
                    expect(newConstructionPlayerItem).toNot(beNil())
                    expect(constructionPlayerItem?.body).to(equal(someClientName1))
                    expect(newConstructionPlayerItem?.body).to(equal(someClientName1))
                }
            }
        }

        describe("黒板データの工事名のタイトル部分のテキストについて") {
            context("`func updating(constructionNameTitle: String) -> Self` を実行したときの戻り値が") {
                let originalConstructionNameTitle = "工事名"
                let blackboardMaterial = makeSomeBlackboardMaterial(snapshotData: nil)

                // テスト前の値をチェック
                expect(blackboardMaterial.item(key: .position(1))?.itemName).to(equal(originalConstructionNameTitle))

                // act
                let newConstructionNameTitle = "自由な工事名"
                let newBlackboardMaterial = blackboardMaterial.updating(constructionNameTitle: newConstructionNameTitle)

                it("新しい値になっている") {
                    expect(newBlackboardMaterial.item(key: .position(1))?.itemName).to(equal(newConstructionNameTitle))
                }
            }
        }
        func makeSomeBlackboardMaterial(snapshotData: SnapshotData?) -> ModernBlackboardMaterial {
            .forTesting(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 5
                    )
                ],
                blackboardTrees: [],
                miniatureMap: nil,
                snapshotData: snapshotData,
                createdUser: nil,
                updatedUser: nil,
                createdAt: nil,
                updatedAt: nil
            )
        }
        
        func someSnapshotData(clientName: String) -> SnapshotData {
            .init(
                userID: 1234,
                orderName: "ダミーxxx邸",
                clientName: clientName,
                startDate: Date()
            )
        }
    }
}

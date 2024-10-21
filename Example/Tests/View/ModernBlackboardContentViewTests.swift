//
//  ModernBlackboardContentViewTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2021/05/28.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick

final class ModernBlackboardContentViewTests: QuickSpec {
    override class func spec() {

        describe("ModernBlackboardContentViewの生成") {

            let date = Date()

            let snapshotData: SnapshotData = .init(
                userID: 999999,
                orderName: "工事1",
                clientName: "担当者A",
                startDate: date
            )

            // MARK: - layout id 1
            context("layout id 1に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 1,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        memoItem(position: 3),
                        constructionDateItem(position: 4),
                        constructionPlayerItem(position: 5)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 1の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase1View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase1View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))

                    expect(caseView.separatedLeftValue).toNot(beNil())
                    expect(caseView.separatedRightValue).toNot(beNil())
                    expect(caseView.separatedLeftValue.text).to(equal(date.asDateString()))
                    expect(caseView.separatedRightValue.text).to(equal("担当者A"))
                }
            }

            // MARK: - layout id 2
            context("layout id 2に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 2,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        constructionDivisionItem(position: 3),
                        memoItem(position: 4),
                        constructionDateItem(position: 5),
                        constructionPlayerItem(position: 6)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 2の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase2View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase2View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.attributeTitle3).toNot(beNil())
                    expect(caseView.attributeValue3).toNot(beNil())
                    expect(caseView.attributeTitle3.text).to(equal("工区"))
                    expect(caseView.attributeValue3.text).to(equal("2工区"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))

                    expect(caseView.separatedLeftValue).toNot(beNil())
                    expect(caseView.separatedRightValue).toNot(beNil())
                    expect(caseView.separatedLeftValue.text).to(equal(date.asDateString()))
                    expect(caseView.separatedRightValue.text).to(equal("担当者A"))
                }
            }

            // MARK: - layout id 3
            context("layout id 3に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 3,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        constructionDivisionItem(position: 3),
                        roomNumberItem(position: 4),
                        memoItem(position: 5),
                        constructionDateItem(position: 6),
                        constructionPlayerItem(position: 7)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 3の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase3View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase3View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.attributeTitle3).toNot(beNil())
                    expect(caseView.attributeValue3).toNot(beNil())
                    expect(caseView.attributeTitle3.text).to(equal("工区"))
                    expect(caseView.attributeValue3.text).to(equal("2工区"))

                    expect(caseView.attributeTitle4).toNot(beNil())
                    expect(caseView.attributeValue4).toNot(beNil())
                    expect(caseView.attributeTitle4.text).to(equal("部屋番号"))
                    expect(caseView.attributeValue4.text).to(equal("123号室"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))

                    expect(caseView.separatedLeftValue).toNot(beNil())
                    expect(caseView.separatedRightValue).toNot(beNil())
                    expect(caseView.separatedLeftValue.text).to(equal(date.asDateString()))
                    expect(caseView.separatedRightValue.text).to(equal("担当者A"))
                }
            }

            // MARK: - layout id 4
            context("layout id 4に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 4,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        memoItem(position: 2),
                        constructionDateItem(position: 3),
                        constructionPlayerItem(position: 4)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 4の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase4View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase4View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))

                    expect(caseView.separatedLeftValue).toNot(beNil())
                    expect(caseView.separatedRightValue).toNot(beNil())
                    expect(caseView.separatedLeftValue.text).to(equal(date.asDateString()))
                    expect(caseView.separatedRightValue.text).to(equal("担当者A"))
                }
            }

            // MARK: - layout id 401
            context("layout id 401に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 401,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        memoItem(position: 2)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 401の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase401View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase401View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))
                }
            }

            // MARK: - layout id 5
            context("layout id 5に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 5,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        constructionDivisionItem(position: 3),
                        memoItem(position: 4),
                        constructionDateItem(position: 5),
                        constructionPlayerItem(position: 6)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 5の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase5View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase5View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.attributeTitle3).toNot(beNil())
                    expect(caseView.attributeValue3).toNot(beNil())
                    expect(caseView.attributeTitle3.text).to(equal("工区"))
                    expect(caseView.attributeValue3.text).to(equal("2工区"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))

                    expect(caseView.separatedLeftValue).toNot(beNil())
                    expect(caseView.separatedRightValue).toNot(beNil())
                    expect(caseView.separatedLeftValue.text).to(equal(date.asDateString()))
                    expect(caseView.separatedRightValue.text).to(equal("担当者A"))
                }
            }

            // MARK: - layout id 501
            context("layout id 501に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 501,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        constructionDivisionItem(position: 3),
                        memoItem(position: 4),
                        constructionDateItem(position: 5),
                        constructionPlayerItem(position: 6)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 501の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase501View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase501View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.attributeTitle3).toNot(beNil())
                    expect(caseView.attributeValue3).toNot(beNil())
                    expect(caseView.attributeTitle3.text).to(equal("工区"))
                    expect(caseView.attributeValue3.text).to(equal("2工区"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))
                }
            }

            // MARK: - layout id 6
            context("layout id 6に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 6,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        constructionDivisionItem(position: 3),
                        roomNumberItem(position: 4),
                        memoItem(position: 5),
                        constructionDateItem(position: 6),
                        constructionPlayerItem(position: 7)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 6の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase6View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase6View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.attributeTitle3).toNot(beNil())
                    expect(caseView.attributeValue3).toNot(beNil())
                    expect(caseView.attributeTitle3.text).to(equal("工区"))
                    expect(caseView.attributeValue3.text).to(equal("2工区"))

                    expect(caseView.attributeTitle4).toNot(beNil())
                    expect(caseView.attributeValue4).toNot(beNil())
                    expect(caseView.attributeTitle4.text).to(equal("部屋番号"))
                    expect(caseView.attributeValue4.text).to(equal("123号室"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))

                    expect(caseView.separatedLeftValue).toNot(beNil())
                    expect(caseView.separatedRightValue).toNot(beNil())
                    expect(caseView.separatedLeftValue.text).to(equal(date.asDateString()))
                    expect(caseView.separatedRightValue.text).to(equal("担当者A"))
                }
            }

            // MARK: - layout id 601
            context("layout id 601に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 601,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        constructionDivisionItem(position: 3),
                        roomNumberItem(position: 4),
                        memoItem(position: 5)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 601の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase601View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase601View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.attributeTitle3).toNot(beNil())
                    expect(caseView.attributeValue3).toNot(beNil())
                    expect(caseView.attributeTitle3.text).to(equal("工区"))
                    expect(caseView.attributeValue3.text).to(equal("2工区"))

                    expect(caseView.attributeTitle4).toNot(beNil())
                    expect(caseView.attributeValue4).toNot(beNil())
                    expect(caseView.attributeTitle4.text).to(equal("部屋番号"))
                    expect(caseView.attributeValue4.text).to(equal("123号室"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))
                }
            }

            // MARK: - layout id 201
            context("layout id 201に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 201,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        constructionDivisionItem(position: 3),
                        memoItem(position: 4)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 201の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase201View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase2View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.attributeTitle3).toNot(beNil())
                    expect(caseView.attributeValue3).toNot(beNil())
                    expect(caseView.attributeTitle3.text).to(equal("工区"))
                    expect(caseView.attributeValue3.text).to(equal("2工区"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))
                }
            }

            // MARK: - layout id 301
            context("layout id 301に準ずる黒板データを読み込んだとき") {
                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 301,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        constructionDivisionItem(position: 3),
                        roomNumberItem(position: 4),
                        memoItem(position: 5)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 301の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase301View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase301View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.attributeTitle3).toNot(beNil())
                    expect(caseView.attributeValue3).toNot(beNil())
                    expect(caseView.attributeTitle3.text).to(equal("工区"))
                    expect(caseView.attributeValue3.text).to(equal("2工区"))

                    expect(caseView.attributeTitle4).toNot(beNil())
                    expect(caseView.attributeValue4).toNot(beNil())
                    expect(caseView.attributeTitle4.text).to(equal("部屋番号"))
                    expect(caseView.attributeValue4.text).to(equal("123号室"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))
                }
            }

            // MARK: - layout id 101
            context("layout id 101に準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 101,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionTypeItem(position: 2),
                        memoItem(position: 3)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 101の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase101View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase2View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工種"))
                    expect(caseView.attributeValue2.text).to(equal("ダスター清掃"))

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))
                }
            }

            // MARK: - 未定義のlayout id
            context("未定義のlayout idに準ずる黒板データを読み込んだとき") {

                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 99999, // 未定義のlayout id
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        memoItem(position: 2)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let subject = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )

                // assert
                it("ModernBlackboardContentViewが生成されないこと") {
                    expect(subject).to(beNil())
                }
            }

            // MARK: - 黒板項目名が重複したレイアウト
            context("黒板項目名が重複した黒板データを読み込んだとき") {
                // arrange
                let modernBlackboardMaterial = ModernBlackboardMaterial.forTesting(
                    id: 1,
                    blackboardTemplateID: 250,
                    layoutTypeID: 3,
                    photoCount: 0,
                    blackboardTheme: .black,
                    itemProtocols: [
                        constructionNameItem(position: 1),
                        constructionNameItem(position: 2), // 名称重複の黒板項目
                        constructionDateItem(position: 3), // 名称重複の黒板項目
                        constructionPlayerItem(position: 4), // 名称重複の黒板項目
                        memoItem(position: 5),
                        constructionDateItem(position: 6),
                        constructionPlayerItem(position: 7)
                    ],
                    blackboardTrees: [],
                    miniatureMap: nil,
                    snapshotData: snapshotData,
                    createdUser: nil,
                    updatedUser: nil,
                    createdAt: nil,
                    updatedAt: nil
                )

                // act
                let contentView = ModernBlackboardContentView(
                    modernBlackboardMaterial,
                    theme: modernBlackboardMaterial.blackboardTheme,
                    memoStyleArguments: .defaultSetting(with: modernBlackboardMaterial.blackboardTheme.textColor),
                    dateFormatType: .defaultValue,
                    miniatureMapImageState: nil,
                    displayStyle: .normal(shouldSetCornerRounder: true),
                    shouldBeReflectedNewLine: false,
                    alphaLevel: .full
                )
                let subject = contentView?.subviews.first!

                // assert
                it("layout id 3の黒板Viewが生成されていること") {
                    expect(subject).to(beAnInstanceOf(ModernBlackboardCase3View.self))
                }

                it("各黒板項目名 / 項目値に正しい値が入っていること") {
                    guard let caseView = subject as? ModernBlackboardCase3View else {
                        return
                    }

                    expect(caseView.attributeTitle1).toNot(beNil())
                    expect(caseView.attributeValue1).toNot(beNil())
                    expect(caseView.attributeTitle1.text).to(equal("工事名"))
                    expect(caseView.attributeValue1.text).to(equal("工事1"))

                    expect(caseView.attributeTitle2).toNot(beNil())
                    expect(caseView.attributeValue2).toNot(beNil())
                    expect(caseView.attributeTitle2.text).to(equal("工事名"))
                    expect(caseView.attributeValue2.text).to(equal("")) // 重複した「工事名」には自動入力されない

                    expect(caseView.attributeTitle3).toNot(beNil())
                    expect(caseView.attributeValue3).toNot(beNil())
                    expect(caseView.attributeTitle3.text).to(equal("施工日"))
                    expect(caseView.attributeValue3.text).to(equal("")) // 重複した「施工日」には自動入力されない

                    expect(caseView.attributeTitle4).toNot(beNil())
                    expect(caseView.attributeValue4).toNot(beNil())
                    expect(caseView.attributeTitle4.text).to(equal("施工者"))
                    expect(caseView.attributeValue4.text).to(equal("")) // 重複した「施工者」には自動入力されない

                    expect(caseView.memoValue).toNot(beNil())
                    expect(caseView.memoValue.text).to(equal("現状"))

                    expect(caseView.separatedLeftValue).toNot(beNil())
                    expect(caseView.separatedRightValue).toNot(beNil())
                    expect(caseView.separatedLeftValue.text).to(equal(date.asDateString()))
                    expect(caseView.separatedRightValue.text).to(equal("担当者A"))
                }

            }
        }

        // MARK: - helper (for arrange)

        func constructionNameItem(position: Int) -> ModernBlackboardMaterial.Item {
            .init(
                itemName: "工事名",
                body: "",
                position: position
            )
        }

        func constructionTypeItem(position: Int) -> ModernBlackboardMaterial.Item {
            .init(
                itemName: "工種",
                body: "ダスター清掃",
                position: position
            )
        }

        func constructionDivisionItem(position: Int) -> ModernBlackboardMaterial.Item {
            .init(
                itemName: "工区",
                body: "2工区",
                position: position
            )
        }

        func roomNumberItem(position: Int) -> ModernBlackboardMaterial.Item {
            .init(
                itemName: "部屋番号",
                body: "123号室",
                position: position
            )
        }

        func memoItem(position: Int) -> ModernBlackboardMaterial.Item {
            .init(
                itemName: "備考",
                body: "現状",
                position: position
            )
        }

        func constructionDateItem(position: Int) -> ModernBlackboardMaterial.Item {
            .init(
                itemName: "施工日",
                body: "",
                position: position
            )
        }

        func constructionPlayerItem(position: Int) -> ModernBlackboardMaterial.Item {
            .init(
                itemName: "施工者",
                body: "",
                position: position
            )
        }
    }
}

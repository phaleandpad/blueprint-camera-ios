//
//  ModernBlackboardCommonSettingSpec.swift
//  andpad-camera_Tests
//
//  Created by Toru Kuriyama on 2023/07/13.
//  Copyright © 2023 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import XCTest
import Quick
import Nimble

final class ModernBlackboardCommonSettingSpec: QuickSpec {
    override class func spec() {
        // MARK: initializer(parsing JSON text)
        describe("initializer(parsing JSON text)") {

            // MARK: constructionNameDisplayType
            context("constructionNameDisplayType") {
                context("レスポンスがorder_name(他のパラメータは任意)") {
                    let sampleResponse =
                    """
                    {
                        "edit_theme_flg": true,
                        "blackboard_theme_code": 3,
                        "edit_blackboard_date_flg": true,
                        "builder_name_display": "feature2 オクト水道屋",
                        "date_format_type": 3,
                        "remark_text_size": "large",
                        "remark_horizontal_align": "right",
                        "remark_vertical_align": "bottom",
                        "custom_construction_name_elements": [],
                        "construction_name_display_type": "order_name",
                        "first_row_blackboard_item_body_type": "initial_value",
                        "first_row_blackboard_item_body": "工事名",
                        "first_row_blackboard_item_body_name": "工事名",
                        "blackboard_transparency_type": "opaque",
                        "blackboard_default_size_rate": 100,
                        "taking_photo_image_type": "jpeg"
                    }
                    """
                    it("orderNameが取得できること") {
                        let response = try JSONDecoder().decode(ModernBlackboardCommonSetting.self, from: sampleResponse.data(using: .utf8)!)
                        expect(response.constructionNameDisplayType).to(equal(.orderName))
                    }
                }

                context("レスポンスがcustom_construction_name(他のパラメータは任意)") {
                    let sampleResponse =
                    """
                    {
                        "edit_theme_flg": true,
                        "blackboard_theme_code": 3,
                        "edit_blackboard_date_flg": true,
                        "builder_name_display": "feature2 オクト水道屋",
                        "date_format_type": 3,
                        "remark_text_size": "large",
                        "remark_horizontal_align": "right",
                        "remark_vertical_align": "bottom",
                        "custom_construction_name_elements": [],
                        "construction_name_display_type": "custom_construction_name",
                        "first_row_blackboard_item_body_type": "initial_value",
                        "first_row_blackboard_item_body": "工事名",
                        "first_row_blackboard_item_body_name": "工事名",
                        "blackboard_transparency_type": "opaque",
                        "blackboard_default_size_rate": 100,
                        "taking_photo_image_type": "jpeg"
                    }
                    """
                    it("customConstructionNameが取得できること") {
                        let response = try JSONDecoder().decode(ModernBlackboardCommonSetting.self, from: sampleResponse.data(using: .utf8)!)
                        expect(response.constructionNameDisplayType).to(equal(.customConstructionName))
                    }
                }

                context("レスポンスがcustom_construction_name_reflected_newline(他のパラメータは任意)") {
                    let sampleResponse =
                    """
                    {
                        "edit_theme_flg": true,
                        "blackboard_theme_code": 3,
                        "edit_blackboard_date_flg": true,
                        "builder_name_display": "feature2 オクト水道屋",
                        "date_format_type": 3,
                        "remark_text_size": "large",
                        "remark_horizontal_align": "right",
                        "remark_vertical_align": "bottom",
                        "custom_construction_name_elements": [],
                        "construction_name_display_type": "custom_construction_name_reflected_newline",
                        "first_row_blackboard_item_body_type": "initial_value",
                        "first_row_blackboard_item_body": "工事名",
                        "first_row_blackboard_item_body_name": "工事名",
                        "blackboard_transparency_type": "opaque",
                        "blackboard_default_size_rate": 100,
                        "taking_photo_image_type": "jpeg"
                    }
                    """
                    it("customConstructionNameReflectedNewlineが取得できること") {
                        let response = try JSONDecoder().decode(ModernBlackboardCommonSetting.self, from: sampleResponse.data(using: .utf8)!)
                        expect(response.constructionNameDisplayType).to(equal(.customConstructionNameReflectedNewline))
                    }
                }
            }

            // MARK: customConstructionNameElements
            context("customConstructionNameElements") {
                context("3つの文字列が含まれる(他のパラメータは任意)") {
                    let sampleResponse =
                    """
                    {
                        "edit_theme_flg": true,
                        "blackboard_theme_code": 3,
                        "edit_blackboard_date_flg": true,
                        "builder_name_display": "feature2 オクト水道屋",
                        "date_format_type": 3,
                        "remark_text_size": "large",
                        "remark_horizontal_align": "right",
                        "remark_vertical_align": "bottom",
                        "custom_construction_name_elements": [
                            "案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名",
                            "改行改行改行改行改行改行改行改行改行改行改行改行改行",
                            "入力させる入力させる入力させる入力させる入力させる入力させる入力させる入力させる入力させる入力させる入力させる"
                        ],
                        "construction_name_display_type": "custom_construction_name_reflected_newline",
                        "first_row_blackboard_item_body_type": "initial_value",
                        "first_row_blackboard_item_body": "工事名",
                        "first_row_blackboard_item_body_name": "工事名",
                        "blackboard_transparency_type": "opaque",
                        "blackboard_default_size_rate": 100,
                        "taking_photo_image_type": "jpeg"
                    }
                    """
                    it("customConstructionNameElementsの要素数が3つ、かつ入力した文字列が含まれること") {
                        let response = try JSONDecoder().decode(ModernBlackboardCommonSetting.self, from: sampleResponse.data(using: .utf8)!)
                        expect(response.customConstructionNameElements).to(equal([
                            "案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名案件名",
                            "改行改行改行改行改行改行改行改行改行改行改行改行改行",
                            "入力させる入力させる入力させる入力させる入力させる入力させる入力させる入力させる入力させる入力させる入力させる"
                        ]))
                    }
                }

                context("空配列(他のパラメータは任意)") {
                    let sampleResponse =
                    """
                    {
                        "edit_theme_flg": true,
                        "blackboard_theme_code": 3,
                        "edit_blackboard_date_flg": true,
                        "builder_name_display": "feature2 オクト水道屋",
                        "date_format_type": 3,
                        "remark_text_size": "large",
                        "remark_horizontal_align": "right",
                        "remark_vertical_align": "bottom",
                        "custom_construction_name_elements": [],
                        "construction_name_display_type": "custom_construction_name_reflected_newline",
                        "first_row_blackboard_item_body_type": "initial_value",
                        "first_row_blackboard_item_body": "工事名",
                        "first_row_blackboard_item_body_name": "工事名",
                        "blackboard_transparency_type": "opaque",
                        "blackboard_default_size_rate": 100,
                        "taking_photo_image_type": "jpeg"
                    }
                    """
                    it("customConstructionNameElementsの要素数が0であること") {
                        let response = try JSONDecoder().decode(ModernBlackboardCommonSetting.self, from: sampleResponse.data(using: .utf8)!)
                        expect(response.customConstructionNameElements).to(beEmpty())
                    }
                }
            }

            // MARK: first_row_blackboard_item_body_name

            context("first_row_blackboard_item_body_name") {
                context("レスポンスが任意の文字列(他のパラメータは任意)") {
                    let sampleResponse =
                        """
                        {
                            "edit_theme_flg": true,
                            "blackboard_theme_code": 3,
                            "edit_blackboard_date_flg": true,
                            "builder_name_display": "feature2 オクト水道屋",
                            "date_format_type": 3,
                            "remark_text_size": "large",
                            "remark_horizontal_align": "right",
                            "remark_vertical_align": "bottom",
                            "custom_construction_name_elements": [],
                            "construction_name_display_type": "order_name",
                            "first_row_blackboard_item_body_type": "custom",
                            "first_row_blackboard_item_body": "自由な工事名1",
                            "first_row_blackboard_item_body_name": "自由な工事名2",
                            "blackboard_transparency_type": "opaque",
                            "blackboard_default_size_rate": 100,
                            "taking_photo_image_type": "jpeg"
                        }
                        """
                    it("入力した文字列が取得できること") {
                        let response = try JSONDecoder().decode(ModernBlackboardCommonSetting.self, from: sampleResponse.data(using: .utf8)!)
                        expect(response.constructionNameTitle).to(equal("自由な工事名2"))
                    }
                }
            }
            
            // MARK: blackboard_transparency_type
            context("blackboard_transparency_type") {
                context("レスポンスがopaque(他のパラメータは任意)") {
                    let sampleResponse =
                        """
                        {
                            "edit_theme_flg": true,
                            "blackboard_theme_code": 3,
                            "edit_blackboard_date_flg": true,
                            "builder_name_display": "feature2 オクト水道屋",
                            "date_format_type": 3,
                            "remark_text_size": "large",
                            "remark_horizontal_align": "right",
                            "remark_vertical_align": "bottom",
                            "custom_construction_name_elements": [],
                            "construction_name_display_type": "order_name",
                            "first_row_blackboard_item_body_type": "initial_value",
                            "first_row_blackboard_item_body": "工事名",
                            "first_row_blackboard_item_body_name": "工事名",
                            "blackboard_transparency_type": "opaque",
                            "blackboard_default_size_rate": 100,
                            "taking_photo_image_type": "jpeg"
                        }
                        """
                    it("opaqueが取得できること") {
                        let response = try JSONDecoder().decode(ModernBlackboardCommonSetting.self, from: sampleResponse.data(using: .utf8)!)
                        expect(response.blackboardTransparencyType).to(equal(.opaque))
                    }
                }

                context("レスポンスがtranslucent(他のパラメータは任意)") {
                    let sampleResponse =
                        """
                        {
                            "edit_theme_flg": true,
                            "blackboard_theme_code": 3,
                            "edit_blackboard_date_flg": true,
                            "builder_name_display": "feature2 オクト水道屋",
                            "date_format_type": 3,
                            "remark_text_size": "large",
                            "remark_horizontal_align": "right",
                            "remark_vertical_align": "bottom",
                            "custom_construction_name_elements": [],
                            "construction_name_display_type": "order_name",
                            "first_row_blackboard_item_body_type": "initial_value",
                            "first_row_blackboard_item_body": "工事名",
                            "first_row_blackboard_item_body_name": "工事名",
                            "blackboard_transparency_type": "translucent",
                            "blackboard_default_size_rate": 100,
                            "taking_photo_image_type": "jpeg"
                        }
                        """
                    it("translucentが取得できること") {
                        let response = try JSONDecoder().decode(ModernBlackboardCommonSetting.self, from: sampleResponse.data(using: .utf8)!)
                        expect(response.blackboardTransparencyType).to(equal(.translucent))
                    }
                }

                context("レスポンスがtransparent(他のパラメータは任意)") {
                    let sampleResponse =
                        """
                        {
                            "edit_theme_flg": true,
                            "blackboard_theme_code": 3,
                            "edit_blackboard_date_flg": true,
                            "builder_name_display": "feature2 オクト水道屋",
                            "date_format_type": 3,
                            "remark_text_size": "large",
                            "remark_horizontal_align": "right",
                            "remark_vertical_align": "bottom",
                            "custom_construction_name_elements": [],
                            "construction_name_display_type": "order_name",
                            "first_row_blackboard_item_body_type": "initial_value",
                            "first_row_blackboard_item_body": "工事名",
                            "first_row_blackboard_item_body_name": "工事名",
                            "blackboard_transparency_type": "transparent",
                            "blackboard_default_size_rate": 100,
                            "taking_photo_image_type": "jpeg"
                        }
                        """
                    it("transparentが取得できること") {
                        let response = try JSONDecoder().decode(ModernBlackboardCommonSetting.self, from: sampleResponse.data(using: .utf8)!)
                        expect(response.blackboardTransparencyType).to(equal(.transparent))
                    }
                }
            }
        }

        // MARK: constructionNameConsideringDisplayType
        describe("constructionNameConsideringDisplayType") {
            context("constructionNameDisplayTypeがorderName") {
                context("customConstructionNameElementsが非nil") {
                    let constructionNameArray = "案件名配列1"
                    it("nilを返すこと") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .orderName,
                            customConstructionNameElements: [constructionNameArray],
                            constructionNameTitle: "工事名",
                            blackboardTransparencyType: .opaque, 
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionNameConsideringDisplayType).to(beNil())
                    }
                }
            }

            context("constructionNameDisplayTypeがcustomConstructionName") {
                context("customConstructionNameElementsが要素1の配列") {
                    let constructionNameArray = "案件名配列1"
                    it("文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .customConstructionName,
                            customConstructionNameElements: [constructionNameArray],
                            constructionNameTitle: "工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionNameConsideringDisplayType).to(equal("案件名配列1"))
                    }
                }

                context("customConstructionNameElementsが要素3の配列") {
                    let constructionNameArray1 = "案件名配列1"
                    let constructionNameArray2 = "案件名配列2"
                    let constructionNameArray3 = "案件名配列3"
                    it("連結した文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .customConstructionName,
                            customConstructionNameElements: [constructionNameArray1, constructionNameArray2, constructionNameArray3],
                            constructionNameTitle: "工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionNameConsideringDisplayType).to(equal("案件名配列1案件名配列2案件名配列3"))
                    }
                }
            }

            context("constructionNameDisplayTypeがcustomConstructionNameReflectedNewline") {
                context("customConstructionNameElementsが要素1の配列") {
                    let constructionNameArray = "案件名配列1"
                    it("文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .customConstructionNameReflectedNewline,
                            customConstructionNameElements: [constructionNameArray],
                            constructionNameTitle: "工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionNameConsideringDisplayType).to(equal(constructionNameArray))
                    }
                }

                context("customConstructionNameElementsが要素3の配列") {
                    let constructionNameArrayArray1 = "案件名配列1"
                    let constructionNameArrayArray2 = "案件名配列2"
                    let constructionNameArrayArray3 = "案件名配列3"
                    it("改行コードで連結した文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .customConstructionNameReflectedNewline,
                            customConstructionNameElements: [constructionNameArrayArray1, constructionNameArrayArray2, constructionNameArrayArray3],
                            constructionNameTitle: "工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionNameConsideringDisplayType).to(equal("案件名配列1\n案件名配列2\n案件名配列3"))
                    }
                }
            }
        }

        // MARK: constructionName
        describe("constructionNameValue") {
            context("constructionNameDisplayTypeがorderName") {
                context("customConstructionNameElementsが要素1の配列") {
                    let constructionNameArray = "案件名配列1"
                    it("文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .orderName,
                            customConstructionNameElements: [constructionNameArray],
                            constructionNameTitle: "カスタム工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionName).to(equal("案件名配列1"))
                    }
                }

                context("customConstructionNameElementsが要素3の配列") {
                    let constructionNameArray1 = "案件名配列1"
                    let constructionNameArray2 = "案件名配列2"
                    let constructionNameArray3 = "案件名配列3"
                    it("連結した文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .orderName,
                            customConstructionNameElements: [constructionNameArray1, constructionNameArray2, constructionNameArray3],
                            constructionNameTitle: "カスタム工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionName).to(equal("案件名配列1案件名配列2案件名配列3"))
                    }
                }
            }

            context("constructionNameDisplayTypeがcustomConstructionName") {
                context("customConstructionNameElementsが要素1の配列") {
                    let constructionNameArray = "案件名配列1"
                    it("文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .customConstructionName,
                            customConstructionNameElements: [constructionNameArray],
                            constructionNameTitle: "カスタム工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionName).to(equal("案件名配列1"))
                    }
                }

                context("customConstructionNameElementsが要素3の配列") {
                    let constructionNameArray1 = "案件名配列1"
                    let constructionNameArray2 = "案件名配列2"
                    let constructionNameArray3 = "案件名配列3"
                    it("連結した文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .customConstructionName,
                            customConstructionNameElements: [constructionNameArray1, constructionNameArray2, constructionNameArray3],
                            constructionNameTitle: "カスタム工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionName).to(equal("案件名配列1案件名配列2案件名配列3"))
                    }
                }
            }

            context("constructionNameDisplayTypeがcustomConstructionName") {
                context("customConstructionNameElementsが要素1の配列") {
                    let constructionNameArray = "案件名配列1"
                    it("文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .customConstructionNameReflectedNewline,
                            customConstructionNameElements: [constructionNameArray],
                            constructionNameTitle: "カスタム工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionName).to(equal("案件名配列1"))
                    }
                }

                context("customConstructionNameElementsが要素3の配列") {
                    let constructionNameArray1 = "案件名配列1"
                    let constructionNameArray2 = "案件名配列2"
                    let constructionNameArray3 = "案件名配列3"
                    it("改行で連結した文字列が返ること") {
                        let targetModel = ModernBlackboardCommonSetting(
                            defaultTheme: .green,
                            canEditBlackboardStyle: true,
                            remarkTextSize: "large",
                            remarkHorizontalAlign: "right",
                            remarkVerticalAlign: "bottom",
                            dateFormatType: .withSlash,
                            canEditDate: true,
                            selectedConstructionPlayerName: "feature2 オクト水道屋",
                            constructionNameDisplayType: .customConstructionNameReflectedNewline,
                            customConstructionNameElements: [constructionNameArray1, constructionNameArray2, constructionNameArray3],
                            constructionNameTitle: "カスタム工事名",
                            blackboardTransparencyType: .opaque,
                            blackboardDefaultSizeRate: 100,
                            preferredPhotoFormat: .jpeg
                        )
                        expect(targetModel.constructionName).to(equal("案件名配列1\n案件名配列2\n案件名配列3"))
                    }
                }
            }
        }

        // MARK: shouldBeReflectedNewLine
        context("shouldBeReflectedNewLine") {
            context("constructionNameDisplayTypeがorderName") {
                it("falseを返すこと") {
                    let targetModel = ModernBlackboardCommonSetting(
                        defaultTheme: .green,
                        canEditBlackboardStyle: true,
                        remarkTextSize: "large",
                        remarkHorizontalAlign: "right",
                        remarkVerticalAlign: "bottom",
                        dateFormatType: .withSlash,
                        canEditDate: true,
                        selectedConstructionPlayerName: "feature2 オクト水道屋",
                        constructionNameDisplayType: .orderName,
                        customConstructionNameElements: ["案件名"],
                        constructionNameTitle: "工事名",
                        blackboardTransparencyType: .opaque,
                        blackboardDefaultSizeRate: 100,
                        preferredPhotoFormat: .jpeg
                    )
                    expect(targetModel.shouldBeReflectedNewLine).to(beFalse())
                }
            }

            context("constructionNameDisplayTypeがcustomConstructionName") {
                it("falseを返すこと") {
                    let targetModel = ModernBlackboardCommonSetting(
                        defaultTheme: .green,
                        canEditBlackboardStyle: true,
                        remarkTextSize: "large",
                        remarkHorizontalAlign: "right",
                        remarkVerticalAlign: "bottom",
                        dateFormatType: .withSlash,
                        canEditDate: true,
                        selectedConstructionPlayerName: "feature2 オクト水道屋",
                        constructionNameDisplayType: .customConstructionName,
                        customConstructionNameElements: ["案件名"],
                        constructionNameTitle: "工事名",
                        blackboardTransparencyType: .opaque,
                        blackboardDefaultSizeRate: 100,
                        preferredPhotoFormat: .jpeg
                    )
                    expect(targetModel.shouldBeReflectedNewLine).to(beFalse())
                }
            }

            context("constructionNameDisplayTypeがcustomConstructionNameReflectedNewline") {
                it("trueを返すこと") {
                    let targetModel = ModernBlackboardCommonSetting(
                        defaultTheme: .green,
                        canEditBlackboardStyle: true,
                        remarkTextSize: "large",
                        remarkHorizontalAlign: "right",
                        remarkVerticalAlign: "bottom",
                        dateFormatType: .withSlash,
                        canEditDate: true,
                        selectedConstructionPlayerName: "feature2 オクト水道屋",
                        constructionNameDisplayType: .customConstructionNameReflectedNewline,
                        customConstructionNameElements: ["案件名"],
                        constructionNameTitle: "工事名",
                        blackboardTransparencyType: .opaque,
                        blackboardDefaultSizeRate: 100,
                        preferredPhotoFormat: .jpeg
                    )
                    expect(targetModel.shouldBeReflectedNewLine).to(beTrue())
                }
            }
        }
      
        // MARK: constructionNameTitle

        context("constructionNameTitle") {
            context("constructionNameTitleが任意の文字列") {
                let constructionNameTitleValue = "自由な工事名"
                it("入力された文字列を返すこと") {
                    let targetModel = ModernBlackboardCommonSetting(
                        defaultTheme: .green,
                        canEditBlackboardStyle: true,
                        remarkTextSize: "large",
                        remarkHorizontalAlign: "right",
                        remarkVerticalAlign: "bottom",
                        dateFormatType: .withSlash,
                        canEditDate: true,
                        selectedConstructionPlayerName: "feature2 オクト水道屋",
                        constructionNameDisplayType: .orderName,
                        customConstructionNameElements: [],
                        constructionNameTitle: constructionNameTitleValue,
                        blackboardTransparencyType: .opaque,
                        blackboardDefaultSizeRate: 100,
                        preferredPhotoFormat: .jpeg
                    )
                    expect(targetModel.constructionNameTitle).to(equal(constructionNameTitleValue))
                }
            }
        }
        
        // MARK: blackboardTransparencyType

        context("blackboardTransparencyType") {
            context("blackboardTransparencyTypeがopaque") {
                it("opaqueを返すこと") {
                    let targetModel = ModernBlackboardCommonSetting(
                        defaultTheme: .green,
                        canEditBlackboardStyle: true,
                        remarkTextSize: "large",
                        remarkHorizontalAlign: "right",
                        remarkVerticalAlign: "bottom",
                        dateFormatType: .withSlash,
                        canEditDate: true,
                        selectedConstructionPlayerName: "feature2 オクト水道屋",
                        constructionNameDisplayType: .orderName,
                        customConstructionNameElements: [],
                        constructionNameTitle: "工事名",
                        blackboardTransparencyType: .opaque,
                        blackboardDefaultSizeRate: 100,
                        preferredPhotoFormat: .jpeg
                    )
                    expect(targetModel.blackboardTransparencyType).to(equal(.opaque))
                }
            }

            context("blackboardTransparencyTypeがtranslucent") {
                it("translucentを返すこと") {
                    let targetModel = ModernBlackboardCommonSetting(
                        defaultTheme: .green,
                        canEditBlackboardStyle: true,
                        remarkTextSize: "large",
                        remarkHorizontalAlign: "right",
                        remarkVerticalAlign: "bottom",
                        dateFormatType: .withSlash,
                        canEditDate: true,
                        selectedConstructionPlayerName: "feature2 オクト水道屋",
                        constructionNameDisplayType: .orderName,
                        customConstructionNameElements: [],
                        constructionNameTitle: "工事名",
                        blackboardTransparencyType: .translucent,
                        blackboardDefaultSizeRate: 100,
                        preferredPhotoFormat: .jpeg
                    )
                    expect(targetModel.blackboardTransparencyType).to(equal(.translucent))
                }
            }

            context("blackboardTransparencyTypeがtransparent") {
                it("transparentを返すこと") {
                    let targetModel = ModernBlackboardCommonSetting(
                        defaultTheme: .green,
                        canEditBlackboardStyle: true,
                        remarkTextSize: "large",
                        remarkHorizontalAlign: "right",
                        remarkVerticalAlign: "bottom",
                        dateFormatType: .withSlash,
                        canEditDate: true,
                        selectedConstructionPlayerName: "feature2 オクト水道屋",
                        constructionNameDisplayType: .orderName,
                        customConstructionNameElements: [],
                        constructionNameTitle: "工事名",
                        blackboardTransparencyType: .transparent,
                        blackboardDefaultSizeRate: 100,
                        preferredPhotoFormat: .jpeg
                    )
                    expect(targetModel.blackboardTransparencyType).to(equal(.transparent))
                }
            }
        }
    }
}

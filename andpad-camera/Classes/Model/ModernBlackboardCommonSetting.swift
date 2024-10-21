//
//  ModernBlackboardCommonSetting.swift
//  andpad-camera
//
//  Created by msano on 2021/06/10.
//

/// 黒板の共通設定データ
public struct ModernBlackboardCommonSetting: Codable, Sendable {
    public let defaultTheme: ModernBlackboardAppearance.Theme
    
    /// 撮影時にスタイル変更が可能かどうかのフラグ
    ///
    /// 会社毎の黒板設定において、撮影時のスタイル変更がOFFの場合は false
    public let canEditBlackboardStyle: Bool
    /// 備考のデフォルトテキストサイズ
    ///
    /// 会社毎の黒板設定において、案件毎のスタイル設定が不可の場合は 会社設定側のテキストサイズ
    public let remarkTextSize: String
    /// 備考のデフォルト水平方向配置
    ///
    /// 会社毎の黒板設定において、案件毎のスタイル設定が不可の場合は 会社設定側の水平方向配置
    public let remarkHorizontalAlign: String
    /// 備考のデフォルト垂直方向配置
    ///
    /// 会社毎の黒板設定において、案件毎のスタイル設定が不可の場合は 会社設定側の垂直方向配置
    public let remarkVerticalAlign: String
    /// 撮影日の表示形式
    ///
    /// 1: yyyy/mm/dd
    /// 2: yyyy年mm月dd日
    /// 3: 和暦yy年mm月dd日
    public let dateFormatType: DateFormatType
    /// 撮影日を変更可能か否か
    ///
    /// アプリ撮影時、撮影日（施工日）を変更可能かどうかの可否を返す。不可の場合 `false`
    public let canEditDate: Bool
    /// 黒板に表示する施工者名デフォルト設定
    public let selectedConstructionPlayerName: String
    /// 表示する工事名のタイプ
    public let constructionNameDisplayType: ConstructionNameDisplayType
    /// construction_name_display_type が order_name 以外の場合に黒板に表示する工事名。一行目から文字列が配列で渡される。
    public let customConstructionNameElements: [String]
    /// 黒板項目1行目に表示する値
    public let constructionNameTitle: String
    /// 黒板の透過度
    ///
    /// 会社毎の黒板設定において、案件毎のスタイル設定が不可の場合は 会社設定側の透過度
    public let blackboardTransparencyType: BlackboardTransparencyType
    /// 黒板のデフォルトサイズを100%とした場合のサイズ比率。0は指定なし。
    public let blackboardDefaultSizeRate: Int
    /// 黒板写真を撮影したときに保存されるファイル形式の設定
    ///
    /// 撮影時の初期設定、撮影時にファイル形式の設定は変更可能
    public let preferredPhotoFormat: PhotoFormat

    private enum CodingKeys: String, CodingKey {
        case defaultTheme = "blackboard_theme_code"
        
        // NOTE: もともとは黒板色の編集権限だったが、
        // 今回の改修（2022/7/4全体公開）で、黒板スタイル（備考書式設定、黒板色）の編集権限として扱われるようになった
        //  -> ただし、jsonパラメータ名自体は「edit_theme_flg」という、前の仕様に基づいた名前のままなので注意すること
        case canEditBlackboardStyle = "edit_theme_flg"

        case selectedConstructionPlayerName = "builder_name_display"
        case remarkTextSize = "remark_text_size"
        case remarkHorizontalAlign = "remark_horizontal_align"
        case remarkVerticalAlign = "remark_vertical_align"
        case dateFormatType = "date_format_type"
        case canEditDate = "edit_blackboard_date_flg"
        case constructionNameDisplayType = "construction_name_display_type"
        case customConstructionNameElements = "custom_construction_name_elements"
        case constructionNameTitle = "first_row_blackboard_item_body_name"
        case blackboardTransparencyType = "blackboard_transparency_type"
        case blackboardDefaultSizeRate = "blackboard_default_size_rate"
        case preferredPhotoFormat = "taking_photo_image_type"
    }
    
    public init(
        defaultTheme: ModernBlackboardAppearance.Theme,
        canEditBlackboardStyle: Bool,
        remarkTextSize: String,
        remarkHorizontalAlign: String,
        remarkVerticalAlign: String,
        dateFormatType: DateFormatType,
        canEditDate: Bool,
        selectedConstructionPlayerName: String,
        constructionNameDisplayType: ConstructionNameDisplayType,
        customConstructionNameElements: [String],
        constructionNameTitle: String,
        blackboardTransparencyType: BlackboardTransparencyType,
        blackboardDefaultSizeRate: Int,
        preferredPhotoFormat: PhotoFormat
    ) {
        self.defaultTheme = defaultTheme
        self.canEditBlackboardStyle = canEditBlackboardStyle
        self.remarkTextSize = remarkTextSize
        self.remarkHorizontalAlign = remarkHorizontalAlign
        self.remarkVerticalAlign = remarkVerticalAlign
        self.dateFormatType = dateFormatType
        self.canEditDate = canEditDate
        self.selectedConstructionPlayerName = selectedConstructionPlayerName
        self.constructionNameDisplayType = constructionNameDisplayType
        self.customConstructionNameElements = customConstructionNameElements
        self.constructionNameTitle = constructionNameTitle
        self.blackboardTransparencyType = blackboardTransparencyType
        self.blackboardDefaultSizeRate = blackboardDefaultSizeRate
        self.preferredPhotoFormat = preferredPhotoFormat
    }
}

// MARK: - decode
extension ModernBlackboardCommonSetting {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        defaultTheme = try .init(themeCode: values.decode(Int.self, forKey: .defaultTheme))
        canEditBlackboardStyle = try values.decode(Bool.self, forKey: .canEditBlackboardStyle)
        selectedConstructionPlayerName = try values.decode(String.self, forKey: .selectedConstructionPlayerName)
        remarkTextSize = try values.decode(String.self, forKey: .remarkTextSize)
        remarkHorizontalAlign = try values.decode(String.self, forKey: .remarkHorizontalAlign)
        remarkVerticalAlign = try values.decode(String.self, forKey: .remarkVerticalAlign)

        let dateFormatTypeInt = try values.decode(Int.self, forKey: .dateFormatType)
        if let dateFormatType = DateFormatType(rawValue: dateFormatTypeInt) {
            self.dateFormatType = dateFormatType
        } else {
            assertionFailure("[想定外のエラー]dateFormatTypeが不正な値です: \(dateFormatTypeInt)")
            // クラッシュしないようデフォルト値を設定
            self.dateFormatType = .defaultValue
        }

        canEditDate = try values.decode(Bool.self, forKey: .canEditDate)

        let constructionNameDisplayTypeString = try values.decode(String.self, forKey: .constructionNameDisplayType)
        if let constructionNameDisplayType = ConstructionNameDisplayType(rawValue: constructionNameDisplayTypeString) {
            self.constructionNameDisplayType = constructionNameDisplayType
        } else {
            assertionFailure("[想定外のエラー]constructionNameDisplayTypeが不正な値です: \(constructionNameDisplayTypeString)")
            // クラッシュしないようデフォルト値を設定
            self.constructionNameDisplayType = .orderName
        }

        customConstructionNameElements = try values.decode([String].self, forKey: .customConstructionNameElements)
        constructionNameTitle = try values.decode(String.self, forKey: .constructionNameTitle)

        let blackboardTransparencyTypeString = try values.decode(String.self, forKey: .blackboardTransparencyType)
        if let blackboardTransparencyType = BlackboardTransparencyType(rawValue: blackboardTransparencyTypeString) {
            self.blackboardTransparencyType = blackboardTransparencyType
        } else {
            assertionFailure("[想定外のエラー]blackboardTransparencyTypeが不正な値です: \(blackboardTransparencyTypeString)")
            // クラッシュしないようデフォルト値を設定
            self.blackboardTransparencyType = .opaque
        }

        blackboardDefaultSizeRate = try values.decode(Int.self, forKey: .blackboardDefaultSizeRate)

        let preferredPhotoFormatString = try values.decode(String.self, forKey: .preferredPhotoFormat)
        if let preferredPhotoFormat = PhotoFormat(rawValue: preferredPhotoFormatString) {
            self.preferredPhotoFormat = preferredPhotoFormat
        } else {
            assertionFailure("[想定外のエラー]preferredPhotoFormatが不正な値です: \(preferredPhotoFormatString)")
            // クラッシュしないようデフォルト値を設定
            self.preferredPhotoFormat = .jpeg
        }
    }
}

// MARK: - DateFormatType
extension ModernBlackboardCommonSetting {
    public enum DateFormatType: Int, Encodable, Sendable {
        /// yyyy/mm/dd
        case withSlash = 1
        
        /// yyyy年mm月dd日
        case withChineseChar
        
        /// 元号y年m月d日
        case withChineseCharAndEraName
        
        public static var defaultValue: Self {
            .withSlash
        }
        
        var formatString: String {
            switch self {
            case .withSlash:
                "yyyy/MM/dd"
            case .withChineseChar:
                "yyyy年MM月dd日"
            case .withChineseCharAndEraName:
                "Gy年M月d日" // このフォーマットは0埋めしない
            }
        }
        
        var calenderIdentifier: Calendar.Identifier {
            switch self {
            // .withChineseCharは西暦表示をしたいため .gregorianとなる
            case .withSlash, .withChineseChar:
                    .gregorian
            case .withChineseCharAndEraName:
                    .japanese
            }
        }
        
        var locale: Locale {
            switch self {
            case .withSlash:
                    .init(identifier: "en_US_POSIX")
            case .withChineseChar, .withChineseCharAndEraName:
                    .init(identifier: "ja")
            }
        }
    }
}

// MARK: - for memo style
extension ModernBlackboardCommonSetting {
    public var memoStyleArguments: ModernBlackboardMemoStyleArguments {
        .init(
            textColor: defaultTheme.textColor,
            adjustableMaxFontSize: adjustableMaxFontSize,
            verticalAlignment: verticalAlignment,
            horizontalAlignment: horizontalAlignment
        )
    }
    
    public var adjustableMaxFontSize: ModernMemoStyleType.AdjustableMaxFontSize {
        switch remarkTextSize {
        case "small":
                .small
        case "medium":
                .medium
        case "large":
                .large
        default:
                .small
        }
    }
    
    public var horizontalAlignment: NSTextAlignment {
        switch remarkHorizontalAlign {
        case "left":
                .left
        case "center":
                .center
        case "right":
                .right
        default:
                .left
        }
    }
    
    public var verticalAlignment: ModernMemoStyleType.VerticalAlignment {
        switch remarkVerticalAlign {
        case "top":
                .top
        case "middle":
                .middle
        case "bottom":
                .bottom
        default:
                .top
        }
    }
}

// MARK: - DateFormatType
extension ModernBlackboardCommonSetting {
    /// 表示する工事名のタイプ
    public enum ConstructionNameDisplayType: String, Encodable, Sendable {
        /// 工事名に案件名を利用
        case orderName = "order_name"
        /// 工事名に custom_construction_name を利用(改行反映なし)
        case customConstructionName = "custom_construction_name"
        /// 工事名に custom_construction_name を利用(改行反映)
        case customConstructionNameReflectedNewline = "custom_construction_name_reflected_newline"
    }
}

// MARK: - for construction name
extension ModernBlackboardCommonSetting {
    public var constructionNameConsideringDisplayType: String? {
        switch constructionNameDisplayType {
        case .orderName:
            // orderNameの場合は呼び出し元でorderNameを代入する必要があるので、nilを返す
            nil
        case .customConstructionName:
            customConstructionNameElements.joined()
        case .customConstructionNameReflectedNewline:
            customConstructionNameElements.joined(separator: "\n")
        }
    }

    /// constructionNameDisplayTypeによらずcustomConstructionNameElementsで取得した文字列をそのまま返す。
    /// 文字配列を結合する際に使用するセパレータについてはconstructionNameDisplayTypeに応じて使い分ける(Androidと同じロジック)
    ///  ※カメラ画面から選択黒板一覧画面で黒板を選び直すまでの間にWebで設定が変更された際、元々の案件名を取得できないケースがあったので、
    ///   確実に最新の案件名を取得可能なこちらのプロパティから取得するようにした
    public var constructionName: String {
        switch constructionNameDisplayType {
        case .orderName, .customConstructionName:
            customConstructionNameElements.joined()
        case .customConstructionNameReflectedNewline:
            customConstructionNameElements.joined(separator: "\n")
        }
    }

    public var shouldBeReflectedNewLine: Bool {
        switch constructionNameDisplayType {
        case .orderName, .customConstructionName:
            false
        case .customConstructionNameReflectedNewline:
            true
        }
    }
}

// MARK: - ModernBlackboardCommonSetting.BlackboardTransparencyType

extension ModernBlackboardCommonSetting {
    /// 黒板の透明度の種類
    ///
    /// - Note: この型はAPIからのレスポンスであり、ユーザーが操作できません。`AlphaLevel`はユーザーが直接操作する型です。それぞれ異なるケースで使用されます。
    ///
    /// - SeeAlso: ``ModernBlackboardAppearance/AlphaLevel``
    public enum BlackboardTransparencyType: String, Encodable, Sendable {
        /// 透過なし
        case opaque
        /// 半透明
        case translucent
        /// 透明
        case transparent
    }
}

// MARK: - ModernBlackboardCommonSetting.PhotoFormat

extension ModernBlackboardCommonSetting {
    /// 黒板写真を撮影したときに保存されるファイル形式の設定
    public enum PhotoFormat: String, Encodable, Sendable {
        /// JPEG形式
        case jpeg
        /// SVG形式
        case svg
    }
}

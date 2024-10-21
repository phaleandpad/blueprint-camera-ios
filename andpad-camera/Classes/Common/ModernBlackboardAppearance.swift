//
//  ModernBlackboardAppearance.swift
//  andpad-camera
//
//  Created by msano on 2021/06/08.
//

public struct ModernBlackboardAppearance: Equatable {
    public private(set) var theme: Theme
    public private(set) var alphaLevel: AlphaLevel
    public private(set) var dateFormatType: ModernBlackboardCommonSetting.DateFormatType
    public private(set) var memoStyleArguments: ModernBlackboardMemoStyleArguments
    public private(set) var shouldBeReflectedNewLine: Bool
    /// 黒板のサイズの種類
    public private(set) var sizeType: ModernBlackboardSizeType

    public var backgroundColorWithAlpha: UIColor {
        switch alphaLevel {
        case .zero:
            return theme.baseColor
        case .half:
            return theme.baseColor.withAlphaComponent(0.5)
        case .full:
            return .clear
        }
    }

    public init(
        theme: Theme,
        alphaLevel: AlphaLevel,
        dateFormatType: ModernBlackboardCommonSetting.DateFormatType,
        memoStyleArguments: ModernBlackboardMemoStyleArguments? = nil,
        shouldBeReflectedNewLine: Bool,
        sizeRate: Int? = nil
    ) {
        self.theme = theme
        self.alphaLevel = alphaLevel
        self.dateFormatType = dateFormatType
        self.shouldBeReflectedNewLine = shouldBeReflectedNewLine
        self.sizeType = .init(sizeRate: sizeRate)
        
        guard let memoStyleArguments else {
            // 備考スタイル指定がない場合、デフォルトスタイルを渡す
            self.memoStyleArguments = .defaultSetting(with: theme.textColor)
            return
        }
        self.memoStyleArguments = memoStyleArguments
    }
    
    /// 黒板アピアランスの初期化
    ///
    /// - Parameters:
    ///   - theme: 黒板の色
    ///   - blackboardTransparencyType: 黒板の透明度の種類
    ///   - dateFormatType: 撮影日の表示形式の種類
    ///   - memoStyleArguments: 備考欄の書式設定
    ///   - shouldBeReflectedNewLine: 改行を反映すべきか否か
    ///   - sizeRate: 黒板サイズレート〔%〕。初期値は `nil`
    ///
    /// - Note: 黒板の透明度は設定APIからの反映を想定しています。
    public init(
        theme: Theme,
        blackboardTransparencyType: ModernBlackboardCommonSetting.BlackboardTransparencyType,
        dateFormatType: ModernBlackboardCommonSetting.DateFormatType,
        memoStyleArguments: ModernBlackboardMemoStyleArguments? = nil,
        shouldBeReflectedNewLine: Bool,
        sizeRate: Int? = nil
    ) {
        let alphaLevel = AlphaLevel(blackboardTransparencyType: blackboardTransparencyType)
        self.init(
            theme: theme,
            alphaLevel: alphaLevel,
            dateFormatType: dateFormatType,
            memoStyleArguments: memoStyleArguments,
            shouldBeReflectedNewLine: shouldBeReflectedNewLine,
            sizeRate: sizeRate
        )
    }
}

// MARK: - update
extension ModernBlackboardAppearance {
    func updating(by theme: Theme) -> Self {
        with {
            $0.theme = theme
        }
    }
    
    /// 設定APIから取得した黒板の透明度の種類を用いて黒板の透明度を更新する
    ///
    /// 指定された設定APIから取得した黒板の透明度の種類に基づいて `AlphaLevel` を生成し、
    /// それを使用して黒板の透明度を更新する。
    ///
    /// - Parameter blackboardTransparencyType: 更新に使用する黒板の透明度の種類
    /// - Returns: 更新後のオブジェクト
    func updating(by blackboardTransparencyType: ModernBlackboardCommonSetting.BlackboardTransparencyType) -> Self {
        let alphaLevel = AlphaLevel(blackboardTransparencyType: blackboardTransparencyType)
        return updating(by: alphaLevel)
    }

    func updating(by alphaLevel: AlphaLevel) -> Self {
        with {
            $0.alphaLevel = alphaLevel
        }
    }

    func updating(by dateFormatType: ModernBlackboardCommonSetting.DateFormatType) -> Self {
        with {
            $0.dateFormatType = dateFormatType
        }
    }

    func updating(by memoStyleArguments: ModernBlackboardMemoStyleArguments) -> Self {
        with {
            $0.memoStyleArguments = memoStyleArguments
        }
    }

    func updating(shouldBeReflectedNewLine: Bool) -> Self {
        with {
            $0.shouldBeReflectedNewLine = shouldBeReflectedNewLine
        }
    }

    func updating(by sizeType: ModernBlackboardSizeType) -> Self {
        with {
            $0.sizeType = sizeType
        }
    }

    func updating(sizeTypeWithRate sizeRate: Int?) -> Self {
        updating(by: .init(sizeRate: sizeRate))
    }
}

// MARK: - Theme
extension ModernBlackboardAppearance {
    public enum Theme: Int, Encodable, CaseIterable, Sendable, EditableBlackboardDataProtocol {
        case black = 1
        case white
        case green

        init(themeCode: Int) {
            guard let theme = Self.allCases.first(where: { $0.themeCode == themeCode }) else {
                self = .black // 設定値がない場合はblackテーマをデフォルトとする
                return
            }
            self = theme
        }

        var themeCode: Int {
            self.rawValue
        }

        fileprivate var baseColor: UIColor {
            switch self {
            case .black:
                return .gray444
            case .white:
                return .white
            case .green:
                return .modernBlackboardBackgroundGreenColor
            }
        }

        public var textColor: UIColor {
            switch self {
            case .black:
                return .white
            case .white:
                return .gray222
            case .green:
                return .white
            }
        }

        var borderColor: UIColor {
            switch self {
            case .black:
                return .white
            case .white:
                return .gray222
            case .green:
                return .white
            }
        }
        
        /// プレースホルダー（風の表現に使用する）テキスト色
        var likePlaceholderTextColor: UIColor {
            switch self {
            case .black:
                return .gray7C
            case .white:
                return .gray222.withAlphaComponent(0.2)
            case .green:
                return .white.withAlphaComponent(0.3)
            }
        }
    }
}

// MARK: - AlphaLevel
extension ModernBlackboardAppearance {
    /// 黒板の透明度のアルファ値を管理する
    ///
    /// - Note: この型はユーザーが直接操作可能です。一方で`BlackboardTransparencyType`はAPIレスポンスに基づいていますので、ユーザーが操作できません。そのため、それぞれ異なるケースで使用されます。
    ///
    /// - SeeAlso: ``ModernBlackboardCommonSetting/BlackboardTransparencyType``
    public enum AlphaLevel: Int, EditableBlackboardDataProtocol, CaseIterable {
        /// 透過なし
        case zero = 0
        
        /// 半透明
        case half
        
        /// 透明
        case full

        var title: String {
            switch self {
            case .zero: return "透過なし"
            case .half: return "半透過"
            case .full: return "透明"
            }
        }

        /// 黒板のアルファ値を、設定APIから取得した黒板の透明度の種類を元に初期化する
        /// - Parameter blackboardTransparencyType: 黒板の透明度の種類
        init(blackboardTransparencyType: ModernBlackboardCommonSetting.BlackboardTransparencyType) {
            switch blackboardTransparencyType {
            case .opaque:
                self = .zero
            case .translucent:
                self = .half
            case .transparent:
                self = .full
            }
        }
    }
}

// MARK: - データ比較

extension ModernBlackboardAppearance {
    /// 黒板のスタイルが一致するかどうかを判定する
    ///
    /// この関数は、二つの黒板アピアランスのインスタンスが一致するか判定する。
    /// 一致していない場合、たとえばWeb側の設定とローカルの設定が異なるときに、
    /// アラートを表示してWeb側のデータを反映するかどうかを尋ねる際に使用することができる。
    /// - Parameter target: 比較する対象の黒板アピアランスのインスタンス
    /// - Returns: 一致している場合は`true`、そうでない場合は`false`
    func matchesAppearance(with target: Self) -> Bool {
        theme == target.theme
            && memoStyleArguments == target.memoStyleArguments
            && dateFormatType == target.dateFormatType
            && alphaLevel == target.alphaLevel
    }
}

private extension ModernBlackboardAppearance {
    /// この `ModernBlackboardAppearance` のインスタンスを変更するための便利メソッドです。
    /// このメソッドは、インスタンスのプロパティを変更するクロージャを受け取り、
    /// 変更された新しいインスタンスを返します。
    ///
    /// - 使用方法:
    ///
    /// ```
    /// let appearance = ModernBlackboardAppearance(...).with {
    ///   $0.theme = .black
    ///   $0.alphaLevel = .half
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - block: `ModernBlackboardAppearance` のプロパティを変更するためのクロージャ。
    ///     `inout Self` を受け取り、変更を適用します。
    /// - Returns: 変更された `ModernBlackboardAppearance` の新しいインスタンス。
    func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
}

// MARK: - ModernBlackboardAppearance.ModernBlackboardSizeType

public extension ModernBlackboardAppearance {
    /// 黒板のサイズの種類
    ///
    /// - Note: この型はユーザーが直接操作可能です。
    enum ModernBlackboardSizeType: Int, EditableBlackboardDataProtocol, CaseIterable {
        /// 小
        case small
        /// 中
        case medium
        /// 大
        case large
        /// 自由値
        case free

        /// 黒板サイズレートを元に黒板サイズタイプを初期化する
        ///
        /// 初期化時に黒板のサイズレートを受け取り、以下のカテゴリーに分類する: 75％: 小。100%: 中。150%: 大。 `0`: 自由値。
        ///
        /// オフラインモードの場合、黒板サイズレートがダウンロードされていない場合は、サイズレートが `nil` になる。この場合は自由値として扱う。
        /// - Parameter sizeRate: 黒板サイズレート〔%〕
        public init(sizeRate: Int?) {
            guard let sizeRate else {
                self = .free
                return
            }
            switch sizeRate {
            case 0:
                self = .free
            case 75:
                self = .small
            case 100:
                self = .medium
            case 150:
                self = .large
            default:
                // 通常はここに到達すべきではない
                assertionFailure("Warning: Unexpected sizeRate \(sizeRate). Defaulting to .free")
                self = .free
            }
        }

        var title: String {
            switch self {
            case .small:
                L10n.Camera.BlackboardSettings.Size.small
            case .medium:
                L10n.Camera.BlackboardSettings.Size.medium
            case .large:
                L10n.Camera.BlackboardSettings.Size.large
            case .free:
                L10n.Camera.BlackboardSettings.Size.free
            }
        }

        /// 黒板のデフォルトサイズに対するスケール係数
        ///
        /// 要件: 拡大比率は、小は75％、中は100%、大は150%に設定する。
        var scaleFactor: CGFloat? {
            switch self {
            case .small:
                return 0.75
            case .medium:
                return 1.0
            case .large:
                return 1.5
            case .free:
                return nil
            }
        }

        /// このサイズタイプが指定されたサイズレートと一致するかどうかを判定する
        /// - Parameter otherSizeRate: サイズレート
        /// - Returns: 一致している場合は`true`、そうでない場合は`false`
        func matchesSizeRate(_ otherSizeRate: Int?) -> Bool {
            let otherSizeType = ModernBlackboardSizeType(sizeRate: otherSizeRate)
            return self == otherSizeType
        }
    }
}

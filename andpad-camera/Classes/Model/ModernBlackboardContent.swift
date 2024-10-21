//
//  ModernBlackboardContent.swift
//  andpad-camera
//
//  Created by 江本 光晴 on 2024/06/26.
//

import Foundation

/**
 黒板を生成するコンテンツデータ
 */
public struct ModernBlackboardContent: Sendable {
    public enum BlackboardContentError: LocalizedError {
        /// 未定義の黒板エラー
        case undefinedBlackboard(layoutTypeID: Int)

        public var errorDescription: String? {
            switch self {
            case .undefinedBlackboard(let layoutTypeID):
                return "未定義の黒板エラーが発生しました: \(layoutTypeID)"
            }
        }
    }

    enum ModernBlackboardDataObject {
        case material(item: ModernBlackboardMaterial)
        case layout(item: ModernBlackboardLayout)
    }
    
    let modernBlackboardDataObject: ModernBlackboardDataObject
    let pattern: ModernBlackboardContentView.Pattern
    let customTitles: [String]
    let values: [String]?
    let theme: ModernBlackboardAppearance.Theme
    let memoStyleArguments: ModernBlackboardMemoStyleArguments
    let displayStyle: ModernBlackboardCaseViewDisplayStyle
    let alphaLevel: ModernBlackboardAppearance.AlphaLevel
    let shouldBeReflectedNewLine: Bool

    init(
        modernBlackboardDataObject: ModernBlackboardDataObject,
        pattern: ModernBlackboardContentView.Pattern,
        customTitles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        alphaLevel: ModernBlackboardAppearance.AlphaLevel,
        shouldBeReflectedNewLine: Bool
    ) {
        self.modernBlackboardDataObject = modernBlackboardDataObject
        self.pattern = pattern
        self.customTitles = customTitles
        self.values = values
        self.theme = theme
        self.memoStyleArguments = memoStyleArguments
        self.displayStyle = displayStyle
        self.alphaLevel = alphaLevel
        self.shouldBeReflectedNewLine = shouldBeReflectedNewLine
    }

    public init(
        material: ModernBlackboardMaterial,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        dateFormatType: ModernBlackboardCommonSetting.DateFormatType,
        alphaLevel: ModernBlackboardAppearance.AlphaLevel,
        miniatureMapImageState: MiniatureMapImageState?,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) throws {
        guard let pattern = ModernBlackboardContentView.Pattern(by: material.layoutTypeID) else {
            throw BlackboardContentError.undefinedBlackboard(layoutTypeID: material.layoutTypeID)
        }
        self.init(
            modernBlackboardDataObject: .material(item: material),
            pattern: pattern,
            customTitles: material.items.map { $0.itemName },
            values: material.items.map { item -> String in
                guard item.position == pattern.specifiedPosition(by: .date) else {
                    return item.body
                }
                return item.body
                    .asDateFromDateString()?
                    .asDateString(
                        formatString: dateFormatType.formatString,
                        locale: dateFormatType.locale,
                        calenderIdentifier: dateFormatType.calenderIdentifier
                    ) ?? item.body
            },
            theme: theme,
            memoStyleArguments: memoStyleArguments,
            displayStyle: displayStyle,
            alphaLevel: alphaLevel,
            shouldBeReflectedNewLine: shouldBeReflectedNewLine
        )
    }
}

extension ModernBlackboardContent {
    
    func makeSVGBlackboardURL(
        size: CGSize,
        miniatureMapImageType: MiniatureMapImageType,
        shouldShowMiniatureMapFromLocal: Bool,
        isShowEmptyMiniatureMap: Bool,
        isHiddenNoneAndEmptyMiniatureMap: Bool
    ) async -> URL? {
        let blackboardProps = await BlackboardProps(
            blackboardContent: self,
            size: size,
            miniatureMapImageType: miniatureMapImageType,
            shouldShowMiniatureMapFromLocal: shouldShowMiniatureMapFromLocal,
            isShowEmptyMiniatureMap: isShowEmptyMiniatureMap,
            isHiddenNoneAndEmptyMiniatureMap: isHiddenNoneAndEmptyMiniatureMap,
            shouldShowPlaceholder: false
        )
        // index.html と汎用性高い名前だが、今は他にリソースに同名ファイルがないので、そのまま利用してます
        guard
            let url = Bundle.andpadCamera.url(forResource: "index.html", withExtension: nil),
            // TODO: カメラ画面への影響が広いので、暫定的にエラー処理を省略します。
            let query = try? blackboardProps.makeQueryParameter() else {
            return nil
        }

        let urlString = "\(url.absoluteString)?\(query)"
        return URL(string: urlString)
    }
}

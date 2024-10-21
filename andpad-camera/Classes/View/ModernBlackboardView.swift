//
//  ModernBlackboardView.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2021/02/15.
//

import EasyPeasy
import UIKit

public final class ModernBlackboardView: BlackboardBaseView {
    private let contentView: ModernBlackboardContentView

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(
        contentView: ModernBlackboardContentView,
        appearance: ModernBlackboardAppearance,
        shouldSetCornerRounder: Bool = true
    ) {
        self.contentView = contentView
        super.init(frame: .zero)

        addSubview(contentView)
        contentView.easy.layout(Edges())
        backgroundColor = appearance.backgroundColorWithAlpha
        
        if shouldSetCornerRounder {
            layer.cornerRadius = 8.0
        }
        clipsToBounds = true
    }

    public convenience init?(
        _ modernBlackboardData: ModernBlackboardData,
        appearance: ModernBlackboardAppearance,
        miniatureMapImageState: MiniatureMapImageState?,
        displayStyle: ModernBlackboardCaseViewDisplayStyle
    ) {
        let contentView = ModernBlackboardContentView(
            modernBlackboardData,
            theme: appearance.theme,
            memoStyleArguments: appearance.memoStyleArguments,
            dateFormatType: appearance.dateFormatType,
            miniatureMapImageState: miniatureMapImageState,
            displayStyle: displayStyle,
            shouldBeReflectedNewLine: appearance.shouldBeReflectedNewLine,
            alphaLevel: appearance.alphaLevel
        )
        guard let contentView else { return nil }

        self.init(
            contentView: contentView,
            appearance: appearance,
            shouldSetCornerRounder: displayStyle.shouldSetCornerRounder
        )
    }
}

extension ModernBlackboardView {
    
    /**
     生成される黒板サイズ（下のimage関数から切り出しました）
     */
    public static var blackboardImageSize: CGSize {
        return .init(width: 360, height: 276)
    }
    
    /**
     生成される黒板フレーム（下のimage関数から切り出しました）
     */
    public func prepareFrameForImage() {
        frame = .init(
            origin: .zero,
            size: ModernBlackboardView.blackboardImageSize
        )
    }
    
    /**
     従来型の手順で作成される黒板画像
     */
    public var image: UIImage? {
        // NOTE: 画像出力前にxibと同サイズのframeを渡す
        prepareFrameForImage()

        do {
            return try toImage()
        } catch {
            print(error)
            return nil
        }
    }
}

// MARK: - 本体 / カメラ両用
extension ModernBlackboardView {
    public static func image(
        _ modernBlackboardData: ModernBlackboardData,
        appearance: ModernBlackboardAppearance,
        miniatureMapImageState: MiniatureMapImageState?,
        displayStyle: ModernBlackboardCaseViewDisplayStyle
    ) -> UIImage? {
        return ModernBlackboardView(
            modernBlackboardData,
            appearance: appearance,
            miniatureMapImageState: miniatureMapImageState,
            displayStyle: displayStyle
        )?.image
    }
    
    public static func image(
        _ modernBlackboardData: ModernBlackboardData,
        dateFormatType: ModernBlackboardCommonSetting.DateFormatType,
        memoStyleArguments: ModernBlackboardMemoStyleArguments?,
        miniatureMapImageState: MiniatureMapImageState?,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) -> UIImage? {
        let theme: ModernBlackboardAppearance.Theme
        if let layout = modernBlackboardData as? ModernBlackboardLayout {
            theme = layout.blackboardTheme
        } else if let material = modernBlackboardData as? ModernBlackboardMaterial {
            theme = material.blackboardTheme
        } else {
            return nil
        }
        
        return ModernBlackboardView(
            modernBlackboardData,
            appearance: .init(
                theme: theme,
                alphaLevel: .zero,
                dateFormatType: dateFormatType,
                memoStyleArguments: memoStyleArguments,
                shouldBeReflectedNewLine: shouldBeReflectedNewLine
            ),
            miniatureMapImageState: miniatureMapImageState,
            displayStyle: displayStyle
        )?.image
    }
}

/**
 黒板を画像化する
 */
extension ModernBlackboardView {
    /**
     黒板を画像化する
     */
    func exportImage(
        miniatureMapImageType: MiniatureMapImageType,
        shouldShowMiniatureMapFromLocal: Bool,
        isShowEmptyMiniatureMap: Bool,
        isHiddenNoneAndEmptyMiniatureMap: Bool,
        useBlackboardGeneratedWithSVG: Bool
    ) async -> UIImage? {
        if useBlackboardGeneratedWithSVG {
            // SVGで黒板を生成する
            
            // カッコ悪いが、self.image でも冒頭でframeを設定しているので、従う
            prepareFrameForImage()
                        
            // SVGで黒板を生成する
            let image = await contentView.exportImageWithSVG(
                size: frame.size,
                miniatureMapImageType: miniatureMapImageType,
                shouldShowMiniatureMapFromLocal: shouldShowMiniatureMapFromLocal,
                isShowEmptyMiniatureMap: isShowEmptyMiniatureMap,
                isHiddenNoneAndEmptyMiniatureMap: isHiddenNoneAndEmptyMiniatureMap
            )
            return image
        } else {
            // 従来の画像化
            return self.image
        }
    }
}

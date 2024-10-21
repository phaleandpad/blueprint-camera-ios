//
//  ModernBlackboardCase2205View.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/02/11.
//

import Foundation
import UIKit

// MARK: - ModernBlackboardCase2205View

final class ModernBlackboardCase2205View: BlackboardBaseView {
    /// 項目のタイトル
    @IBOutlet private var attributeTitles: [UILabel]!
    /// 項目の値
    @IBOutlet private var attributeValues: [UILabel]!
    /// 備考欄の値
    @IBOutlet private weak var memoValue: ModernBlackboardItemTextView!
    /// 豆図
    @IBOutlet private weak var miniatureMapImageView: UIImageView!
    /// 設定された施工者名の値
    @IBOutlet private weak var companyNameValue: UILabel!

    /// 工事名の値のラベル
    ///
    /// 項目の値の最初の行は、工事名として扱う
    private var constructionNameValueLabel: UILabel? {
        attributeValues.first
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpViews()
    }

    private func setUpViews() {
        // Note: XibファイルのAttributes Inspectorでtagを設定している
        // IBOutlet Collectionは順不同で接続されるため、tagに基づいて昇順にソートする
        attributeTitles.sort(by: { $0.tag < $1.tag })
        attributeValues.sort(by: { $0.tag < $1.tag })
    }
}

// MARK: ModernBlackboardCaseViewProtocol

extension ModernBlackboardCase2205View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        setAttributeTitles(titles)
        setAttributeValues(values, with: displayStyle)
        setLabelStyles(
            with: theme,
            memoStyleArguments: memoStyleArguments,
            displayStyle: displayStyle,
            patternType: patternType,
            shouldBeReflectedNewLine: shouldBeReflectedNewLine
        )
    }

    private func setAttributeTitles(_ titles: [String]) {
        for (offset, title) in titles.enumerated() {
            guard offset < attributeTitles.count else {
                // これを満たさないのは備考、撮影日、施工者名のみ。これらの項目はvalueだけでtitleは表示しないため、breakして問題ない
                break
            }
            attributeTitles[offset].text = title
        }
    }

    private func setAttributeValues(_ values: [String]?, with displayStyle: ModernBlackboardCaseViewDisplayStyle) {
        guard let values else {
            // 値がない場合は別途設定する
            constructionNameValueLabel?.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            companyNameValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
            return
        }

        for (offset, value) in values.enumerated() {
            setAttributeValue(value, offset: offset, displayStyle: displayStyle)
        }
    }

    private func setAttributeValue(
        _ value: String,
        offset: Int,
        displayStyle: ModernBlackboardCaseViewDisplayStyle
    ) {
        switch offset {
        case 0:
            // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
            constructionNameValueLabel?.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: value
            )
        case 1 ... 5:
            attributeValues[offset].text = value
        case 6:
            // 備考欄
            memoValue.text = value
        case 7:
            // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
            companyNameValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: value
            )
        default:
            assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 value：\(value) , offset：\(offset)")
        }
    }

    private func setLabelStyles(
        with theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        patternType: ModernBlackboardContentView.PatternType,
        shouldBeReflectedNewLine: Bool
    ) {
        attributeTitles.forEach {
            $0.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .title
            )
        }

        attributeValues.forEach {
            $0.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )

        companyNameValue.configureBlackboardItemStyle(
            with: theme,
            displayStyle: displayStyle,
            labelType: .value,
            shouldShowEmpty: true
        )

        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        // 最大文字数(50文字)の範囲内であれば意図せず改行されないようにするために、numberOfLinesに表示する文字列の行数を設定する
        // また、numberOfLinesを設定した場合に表示崩れが発生しないようにbaselineAdjustmentも中央寄せに設定する
        if shouldBeReflectedNewLine, let numberOfLines = constructionNameValueLabel?.text?.numberOfLines {
            constructionNameValueLabel?.numberOfLines = numberOfLines
            constructionNameValueLabel?.baselineAdjustment = .alignCenters
        }
    }
}

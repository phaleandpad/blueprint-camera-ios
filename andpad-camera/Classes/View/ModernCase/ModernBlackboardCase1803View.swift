//
//  ModernBlackboardCase1803View.swift
//  andpad-camera
//
//  Created by Toru Kuriyama on 2023/06/16.
//

// MARK: - ModernBlackboardCase1803View
final class ModernBlackboardCase1803View: BlackboardBaseView {
    @IBOutlet private weak var attributeTitle1: UILabel!
    @IBOutlet private weak var attributeTitle2: UILabel!
    @IBOutlet private weak var attributeTitle3: UILabel!
    @IBOutlet private weak var attributeTitle4: UILabel!
    @IBOutlet private weak var attributeTitle5: UILabel!
    @IBOutlet private weak var attributeTitle6: UILabel!
    @IBOutlet private weak var attributeTitle7: UILabel!
    @IBOutlet private weak var attributeTitle8: UILabel!
    @IBOutlet private weak var attributeTitle9: UILabel!
    @IBOutlet private weak var attributeTitle10: UILabel!
    @IBOutlet private weak var attributeTitle11: UILabel!

    @IBOutlet private weak var attributeValue1: UILabel!
    @IBOutlet private weak var attributeValue2: UILabel!
    @IBOutlet private weak var attributeValue3: UILabel!
    @IBOutlet private weak var attributeValue4: UILabel!
    @IBOutlet private weak var attributeValue5: UILabel!
    @IBOutlet private weak var attributeValue6: UILabel!
    @IBOutlet private weak var attributeValue7: UILabel!
    @IBOutlet private weak var attributeValue8: UILabel!
    @IBOutlet private weak var attributeValue9: UILabel!
    @IBOutlet private weak var attributeValue10: UILabel!
    @IBOutlet private weak var attributeValue11: UILabel!

    @IBOutlet private weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1803View: ModernBlackboardCaseViewProtocol {
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
            displayStyle: displayStyle,
            patternType: patternType,
            shouldBeReflectedNewLine: shouldBeReflectedNewLine
        )
    }

    private func setAttributeTitles(_ titles: [String]) {
        titles.enumerated().forEach {
            switch $0.offset {
            case 0:
                attributeTitle1.text = $0.element
                attributeTitle1.tag = $0.offset
            case 1:
                attributeTitle2.text = $0.element
                attributeTitle2.tag = $0.offset
            case 2:
                attributeTitle3.text = $0.element
                attributeTitle3.tag = $0.offset
            case 3:
                attributeTitle4.text = $0.element
                attributeTitle4.tag = $0.offset
            case 4:
                attributeTitle5.text = $0.element
                attributeTitle5.tag = $0.offset
            case 5:
                attributeTitle6.text = $0.element
                attributeTitle6.tag = $0.offset
            case 6:
                attributeTitle7.text = $0.element
                attributeTitle7.tag = $0.offset
            case 7:
                attributeTitle8.text = $0.element
                attributeTitle8.tag = $0.offset
            case 8:
                attributeTitle9.text = $0.element
                attributeTitle9.tag = $0.offset
            case 9:
                attributeTitle10.text = $0.element
                attributeTitle10.tag = $0.offset
            case 10:
                attributeTitle11.text = $0.element
                attributeTitle11.tag = $0.offset
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
    }

    private func setAttributeValues(_ values: [String]?, with displayStyle: ModernBlackboardCaseViewDisplayStyle) {
        if let values {
            values.enumerated().forEach {
                setAttributeValue($0.element, offset: $0.offset, displayStyle: displayStyle)
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
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
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: value
            )
            attributeValue1.tag = offset
        case 1:
            attributeValue2.text = value
            attributeValue2.tag = offset
        case 2:
            attributeValue3.text = value
            attributeValue3.tag = offset
        case 3:
            attributeValue4.text = value
            attributeValue4.tag = offset
        case 4:
            attributeValue5.text = value
            attributeValue5.tag = offset
        case 5:
            attributeValue6.text = value
            attributeValue6.tag = offset
        case 6:
            attributeValue7.text = value
            attributeValue7.tag = offset
        case 7:
            attributeValue8.text = value
            attributeValue8.tag = offset
        case 8:
            attributeValue9.text = value
            attributeValue9.tag = offset
        case 9:
            attributeValue10.text = value
            attributeValue10.tag = offset
        case 10:
            attributeValue11.text = value
            attributeValue11.tag = offset
        default:
            assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 value：\(value) , offset：\(offset)")
        }
    }

    private func setLabelStyles(
        with theme: ModernBlackboardAppearance.Theme,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        patternType: ModernBlackboardContentView.PatternType,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6,
            attributeTitle7,
            attributeTitle8,
            attributeTitle9,
            attributeTitle10,
            attributeTitle11
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .title
            )
        }

        [
            // value labels
            attributeValue1,
            attributeValue2,
            attributeValue3,
            attributeValue4,
            attributeValue5,
            attributeValue6,
            attributeValue7,
            attributeValue8,
            attributeValue9,
            attributeValue10,
            attributeValue11
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }

        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        // 最大文字数(50文字)が改行されずに表示されるよう、numberOfLinesに文字列の行数を設定する
        // また、numberOfLinesを設定した場合に表示崩れが発生しないようにbaselineAdjustmentも設定する
        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

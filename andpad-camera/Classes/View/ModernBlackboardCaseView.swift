//
//  ModernBlackboardCaseView.swift
//  andpad-camera
//
//  Created by msano on 2021/03/09.
//

// MARK: - ModernBlackboardCaseViewProtocol
protocol ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    )
}

// MARK: - ModernBlackboardCaseViewDisplayStyle
// NOTE: 黒板上の表記スタイル（原則、黒板データ自体に変更を加えることなくスタイル切り替えをする想定）
public enum ModernBlackboardCaseViewDisplayStyle {
    /// 黒板データ通りの表示
    case normal(shouldSetCornerRounder: Bool)
    
    /// 必要な箇所には「自動入力値についての情報」を表記する
    case withAutoInputInformation
    
    // ↑現状は「施工者」のみ
    // （後のフェーズで「工事名」「施工日」も対応予定）
    
    // NOTE: 新規作成画面追加のフェーズに恐らく増やすことになる
     case withPlaceholder
    
    func autoInputInformationText(keyItem: ModernBlackboardKeyItemName) -> String? {
        switch self {
        case .normal, .withPlaceholder:
            return nil
        case .withAutoInputInformation:
            switch keyItem {
            case .constructionName:
                return L10n.Blackboard.AutoInputInformation.constructionName
            case .memo:
                return nil
            case .constructionPlayer:
                return L10n.Blackboard.AutoInputInformation.constructionPlayerName
            case .date:
                return L10n.Blackboard.AutoInputInformation.date
            }
        }
    }
    
    var shouldShowPlaceHolder: Bool {
        switch self {
        case .normal, .withAutoInputInformation:
            return false
        case .withPlaceholder:
            return true
        }
    }
    
    var shouldSetCornerRounder: Bool {
        switch self {
        case .normal(let shouldSetCornerRounder):
            return shouldSetCornerRounder
        case .withAutoInputInformation, .withPlaceholder:
            return true
        }
    }
}

enum CaseViewLabelType {
    case title
    case value
}

// MARK: - ModernBlackboardCase1View
final class ModernBlackboardCase1View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
}

// MARK: - ModernBlackboardCase1View
extension ModernBlackboardCase1View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
        titles.enumerated().forEach {
            switch $0.offset {
            case 0:
                attributeTitle1.text = $0.element
                attributeTitle1.tag = $0.offset
            case 1:
                attributeTitle2.text = $0.element
                attributeTitle2.tag = $0.offset
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 3:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 4:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }

        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2
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
            attributeValue2
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        // 最大文字数(50文字)が改行されずに表示されるよう、numberOfLinesに文字列の行数を設定する
        // また、numberOfLinesを設定した場合に表示崩れが発生しないようにbaselineAdjustmentも設定する
        // ※他のレイアウトも同様の実装を行っている
        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase101View
final class ModernBlackboardCase101View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
}

extension ModernBlackboardCase101View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
        titles.enumerated().forEach {
            switch $0.offset {
            case 0:
                attributeTitle1.text = $0.element
                attributeTitle1.tag = $0.offset
            case 1:
                attributeTitle2.text = $0.element
                attributeTitle2.tag = $0.offset
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }

        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }

        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2
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
            attributeValue2
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
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
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase102View
final class ModernBlackboardCase102View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase102View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
        titles.enumerated().forEach {
            switch $0.offset {
            case 0:
                attributeTitle1.text = $0.element
                attributeTitle1.tag = $0.offset
            case 1:
                attributeTitle2.text = $0.element
                attributeTitle2.tag = $0.offset
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 3:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 4:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2
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
            attributeValue2
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }
        
        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase103View
final class ModernBlackboardCase103View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase103View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
        titles.enumerated().forEach {
            switch $0.offset {
            case 0:
                attributeTitle1.text = $0.element
                attributeTitle1.tag = $0.offset
            case 1:
                attributeTitle2.text = $0.element
                attributeTitle2.tag = $0.offset
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2
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
            attributeValue2
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
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
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }
        
        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase2View
final class ModernBlackboardCase2View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
}

extension ModernBlackboardCase2View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
 
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 4:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 5:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3
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
            attributeValue3
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase201View
final class ModernBlackboardCase201View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
}

extension ModernBlackboardCase201View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }

        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }

        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3
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
            attributeValue3
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
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
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase202View
final class ModernBlackboardCase202View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase202View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
 
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 4:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 5:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3
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
            attributeValue3
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }
        
        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase203View
final class ModernBlackboardCase203View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase203View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
 
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3
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
            attributeValue3
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
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
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }
        
        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase204View
final class ModernBlackboardCase204View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    
    @IBOutlet private(set) weak var alignRightValue: UILabel!
}

extension ModernBlackboardCase204View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
 
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 4:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    alignRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3
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
            attributeValue3
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            alignRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase205View
final class ModernBlackboardCase205View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    
    @IBOutlet private(set) weak var alignRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase205View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
 
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 4:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    alignRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3
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
            attributeValue3
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            alignRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }
        
        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase3View
final class ModernBlackboardCase3View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
}

extension ModernBlackboardCase3View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }

        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 5:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 6:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }

        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4
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
            attributeValue4
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }
        
        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase301View
final class ModernBlackboardCase301View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
}

extension ModernBlackboardCase301View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }

        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4
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
            attributeValue4
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
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

        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase4View
final class ModernBlackboardCase4View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
}

extension ModernBlackboardCase4View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
        titles.enumerated().forEach {
            switch $0.offset {
            case 0:
                attributeTitle1.text = $0.element
                attributeTitle1.tag = $0.offset
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }

        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 2:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 3:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }

        // configure label styles
        [
            // title labels
            attributeTitle1
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
            attributeValue1
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )

        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase401View
final class ModernBlackboardCase401View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
}

extension ModernBlackboardCase401View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
        titles.enumerated().forEach {
            switch $0.offset {
            case 0:
                attributeTitle1.text = $0.element
                attributeTitle1.tag = $0.offset
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }

        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }

        // configure label styles
        [
            // title labels
            attributeTitle1
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
            attributeValue1
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
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

        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase5View
final class ModernBlackboardCase5View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
}

extension ModernBlackboardCase5View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }

        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 4:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 5:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }

        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3
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
            attributeValue3
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }
        
        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase501View
final class ModernBlackboardCase501View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
}

extension ModernBlackboardCase501View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }

        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                default:
                    // NOTE: 501に限り、施工日、施工者が空でvalueとして追加されてしまい、defaultにマッチすることがある
                    //  -> 原因不明だが、黒板Viewの生成自体に問題はないため、501に限りbreakさせる
                    break
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3
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
            attributeValue3
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
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
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase6View
final class ModernBlackboardCase6View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
}

extension ModernBlackboardCase6View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 5:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 6:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4
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
            attributeValue4
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase601View
final class ModernBlackboardCase601View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
}

extension ModernBlackboardCase601View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4
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
            attributeValue4
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
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
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase602View
final class ModernBlackboardCase602View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase602View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 5:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 6:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4
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
            attributeValue4
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }
        
        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase603View
final class ModernBlackboardCase603View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase603View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4
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
            attributeValue4
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
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
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }
        
        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase604View
final class ModernBlackboardCase604View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    @IBOutlet private(set) weak var alignRightValue: UILabel!
}

extension ModernBlackboardCase604View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 5:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    alignRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4
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
            attributeValue4
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            alignRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase605View
final class ModernBlackboardCase605View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var memoValue: ModernBlackboardItemTextView!
    @IBOutlet private(set) weak var alignRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase605View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    memoValue.text = $0.element
                    memoValue.tag = $0.offset
                case 5:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    alignRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4
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
            attributeValue4
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            alignRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
            )
        }

        // configure memo item style
        memoValue.configureBlackboardMemoItemStyle(
            by: memoStyleArguments,
            displayStyle: displayStyle,
            likePlaceholderTextColor: theme.likePlaceholderTextColor
        )
        
        // configure border style
        recursiveSubviews
            .filter { $0 is ModernBlackboardBorderView }
            .forEach { $0.backgroundColor = theme.borderColor }
        
        // configure miniature map style
        if let miniatureMapState = patternType.miniatureMapState {
            miniatureMapImageView.apply(.init(state: miniatureMapState))
        }

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase702View
final class ModernBlackboardCase702View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase702View: ModernBlackboardCaseViewProtocol {
    // swiftlint:disable:next function_body_length
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 7:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6
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
            attributeValue6
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase703View
final class ModernBlackboardCase703View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase703View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6
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
            attributeValue6
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase802View
final class ModernBlackboardCase802View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase802View: ModernBlackboardCaseViewProtocol {
    // swiftlint:disable:next function_body_length
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 7:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6
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
            attributeValue6
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase803View
final class ModernBlackboardCase803View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase803View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6
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
            attributeValue6
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase902View
final class ModernBlackboardCase902View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase902View: ModernBlackboardCaseViewProtocol {
    // swiftlint:disable:next function_body_length
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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

            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                case 7:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 8:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6,
            attributeTitle7
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
            attributeValue7
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase903View
final class ModernBlackboardCase903View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase903View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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

            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6,
            attributeTitle7
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
            attributeValue7
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1003View
final class ModernBlackboardCase1003View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1003View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6,
            attributeTitle7
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
            attributeValue7
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1103View
final class ModernBlackboardCase1103View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1103View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6,
            attributeTitle7
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
            attributeValue7
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1105View
final class ModernBlackboardCase1105View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    @IBOutlet private(set) weak var alignRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1105View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                case 7:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    alignRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6,
            attributeTitle7
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
            attributeValue7
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            alignRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1202View
final class ModernBlackboardCase1202View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    @IBOutlet private(set) weak var attributeTitle8: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    @IBOutlet private(set) weak var attributeValue8: UILabel!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1202View: ModernBlackboardCaseViewProtocol {
    // swiftlint:disable:next cyclomatic_complexity
    func configure( // swiftlint:disable:this function_body_length
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                case 7:
                    attributeValue8.text = $0.element
                    attributeValue8.tag = $0.offset
                case 8:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 9:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
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
            attributeTitle8
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
            attributeValue8
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1203View
final class ModernBlackboardCase1203View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    @IBOutlet private(set) weak var attributeTitle8: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    @IBOutlet private(set) weak var attributeValue8: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1203View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                case 7:
                    attributeValue8.text = $0.element
                    attributeValue8.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
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
            attributeTitle8
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
            attributeValue8
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1303View
final class ModernBlackboardCase1303View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    @IBOutlet private(set) weak var attributeTitle8: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    @IBOutlet private(set) weak var attributeValue8: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1303View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                case 7:
                    attributeValue8.text = $0.element
                    attributeValue8.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
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
            attributeTitle8
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
            attributeValue8
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1403View
final class ModernBlackboardCase1403View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    @IBOutlet private(set) weak var attributeTitle8: UILabel!
    
    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    @IBOutlet private(set) weak var attributeValue8: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1403View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                case 7:
                    attributeValue8.text = $0.element
                    attributeValue8.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
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
            attributeTitle8
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
            attributeValue8
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1502View
final class ModernBlackboardCase1502View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    @IBOutlet private(set) weak var attributeTitle8: UILabel!
    @IBOutlet private(set) weak var attributeTitle9: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    @IBOutlet private(set) weak var attributeValue8: UILabel!
    @IBOutlet private(set) weak var attributeValue9: UILabel!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1502View: ModernBlackboardCaseViewProtocol {
    // swiftlint:disable:next cyclomatic_complexity
    func configure( // swiftlint:disable:this function_body_length
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                case 7:
                    attributeValue8.text = $0.element
                    attributeValue8.tag = $0.offset
                case 8:
                    attributeValue9.text = $0.element
                    attributeValue9.tag = $0.offset
                case 9:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 10:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
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
            attributeTitle9
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
            attributeValue9
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            separatedLeftValue,
            separatedRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1503View
final class ModernBlackboardCase1503View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    @IBOutlet private(set) weak var attributeTitle8: UILabel!
    @IBOutlet private(set) weak var attributeTitle9: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    @IBOutlet private(set) weak var attributeValue8: UILabel!
    @IBOutlet private(set) weak var attributeValue9: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1503View: ModernBlackboardCaseViewProtocol {
    // swiftlint:disable:next cyclomatic_complexity
    func configure( // swiftlint:disable:this function_body_length
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                case 7:
                    attributeValue8.text = $0.element
                    attributeValue8.tag = $0.offset
                case 8:
                    attributeValue9.text = $0.element
                    attributeValue9.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
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
            attributeTitle9
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
            attributeValue9
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1505View
final class ModernBlackboardCase1505View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!
    @IBOutlet private(set) weak var attributeTitle7: UILabel!
    @IBOutlet private(set) weak var attributeTitle8: UILabel!
    @IBOutlet private(set) weak var attributeTitle9: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var attributeValue7: UILabel!
    @IBOutlet private(set) weak var attributeValue8: UILabel!
    @IBOutlet private(set) weak var attributeValue9: UILabel!
    @IBOutlet private(set) weak var alignRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1505View: ModernBlackboardCaseViewProtocol {
    // swiftlint:disable:next cyclomatic_complexity
    func configure( // swiftlint:disable:this function_body_length
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    attributeValue7.text = $0.element
                    attributeValue7.tag = $0.offset
                case 7:
                    attributeValue8.text = $0.element
                    attributeValue8.tag = $0.offset
                case 8:
                    attributeValue9.text = $0.element
                    attributeValue9.tag = $0.offset
                case 9:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    alignRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            alignRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
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
            attributeTitle9
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
            attributeValue9
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        [
            // value labels (date, constructionPlayer)
            alignRightValue
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                shouldShowEmpty: true
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1602View
final class ModernBlackboardCase1602View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    @IBOutlet private(set) weak var separatedLeftValue: UILabel!
    @IBOutlet private(set) weak var separatedRightValue: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1602View: ModernBlackboardCaseViewProtocol {
    // swiftlint:disable:next function_body_length
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                case 6:
                    // NOTE: 「施工日」（ = 撮影日）はdisplayStyleに応じて表示を出し分けする
                    separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .date,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedLeftValue.tag = $0.offset
                case 7:
                    // NOTE: 「施工者」はdisplayStyleに応じて表示を出し分けする
                    separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionPlayer,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    separatedRightValue.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedLeftValue.text = setSpecifiedBlackboardItemValueWith(
                target: .date,
                displayStyle: displayStyle,
                rawValue: ""
            )
            separatedRightValue.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionPlayer,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6
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
            attributeValue6
        ]
        .forEach {
            $0!.configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value
            )
        }
        
        // value labels (date, constructionPlayer)
        separatedLeftValue!
            .configureBlackboardItemStyle(
                with: theme,
                displayStyle: displayStyle,
                labelType: .value,
                numberOfLines: 1, // 一行で表示固定させたいため追加（他のレイアウトより表示高があるため、必要になる）
                shouldShowEmpty: true
            )
        separatedRightValue!
            .configureBlackboardItemStyle(
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardCase1603View
final class ModernBlackboardCase1603View: BlackboardBaseView {
    @IBOutlet private(set) weak var attributeTitle1: UILabel!
    @IBOutlet private(set) weak var attributeTitle2: UILabel!
    @IBOutlet private(set) weak var attributeTitle3: UILabel!
    @IBOutlet private(set) weak var attributeTitle4: UILabel!
    @IBOutlet private(set) weak var attributeTitle5: UILabel!
    @IBOutlet private(set) weak var attributeTitle6: UILabel!

    @IBOutlet private(set) weak var attributeValue1: UILabel!
    @IBOutlet private(set) weak var attributeValue2: UILabel!
    @IBOutlet private(set) weak var attributeValue3: UILabel!
    @IBOutlet private(set) weak var attributeValue4: UILabel!
    @IBOutlet private(set) weak var attributeValue5: UILabel!
    @IBOutlet private(set) weak var attributeValue6: UILabel!
    
    @IBOutlet private(set) weak var miniatureMapImageView: UIImageView!
}

extension ModernBlackboardCase1603View: ModernBlackboardCaseViewProtocol {
    func configure(
        titles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: ModernBlackboardContentView.PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool
    ) {
        // configure titles
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
            default:
                // titleは項目によっては省略することもある（ = 施工者などvalueだけのパターン）ため、breakで対応
                break
            }
        }
        
        // configure values
        if let values = values {
            values.enumerated().forEach {
                switch $0.offset {
                case 0:
                    // NOTE: 「工事名」（ = 案件名）はdisplayStyleに応じて表示を出し分けする
                    attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                        target: .constructionName,
                        displayStyle: displayStyle,
                        rawValue: $0.element
                    )
                    attributeValue1.tag = $0.offset
                case 1:
                    attributeValue2.text = $0.element
                    attributeValue2.tag = $0.offset
                case 2:
                    attributeValue3.text = $0.element
                    attributeValue3.tag = $0.offset
                case 3:
                    attributeValue4.text = $0.element
                    attributeValue4.tag = $0.offset
                case 4:
                    attributeValue5.text = $0.element
                    attributeValue5.tag = $0.offset
                case 5:
                    attributeValue6.text = $0.element
                    attributeValue6.tag = $0.offset
                default:
                    assertionFailure("黒板項目値のうち、offsetが範囲外のものがあります。 element：\($0.element) , offset：\($0.offset)")
                }
            }
        } else {
            attributeValue1.text = setSpecifiedBlackboardItemValueWith(
                target: .constructionName,
                displayStyle: displayStyle,
                rawValue: ""
            )
        }
        
        // configure label styles
        [
            // title labels
            attributeTitle1,
            attributeTitle2,
            attributeTitle3,
            attributeTitle4,
            attributeTitle5,
            attributeTitle6
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
            attributeValue6
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

        if shouldBeReflectedNewLine, let numberOfLines = attributeValue1.text?.numberOfLines {
            attributeValue1.numberOfLines = numberOfLines
            attributeValue1.baselineAdjustment = .alignCenters
        }
    }
}

// MARK: - ModernBlackboardBorderView
// NOTE: 黒板レイアウトのうち、枠線にあたるViewはこちらに準拠させること
final class ModernBlackboardBorderView: UIView {}

extension UILabel {
    func configureBlackboardItemStyle(
        with theme: ModernBlackboardAppearance.Theme,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        labelType: CaseViewLabelType,
        numberOfLines: Int = 0,
        shouldShowEmpty: Bool = false // displayStyle.shouldShowPlaceHolderとは別に、個別にプレースホルダー表記をスキップしたい場合はtrueにする
    ) {
        /// NOTE: あくまでUILabelなので、プレースホルダー（風のスタイル）を適用する
        func setPlaceHolder() {
            self.textColor = theme.likePlaceholderTextColor
            switch labelType {
            case .title:
                self.text = L10n.Blackboard.Variable.Input.blackboardItemName(self.tag)
            case .value:
                self.text = L10n.Blackboard.Variable.Input.blackboardItemValue(self.tag)
            }
        }
        
        // Note: テキストの長さに応じて縮小を可能とするが、既存のXibファイルに合わせて、デフォルトのフォントサイズを18ptに設定する
        font = .systemFont(ofSize: 18, weight: .semibold)
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.2
        self.numberOfLines = numberOfLines
        self.textColor = theme.textColor
        
        guard displayStyle.shouldShowPlaceHolder, !shouldShowEmpty else { return }
        guard let text else {
            setPlaceHolder()
            return
        }
        guard text.isEmpty else { return }
        setPlaceHolder()
    }
}

extension BlackboardBaseView {
    func setSpecifiedBlackboardItemValueWith(
        target: ModernBlackboardKeyItemName,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        rawValue: String
    ) -> String {
        return displayStyle.autoInputInformationText(keyItem: target) ?? rawValue
    }
} // swiftlint:disable:this file_length

//
//  ModernBlackboardItemInputsCell.swift
//  andpad-camera-andpad-camera
//
//  Created by msano on 2022/01/25.
//

import Instantiate
import InstantiateStandard
import SnapKit
import UIKit
import RxSwift
import RxCocoa

// MARK: - InputsCellRowType
public enum InputsCellRowType {
    case constructionName(position: Int)
    case normal(position: Int)
    case memo(position: Int)
    case dateAndConstructionPlayer(leftPosition: Int, rightPosition: Int)
    case constructionPlayer(position: Int)
    
    var positions: [Int] {
        switch self {
        case .constructionName(let position):
            return [position]
        case .normal(let position):
            return [position]
        case .memo(let position):
            return [position]
        case .dateAndConstructionPlayer(let leftPosition, let rightPosition):
            return [leftPosition, rightPosition]
        case .constructionPlayer(let position):
            return [position]
        }
    }
}

// MARK: - ForceWarningInputsCellData
struct ForceWarningInputsCellData {
    let position: Int
    
    // NOTE:
    // isItemName、isBodyに限らずだが、このView（子View含む）はパラメータがかなり多く、dataの属性を把握しづらい状態となっている、
    // enum（associated value付き）にすることで、ある程度整理が見込めそうでもあるため、
    //
    // FIXME: ↑どこかのタイミングで整理したい
    //
    // ref: https://github.com/88labs/andpad-camera-ios/pull/300#discussion_r805579057
    let isItemName: Bool
    let isBody: Bool
}

//    NOTE:
//
//    Androidと比較して、2点挙動の差異があります（対応判断、時期は未定）
//
//    - 1. 入力欄に複数改行などを入れheightを伸ばした際に、隣接する入力欄の文字（プレースホルダーを含む）が左中央寄せになっていない
//      - 現状iOSは左上寄せ
//    - 2. エラーラベル表示状態で、アンフォーカス時にエラーラベルが隠れない
//      - 現状iOSはフォーカス / アンフォーカスともに出したままとしている
//      - （なぜか変換前の文字列があると、エラーラベルのisHiddenが効かなくなる、という事象を確認済み）

final class ModernBlackboardItemInputsCell: UITableViewCell {
    struct Dependency {
        let modernBlackboardMaterial: ModernBlackboardMaterial!
        
        /// 強制的にエラー（赤枠表示）としたい入力欄のリスト
        let forceWarningInputsCellDatas: [ForceWarningInputsCellData]
        
        let disabledCase: DisabledInputsCase

        /// 工事名のTextViewの編集状態を設定するためのstream
        /// - note: isEditable: trueなら編集可能、falseならタップしても入力できない
        /// - note: shouldBeFocus: trueならTextViewにフォーカスを当てる、falseなら何もしない
        let constructionNameShouldBeEditableSignal: Signal<(isEditable: Bool, shouldBeFocus: Bool)>
    }

    /// 入力群のうち、どの入力欄をdisableするか決めるtype
    enum DisabledInputsCase {
        /// 工事名の項目名のみdisableする
        case onlyConstructionItemName
        
        /// 工事名の項目名と施工日をdisableする
        case constructionItemNameAndDate
        
        // 工事名、施工日、施工者の項目名および項目内容をdisableする
        case constructionNameAndDateAndConstructionPlayer // swiftlint:disable:this identifier_name
        
        func isEnabled(keyName: ModernBlackboardKeyItemName, inputType: InputType) -> Bool {
            switch self {
            case .onlyConstructionItemName:
                switch keyName {
                case .constructionName:
                    switch inputType {
                    case .itemName:
                        return false
                    case .body:
                        break
                    }
                case .memo, .date, .constructionPlayer:
                    break
                }
            case .constructionItemNameAndDate:
                switch keyName {
                case .constructionName:
                    switch inputType {
                    case .itemName:
                        return false
                    case .body:
                        break
                    }
                case .date:
                    return false
                case .memo, .constructionPlayer:
                    break
                }
            case .constructionNameAndDateAndConstructionPlayer:
                switch keyName {
                case .constructionName, .date, .constructionPlayer:
                    return false
                case .memo:
                    break
                }
            }
            return true
        }
        
        func disabledTitle(keyName: ModernBlackboardKeyItemName, inputType: InputType) -> String {
            switch self {
            case .onlyConstructionItemName:
                switch keyName {
                case .constructionName:
                    switch inputType {
                    case .itemName:
                        break // この場合、ステータスに関係なく「工事名」という実際の値を渡すので、break
                    case .body:
                        return L10n.Blackboard.AutoInputInformation.constructionName
                    }
                case .memo, .date, .constructionPlayer:
                    break
                }
            case .constructionItemNameAndDate:
                switch keyName {
                case .constructionName:
                    switch inputType {
                    case .itemName:
                        break // この場合、ステータスに関係なく「工事名」という実際の値を渡すので、break
                    case .body:
                        return L10n.Blackboard.AutoInputInformation.constructionName
                    }
                // dateは入力値のままdisableする
                case .date, .memo, .constructionPlayer:
                    break
                }
            case .constructionNameAndDateAndConstructionPlayer:
                switch keyName {
                case .constructionName:
                    switch inputType {
                    case .itemName:
                        break // この場合、ステータスに関係なく「工事名」という実際の値を渡すので、break
                    case .body:
                        return L10n.Blackboard.AutoInputInformation.constructionName
                    }
                case .memo:
                    break
                case .date:
                    return L10n.Blackboard.AutoInputInformation.date
                case .constructionPlayer:
                    return L10n.Blackboard.AutoInputInformation.constructionPlayerName
                }
            }
            return ""
        }
        
        enum InputType {
            case itemName
            case body
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet private weak var inputsStackView: UIStackView!
    @IBOutlet private weak var inputsStackViewBottomConstraint: NSLayoutConstraint!
    
    var disposeBag = DisposeBag()
    
    private var modernBlackboardMaterial: ModernBlackboardMaterial!
    private var forceWarningInputsCellDatas: [ForceWarningInputsCellData] = []
    private var disabledCase: DisabledInputsCase = .onlyConstructionItemName
    
    /// 各行のheightをまとめたリスト
    private var rowHeights: [RowHeight] = [] {
        // for debug
        didSet {
            #if DEBUG
            rowHeights.forEach {
                print("👀 row height (\($0.number)): \($0.height)")
            }
            #endif
        }
    }

    // subscribe対象
    let updateBlackboardItemsSignal: Signal<[ModernBlackboardMaterial.Item]>
    let updateCellHeightSignal: Signal<CGFloat>
    let constructionNameDidTapSignal: Signal<Void>

    private let updateBlackboardItemsRelay = PublishRelay<[ModernBlackboardMaterial.Item]>()
    private let updateCellHeightRelay = BehaviorRelay<CGFloat>(value: .zero)
    private let constructionNameDidTapRelay = PublishRelay<Void>()

    private var constructionNameShouldBeEditableSignal: Signal<(isEditable: Bool, shouldBeFocus: Bool)> = Signal.empty()

    // initialize
    required init?(coder: NSCoder) {
        updateBlackboardItemsSignal = updateBlackboardItemsRelay
            .asSignal()
            .distinctUntilChanged()
        updateCellHeightSignal = updateCellHeightRelay
            .asSignal(onErrorJustReturn: .zero)
            .distinctUntilChanged()
            .filter { $0 > 0 }
        constructionNameDidTapSignal = constructionNameDidTapRelay
            .asSignal()
        super.init(coder: coder)
    }
    
    private var inputsStackViewHeight: CGFloat {
        rowHeights
            .map { $0.height }
            .reduce(0.0) { $0 + $1 }
    }
    
    /// セル全体の高さ（rowHeightsの合計 + 上下マージンの合計）
    private var totalHeight: CGFloat {
        inputsStackViewHeight + inputsStackViewBottomConstraint.constant
    }
    
    /// inputsStackViewにスタックしたColumnStackViewを全取得する
    private var columnStackViews: [ColumnStackView] {
        let views = inputsStackView.arrangedSubviews
            .map { rootView -> [UIView] in
                if rootView is ColumnStackContainerView {
                    return [rootView]
                }
                
                let columnStackContainerViews = rootView.recursiveSubviews.filter { view in
                    view is ColumnStackContainerView
                }
                return columnStackContainerViews
            }
            .flatMap { $0 }
            .map { view -> ColumnStackView? in
                guard let containerView = view as? ColumnStackContainerView else { return nil }
                return containerView.columnStackView
            }
            .compactMap { $0 }
        return views
    }
    
    var editedBlackboardItems: [ModernBlackboardMaterial.Item] {
        let positions = columnStackViews
            .map { $0.inputdata?.blackboardItemPosition }
            .compactMap { $0 }

        // rowView内のペアのColumnViewなどは、重複したpositionを持っているので、ユニークなリストにする
        guard let uniquePositions = NSOrderedSet(array: positions).array as? [Int] else {
            fatalError()
        }
        
        return uniquePositions
            .map { [weak self] position -> ModernBlackboardMaterial.Item? in
                guard let self else { return nil }
                let targetColumnStackViews = columnStackViews
                    .filter { $0.inputdata?.blackboardItemPosition == position }
                
                switch targetColumnStackViews.count {
                case 2:
                    let itemNameColumnStackView = targetColumnStackViews.first { $0.inputdata?.isItemName == true }
                    let bodyColumnStackView = targetColumnStackViews.first { $0.inputdata?.isItemName == false }
                    
                    return ModernBlackboardMaterial.Item(
                        itemName: itemNameColumnStackView?.inputdata?.text ?? "",
                        body: bodyColumnStackView?.inputdata?.text ?? "",
                        position: position
                    )
                case 1:
                    let blackboardItem = self.modernBlackboardMaterial.items.first { $0.position == position }
                    return ModernBlackboardMaterial.Item(
                        itemName: blackboardItem?.itemName ?? "",
                        body: targetColumnStackViews[0].inputdata?.text ?? "",
                        position: position
                    )
                default:
                    return nil
                }
            }
            .compactMap { $0 }
    }
    
    enum BlackboardItemPositionType {
        case single(position: Int)
        case double(leftPosition: Int, rightPosition: Int)
    }

    // MARK: - LayoutParams
    enum LayoutParams {
        // NOTE: 文字組みなどを考慮して、Figmaの数値より少し調整した値を使っている箇所があります
        
        // normalInput
        static let normalInputFontSize: CGFloat = 14
        static let normalInputMinHeight: CGFloat = 48
        static let normalInputLeftWidthRatio: CGFloat = 0.35
        static let normalInputLeftMinWidth: CGFloat = 120
        static let normalInputCornerRadius: CGFloat = 4
        static let normalInputTopBottomContentInset: CGFloat = 8
        static let normalInputLeftRightContentInset: CGFloat = 10
        static let normalInputTopBottomMargin = normalInputTopBottomContentInset
        
        // memoInput
        static let memoInputMinHeight: CGFloat = 120
        
        // dateInput
        static let dateInputWidthRatio: CGFloat = 0.40
        static let dateInputMinWidth: CGFloat = 136
        
        // errorLabel
        static let errorLabelHeight: CGFloat = 21
        
        // columnView
        static let columnViewMinWidth: CGFloat = 100
        
        // placeHolderLabel
        static let placeHolderLabelAdjustLeftRightMargin: CGFloat = 4
    }
    
    private enum TextParams {
        // normalInput
        static let normalInputLeftMaxTextLength: Int = 10
        static let normalInputRightMaxTextLength: Int = 30
        
        // memoInput
        static let memoInputMaxTextLength: Int = 200
        
        // 「撮影日」
        // NOTE: 文字数制限のバリデート対象から外すために最大有限数を使っている
        //
        // - なお下記の理由で0で表現していない
        //   - 0で表現してしまうと入力テキスト自体表示できなくなる
        //   - 赤枠ボーダー表記されることがある
        static let dateMaxTextLength: Int = .max
        
        // 「工事名」の項目内容
        static let constructureNameMaxTextLength: Int = 254
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        inputsStackView.removeAllArrangedSubviews()
    }
}

// MARK: - private
extension ModernBlackboardItemInputsCell {
    private func configureView() {
        func columnView(
            text: String,
            rowNumber: Int,
            textWidth: CGFloat,
            verticalType: ColumnStackView.VerticalType,
            horizontalType: ColumnStackView.HorizontalType?,
            maxTextLength: Int,
            placeHolder: String,
            disabledTitle: String,
            blackboardItemPosition: Int,
            isItemName: Bool,
            forceWarning: Bool,
            isEnabled: Bool = true,
            useDatePicker: Bool = false,
            isConstructionNameValue: Bool = false
        ) -> ColumnStackContainerView {
            let textView = TextView()
            textView.configure(
                text: text,
                placeholder: placeHolder,
                disabledTitle: disabledTitle,
                maxTextLength: maxTextLength,
                isEnabled: isEnabled,
                useDatePicker: useDatePicker
            )
            
            let columnView = ColumnStackView()
            columnView.configure(
                textView,
                rowNumber: rowNumber,
                textWidth: textWidth,
                verticalType: verticalType,
                horizontalType: horizontalType,
                maxTextLength: maxTextLength,
                blackboardItemPosition: blackboardItemPosition,
                isItemName: isItemName,
                forceWarning: forceWarning
            )

            let containerView = ColumnStackContainerView()
            containerView.configure(stackView: columnView)

            // 工事名(設定値の方)の場合はアラートを出すための各種設定処理を行う
            // (工事名のTextViewかどうかを判別できるのはここが最初で最後のため)
            if isConstructionNameValue {
                textView.didTapSignal
                    .emit(to: constructionNameDidTapRelay)
                    .disposed(by: disposeBag)
                constructionNameShouldBeEditableSignal
                    .emit(onNext: textView.editAction)
                    .disposed(by: disposeBag)
            }

            return containerView
        }
        
        func rowView(
            rowNumber: Int,
            rowDividingType: RowStackView.RowDividingType,
            columnVerticalType: ColumnStackView.VerticalType,
            leftText: String,
            rightText: String,
            leftPlaceHolder: String,
            rightPlaceHolder: String,
            leftDisabledTitle: String,
            rightDisabledTitle: String,
            leftMaxTextLength: Int,
            rightMaxTextLength: Int,
            leftForceWarning: Bool,
            rightForceWarning: Bool,
            blackboardItemPositionType: BlackboardItemPositionType,
            isEnabledleftTextView: Bool = true,
            isEnabledRightTextView: Bool = true,
            useDatePicker: Bool = false,
            isConstructionName: Bool = false
        ) -> RowStackView {

            var leftPosition = 0
            var rightPosition = 0
            
            switch blackboardItemPositionType {
            case .single(let pos):
                leftPosition = pos
                rightPosition = pos
            case .double(let leftPos, let rightPos):
                leftPosition = leftPos
                rightPosition = rightPos
            }
            
            let leftColumnView = columnView(
                text: leftText,
                rowNumber: rowNumber,
                textWidth: rowDividingType.columnWidth.left,
                verticalType: columnVerticalType,
                horizontalType: .left,
                maxTextLength: leftMaxTextLength,
                placeHolder: leftPlaceHolder,
                disabledTitle: leftDisabledTitle,
                blackboardItemPosition: leftPosition,
                isItemName: true,
                forceWarning: leftForceWarning,
                isEnabled: isEnabledleftTextView,
                useDatePicker: useDatePicker
            )
            
            let rightColumnView = columnView(
                text: rightText,
                rowNumber: rowNumber,
                textWidth: rowDividingType.columnWidth.right,
                verticalType: columnVerticalType,
                horizontalType: .right,
                maxTextLength: rightMaxTextLength,
                placeHolder: rightPlaceHolder,
                disabledTitle: rightDisabledTitle,
                blackboardItemPosition: rightPosition,
                isItemName: false,
                forceWarning: rightForceWarning,
                isEnabled: isEnabledRightTextView,
                isConstructionNameValue: isConstructionName
            )
            
            let stackView = RowStackView()
            stackView.configure(
                rowNumber: rowNumber,
                dividingType: rowDividingType,
                leftColumnView: leftColumnView,
                rightColumnView: rightColumnView
            )
            return stackView
        }
        
        func memoInputView(
            rowNumber: Int,
            text: String,
            blackboardItemPosition: Int
        ) -> ColumnStackContainerView {
            columnView(
                text: text,
                rowNumber: rowNumber,
                textWidth: inputsStackView.bounds.width,
                verticalType: .middle,
                horizontalType: nil,
                maxTextLength: TextParams.memoInputMaxTextLength,
                placeHolder: L10n.Memo.Input.placeholder,
                disabledTitle: "",
                blackboardItemPosition: blackboardItemPosition,
                isItemName: false,
                forceWarning: false // 現状、対象となりえない入力欄のためfalse
            )
        }
        selectionStyle = .none
        
        // layoutIDに応じて、必要な入力欄を生成、スタックしていく
        if let stackedInputsRowType = ModernBlackboardContentView.Pattern(by: modernBlackboardMaterial.layoutTypeID)?.stackedInputsRowType {
                stackedInputsRowType.enumerated()
                .map { [weak self] object -> UIView? in
                    guard let self else { return nil }
                    switch object.element {
                    case .constructionName(let position):
                        guard let blackboardItem = self.modernBlackboardMaterial.items.first(where: { $0.position == position }) else { return nil }
                        let forceWarningData = forceWarningInputsCellDatas.first { $0.position == position }

                        return rowView(
                            rowNumber: object.offset,
                            rowDividingType: .normal(parentStackViewWidth: inputsStackView.bounds.width),
                            columnVerticalType: .top,
                            leftText: blackboardItem.itemName,
                            rightText: blackboardItem.body,
                            leftPlaceHolder: "",
                            rightPlaceHolder: "",
                            leftDisabledTitle: disabledCase.disabledTitle(keyName: .constructionName, inputType: .itemName),
                            rightDisabledTitle: disabledCase.disabledTitle(keyName: .constructionName, inputType: .body),
                            leftMaxTextLength: TextParams.normalInputLeftMaxTextLength,
                            rightMaxTextLength: TextParams.constructureNameMaxTextLength,
                            leftForceWarning: forceWarningData?.isItemName ?? false,
                            rightForceWarning: forceWarningData?.isBody ?? false,
                            blackboardItemPositionType: .single(position: position),
                            isEnabledleftTextView: disabledCase.isEnabled(keyName: .constructionName, inputType: .itemName),
                            isEnabledRightTextView: disabledCase.isEnabled(keyName: .constructionName, inputType: .body),
                            isConstructionName: true
                        )
                    case .normal(let position):
                        guard let blackboardItem = self.modernBlackboardMaterial.items.first(where: { $0.position == position }) else { return nil }
                        let forceWarningData = forceWarningInputsCellDatas.first { $0.position == position }

                        return rowView(
                            rowNumber: object.offset,
                            rowDividingType: .normal(parentStackViewWidth: inputsStackView.bounds.width),
                            columnVerticalType: .middle,
                            leftText: blackboardItem.itemName,
                            rightText: blackboardItem.body,
                            leftPlaceHolder: L10n.Blackboard.Variable.Input.blackboardItemName(object.offset),
                            rightPlaceHolder: L10n.Blackboard.Variable.Input.blackboardItemValue(object.offset),
                            leftDisabledTitle: "",
                            rightDisabledTitle: "",
                            leftMaxTextLength: TextParams.normalInputLeftMaxTextLength,
                            rightMaxTextLength: TextParams.normalInputRightMaxTextLength,
                            leftForceWarning: forceWarningData?.isItemName ?? false,
                            rightForceWarning: forceWarningData?.isBody ?? false,
                            blackboardItemPositionType: .single(position: position)
                        )
                    case .memo(let position):
                        guard let blackboardItem = self.modernBlackboardMaterial.items.first(where: { $0.position == position }) else { return nil }
                        return memoInputView(
                            rowNumber: object.offset,
                            text: blackboardItem.body,
                            blackboardItemPosition: position
                        )
                    case .dateAndConstructionPlayer(let leftPosition, let rightPosition):
                        guard let leftBlackboardItem = self.modernBlackboardMaterial.items.first(where: { $0.position == leftPosition }),
                              let rightBlackboardItem = self.modernBlackboardMaterial.items.first(where: { $0.position == rightPosition }) else { return nil }

                        return rowView(
                            rowNumber: object.offset,
                            rowDividingType: .separateTwoItemValues(parentStackViewWidth: inputsStackView.bounds.width),
                            columnVerticalType: .bottom(isOnlyRightValue: false),
                            leftText: leftBlackboardItem.body.isEmpty ? Date().asDateString() : leftBlackboardItem.body,
                            rightText: rightBlackboardItem.body,
                            leftPlaceHolder: "",
                            rightPlaceHolder: "",
                            leftDisabledTitle: disabledCase.disabledTitle(keyName: .date, inputType: .body),
                            rightDisabledTitle: disabledCase.disabledTitle(keyName: .constructionPlayer, inputType: .body),
                            leftMaxTextLength: TextParams.dateMaxTextLength,
                            rightMaxTextLength: TextParams.normalInputRightMaxTextLength,
                            leftForceWarning: false, // 施工日、施工者は強制エラー表記の対象外
                            rightForceWarning: false, // 施工日、施工者は強制エラー表記の対象外
                            blackboardItemPositionType: .double(leftPosition: leftPosition, rightPosition: rightPosition),
                            isEnabledleftTextView: disabledCase.isEnabled(keyName: .date, inputType: .body),
                            isEnabledRightTextView: disabledCase.isEnabled(keyName: .constructionPlayer, inputType: .body),
                            useDatePicker: true
                        )
                    case .constructionPlayer(position: let position):
                        guard let blackboardItem = self.modernBlackboardMaterial.items.first(where: { $0.position == position }) else { return nil }
                        let forceWarningData = forceWarningInputsCellDatas.first { $0.position == position }

                        return rowView(
                            rowNumber: object.offset,
                            rowDividingType: .onlyOneValue(parentStackViewWidth: inputsStackView.bounds.width),
                            columnVerticalType: .bottom(isOnlyRightValue: true), // 施工者のみのためフラグON
                            leftText: blackboardItem.itemName,
                            rightText: blackboardItem.body,
                            leftPlaceHolder: L10n.Blackboard.Variable.Input.blackboardItemName(object.offset),
                            rightPlaceHolder: "",
                            leftDisabledTitle: "",
                            rightDisabledTitle: disabledCase.disabledTitle(keyName: .constructionPlayer, inputType: .body),
                            leftMaxTextLength: 0,
                            rightMaxTextLength: TextParams.normalInputRightMaxTextLength,
                            leftForceWarning: false,
                            rightForceWarning: forceWarningData?.isBody ?? false,
                            blackboardItemPositionType: .single(position: position),
                            isEnabledleftTextView: false,
                            isEnabledRightTextView: disabledCase.isEnabled(keyName: .constructionPlayer, inputType: .body)
                        )
                    }
                }
                .compactMap { $0 }
                .forEach { [weak self] in self?.inputsStackView.addArrangedSubview($0) }
        }
        
        rowHeights = inputsStackView.arrangedSubviews.compactMap {
            if let rowView = $0 as? RowStackView {
                return rowView.scalableHeightRelay.value
            } else if let columnContainerView = $0 as? ColumnStackContainerView,
                      let columnView = columnContainerView.columnStackView,
                      columnView.isMemoInput {
                return columnView.adjustedRowHeight
            }
            return nil
        }
        
        inputsStackView.snp.remakeConstraints { make in
            make.height.equalTo(inputsStackViewHeight).priority(.high)
        }
        updateCellHeightRelay.accept(totalHeight)
    }
    
    private func addBinding() {
        inputsStackView.arrangedSubviews.forEach {
            if let rowView = $0 as? RowStackView {
                rowView.scalableHeightRelay
                    .asDriver()
                    .drive(onNext: { [weak self] in self?.update(rowHeight: $0) })
                    .disposed(by: disposeBag)
                
                rowView.arrangedSubviews.forEach {
                    if let columnContainerView = $0 as? ColumnStackContainerView,
                       let columnView = columnContainerView.columnStackView {
                        
                        columnView.shouldAdjustHeightDriver
                            .drive(onNext: { [weak self] in self?.update(rowHeight: $0) })
                            .disposed(by: disposeBag)

                        columnView.inputTextsSignal
                            .map { [weak self] in self?.editedBlackboardItems }
                            .compactMap { $0 }
                            .emit(to: updateBlackboardItemsRelay)
                            .disposed(by: disposeBag)
                    }
                }
            } else if let columnContainerView = $0 as? ColumnStackContainerView,
                      let columnView = columnContainerView.columnStackView,
                      columnView.isMemoInput {
                
                columnView.shouldAdjustHeightDriver
                    .drive(onNext: { [weak self] in self?.update(rowHeight: $0) })
                    .disposed(by: disposeBag)
                
                columnView.inputTextsSignal
                    .map { [weak self] in self?.editedBlackboardItems }
                    .compactMap { $0 }
                    .emit(to: updateBlackboardItemsRelay)
                    .disposed(by: disposeBag)
            }
        }
    }
    
    private func update(rowHeight: RowHeight) {
        rowHeights = rowHeights.map { target -> RowHeight in
            guard target.number == rowHeight.number else { return target }
            return rowHeight
        }
        inputsStackView.snp.updateConstraints { make in
            make.height.equalTo(self.inputsStackViewHeight).priority(.high)
        }
        updateCellHeightRelay.accept(totalHeight)
    }
}

// MARK: - NibType
extension ModernBlackboardItemInputsCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension ModernBlackboardItemInputsCell: Reusable {
    func inject(_ dependency: Dependency) {
        self.modernBlackboardMaterial = dependency.modernBlackboardMaterial
        self.forceWarningInputsCellDatas = dependency.forceWarningInputsCellDatas
        self.disabledCase = dependency.disabledCase
        self.constructionNameShouldBeEditableSignal
            = dependency.constructionNameShouldBeEditableSignal
        configureView()
        addBinding()
    }
}

// MARK: - RowHeight
extension ModernBlackboardItemInputsCell {
    struct RowHeight {
        let number: Int
        let height: CGFloat
    }
}

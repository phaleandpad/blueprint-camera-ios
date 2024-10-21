//
//  ColumnStackView.swift
//  andpad-camera
//
//  Created by msano on 2022/02/14.
//

import RxSwift
import RxCocoa

// MARK: - ColumnStackView
extension ModernBlackboardItemInputsCell {
    /// NOTE: 列単位（テキスト入力欄 / エラー表記エリア）でまとめたStackView
    final class ColumnStackView: UIStackView {
        
        struct InputData {
            let text: String
            let blackboardItemPosition: Int
            let isItemName: Bool
            
            func updating(by newText: String) -> InputData {
                return .init(
                    text: newText,
                    blackboardItemPosition: self.blackboardItemPosition,
                    isItemName: self.isItemName
                )
            }
        }
        
        enum VerticalType {
            case top
            case middle
            case bottom(isOnlyRightValue: Bool)
        }
        
        enum HorizontalType {
            case left
            case right
        }

        private let disposeBag = DisposeBag()
        private let shouldAdjustHeightRelay = BehaviorRelay<RowHeight>(value: .init(number: 0, height: 0))
        private let changeBorderColorRelay = BehaviorRelay<CGColor>(value: UIColor.gray222.cgColor)
        private let inputTextsRelay = BehaviorRelay<String>(value: "")
        
        private var minHeight: CGFloat = 0
        private var rowNumber: Int = 0
        
        private var currentTextViewContentSizeHeight: CGFloat = 0 {
            didSet {
                guard oldValue != currentTextViewContentSizeHeight else { return }
                adjustHeightIfNeeded()
            }
        }
        
        private var currenErrorLabelHeight: CGFloat = 0 {
            didSet {
                guard oldValue != currenErrorLabelHeight else { return }
                adjustHeightIfNeeded()
            }
        }
        
        private var isHiddenErrorLabel = true {
            didSet { changeBorderColor() }
        }
        
        private var isFocus = false {
            didSet { changeBorderColor() }
        }
        
        private var maxTextLength = 0
        
        private var _errorLabel: ErrorLabel {
            let label = ErrorLabel()
            label.font = .systemFont(ofSize: 11)
            label.textColor = .andpadRed
            label.textAlignment = .center
            label.backgroundColor = .hexStr("FFF0F1", alpha: 1.0)
            
            label.snp.makeConstraints { make in
                make.height.equalTo(LayoutParams.errorLabelHeight)
            }
            return label
        }

        // subscribe対象
        var shouldAdjustHeightDriver: Driver<RowHeight> {
            shouldAdjustHeightRelay.asDriver(onErrorJustReturn: .init(number: 0, height: 0))
        }
        
        var inputTextsSignal: Signal<Void> {
            inputTextsRelay
                .map { _ in () }
                .asSignal(onErrorJustReturn: ())
        }
        
        var changeBorderColorSignal: Signal<CGColor> {
            changeBorderColorRelay.asSignal(onErrorJustReturn: UIColor.gray222.cgColor)
        }
        
        var adjustedRowHeight: RowHeight {
            shouldAdjustHeightRelay.value
        }
        
        var borderColor: CGColor {
            changeBorderColorRelay.value
        }
        
        var textViewBackgroundColor: UIColor? {
            textView?.backgroundColor
        }
        
        var forceWarning = false
        var isMemoInput = false
        var inputdata: InputData?
        var maskedCorners: CACornerMask = []
        
        private var initialInputdata: InputData?
        
        private var textView: UITextView?
        
        func configure(
            _ textView: TextView,
            rowNumber: Int,
            textWidth: CGFloat,
            verticalType: VerticalType,
            horizontalType: HorizontalType?,
            maxTextLength: Int,
            blackboardItemPosition: Int,
            isItemName: Bool,
            forceWarning: Bool // 常にエラー状態（赤枠表示）とするか
        ) {
            self.initialInputdata = .init(
                text: textView.text,
                blackboardItemPosition: blackboardItemPosition,
                isItemName: isItemName
            )
            
            self.rowNumber = rowNumber
            self.maxTextLength = maxTextLength
            self.isMemoInput = horizontalType == nil
            self.forceWarning = forceWarning
            self.textView = textView
            axis = .vertical
            minHeight = horizontalType != nil
                ? LayoutParams.normalInputMinHeight
                : LayoutParams.memoInputMinHeight

            shouldAdjustHeightRelay.accept(.init(number: rowNumber, height: minHeight))
            
            let errorLabel = _errorLabel
            
            addArrangedSubview(textView)
            addArrangedSubview(errorLabel)
            errorLabel.text = L10n.Blackboard.Edit.Validate.lessThanCharacters(maxTextLength)
            
            snp.removeConstraints()
            snp.remakeConstraints { make in
                make.height.equalTo(minHeight).priority(.high)
            }
            
            switch verticalType {
            case .top:
                switch horizontalType {
                case .left:
                    maskedCorners = [.leftTop]
                case .right:
                    maskedCorners = [.rightTop]
                case .none:
                    break
                }
            case .middle:
                break
            case .bottom(let isOnlyRightValue):
                switch horizontalType {
                case .left:
                    maskedCorners = isOnlyRightValue ? [] : [.leftBottom]
                case .right:
                    maskedCorners = isOnlyRightValue ? [.leftBottom, .rightBottom] : [.rightBottom]
                case .none:
                    break
                }
            }
            
            addBinding(
                textView: textView,
                textWidth: textWidth,
                errorLabel: errorLabel,
                maxTextLength: maxTextLength
            )
            
            // 初期時点でheightにおさまらないテキスト量をセットされていることもあるので、
            // height調整処理を走らせるためにbinding後にacceptする
            inputTextsRelay.accept(textView.isEnabled ? textView.attributedText.string : textView.originalText)
            
            updateViewStateIfNeeded(errorLabel, isFocus: false)
        }
        
        private func addBinding(
            textView: TextView,
            textWidth: CGFloat,
            errorLabel: ErrorLabel,
            maxTextLength: Int
        ) {
            textView.rx.attributedText
                .compactMap { $0?.string }
                .bind(to: inputTextsRelay)
                .disposed(by: disposeBag)
            
            inputTextsRelay
                .map { $0.count <= maxTextLength }
                .bind(to: errorLabel.rx.isHidden)
                .disposed(by: disposeBag)

            inputTextsRelay
                .subscribe(onNext: { [weak self] in self?.inputdata = self?.initialInputdata?.updating(by: $0) })
                .disposed(by: disposeBag)
            
            inputTextsRelay
                .asDriver()
                .drive(onNext: { [weak self] _ in
                    self?.currentTextViewContentSizeHeight = textView.sizeThatFits(
                        .init(
                            width: textWidth,
                            height: textView.frame.size.height
                        )
                    ).height
                })
                .disposed(by: disposeBag)
            
            textView.rx.didBeginEditing
                .asDriver()
                .drive(onNext: { [weak self] in self?.updateViewStateIfNeeded(errorLabel, isFocus: true) })
                .disposed(by: disposeBag)
            
            textView.rx.didChange
                .asDriver()
                .drive(onNext: { [weak self] in self?.updateViewStateIfNeeded(errorLabel, isFocus: true) })
                .disposed(by: disposeBag)

            textView.rx.didEndEditing
                .asDriver()
                .drive(onNext: { [weak self] in
                    guard let self else { return }
                    self.isFocus = false
                })
                .disposed(by: disposeBag)
            
            errorLabel
                .changedHiddenStateDriver
                .drive(onNext: { [weak self] in
                    self?.isHiddenErrorLabel = $0
                    self?.adjustHeightIfNeeded()
                })
                .disposed(by: disposeBag)
        }
        
        private func updateViewStateIfNeeded(_ errorLabel: ErrorLabel, isFocus: Bool) {
            self.isFocus = isFocus
            changeBorderColor()
            guard self.inputTextsRelay.value.count > maxTextLength else { return }
        }
        
        private func changeBorderColor() {
            guard !forceWarning else {
                // 赤枠は入力状況に関わらず出しっぱなしとする
                changeBorderColorRelay.accept(UIColor.andpadRed.cgColor)
                return
            }
            
            guard isHiddenErrorLabel else {
                changeBorderColorRelay.accept(UIColor.andpadRed.cgColor)
                return
            }
            
            guard inputTextsRelay.value.count <= maxTextLength else {
                changeBorderColorRelay.accept(UIColor.andpadRed.cgColor)
                return
            }
            
            let newBorderColor = isFocus
                ? UIColor.orangeFEA.cgColor
                : UIColor.grayDDD.cgColor
            changeBorderColorRelay.accept(newBorderColor)
        }
        
        private func adjustHeightIfNeeded() {
            func adjust(_ newHeight: CGFloat) {
                shouldAdjustHeightRelay.accept(.init(number: rowNumber, height: newHeight))
                DispatchQueue.main.async { [weak self] in
                    self?.snp.updateConstraints { make in
                        make.height.equalTo(newHeight).priority(.high)
                    }
                }
            }
            
            var newHeight = max(
                currentTextViewContentSizeHeight + LayoutParams.normalInputTopBottomContentInset * 2,
                minHeight
            )
            newHeight = isHiddenErrorLabel
                ? newHeight
                : newHeight + LayoutParams.errorLabelHeight
            
            guard self.bounds.height != newHeight else { return }
            adjust(newHeight)
        }
    }
}

// MARK: - ErrorLabel
extension ModernBlackboardItemInputsCell {
    final class ErrorLabel: UILabel {
        var changedHiddenStateDriver: Driver<Bool> {
            changedHiddenStateRelay.asDriver(onErrorJustReturn: true)
        }
        private let changedHiddenStateRelay = PublishRelay<Bool>()
        
        override var isHidden: Bool {
            didSet {
                guard oldValue != isHidden else { return }
                changedHiddenStateRelay.accept(isHidden)
            }
        }
    }
}

// MARK: - TextView
extension ModernBlackboardItemInputsCell {
    final class TextView: UITextView {
        
        var originalText: String {
            _originalText
        }// configure時に渡されたtext
        var isEnabled: Bool {
            _isEnabled
        }
        
        private let disposeBag = DisposeBag()
        private let placeHolderLabel = UILabel()
        private let disabledTitleLabel = UILabel()
        
        private var _originalText: String = ""
        private var _isEnabled: Bool = true
        private var datePicker: UIDatePicker?
        private var didTapEventEnabled = true
        private let didTapRelay = PublishRelay<Void>()

        var didTapSignal: Signal<Void> {
            didTapRelay.asSignal()
        }
        
        func configure(
            text: String,
            placeholder: String,
            disabledTitle: String, // disable時のみ表示する文言（placeholderではない）
            maxTextLength: Int,
            isEnabled: Bool = true,
            useDatePicker: Bool = false
        ) {
            self._originalText = text
            self._isEnabled = isEnabled
            self.attributedText = attributeString(
                text,
                maxTextLength: maxTextLength
            )
            
            if useDatePicker {
                configureDatePicker()
            }
            
            configureBaseLayout()
            addPlaceHolderLabel(with: placeholder, text: text)
            addBinding(maxTextLength: maxTextLength)
            
            guard !isEnabled else { return }
            disabled(title: disabledTitle)
        }
        
        func attributeString(
            _ text: String,
            maxTextLength: Int
        ) -> NSMutableAttributedString {
        
            let attributedString = NSMutableAttributedString()
            let nonExceededText = String(text.prefix(maxTextLength))
            let exceededText = text.count > maxTextLength
                ? String(text.suffix(text.count - maxTextLength))
                : ""
            
            attributedString.append(
                NSAttributedString(
                    string: nonExceededText,
                    attributes: [.font: UIFont.systemFont(ofSize: LayoutParams.normalInputFontSize)]
                )
            )
            attributedString.append(
                NSAttributedString(
                    string: exceededText,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: LayoutParams.normalInputFontSize),
                        .foregroundColor: UIColor.red
                    ]
                )
            )
            return attributedString
        }

        /// ユーザーの入力を受け付けるかどうかを設定する
        ///  - Parameters:
        ///        - isEditable: trueなら編集可能、falseならタップしても入力できない
        ///        - shouldBeFocus: trueならTextViewにフォーカスを当てる、falseなら何もしない
        func editAction(isEditable: Bool, shouldBeFocus: Bool) {
            if isEditable {
                self.isEditable = true
                isSelectable = true
                didTapEventEnabled = false
            } else {
                // 確実にタップイベントを出すために入力イベント全般を一時的に塞いでタップイベントだけ有効にする
                self.isEditable = false
                isSelectable = false
                didTapEventEnabled = true
            }

            if shouldBeFocus {
                becomeFirstResponder()
            }
        }
        
        // MARK: - private
        private func configureBaseLayout() {
            font = .systemFont(ofSize: LayoutParams.normalInputFontSize)
            // NOTE: [workaround] 本来であれば、textContainerInsetのみで組めるはずだが、レイアウト崩れが発生したため、contentInsetも併用する形で対応している
            contentInset = .init(
                top: LayoutParams.normalInputTopBottomContentInset,
                left: .zero,
                bottom: LayoutParams.normalInputTopBottomContentInset,
                right: .zero
            )
            textContainerInset = .init(
                top: LayoutParams.normalInputTopBottomContentInset,
                left: LayoutParams.normalInputLeftRightContentInset,
                bottom: LayoutParams.normalInputTopBottomContentInset,
                right: LayoutParams.normalInputLeftRightContentInset
            )
        }
        
        private func addPlaceHolderLabel(with placeholder: String, text: String) {
            placeHolderLabel.text = placeholder
            placeHolderLabel.numberOfLines = 0
            placeHolderLabel.textAlignment = .left
            placeHolderLabel.font = .systemFont(ofSize: LayoutParams.normalInputFontSize)
            placeHolderLabel.textColor = .grayBBB
            placeHolderLabel.alpha = text.isEmpty ? 1 : 0
            
            addSubview(placeHolderLabel)
            
            placeHolderLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(LayoutParams.normalInputLeftRightContentInset + LayoutParams.placeHolderLabelAdjustLeftRightMargin)
                make.top.equalTo(LayoutParams.normalInputTopBottomMargin)
                make.height.equalTo(LayoutParams.normalInputFontSize)
            }
        }
        
        private func addDisabledTitleLabel(with disabledTitle: String) {
            disabledTitleLabel.text = disabledTitle
            disabledTitleLabel.numberOfLines = 0
            disabledTitleLabel.textAlignment = .left
            disabledTitleLabel.font = .systemFont(ofSize: LayoutParams.normalInputFontSize)
            disabledTitleLabel.textColor = .gray888
            
            addSubview(disabledTitleLabel)
            
            disabledTitleLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(LayoutParams.normalInputLeftRightContentInset + LayoutParams.placeHolderLabelAdjustLeftRightMargin)
                make.top.equalTo(LayoutParams.normalInputTopBottomMargin)
                make.height.equalTo(LayoutParams.normalInputFontSize)
            }
            bringSubviewToFront(disabledTitleLabel)
        }
        
        private func addBinding(maxTextLength: Int) {
            rx.didChange
                .asDriver()
                .drive(onNext: { [weak self] in
                    guard let self else { return }
                    self.placeHolderLabel.alpha = self.text.isEmpty ? 1 : 0
                    guard self.markedTextRange == nil, // 変換中はattributedText化しない
                    let selectedTextRangeBeforeInsert = self.selectedTextRange else { return }
                    
                    // ここでテキスト挿入を行うと、caret位置がリセット（ = 最後尾にセット）されるため、
                    self.attributedText = self.attributeString(
                        self.text,
                        maxTextLength: maxTextLength
                    )
                    // テキスト挿入前のcaretポジションに補正し直す
                    self.selectedTextRange = selectedTextRangeBeforeInsert
                })
                .disposed(by: disposeBag)
            
            datePicker?.rx.controlEvent(.valueChanged)
                .asDriver()
                .drive(onNext: { [weak self] in self?.updateDate(doneEditing: false) })
                .disposed(by: disposeBag)
        }
        
        private func disabled(title: String) {
            isUserInteractionEnabled = false
            backgroundColor = .grayEEE
            textColor = .gray888
            
            guard !title.isEmpty else { return }
            addDisabledTitleLabel(with: title)
            
            // NOTE: disabledTitle表示時は、実際の値も消す
            // （苦し紛れの実装ではある。後々変更するかもしれない）
            self.attributedText = nil
        }
        
        // MARK: - date picker
        
        private func configureDatePicker() {
            datePicker = UIDatePicker()
            if #available(iOS 13.4, *) {
                datePicker?.preferredDatePickerStyle = .wheels
            }

            datePicker?.datePickerMode = .date
            datePicker?.date = attributedText.string.asDateFromDateString() ?? Date()
            // 2020/01/01以前は選択できないようにする
            datePicker?.setMinimumDate(year: 2020, month: 1, day: 1)
            inputView = datePicker

            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            let spacer = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                target: self,
                action: nil
            )
            let doneButton = UIBarButtonItem(
                title: "完了",
                style: .plain,
                target: self,
                action: #selector(Self.tappedDoneButton)
            )
            toolBar.items = [spacer, doneButton]
            inputAccessoryView = toolBar
        }

        @objc private func tappedDoneButton() {
            updateDate(doneEditing: true)
        }
        
        private func updateDate(doneEditing: Bool) {
            if doneEditing {
                endEditing(true)
            }
            
            guard let datePicker else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let dateString = dateFormatter.string(from: datePicker.date)
            text = dateString
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            if didTapEventEnabled { didTapRelay.accept(()) }
        }
    }
}

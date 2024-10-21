//
//  ModernEditBlackboardErrorCell.swift
//  andpad-camera
//
//  Created by msano on 2022/02/04.
//

import AndpadUIComponent
import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

final class ModernEditBlackboardErrorCell: UITableViewCell {
    struct Dependency {
        let parentType: ParentType
        let errorTexts: [String]
        let initialPattern: ModernBlackboardContentView.Pattern
    }
    
    enum ParentType {
        case createModernBlackboard
        case editModernBlackboard(ModernEditBlackboardViewController.EditableScope)
        
        var subtitle: String {
            switch self {
            case .createModernBlackboard:
                return L10n.Blackboard.Create.descriptionForInputs
            case .editModernBlackboard:
                return L10n.Blackboard.Edit.descriptionForInputs
            }
        }
        
        var editableScope: ModernEditBlackboardViewController.EditableScope? {
            switch self {
            case .createModernBlackboard:
                return nil
            case .editModernBlackboard(let scope):
                return scope
            }
        }
    }
    
    private enum SelectLayoutButtonState {
        case enabled
        case disabled
        
        init(pattern: ModernBlackboardContentView.Pattern) {
            self = pattern.hasMiniatureMapView ? .disabled : .enabled
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .enabled:
                return .white
            case .disabled:
                return .grayEEE
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .enabled:
                return .gray222
            case .disabled:
                return .gray888
            }
        }
        
        var isEnabled: Bool {
            switch self {
            case .enabled:
                return true
            case .disabled:
                return false
            }
        }
    }
    
    // IBOutlet
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var annotationLabel: UILabel!
    @IBOutlet private weak var annotationLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var errorsLabel: UILabel!
    @IBOutlet private weak var selectLayoutContainerView: UIView!
    @IBOutlet private weak var selectLayoutButton: UIButton!
    @IBOutlet private weak var layoutTextLabel: UILabel!
    @IBOutlet private weak var layoutIdLabel: UILabel!
    @IBOutlet private weak var selectLayoutDescriptionLabel: UILabel!
    @IBOutlet private weak var errorLabelBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet private weak var selectLayoutContainerTopMarginConstraint: NSLayoutConstraint!
    
    enum LayoutParams {
        /// （errorsLabelが0の場合の）cell全体の高さ
        static let defaultBaseCellHeight: CGFloat = 105
        
        // swiftlint:disable:next identifier_name
        static let selectLayoutContainerHeight: CGFloat = 83

        // swiftlint:disable:next identifier_name
        static let defaultSelectLayoutDescriptionLabelHeight: CGFloat = 12
        
        // swiftlint:disable:next identifier_name
        static let defaultSelectLayoutContainerTopMarginConstraint: CGFloat = 4
        
        /// エラーラベルのボトムマージン（エラーラベル表示時に限る）
        static let errorLabelBottomMarginConstraint: CGFloat = 10
    }
    
    var disposeBag = DisposeBag()
    
    // subscribe対象
    let updateCellHeightSignal: Signal<CGFloat>
    var tapSelectLayoutButtonSignal: Signal<Void> {
        selectLayoutButton.rx.tap.asSignal()
    }

    private var pattern: ModernBlackboardContentView.Pattern = .pattern1
    private let updateCellHeightRelay = BehaviorRelay<CGFloat>(value: LayoutParams.defaultBaseCellHeight)
    
    required init?(coder: NSCoder) {
        updateCellHeightSignal = updateCellHeightRelay
            .distinctUntilChanged()
            .asSignal(onErrorJustReturn: .zero)
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subtitleLabel.textColor = .tsukuri.system.primaryTextOnSurface1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: - private
extension ModernEditBlackboardErrorCell {
    private func configureBaseLayout() {
        selectLayoutDescriptionLabel.isHidden = true
        selectLayoutButton.setTitle("", for: .normal)
        selectLayoutContainerView.layer.borderColor = UIColor.grayDDD.cgColor
        selectLayoutContainerView.layer.borderWidth = 1
    }
    
    private func configure(parentType: ParentType, errorTexts: [String]) {
        layoutIdLabel.text = "\(pattern.layoutID)"
        subtitleLabel.text = parentType.subtitle
        
        // NOTE: 近々のリリースで以下に統合される予定です
        selectLayoutContainerView.isHidden = parentType.editableScope == .all
        selectLayoutDescriptionLabel.isHidden = parentType.editableScope == .all
            ? true
            : !pattern.hasMiniatureMapView
        selectLayoutContainerTopMarginConstraint.constant = selectLayoutDescriptionLabel.isHidden
            ? 0
            : LayoutParams.defaultSelectLayoutContainerTopMarginConstraint

        // configure selectLayoutButton
        let selectLayoutButtonState = SelectLayoutButtonState(pattern: pattern)
        selectLayoutContainerView.backgroundColor = selectLayoutButtonState.backgroundColor
        layoutTextLabel.textColor = selectLayoutButtonState.textColor
        layoutIdLabel.textColor = selectLayoutButtonState.textColor
        selectLayoutButton.isEnabled = selectLayoutButtonState.isEnabled

        // configure annotationLabel
        annotationLabelHeightConstraint.constant = annotationLabelHeight(with: parentType)
        
        guard !errorTexts.isEmpty else {
            doOnlyShowSubtitle(parentType: parentType)
            return
        }
        
        // configure error text
        errorsLabel.text = errorTexts.joined(separator: "\n")
        errorLabelBottomMarginConstraint.constant = errorsLabel.text != nil
            ? LayoutParams.errorLabelBottomMarginConstraint
            : .zero
        
        updateCellHeightIfNeeded(
            height: errorsLabel.text?.calcTextHeight(
                font: errorsLabel.font,
                width: errorsLabel.bounds.width
            ),
            parentType: parentType
        )
        
        layoutIfNeeded()
    }
    
    private func updateCellHeightIfNeeded(height: CGFloat?, parentType: ParentType) {
        guard let height else { return }
        
        updateCellHeightRelay.accept(
            height
            + baseCellHeight(with: parentType)
            + errorLabelBottomMarginConstraint.constant
            - calcAdjustNegativeCellMargin(editableScope: parentType.editableScope)
        )
    }
    
    /// サブタイトルのみ表示させる
    private func doOnlyShowSubtitle(parentType: ParentType) {
        // NOTE: UI設計上少しわかりづらくなってしまっているが、
        // このセルには「黒板内容」というタイトルがあり、これはエラーの有無に関わらず表示させたいため、常にbaseCellHeight分の高さは確保する
        errorsLabel.text = nil
        updateCellHeightRelay.accept(baseCellHeight(with: parentType) - calcAdjustNegativeCellMargin(editableScope: parentType.editableScope))
    }
    
    private func calcAdjustNegativeCellMargin(editableScope: ModernEditBlackboardViewController.EditableScope?) -> CGFloat {
        guard editableScope != .all else { return 0 }
        return selectLayoutContainerTopMarginConstraint.constant == 0
            ? LayoutParams.defaultSelectLayoutDescriptionLabelHeight + LayoutParams.defaultSelectLayoutContainerTopMarginConstraint
            : 0
    }
    
    private func calculateAnnotationLabelHeight() -> CGFloat {
        guard let text = annotationLabel.text, !text.isEmpty else {
            return 0
        }
        
        let textHeight = text.calcTextHeight(
            font: annotationLabel.font,
            width: UIScreen.main.bounds.width - 32 // 32 is leading + trailing of the annotation label
        )
        
        return textHeight + 10 // 10 is top and bottom padding of the label
    }
    
    private func annotationLabelHeight(with parentType: ParentType) -> CGFloat {
        guard let editableScope = parentType.editableScope else { return .zero }
        switch editableScope {
        case .all:
            return calculateAnnotationLabelHeight()
        case .onlyBlackboardItems:
            return .zero
        }
    }
    
    private func baseCellHeight(with parentType: ParentType) -> CGFloat {
        switch parentType {
        case .createModernBlackboard:
            return LayoutParams.defaultBaseCellHeight
        case .editModernBlackboard(let scope):
            switch scope {
            case .all:
                // No select layout button
                return LayoutParams.defaultBaseCellHeight - LayoutParams.selectLayoutContainerHeight + calculateAnnotationLabelHeight()
            case .onlyBlackboardItems:
                return LayoutParams.defaultBaseCellHeight
            }
        }
    }
}

// MARK: - NibType
extension ModernEditBlackboardErrorCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension ModernEditBlackboardErrorCell: Reusable {
    func inject(_ dependency: Dependency) {
        pattern = dependency.initialPattern
        
        configureBaseLayout()
        configure(
            parentType: dependency.parentType,
            errorTexts: dependency.errorTexts
        )
    }
}

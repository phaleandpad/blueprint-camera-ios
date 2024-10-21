//
//  BlackboardFreewordConditionCell.swift
//  andpad
//
//  Created by msano on 2021/04/16.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift

final class BlackboardFreewordConditionCell: UITableViewCell {
    struct Dependency {
        let modelType: ConditionModelType
    }
    
    // IBOutlet
    // use .beforeEditing
    @IBOutlet private weak var freewordButton: UIButton!
    // use .editing
    @IBOutlet private weak var freewordTextField: UITextField!
    // use .edited
    @IBOutlet private weak var freewordLabelView: UIView!
    @IBOutlet private weak var freewordTitleLabel: UILabel!
    @IBOutlet private weak var freewordLabel: UILabel!
    @IBOutlet private weak var editedFreewordButton: UIButton!
    
    // IBAction
    @IBAction private func tappedFreewordButton(_ sender: Any) {
        editState = .editing
    }
    
    @IBAction private func tappedEditedFreewordButton(_ sender: Any) {
        editState = .editing
    }
    
    // NOTE:
    // 「未編集」「編集後」のときのみ、イベント送信する
    // （ = パフォーマンスの観点から「編集中」は送信しない）

    var disposeBag = DisposeBag()
    
    private let postInputedText = BehaviorRelay<String>(value: "")
    var postInputedTextObservable: Observable<String> {
        postInputedText.asObservable()
    }

    private var editState: EditState = .beforeEditing {
        didSet {
            guard oldValue != editState else {
                return
            }
            switch editState {
            case .beforeEditing:
                freewordButton.isHidden = false
                freewordTextField.isHidden = true
                freewordLabelView.isHidden = true
                postInputedText.accept("")
                freewordTextField.resignFirstResponder()
            case .editing:
                freewordButton.isHidden = true
                freewordTextField.isHidden = false
                freewordLabelView.isHidden = true
                freewordTextField.becomeFirstResponder()
            case .edited:
                freewordButton.isHidden = true
                freewordTextField.isHidden = true
                freewordLabelView.isHidden = false
                if let text = freewordLabel.text, !text.isEmpty {
                    postInputedText.accept(text)
                }
                freewordTextField.resignFirstResponder()
            }
            layoutIfNeeded()
        }
    }

    // life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        freewordTextField.delegate = self
    }
}

extension BlackboardFreewordConditionCell {
    func configureCell(with modelType: ConditionModelType) {
        selectionStyle = .none
        freewordTextField.returnKeyType = .done
        freewordTextField.delegate = self
        
        freewordTitleLabel.text = L10n.Blackboard.Filter.freeword

        switch modelType {
        case .freeword(let string):
            freewordTextField.text = string
            freewordLabel.text = string
            editState = string.isEmpty ? .beforeEditing : .edited
        case .photo, .pinnedBlackboardItem, .blackboardItemsSeparator, .unpinnedBlackboardItem, .showAllBlackboardItemsButton:
            assertionFailure()
        }
    }
}

// MARK: - UITextFieldDelegate
extension BlackboardFreewordConditionCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        freewordLabel.text = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = freewordLabel.text else {
            editState = .beforeEditing
            return true
        }
        editState = text.isEmpty ? .beforeEditing : .edited
        return true
    }
}

// MARK: - EditState
extension BlackboardFreewordConditionCell {
    private enum EditState {
        case beforeEditing
        case editing
        case edited
    }
}

// MARK: - NibType
extension BlackboardFreewordConditionCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension BlackboardFreewordConditionCell: Reusable {
    func inject(_ dependency: Dependency) {
        configureCell(with: dependency.modelType)
    }
}

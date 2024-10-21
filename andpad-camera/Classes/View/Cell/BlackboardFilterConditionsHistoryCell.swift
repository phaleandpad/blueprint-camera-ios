//
//  BlackboardFilterConditionsHistoryCell.swift
//  andpad-camera
//
//  Created by msano on 2022/01/17.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

final class BlackboardFilterConditionsHistoryCell: UITableViewCell {
    typealias Query = ModernBlackboardSearchQuery
    
    struct Dependency {
        let history: BlackboardFilterConditionsHistory
    }
    
    // IBOutlet
    @IBOutlet private weak var stackContainerShadowView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var deleteButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    private var history: BlackboardFilterConditionsHistory? {
        didSet { readableHistory = .init(by: history?.query) }
    }
    
    private var readableHistory: ReadableHistory? {
        didSet { configureCellLayout() }
    }
    
    // life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        history = nil
        readableHistory = nil
        stackView.removeAllArrangedSubviews()
    }
}

// MARK: - subscribe対象
extension BlackboardFilterConditionsHistoryCell {
    var tappedDeleteButton: Signal<BlackboardFilterConditionsHistory> {
        deleteButton.rx.tap
            .asSignal()
            .compactMap { [weak self] in self?.history }
    }
}

extension BlackboardFilterConditionsHistoryCell {
    func configureCell(with history: BlackboardFilterConditionsHistory) {
        self.history = history
    }
}

// MARK: - private
extension BlackboardFilterConditionsHistoryCell {
    private func configureCellLayout() {
        func addLabelsViewIfNeeded(
            type: BlackboardFilterConditionsHistoryLabelsView.ViewType,
            conditionText: String
        ) {
            guard !conditionText.isEmpty else { return }
            stackView.addArrangedSubview(
                BlackboardFilterConditionsHistoryLabelsView(
                    with: .init(
                        type: type,
                        content: conditionText
                    )
                )
            )
        }
        
        guard let readableHistory else { return }
        
        // NOTE: 「写真の有無」「項目」「備考」「フリーワード」の順にViewを追加していく
        
        addLabelsViewIfNeeded(
            type: .photo,
            conditionText: readableHistory.photoConditionText
        )
        addLabelsViewIfNeeded(
            type: .blackboardItem,
            conditionText: readableHistory.blackboardConditionsValue
        )
        addLabelsViewIfNeeded(
            type: .memo,
            conditionText: readableHistory.memoConditionsValue
        )
        addLabelsViewIfNeeded(
            type: .freeword,
            conditionText: readableHistory.freeWordConditionText
        )
    }
    
    private func setShadow() {
        stackContainerShadowView.layer.cornerRadius = 4.0
        stackContainerShadowView.layer.shadowColor = UIColor.black.cgColor
        stackContainerShadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        stackContainerShadowView.layer.shadowRadius = 4.0
        stackContainerShadowView.layer.shadowOpacity = 0.1
    }
}

// MARK: - ReadableHistory
extension BlackboardFilterConditionsHistoryCell {
    // NOTE: （このセルで表示しやすいよう）検索クエリを扱いやすくしたstruct
    private struct ReadableHistory {
        let freeWordConditionText: String
        let photoConditionText: String
        let blackboardConditionsValue: String
        let memoConditionsValue: String
        
        init?(by query: Query?) {
            guard let query else { return nil }
            freeWordConditionText = query.freewords
            
            switch query.photoCondition {
            case .all:
                photoConditionText = ""
            case .hasPhoto, .hasNoPhoto:
                photoConditionText = query.photoCondition.string
            }
            
            blackboardConditionsValue = query.conditionForBlackboardItems
                .filter { $0.targetItemName != L10n.Blackboard.Filter.memo }
                .map {
                    let name = $0.targetItemName
                    let conditionsString = $0.conditions
                        .map { string in
                            string.isEmpty ? L10n.Blackboard.Filter.selectEmptyItem(name) : string
                        }
                        .joined(separator: L10n.Common.comma)
                    return name + "：" + conditionsString
                }
                .joined(separator: " / ")
            
            memoConditionsValue = query.conditionForBlackboardItems
                .first(where: { $0.targetItemName == L10n.Blackboard.Filter.memo })?
                .conditions
                .map { string in
                    string.isEmpty ? L10n.Blackboard.Filter.selectEmptyItem(L10n.Blackboard.Filter.memo) : string
                }
                .joined(separator: L10n.Common.comma) ?? ""
        }
    }
}

// MARK: - NibType
extension BlackboardFilterConditionsHistoryCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension BlackboardFilterConditionsHistoryCell: Reusable {
    func inject(_ dependency: Dependency) {
        setShadow()
        selectionStyle = .none
        
        configureCell(with: dependency.history)
    }
}

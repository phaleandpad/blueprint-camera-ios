//
//  BlackboardFilterConditionCell.swift
//  andpad
//
//  Created by msano on 2021/04/15.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import AndpadUIComponent
import Instantiate
import InstantiateStandard

final class BlackboardFilterConditionCell: UITableViewCell {
    struct Dependency {
        let modelType: ConditionModelType
    }
    
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var selectedConditionsLabel: UILabel!
    @IBOutlet private weak var nextIcon: UIImageView!

    // life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}

extension BlackboardFilterConditionCell {
    private func configureCell(with modelType: ConditionModelType) {
        switch modelType {
        case .pinnedBlackboardItem(let itemName, let selectedConditions, let isActive),
             .unpinnedBlackboardItem(let itemName, let selectedConditions, _, let isActive):
            itemNameLabel.text = itemName
            if isActive {
                itemNameLabel.textColor = .tsukuri.system.primaryTextOnSurface1

                switch selectedConditions.count {
                case 0:
                    selectedConditionsLabel.text = L10n.Blackboard.Filter.unspecified
                    selectedConditionsLabel.textColor = .tsukuri.system.disabledTextOnSurface1
                case 1:
                    let text = selectedConditions.first!
                    selectedConditionsLabel.text = text.isEmpty
                        ? L10n.Blackboard.Filter.selectEmptyItem(itemName)
                        : text
                    selectedConditionsLabel.textColor = .tsukuri.system.primaryTextOnSurface1
                default:
                    selectedConditionsLabel.text = L10n.Blackboard.Filter.multiSelectText(selectedConditions.count)
                    selectedConditionsLabel.textColor = .tsukuri.system.primaryTextOnSurface1
                }

                nextIcon.isHidden = false
                isUserInteractionEnabled = true
            } else {
                itemNameLabel.textColor = .tsukuri.system.disabledTextOnSurface1

                selectedConditionsLabel.text = L10n.Blackboard.Filter.notApplicable
                selectedConditionsLabel.textColor = .tsukuri.system.disabledTextOnSurface1

                nextIcon.isHidden = true
                isUserInteractionEnabled = false
            }
        case .photo(let conditionString):
            itemNameLabel.text = L10n.Blackboard.Filter.existPhoto
            itemNameLabel.textColor = .tsukuri.system.primaryTextOnSurface1

            selectedConditionsLabel.text = conditionString
            selectedConditionsLabel.textColor = .tsukuri.system.primaryTextOnSurface1

            nextIcon.isHidden = false
            isUserInteractionEnabled = true
        case .blackboardItemsSeparator, .showAllBlackboardItemsButton, .freeword:
            assertionFailure()
        }
    }
}

// MARK: - NibType
extension BlackboardFilterConditionCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension BlackboardFilterConditionCell: Reusable {
    func inject(_ dependency: Dependency) {
        configureCell(with: dependency.modelType)
    }
}

// MARK: - ConditionModelType
enum ConditionModelType: Equatable {
    case photo(String)
    case pinnedBlackboardItem(itemName: String, selectedConditions: [String], isActive: Bool)
    case blackboardItemsSeparator
    /// ピン留めされていない黒板の項目
    /// - Parameters:
    ///     - itemName: 項目名
    ///     - selectedConditions: ユーザーに指定された検索条件
    ///     - isVisible: 表示するか否か
    ///     - isActive: 非活性表示するかどうか
    /// - Note: isVisible は優先表示で利用する。isActive は項目を非活性にするかどうかで利用する。
    case unpinnedBlackboardItem(itemName: String, selectedConditions: [String], isVisible: Bool, isActive: Bool)
    case showAllBlackboardItemsButton
    case freeword(String)
}

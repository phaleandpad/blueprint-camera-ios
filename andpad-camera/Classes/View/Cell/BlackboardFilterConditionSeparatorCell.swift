//
//  BlackboardFilterConditionSeparatorCell.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2023/08/09.
//

import Instantiate
import InstantiateStandard

// MARK: - BlackboardFilterConditionSeparatorCell

final class BlackboardFilterConditionSeparatorCell: UITableViewCell {
    // life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setUpViews()
    }

    private func setUpViews() {
        backgroundColor = .tsukuri.system.lightBorder
        contentView.heightAnchor.constraint(equalToConstant: 3).isActive = true
    }
}

// MARK: Reusable

extension BlackboardFilterConditionSeparatorCell: Reusable {
}

// MARK: NibType

extension BlackboardFilterConditionSeparatorCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

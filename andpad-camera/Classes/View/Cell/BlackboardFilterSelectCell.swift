//
//  BlackboardFilterSelectCell.swift
//  andpad
//
//  Created by 佐藤俊輔 on 2021/04/13.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import Instantiate
import InstantiateStandard
import RxDataSources

final class BlackboardFilterSelectCell: UITableViewCell {
    struct Dependency {
        let text: String
    }
    
    enum Mode {
        case single
        case multi
    }

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var selectIcon: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        selectIcon.image = nil
    }
}

extension BlackboardFilterSelectCell {
    func setSelect(mode: Mode) {
        switch mode {
        case .single:
            selectIcon.image = Asset.iconFilterSelectSingle.image
        case .multi:
            selectIcon.image = Asset.iconFilterSelectMulti.image
        }
    }

    func setDeselect(mode: Mode) {
        switch mode {
        case .single:
            selectIcon.image = nil
        case .multi:
            selectIcon.image = Asset.iconFilterDeselectMulti.image
        }
    }
}

// MARK: - private
extension BlackboardFilterSelectCell {
    private func configureCell(text: String) {
        selectionStyle = .none
        label.textColor = .textColor
        label.text = text
    }
}

// MARK: - NibType
extension BlackboardFilterSelectCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension BlackboardFilterSelectCell: Reusable {
    func inject(_ dependency: Dependency) {
        configureCell(text: dependency.text)
    }
}

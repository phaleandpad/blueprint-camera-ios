//
//  BlackboardFilterConditionsShowAllBlackboardItemsButtonCell.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2023/08/18.
//

import Instantiate
import RxCocoa
import RxSwift
import UIKit

// MARK: - BlackboardFilterConditionsShowAllBlackboardItemsButtonCell

class BlackboardFilterConditionsShowAllBlackboardItemsButtonCell: UITableViewCell {
    let showAllBlackboardItemsButton = RoundGrayButton(title: L10n.Blackboard.Filter.showAllBlackboardItemsButtonText)
    var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func setUpViews() {
        backgroundColor = .clear

        contentView.addSubview(showAllBlackboardItemsButton)

        showAllBlackboardItemsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: Reusable

extension BlackboardFilterConditionsShowAllBlackboardItemsButtonCell: Reusable {
}

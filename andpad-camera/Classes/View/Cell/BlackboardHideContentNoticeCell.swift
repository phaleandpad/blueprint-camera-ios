//
//  BlackboardHideContentNoticeCell.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/04/04.
//

import AndpadUIComponent
import UIKit

final class BlackboardHideContentNoticeCell: UITableViewCell {

    private let descriptionLabel = UILabel()

    static var reuseIdentifier: String {
        String(describing: Self.self)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    private func setUpViews() {
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .tsukuri.system.secondaryTextOnBackground
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)

        descriptionLabel.text = L10n.Blackboard.Filter.hideContentNotice

        addSubview(descriptionLabel)

        descriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 16, bottom: 16, right: 16))
        }
    }
}

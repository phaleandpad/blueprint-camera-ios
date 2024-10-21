//
//  BlackboardSettingsSectionView.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/04/17.
//

import UIKit
import SnapKit
import AndpadUIComponent

final class BlackboardSettingsSectionView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .tsukuri.system.primaryTextOnInverseSurface
        return label
    }()

    let contentView: BlackboardSettingsSegmentContainerView
    let footerView: BlackboardSettingsSectionFooterView?
    let configurationID: UUID

    init(configuration: BlackboardSettingsSectionConfiguration, contentView: BlackboardSettingsSegmentContainerView) {
        self.configurationID = configuration.id
        self.contentView = contentView
        titleLabel.text = configuration.title
        footerView = configuration.footer.map { BlackboardSettingsSectionFooterView(configuration: $0) }

        super.init(frame: .zero)
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with configuration: BlackboardSettingsSectionConfiguration) {
        contentView.update(with: configuration)

        guard let footerView, let footerConfiguration = configuration.footer else { return }
        footerView.update(with: footerConfiguration)
    }
}

private extension BlackboardSettingsSectionView {
    func setUpViews() {
        addSubview(titleLabel)
        addSubview(contentView)

        titleLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(9)
            $0.trailing.equalToSuperview()
            $0.verticalEdges.equalToSuperview().inset(4)
        }
    }
}

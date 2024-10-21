//
//  BlackboardSettingsSectionFooterView.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/05/08.
//

import UIKit
import SnapKit

final class BlackboardSettingsSectionFooterView: UIView {

    private let calloutLabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .tsukuri.system.primaryTextOnInverseSurface
        return label
    }()

    init(configuration: BlackboardSettingsSectionFooterConfiguration) {
        self.calloutLabel.text = configuration.title
        super.init(frame: .zero)
        setUpViews()
        isHidden = configuration.isHidden
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeLayoutConstraintToSectionContent(_ section: BlackboardSettingsSectionView) {
        calloutLabel.snp.makeConstraints {
            $0.leading.equalTo(section.contentView.contentView)
        }
    }

    func update(with configuration: BlackboardSettingsSectionFooterConfiguration) {
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            guard let self, isHidden != configuration.isHidden else { return }
            isHidden = configuration.isHidden
            calloutLabel.alpha = configuration.isHidden ? 0.0 : 1.0
        }
    }
}

private extension BlackboardSettingsSectionFooterView {
    func setUpViews() {
        calloutLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        calloutLabel.setContentHuggingPriority(.required, for: .vertical)
        addSubview(calloutLabel)

        calloutLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8).priority(.low)
            $0.trailing.equalToSuperview().inset(8)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
        }
    }
}

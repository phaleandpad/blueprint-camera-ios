//
//  BlackboardSettingsSegmentedView.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/04/17.
//

import UIKit
import SnapKit

final class BlackboardSettingsSegmentedView: UIView {
    private let stackView: UIStackView
    private let segments: [BlackboardSettingsSegment]

    init(
        configurations: [BlackboardSettingsSegmentConfiguration],
        action: @escaping (BlackboardSettingsSegmentConfiguration) -> Void
    ) {
        let segments = configurations.map {
            BlackboardSettingsSegment(configuration: $0, action: action)
        }
        let stackView = UIStackView(arrangedSubviews: segments)
        self.segments = segments
        self.stackView = stackView

        super.init(frame: .zero)
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with configuration: BlackboardSettingsSectionConfiguration) {
        segments.forEach { segment in
            guard let config = configuration.segmentConfiguration(for: segment.configurationID) else { return }
            segment.update(with: config)
        }
    }
}

private extension BlackboardSettingsSegmentedView {
    func setUpViews() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        stackView.spacing = 4
    }
}

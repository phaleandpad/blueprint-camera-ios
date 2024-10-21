//
//  BlackboardSettingsSegmentContainerView.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/04/17.
//

import UIKit
import SnapKit

final class BlackboardSettingsSegmentContainerView: UIView {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    let contentView: BlackboardSettingsSegmentedView

    init(contentView: BlackboardSettingsSegmentedView) {
        self.contentView = contentView

        super.init(frame: .zero)
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with configuration: BlackboardSettingsSectionConfiguration) {
        contentView.update(with: configuration)
    }
}

private extension BlackboardSettingsSegmentContainerView {
    func setUpViews() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.verticalEdges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
    }
}

//
//  BlackboardSettingsSheetView.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/04/17.
//

import UIKit
import SnapKit
import AndpadUIComponent

final class BlackboardSettingsSheetView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .tsukuri.system.primaryTextOnInverseSurface
        return label
    }()

    private let divider: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .tsukuri.system.inverseBorder
        return view
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.iconBlackboardSettingsClose.image, for: .normal)
        button.viewAccessibilityIdentifier = .blackboardSettingsSheetViewCloseButton
        return button
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: BlackboardSettingsContentView

    init(title: String, contentView: BlackboardSettingsContentView, closeAction: @escaping () -> Void) {
        self.titleLabel.text = title
        self.contentView = contentView
        self.closeButton.addAction(.init(handler: { _ in
            closeAction()
        }), for: .touchUpInside)

        super.init(frame: .zero)
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BlackboardSettingsSheetView {
    func setUpViews() {
        addSubview(titleLabel)
        addSubview(divider)
        addSubview(closeButton)
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(14)
            $0.leading.equalToSuperview().inset(16)
        }

        closeButton.snp.makeConstraints {
            $0.top.equalTo(4)
            $0.trailing.equalToSuperview().inset(8)
            $0.size.equalTo(44)
        }

        divider.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(-100) // safeArea の外へ伸ばす
            $0.height.equalTo(1)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.size.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.lessThanOrEqualTo(scrollView.frameLayoutGuide).priority(.high)
        }
    }
}

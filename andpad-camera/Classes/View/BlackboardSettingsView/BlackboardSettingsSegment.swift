//
//  BlackboardSettingsSegment.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/04/17.
//

import UIKit
import SnapKit
import AndpadUIComponent

final class BlackboardSettingsSegment: UIControl {
    let configurationID: UUID
    private let iconType: BlackboardSettingsSegmentIconType
    private lazy var iconView: UIView = iconView(for: iconType)

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = .tsukuri.system.primaryTextOnInverseSurface
        return label
    }()

    init(configuration: BlackboardSettingsSegmentConfiguration, action: @escaping (BlackboardSettingsSegmentConfiguration) -> Void) {
        self.configurationID = configuration.id
        self.titleLabel.text = configuration.title
        self.iconType = configuration.iconType

        super.init(frame: .zero)
        setUpViews()
        addAction(.init(handler: { _ in
            action(configuration)
        }), for: .touchUpInside)

        isEnabled = configuration.isEnabledForView
        isSelected = configuration.isSelectedForView
        accessibilityIdentifier = configuration.accessibilityIdentifier
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            highlightedEffect(
                for: isHighlighted,
                animated: !isHighlighted
            )
        }
    }

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected
            ? .tsukuri.system.interactiveSurface(for: .primary)
            : .tsukuri.system.inverseSurface(for: .state1)
        }
    }

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.4
        }
    }

    func update(with configuration: BlackboardSettingsSegmentConfiguration) {
        isEnabled = configuration.isEnabledForView
        isSelected = configuration.isSelectedForView
    }
}

private extension BlackboardSettingsSegment {
    func setUpViews() {
        iconView.tintColor = .tsukuri.system.inverseSurface()
        titleLabel.font = .preferredFont(forTextStyle: iconType.titleFontTextStyle)
        backgroundColor = .tsukuri.system.surface1(for: .state1)
        layer.cornerRadius = 4

        let contentView = UIView(frame: .zero)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.isUserInteractionEnabled = false

        addSubview(contentView)

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(2)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        iconView.setContentCompressionResistancePriority(.required, for: .vertical)
        iconView.setContentHuggingPriority(.required, for: .vertical)
        makeIconViewConstraints(with: titleLabel.text ?? "")
        makeContentViewConstraints(contentView)

        self.snp.makeConstraints {
            $0.width.equalTo(52)
            $0.height.greaterThanOrEqualTo(48)
        }
    }

    func iconView(for type: BlackboardSettingsSegmentIconType) -> UIView {
        switch type {
        case .image(let image):
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            return imageView
        case .text(let text):
            let label = UILabel(frame: .zero)
            label.text = text
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .footnote)
            label.adjustsFontForContentSizeCategory = true
            label.textAlignment = .center
            label.textColor = .tsukuri.system.primaryTextOnInverseSurface
            return label
        }
    }

    func makeIconViewConstraints(with titleText: String) {
        switch iconType {
        case .image:
            iconView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.size.equalTo(20)
                $0.centerX.equalToSuperview()
            }
        case .text:
            if titleText.isEmpty {
                titleLabel.snp.removeConstraints()
                titleLabel.isHidden = true
                iconView.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
            } else {
                iconView.snp.makeConstraints {
                    $0.top.equalToSuperview()
                    $0.horizontalEdges.equalToSuperview()
                }
            }
        }
    }

    func makeContentViewConstraints(_ contentView: UIView) {
        switch iconType {
        case .image:
            contentView.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(2)
                $0.top.equalToSuperview().inset(4)
                $0.bottom.lessThanOrEqualToSuperview().inset(4)
            }
        case .text:
            contentView.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(2)
                $0.top.greaterThanOrEqualToSuperview().inset(4)
                $0.bottom.lessThanOrEqualToSuperview().inset(4)
                $0.center.equalToSuperview()
            }
        }
    }

    func highlightedEffect(for isHighlighted: Bool, animated: Bool = true) {
        let effect = { [weak self] in
            self?.alpha = isHighlighted ? 0.6 : 1
        }

        if animated {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                effect()
            }
        } else {
            effect()
        }
    }
}

private extension BlackboardSettingsSegmentConfiguration {
    var isEnabledForView: Bool {
        isEnabled && canEnabled
    }

    var isSelectedForView: Bool {
        isEnabledForView ? isSelected : false
    }
}

private extension BlackboardSettingsSegmentIconType {
    var titleFontTextStyle: UIFont.TextStyle {
        switch self {
        case .image:
                .footnote
        case .text:
                .caption2
        }
    }
}

//
//  EmptyIconWithTextView.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/01/25.
//

import AndpadUIComponent
import SnapKit
import UIKit

// Note: いずれ AndpadUIComponent に移行したい

/// ブランク画面
final class EmptyIconWithTextView: UIView {
    private let iconView = {
        let icon = UIImageView()
        icon.tintColor = .tsukuri.reference.gray20
        return icon
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .tsukuri.system.secondaryTextOnSurface1
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    // MARK: - Initializers

    init(icon: UIImage?, text: String?) {
        super.init(frame: .null)

        self.iconView.image = icon
        self.textLabel.text = text
        setUpViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }

    private func setUpViews() {
        backgroundColor = .tsukuri.system.surface1()

        addSubview(iconView)
        addSubview(textLabel)

        // Layout
        textLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.center.equalToSuperview()
        }
        iconView.snp.makeConstraints { make in
            make.size.equalTo(104)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(textLabel.snp.top).offset(-16)
        }
    }
}

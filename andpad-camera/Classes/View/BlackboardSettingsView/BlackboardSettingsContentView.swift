//
//  BlackboardSettingsContentView.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/04/17.
//

import UIKit
import SnapKit

final class BlackboardSettingsContentView: UIView {
    private let dataSource: BlackboardSettingsDataSource
    private let outputs: BlackboardSettingsView.OutputHandlers

    private lazy var sectionViews: [BlackboardSettingsSectionView] = dataSource.sections.map {
        BlackboardSettingsSectionView(
            configuration: $0,
            contentView: .init(
                contentView: .init(
                    configurations: $0.segments
                ) { [weak self] config in
                    self?.handleSegmentTap(config)
                }
            )
        )
    }

    init(
        dataSource: BlackboardSettingsDataSource,
        outputs: BlackboardSettingsView.OutputHandlers
    ) {
        self.dataSource = dataSource
        self.outputs = outputs
        super.init(frame: .zero)
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BlackboardSettingsContentView {
    func setUpViews() {
        let sectionAndFooterViews = Array(sectionViews.map({ [$0, $0.footerView].compactMap { $0 } }).joined())
        let stackView = UIStackView(arrangedSubviews: sectionAndFooterViews)
        stackView.axis = .vertical
        stackView.spacing = 4
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
        }
        makeFirstColumnLayoutConstraint(to: sectionViews)
        sectionViews.forEach {
            $0.footerView?.makeLayoutConstraintToSectionContent($0)
        }
    }

    func makeFirstColumnLayoutConstraint(to rows: [BlackboardSettingsSectionView]) {
        var rows = rows
        let firstRow = rows.removeFirst()
        rows.forEach {
            $0.titleLabel.snp.makeConstraints {
                $0.width.equalTo(firstRow.titleLabel)
            }
        }
    }

    func handleSegmentTap(_ configuration: BlackboardSettingsSegmentConfiguration) {
        update(with: configuration)
        outputValue(of: configuration)
    }

    func update(with configuration: BlackboardSettingsSegmentConfiguration) {
        dataSource.update(with: configuration)
        updateSectionViews(with: dataSource.sections)
    }

    func updateSectionViews(with configurations: [BlackboardSettingsSectionConfiguration]) {
        sectionViews.forEach { section in
            guard let config = configurations.configuration(for: section) else { return }
            section.update(with: config)
        }
    }

    func outputValue(of configuration: BlackboardSettingsSegmentConfiguration) {
        outputs.handle(configuration)
    }
}

private extension Array where Element == BlackboardSettingsSectionConfiguration {
    func configuration(for sectionView: BlackboardSettingsSectionView) -> BlackboardSettingsSectionConfiguration? {
        first(where: { $0.id == sectionView.configurationID })
    }
}

//
//  BlackboardFilterConditionsTableSectionHeaderView.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2023/08/22.
//

import AndpadUIComponent
import Instantiate

// MARK: - BlackboardFilterConditionsTableSectionHeaderView

/// 黒板の絞り込み画面のテーブルビューのセクションヘッダービュー
final class BlackboardFilterConditionsTableSectionHeaderView: UITableViewHeaderFooterView {
    struct Dependency {
        let title: String?
    }

    let titleLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpViews() {
        // NOTE: 既存画面の色を Tsukuri カラーに置き換えるタイミングを調整すること
//        backgroundColor = .tsukuri.system.background()
        backgroundColor = .hexStr("#F6F6F6", alpha: 1)

        titleLabel.numberOfLines = 0
        titleLabel.textColor = .tsukuri.system.primaryTextOnBackground
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)

        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 24, left: 16, bottom: 8, right: 16))
        }
    }

    private func configure(title: String?) {
        titleLabel.text = title
    }
}

// MARK: Reusable

extension BlackboardFilterConditionsTableSectionHeaderView: Reusable {
    func inject(_ dependency: Dependency) {
        configure(title: dependency.title)
    }
}

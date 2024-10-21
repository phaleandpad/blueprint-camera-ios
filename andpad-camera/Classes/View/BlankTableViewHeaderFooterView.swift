//
//  BlankTableViewHeaderFooterView.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/01/25.
//

import Foundation
import Instantiate
import InstantiateStandard
import SnapKit
import UIKit

// MARK: - BlankTableViewHeaderFooterView

/// ブランク画面（テーブルビューのヘッダーまたはフッターに使用できる）
public final class BlankTableViewHeaderFooterView: UITableViewHeaderFooterView {
    public struct Dependency {
        let icon: UIImage?
        let text: String?
        let height: CGFloat

        public init(icon: UIImage?, text: String?, height: CGFloat) {
            self.icon = icon
            self.text = text
            self.height = height
        }
    }

    private func setUpViews(icon: UIImage?, text: String?, height: CGFloat) {
        let emptyView = EmptyIconWithTextView(icon: icon, text: text)

        contentView.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(height)
        }
    }
}

// MARK: Reusable

extension BlankTableViewHeaderFooterView: Reusable {
    public func inject(_ dependency: Dependency) {
        setUpViews(
            icon: dependency.icon,
            text: dependency.text,
            height: dependency.height
        )
    }
}

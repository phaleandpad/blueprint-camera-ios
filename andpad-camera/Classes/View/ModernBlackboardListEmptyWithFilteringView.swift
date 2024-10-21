//
//  ModernBlackboardListEmptyWithFilteringView.swift
//  andpad
//
//  Created by msano on 2021/04/26.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import UIKit
import Instantiate
import InstantiateStandard

public final class ModernBlackboardListEmptyWithFilteringView: UITableViewHeaderFooterView {
    public struct Dependency {
        public init() {}
    }
    
    public static let viewHeight: CGFloat = 50.0
    
    // IBOutlet
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private func configureView() {
        backgroundColor = .clear

        let noMatchMessage = L10n.Blackboard.List.noMatchMessage
        let attributedString = NSMutableAttributedString()
        attributedString.append(
            NSAttributedString(
                string: noMatchMessage,
                attributes: nil
            )
        )
        descriptionLabel.attributedText = attributedString
    }
}

// MARK: - NibType
extension ModernBlackboardListEmptyWithFilteringView: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension ModernBlackboardListEmptyWithFilteringView: Reusable {
    public func inject(_ dependency: Dependency) {
        configureView()
    }
}

//
//  BlackboardFilterNoMatchView.swift
//  andpad-camera
//
//  Created by msano on 2022/01/13.
//

import Instantiate
import InstantiateStandard

final class BlackboardFilterNoMatchView: UIView {
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    struct Dependency {
        let tappedHandler: (() -> Void)
    }
    
    private var _tappedHandler: (() -> Void) = {}
    
    var tappedHandler: (() -> Void) {
        _tappedHandler
    }

    @IBAction private func tapped(_ sender: Any) {
        tappedHandler()
    }
}

// MARK: - private
extension BlackboardFilterNoMatchView {
    private func configure() {
        self.backgroundColor = .clear

        let noMatchMessage = L10n.Blackboard.Filter.noMatchMessage
        let retryMessage = L10n.Blackboard.Filter.reSearch

        let attributedString = NSMutableAttributedString()
        attributedString.append(
            NSAttributedString(
                string: noMatchMessage,
                attributes: nil
            )
        )
        attributedString.append(
            NSAttributedString(
                string: retryMessage,
                attributes: [.foregroundColor: UIColor.linkColor]
            )
        )
        descriptionLabel.attributedText = attributedString
    }
}

// MARK: - NibType
extension BlackboardFilterNoMatchView: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension BlackboardFilterNoMatchView: NibInstantiatable {
    func inject(_ dependency: Dependency) {
        _tappedHandler = dependency.tappedHandler
        configure()
    }
}

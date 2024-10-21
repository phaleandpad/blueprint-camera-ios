//
//  BlackboardTemplateCell.swift
//  andpad-camera
//
//  Created by Michitoshi.Tabata on 2020/04/16.
//

import UIKit

final class BlackboardTemplateCell: UITableViewCell {
    @IBOutlet weak var templateImage: UIImageView!
    @IBOutlet weak var buttonView: UIButton!

    private var observer: (() -> Void)?

    // life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        self.templateImage.image = nil
        self.observer = nil
    }
}

// MARK: - button action
extension BlackboardTemplateCell {
    @objc func buttonTapped(sender: UIButton) {
        observer?()
    }

    func addObserver(observer: @escaping () -> Void) {
        self.observer = observer
    }
}

extension BlackboardTemplateCell {
    func configure(isHiddenButtonView: Bool) {
        buttonView.isHidden = isHiddenButtonView
        guard !buttonView.isHidden else { return }
        buttonView.addTarget(
            self,
            action: #selector(self.buttonTapped),
            for: UIControl.Event.touchUpInside
        )

        setAccessibilityIdentifiers()
    }

    private func setAccessibilityIdentifiers() {
        viewAccessibilityIdentifier = .editLegacyBlackboardViewTemplateListCell
        buttonView.viewAccessibilityIdentifier = .editLegacyBlackboardViewTemplateListButton
    }
}

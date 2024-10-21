//
//  BlackboardAlphaCell.swift
//  andpad-camera
//
//  Created by Michitoshi.Tabata on 2020/04/16.
//

import UIKit

final class BlackboardAlphaCell: UITableViewCell {
    private struct AlphaTitleSet {
        var title: String
        var value: CGFloat
    }

    private let segmentControlMembers = [
        AlphaTitleSet(title: "透過なし", value: 1.0),
        AlphaTitleSet(title: "半透過", value: 0.5),
        AlphaTitleSet(title: "透明", value: 0.0)
    ]

    @IBOutlet weak var alphaSegmentedControl: UISegmentedControl! {
        didSet {
            let alphaSegmentedControlTitles = segmentControlMembers.map { $0.title }
            zip(alphaSegmentedControlTitles.indices, alphaSegmentedControlTitles).forEach {
                alphaSegmentedControl.setTitle($0.1, forSegmentAt: $0.0)
            }
        }
    }

    private var observer: ((_ value: CGFloat) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        alphaSegmentedControl.addTarget(self, action: #selector(BlackboardAlphaCell.segmentControlChanged), for: UIControl.Event.valueChanged)

        setAccessibilityIdentifiers()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        observer = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setAlpha(alpha: CGFloat?) {
        if let index = (segmentControlMembers.map { $0.value }.firstIndex(of: alpha)) {
            alphaSegmentedControl.selectedSegmentIndex = index
        }
    }

    func setItem(item: BlackboardItem, value: Any?) {
        switch item.type {
        case .alpha:
            setAlpha(alpha: value as? CGFloat)
        case .date, .theme, .textField, .textArea, .memoStyle:
            fatalError()
        case .none:
            fatalError()
        }
    }

    func setItem(value: CGFloat, type: BlackboardItemType) {
        switch type {
        case .alpha:
            setAlpha(alpha: value as? CGFloat)
        case .date, .theme, .textField, .textArea, .memoStyle:
            fatalError()
        }
    }

    @objc func segmentControlChanged(sender: UISegmentedControl) {
        observer?(segmentControlMembers[sender.selectedSegmentIndex].value)
    }

    func addObserver(observer: @escaping (_ value: CGFloat) -> Void) {
        self.observer = observer
    }

    private func setAccessibilityIdentifiers() {
        alphaSegmentedControl.viewAccessibilityIdentifier = .editLegacyBlackboardAlphaSegmentedControl
    }
}

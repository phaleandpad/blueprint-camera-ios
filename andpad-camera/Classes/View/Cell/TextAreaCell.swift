//
//  TextAreaCell.swift
//  andpad-camera
//
//  Created by Michitoshi.Tabata on 2020/04/16.
//

import UIKit

final class TextAreaCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textArea: UITextView!
    private var observer: ((_ value: String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        textArea.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        observer = nil
    }

    func setItem(item: BlackboardItem, value: Any?) {
        switch item.type {
        case .textArea:
            label.text = item.name
            textArea.text = (value as? String) ?? ""
        case .date, .alpha, .theme, .textField, .memoStyle:
            fatalError()
        case .none:
            fatalError()
        }
    }

    @objc func textFieldChanged(sender: UITextField) {
        observer?(sender.text)
    }

    func addObserver(observer: @escaping (_ value: String?) -> Void) {
        self.observer = observer
    }
}

extension TextAreaCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        observer?(textView.text)
    }
}

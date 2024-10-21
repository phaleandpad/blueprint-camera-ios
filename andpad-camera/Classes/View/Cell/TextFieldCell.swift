//
//  TextFieldCell.swift
//  andpad-camera
//
//  Created by Michitoshi.Tabata on 2020/04/16.
//

import UIKit

final class TextFieldCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!

    private var datePicker: UIDatePicker?
    private var observer: ((_ value: String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textField.inputView = nil
        textField.inputAccessoryView = nil
        textField?.removeTarget(nil, action: nil, for: UIControl.Event.allEvents)
        datePicker?.removeTarget(nil, action: nil, for: UIControl.Event.allEvents)
        observer = nil
    }

    func setItem(item: BlackboardItem, value: Any?) {
        switch item.type {
        case .textField:
            label.text = item.name
            textField.text = value as? String
            textField.addTarget(self, action: #selector(Self.textFieldChanged), for: UIControl.Event.editingChanged)
            viewAccessibilityIdentifier = .editLegacyBlackboardViewTextFieldCell
        case .date:
            label.text = item.name
            textField.text = (value as? String) ?? Date().asDateString()
            textField.addTarget(self, action: #selector(Self.textFieldChanged), for: UIControl.Event.editingChanged)
            textField.addTarget(self, action: #selector(Self.textFieldEditing), for: UIControl.Event.editingDidBegin)
            viewAccessibilityIdentifier = .editLegacyBlackboardViewDatePickerCell
        case .alpha, .theme, .textArea, .memoStyle:
            fatalError()
        case .none:
            fatalError()
        }
    }

    @objc func textFieldEditing(sender: UITextField) {
        datePicker = UIDatePicker()
        datePicker?.viewAccessibilityIdentifier = .editLegacyBlackboardViewDatePicker

        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        }

        datePicker?.datePickerMode = .date
        datePicker?.date = textField.text?.asDate() ?? Date()
        datePicker?.addTarget(self, action: #selector(Self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        sender.inputView = datePicker

        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(Self.datePickerDone))
        toolBar.items = [spacer, doneButton]
        sender.inputAccessoryView = toolBar
    }

    @objc func textFieldChanged(sender: UITextField) {
        observer?(sender.text)
    }

    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        textField.text = dateFormatter.string(from: sender.date)
        observer?(textField.text)
    }

    @objc func datePickerDone() {
        textField.endEditing(true)
    }

    func addObserver(observer: @escaping (_ value: String?) -> Void) {
        self.observer = observer
    }
}

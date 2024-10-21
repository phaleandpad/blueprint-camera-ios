//
//  UIDatePicker+Configuration.swift
//  andpad-camera
//
//  Created by msano on 2022/06/27.
//

extension UIDatePicker {
    func setMinimumDate(year: Int, month: Int, day: Int) {
        let calender = Calendar(identifier: .gregorian)
        minimumDate = calender.date(from: .init(year: year, month: month, day: day))
    }
}

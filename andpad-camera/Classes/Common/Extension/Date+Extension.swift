//
//  Date+Extension.swift
//  andpad-camera
//
//  Created by daisuke on 2018/05/25.
//

extension Date {
    func asDateString(
        formatString: String = "yyyy/MM/dd",
        locale: Locale = Locale(identifier: "en_US_POSIX"),
        calenderIdentifier: Calendar.Identifier = .gregorian
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.timeZone = .init(identifier: "JST")
        dateFormatter.calendar = .init(identifier: calenderIdentifier)
        dateFormatter.dateFormat = formatString
        return dateFormatter.string(from: self)
    }

    func asOriginalDateNameString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}

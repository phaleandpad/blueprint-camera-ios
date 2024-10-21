//
//  String+Extension.swift
//  andpad-camera
//
//  Created by Michitoshi.Tabata on 2020/04/17.
//

import Foundation

extension String {

    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }

    //    文字列から数値のみを取り出すメソッド
    func getNumberFromString() -> String {
        let numberChars = NSCharacterSet(charactersIn: "0123456789.")
        let splitNumbers = (self.components(separatedBy: numberChars.inverted))
        var number = splitNumbers.joined()

        // "."が複数ある時、先頭の"."以外は除去
        if let firstDotIndex = number.firstIndex(of: ".") {
            number = number.replacingOccurrences(
                of: ".",
                with: "",
                options: .literal,
                range: (number.index(after: firstDotIndex)..<number.endIndex)
            )
        }

        return number
    }

    func asDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "JST")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.date(from: self)
    }

    func asDateFromDateString() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "JST")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.date(from: self)
    }

    func asDateTimeDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.date(from: self)
    }

    func asUTCDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "JST")
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.date(from: self)
    }

    func asISODate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'+09:00'"
        return dateFormatter.date(from: self)
    }
    
    func asISOWithMillisecondDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss':'sss'+09:00'"
        return dateFormatter.date(from: self)
    }

    func asYYYYMMDDDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "JST")
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' Z"
        return dateFormatter.date(from: self)
    }

    // 電話番号チェック
    var isPhoneNumber: Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[-0-9]+").evaluate(with: self)
    }

    //        最後の文字列を削除するメソッド
    func deleteLastChar() -> String {
        //        空文字の場合には処理を行わない
        guard !isEmpty else { return self }
        return String(self.prefix(self.count - 1))
    }

    /// JSON配列の文字列をswiftの文字列配列に置き換える。
    /// e.g. "[\"test\",\"testtest\"]" -> ["test", "testtest"]
    ///
    /// - Returns JSON配列の文字列をswiftの文字列配列に置き換えたもの。形式不正の場合は、自身を文字列配列として返す。
    func arrayStringToArray() -> [String] {
        if self.isEmpty {
            return []
        } else if let json = try? JSONSerialization.jsonObject(with: self.data(using: .utf8)!),
                  let array = (json as? [String]) {
            return array
        } else {
            return [self]
        }
    }

    // 最後の2文字の除いて`*`で文字を隠す
    func hideExecptLastTwo() -> String {
        let keepCount = 2
        guard count > keepCount else { return self }
        var result = String(repeating: "*", count: count - keepCount)
        result.append(contentsOf: suffix(keepCount))
        return result
    }

    func width(by font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: attributes)
        return size.width
    }

    func asAttributed() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    func calcTextHeight(font: UIFont, width: CGFloat) -> CGFloat {
        (self as NSString)
            .boundingRect(
                with: CGSize(width: width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font],
                context: nil
            )
            .height
    }

    /// 文字列の中の改行("\n")の個数をカウントする
    /// - returns: 改行の個数
    var numberOfNewLines: Int {
        var count = 0
        var nextRange = self.startIndex..<self.endIndex
        while let range = self.range(of: "\n", options: .caseInsensitive, range: nextRange) {
            count += 1
            nextRange = range.upperBound..<self.endIndex
        }
        return count
    }

    /// 文字列の行数をカウントする
    /// - returns: 行数
    /// - note: このメソッドは文字列の改行の個数をカウントすることで行数を算出している
    /// - note: 空文字は0を返す
    var numberOfLines: Int {
        guard !self.isEmpty else { return 0 }
        return numberOfNewLines + 1   // 行数は改行の個数 + 1
    }
}

extension Optional where Wrapped == String {
    func unwrapped() -> String {
        return self ?? ""
    }
}

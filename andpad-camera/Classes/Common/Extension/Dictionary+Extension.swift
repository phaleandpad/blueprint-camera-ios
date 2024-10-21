//
//  Dictionary+Extension.swift
//  andpad-camera
//
//  Created by msano on 2020/11/04.
//

extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { key, value -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = "\(value)".stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        return parameterArray.joined(separator: "&")
    }
}

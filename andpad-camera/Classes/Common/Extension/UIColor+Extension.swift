//
//  UIColor+Extension.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/25.
//

// MARK: - Andpad Color Set
extension UIColor {
    static let focus: UIColor = .hexStr("#F4D528", alpha: 1.0)
    static let andpadRed: UIColor = .hexStr("#FF5959", alpha: 1.0)
    static let whiteFAFA: UIColor = .hexStr("#FAFAFA", alpha: 1.0)
    static let grayBBB: UIColor = .hexStr("#BBBBBB", alpha: 1.0)
    static let grayDDD: UIColor = .hexStr("#DDDDDD", alpha: 1.0)
    static let gray999: UIColor = .hexStr("#999999", alpha: 1.0)
    static let gray444: UIColor = .hexStr("#444444", alpha: 1.0)
    static let grayEEE: UIColor = .hexStr("#EEEEEE", alpha: 1.0)
    static let gray222: UIColor = .hexStr("#222222", alpha: 1.0)
    static let gray888: UIColor = .hexStr("#888888", alpha: 1.0)
    static let gray7C: UIColor = .hexStr("#7C7C7C", alpha: 1.0)
    static let grayB6B: UIColor = .hexStr("#B6B6B6", alpha: 1.0)
    static let grayC5C6C8: UIColor = .hexStr("#C5C6C8", alpha: 1)
    static let orangeFEA: UIColor = .hexStr("#FEA800", alpha: 1.0)
    static let redEF3: UIColor = .hexStr("#EF3340", alpha: 1.0)
    static let textColor: UIColor = .hexStr("#222222", alpha: 1.0)
    static let lightTextColor: UIColor = .hexStr("#888888", alpha: 1.0)
    static let linkColor: UIColor = .hexStr("#007DFF", alpha: 1.0)
    static let modernBlackboardBackgroundGreenColor: UIColor = .hexStr("#026302", alpha: 1.0)
}

// MARK: - base logic
extension UIColor {
    class func hexStr (_ hex: NSString, alpha: CGFloat) -> UIColor {
        let hexStr = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return UIColor.white
        }
    }

    func createImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setFillColor(self.cgColor)
        contextRef?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

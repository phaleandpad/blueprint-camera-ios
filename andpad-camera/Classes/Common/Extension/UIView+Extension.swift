//
//  UIView+Extension.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/24.
//

import Foundation

extension UIView {
    enum ImageConvertError: Error {
        case invaliedViewSize
    }

    /** 画像処理用 */
    func toImage() throws -> UIImage {
        guard bounds.width > 0, bounds.height > 0 else {
            throw ImageConvertError.invaliedViewSize
        }

        self.subviews.forEach {
            if $0.tag == 300 {
                $0.isHidden = true
            }
        }

        return UIGraphicsImageRenderer(size: self.bounds.size).image { [weak self] context in
            self?.subviews.forEach {
                if $0.tag == 300 {
                    $0.isHidden = false
                }
            }
            self?.layer.render(in: context.cgContext)
        }
    }

    @IBInspectable var bottomBorderStyleChange: Bool {
        get {
            return self.bottomBorderStyleChange
        }
        set(newValue) {
            if newValue {
                setBottomBorder()
            }
        }
    }

    func setBottomBorder() {
        let bottomLine = CALayer()
        bottomLine.backgroundColor = UIColor.grayDDD.cgColor
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.size.height - 1.0, width: self.frame.size.width, height: 1.0)
        self.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }

        self.layer.addSublayer(bottomLine)
    }

    func setHighlightedBottomBorder() {
        if #available(iOS 15.0, *) {
            // TODO: iOS15だとcrashしてしまうことがわかったので直すこと
        } else {
            let bottomLine = CALayer()
            bottomLine.backgroundColor = UIColor.andpadRed.cgColor
            bottomLine.frame = CGRect(x: 0.0, y: self.frame.size.height - 1.0, width: self.frame.size.width, height: 1.0)
            self.layer.sublayers?.forEach {
                $0.removeFromSuperlayer()
            }
            self.layer.addSublayer(bottomLine)
        }
    }

    func rotateWhenDeviceOrientationIsLandscape(orientation: UIDeviceOrientation) {
        let rate = frame.size.width / frame.size.height

        let originalFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        let rotatedFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.height, height: frame.size.width)

        switch orientation {
        case .portrait,
             .portraitUpsideDown:
            if rate > 1.0 {
                frame = originalFrame
            } else {
                frame = rotatedFrame
            }
        case .landscapeRight,
             .landscapeLeft:
            if rate > 1.0 {
                frame = rotatedFrame
            } else {
                frame = originalFrame
            }
        default:
            if rate > 1.0 {
                frame = originalFrame
            } else {
                frame = rotatedFrame
            }
        }
    }

    func rotateAnimation(angle: Double) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.2
        animation.toValue = angle
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: nil)
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.cornerRadius
        }
        set(newValue) {
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }

    @IBInspectable var circleStyle: Bool {
        get {
            return self.circleStyle
        }
        set(newValue) {
            if newValue {
                self.layer.cornerRadius = self.frame.size.width / 2.0
                self.clipsToBounds = true
            }
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }

    func anchorAll(equalTo: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: equalTo.topAnchor, constant: 0).isActive = true
        leftAnchor.constraint(equalTo: equalTo.leftAnchor, constant: 0).isActive = true
        bottomAnchor.constraint(equalTo: equalTo.bottomAnchor, constant: 0).isActive = true
        rightAnchor.constraint(equalTo: equalTo.rightAnchor, constant: 0).isActive = true
    }
}

// MARK: - recursive logic
extension UIView {
    // 再帰的に対象のUIViewに属するsubviewsを全て取得する
    // ref: https://qiita.com/shtnkgm/items/fac2756599b3dfcb7aa2
    var recursiveSubviews: [UIView] {
        return subviews + subviews.flatMap { $0.recursiveSubviews }
    }
}

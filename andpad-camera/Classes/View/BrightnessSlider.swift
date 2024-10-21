//
//
//  BrightnessSlider.swift
//  Pods
//
//  Created by Yosuke Nakamura on 2021/05/10.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//
//

import RxCocoa
import UIKit

final class BrightnessSlider: UISlider {

    private let minTrackView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .focus
        view.layer.opacity = 0
        return view
    }()

    private let maxTrackView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .focus
        view.layer.opacity = 0
        return view
    }()

    init(frame: CGRect, orientation: UIDeviceOrientation) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        transform = CGAffineTransform(rotationAngle: rotationAngle(orientation))
        let image = UIImage(
            named: "icon_focus",
            in: .andpadCamera,
            compatibleWith: nil
        )
        setThumbImage(image, for: .normal)
        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        addSubview(minTrackView)
        addSubview(maxTrackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let trackHeight: CGFloat = 0.5
        let space: CGFloat = 3
        let rect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)

        let originY = (bounds.height - trackHeight) / 2.0
        minTrackView.frame = CGRect(
            x: 0,
            y: originY,
            width: rect.minX - space,
            height: trackHeight
        )
        maxTrackView.frame = CGRect(
            x: rect.maxX + space,
            y: originY,
            width: bounds.width - rect.maxX - space,
            height: trackHeight
        )
        return rect
    }

    func showTrackView() {
        minTrackView.layer.removeAllAnimations()
        maxTrackView.layer.removeAllAnimations()

        minTrackView.layer.opacity = 1
        maxTrackView.layer.opacity = 1
    }

    func hideTrackView(withAnimation: Bool = false) {
        guard minTrackView.layer.opacity != 0 else {
            return
        }

        if !withAnimation {
            minTrackView.layer.opacity = 0
            maxTrackView.layer.opacity = 0
            return
        }

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.5
        animation.fromValue = 1.0
        animation.toValue = 0
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        minTrackView.layer.add(animation, forKey: nil)
        maxTrackView.layer.add(animation, forKey: nil)
    }

    private func rotationAngle(_ orientation: UIDeviceOrientation) -> CGFloat {
        switch orientation {
        case .portrait:
            return CGFloat(Double.pi / 2 * -1)
        case .portraitUpsideDown:
            return CGFloat(Double.pi / 2)
        case .landscapeLeft:
            return 0
        case .landscapeRight:
            return CGFloat(Double.pi)
        default:
            assertionFailure("unexpected orientation")
            return CGFloat(Double.pi / 2 * -1)
        }
    }
}

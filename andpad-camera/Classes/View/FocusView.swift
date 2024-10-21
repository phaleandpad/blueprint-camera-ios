//
//
//  FocusView.swift
//  Pods
//
//  Created by Yosuke Nakamura on 2021/05/11.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//
//

import RxCocoa
import UIKit

final class FocusView: UIView {

    let sliderValue: BehaviorRelay<Float> = .init(value: 0.5)

    private var brightnessSlider: BrightnessSlider?

    private var hideTimer: Timer?

    private var lastPoint: CGPoint = .zero

    private let viewEdgeLength: CGFloat = 400

    private let borderViewEdgeLength: CGFloat = 80

    private let sliderWidth: CGFloat = 150

    private let sliderHeight: CGFloat = 30

    private let animationKeyShow = "animationKeyShow"

    private let animationKeyHide = "animationKeyHide"

    private (set) var deviceOrientation: UIDeviceOrientation = .portrait

    private var parentViewFrame: CGRect = .zero

    private enum SliderPosition {
        case top, bottom, left, right
    }

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: viewEdgeLength, height: viewEdgeLength))
        backgroundColor = UIColor.white.withAlphaComponent(0)

        let frameView = UIView(frame: CGRect(x: 0, y: 0, width: borderViewEdgeLength, height: borderViewEdgeLength))
        frameView.backgroundColor = UIColor.white.withAlphaComponent(0)
        frameView.center = CGPoint(x: viewEdgeLength / 2, y: viewEdgeLength / 2)
        frameView.layer.borderColor = UIColor.focus.cgColor
        frameView.layer.borderWidth = 1

        addSubview(frameView)

        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(FocusView.panAction)
        )
        addGestureRecognizer(pan)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(
        center: CGPoint,
        parentViewFrame: CGRect,
        orientation: UIDeviceOrientation,
        didTap: Bool = false
    ) {
        deviceOrientation = orientation
        self.parentViewFrame = parentViewFrame
        self.center = center
        let lastValue = brightnessSlider?.value
        self.brightnessSlider?.removeFromSuperview()

        let brightnessSlider = BrightnessSlider(
            frame: sliderRect(orientation: orientation),
            orientation: orientation
        )
        if didTap {
            brightnessSlider.setValue(0.5, animated: false)
        } else if let value = lastValue {
            brightnessSlider.setValue(value, animated: false)
        }

        addSubview(brightnessSlider)

        hideTimer?.invalidate()

        layer.removeAnimation(forKey: animationKeyShow)
        layer.removeAnimation(forKey: animationKeyHide)

        brightnessSlider.hideTrackView()
        self.brightnessSlider = brightnessSlider

        CATransaction.begin()

        CATransaction.setCompletionBlock {
            self.setHideTimer(timeInterval: 3.5)
        }

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.5
        animationGroup.isRemovedOnCompletion = false

        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 1.5
        scaleDown.toValue = 1.0

        let appear = CABasicAnimation(keyPath: "opacity")
        appear.fromValue = 0.0
        appear.toValue = 1.0

        animationGroup.animations = [scaleDown, appear]
        layer.add(animationGroup, forKey: animationKeyShow)

        CATransaction.commit()
    }

    func setHideTimer(timeInterval: TimeInterval) {
        self.hideTimer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(FocusView.hide),
            userInfo: nil,
            repeats: false
        )
    }

    @objc func hide() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.5
        animation.fromValue = 1.0
        animation.toValue = 0.3
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: animationKeyHide)
        brightnessSlider?.hideTrackView(withAnimation: true)
    }

    func lockAnimation() {
        let scaleDown1 = CABasicAnimation(keyPath: "transform.scale")
        scaleDown1.fromValue = 1.5
        scaleDown1.toValue = 1.0
        scaleDown1.beginTime = 0
        scaleDown1.duration = 0.25

        let scaleDown2 = CABasicAnimation(keyPath: "transform.scale")
        scaleDown2.fromValue = 1.5
        scaleDown2.toValue = 1.0
        scaleDown2.beginTime = 0.25
        scaleDown2.duration = 0.25

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.5
        animationGroup.isRemovedOnCompletion = false
        animationGroup.animations = [scaleDown1, scaleDown2]
        layer.add(animationGroup, forKey: nil)
    }

    // MARK: - private
    @objc private func panAction(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.translation(in: self)

        switch recognizer.state {
        case .began:
            lastPoint = point
            brightnessSlider?.showTrackView()

            hideTimer?.invalidate()
            layer.removeAllAnimations()
            layer.opacity = 1
        case .changed:
            moveSlider(point)
        case .ended:
            moveSlider(point)
            setHideTimer(timeInterval: 1.5)
        default:
            // do nothing
            break
        }
    }

    private func moveSlider(_ point: CGPoint) {
        guard let brightnessSlider else { return }
        let move = calculateMove(point)
        // 光量を微調整できるよう、標準カメラに合わせてスライダーの移動量を調整している。
        brightnessSlider.value += Float(move / 1500.0)
        sliderValue.accept(brightnessSlider.value)
        lastPoint = point
    }

    private func sliderRect(orientation: UIDeviceOrientation) -> CGRect {
        let originXForCenter: CGFloat = (viewEdgeLength - sliderWidth) / 2
        let originYForCenter: CGFloat = (viewEdgeLength - sliderHeight) / 2
        let margin: CGFloat = 3

        switch toSliderPosition(from: orientation) {
        case .right:
            // スライダー縦回転させた状態でのxをまず計算する
            let x = viewEdgeLength / 2 + borderViewEdgeLength / 2 + margin
            // 縦回転させる前のxを計算する（スライダーのcenterXは回転前と同じ）
            let originXBeforeRotation = x + (sliderHeight / 2) - (sliderWidth / 2)
            return CGRect(x: originXBeforeRotation, y: originYForCenter, width: sliderWidth, height: sliderHeight)
        case .left:
            // スライダー縦回転させた状態でのxをまず計算する
            let x = viewEdgeLength / 2 - borderViewEdgeLength / 2 - margin - sliderHeight
            // 縦回転させる前のxを計算する（スライダーのcenterXは回転前と同じ）
            let originXBeforeRotation = x + (sliderHeight / 2) - (sliderWidth / 2)
            return CGRect(x: originXBeforeRotation, y: originYForCenter, width: sliderWidth, height: sliderHeight)
        case .top:
            let y = viewEdgeLength / 2 - borderViewEdgeLength / 2 - sliderHeight - margin
            return CGRect(x: originXForCenter, y: y, width: sliderWidth, height: sliderHeight)
        case .bottom:
            let y = viewEdgeLength / 2 + borderViewEdgeLength / 2 + margin
            return CGRect(x: originXForCenter, y: y, width: sliderWidth, height: sliderHeight)
        }
    }

    private func toSliderPosition(from orientation: UIDeviceOrientation) -> SliderPosition {
        let fromCenterToEdge = (borderViewEdgeLength / 2.0) + sliderHeight

        switch orientation {
        case .portrait:
            // スライダーがビューからはみ出そうなときは反対側にスライダーを表示する
            let edge = parentViewFrame.minX + parentViewFrame.width
            return fromCenterToEdge < (edge - center.x) ? .right : .left
        case .portraitUpsideDown:
            let edge = parentViewFrame.minX
            return fromCenterToEdge < (center.x - edge) ? .left : .right
        case .landscapeLeft:
            let edge = parentViewFrame.minY + parentViewFrame.height
            return fromCenterToEdge < (edge - center.y) ? .bottom : .top
        case .landscapeRight:
            let edge = parentViewFrame.minY
            return fromCenterToEdge < (center.y - edge) ? .top : .bottom
        default:
            assertionFailure("unexpected orientation")
            return .right
        }
    }

    private func calculateMove(_ point: CGPoint) -> CGFloat {
        switch deviceOrientation {
        case .portrait:
            return lastPoint.y - point.y
        case .portraitUpsideDown:
            return (lastPoint.y - point.y) * -1
        case .landscapeRight:
            return lastPoint.x - point.x
        case .landscapeLeft:
            return (lastPoint.x - point.x) * -1
        default:
            assertionFailure("unexpected orientation")
            return lastPoint.y - point.y
        }
    }
}

//
//  BlackboardSettingsView.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/04/17.
//

import UIKit
import SnapKit
import AndpadUIComponent
import AndpadCore

final class BlackboardSettingsView: UIView {
    struct OutputHandlers {
        let blackboardVisibilityDidChangeHandler: (Bool) -> Void
        let rotationLockDidChangeHandler: (Bool) -> Void
        let sizeTypeDidChangeHandler: (ModernBlackboardAppearance.ModernBlackboardSizeType) -> Void
        let photoQualityDidChangeHandler: (PhotoQuality) -> Void
        let photoFormatDidChangeHandler: (ModernBlackboardCommonSetting.PhotoFormat) -> Void
    }

    private lazy var sheetView = BlackboardSettingsSheetView(
        title: L10n.Camera.BlackboardSettings.title,
        contentView: .init(dataSource: settingsDataSource, outputs: outputs)
    ) { [weak self] in
        guard let self else { return }
        dismiss(completion: dismissCompletion)
    }

    private let sheetBackgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .tsukuri.system.inverseSurface()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.tsukuri.system.inverseBorder.cgColor
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let rotationBaseView: UIView = {
        let view = UIView(frame: .zero)
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    let backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black.withAlphaComponent(0.2)
        view.alpha = .zero
        return view
    }()

    private lazy var presentSheetOnce: Void = {
        rotateSheet(animated: false)
        moveSheet(for: .hide, animated: false)
        rotationBaseView.isHidden = false
        moveSheet(for: .show)
    }()

    private var orientation: UIDeviceOrientation = .portrait
    private var rotateAngle: Double = 0.0
    private var sourceView: UIView?
    private let settingsDataSource: BlackboardSettingsDataSource
    private let outputs: OutputHandlers
    private var dismissCompletion: (() -> Void)?

    init(
        isBlackboardVisible: Bool,
        isRotationLocked: Bool,
        canSelectSize: Bool,
        sizeType: ModernBlackboardAppearance.ModernBlackboardSizeType?,
        sizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType?,
        photoQuality: PhotoQuality?,
        photoQualityOptions: [PhotoQuality],
        photoFormat: ModernBlackboardCommonSetting.PhotoFormat,
        isModernBlackboard: Bool,
        blackboardVisibilityDidChangeHandler: @escaping (Bool) -> Void,
        rotationLockDidChangeHandler: @escaping (Bool) -> Void,
        sizeTypeDidChangeHandler: @escaping (ModernBlackboardAppearance.ModernBlackboardSizeType) -> Void,
        photoQualityDidChangeHandler: @escaping (PhotoQuality) -> Void,
        photoFormatDidChangeHandler: @escaping (ModernBlackboardCommonSetting.PhotoFormat) -> Void
    ) {
        let outputs = OutputHandlers(
            blackboardVisibilityDidChangeHandler: blackboardVisibilityDidChangeHandler,
            rotationLockDidChangeHandler: rotationLockDidChangeHandler,
            sizeTypeDidChangeHandler: sizeTypeDidChangeHandler,
            photoQualityDidChangeHandler: photoQualityDidChangeHandler,
            photoFormatDidChangeHandler: photoFormatDidChangeHandler
        )
        self.settingsDataSource = .init(
            isBlackboardVisible: isBlackboardVisible,
            isRotationLocked: isRotationLocked,
            canSelectSize: canSelectSize,
            selectedSizeType: sizeType,
            sizeTypeOnServer: sizeTypeOnServer,
            selectedPhotoQuality: photoQuality,
            photoQualityOptions: photoQualityOptions,
            photoFormat: photoFormat,
            isModernBlackboard: isModernBlackboard,
            outputValueHandler: { outputs.handle($0) }
        )
        self.outputs = outputs
        super.init(frame: .zero)
        setUpViews()
        setAccessibilityIdentifiers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _ = presentSheetOnce
    }

    func present(
        on presentingView: UIView,
        from sourceView: UIView,
        orientation: UIDeviceOrientation,
        rotateAngle: Double,
        dismissCompletion: (() -> Void)? = nil
    ) {
        self.sourceView = sourceView
        self.orientation = orientation
        self.rotateAngle = rotateAngle
        self.dismissCompletion = dismissCompletion

        presentingView.addSubview(self)
        self.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        remakeRotationBaseViewConstraintsIfPadUserInterfaceIdiom()

        // layoutSubviews() でレイアウト完了後に presentSheetOnce を呼ぶことで delay (e.g. asyncAfter) 等を入れずにシート出現アニメーションが正しく動く
        // また safeAreaInset の値も上記タイミングでは更新されている
    }

    func dismiss(completion: (() -> Void)? = nil) {
        moveSheet(for: .hide) {
            self.removeFromSuperview()
            completion?()
        }
    }

    func rotate(to orientation: UIDeviceOrientation, rotateAngle: Double) {
        guard self.orientation != orientation else { return }
        self.orientation = orientation
        self.rotateAngle = rotateAngle
        rotateSheet()
    }
}

private extension BlackboardSettingsView {
    enum SheetVisibility {
        case show
        case hide
    }

    func setUpViews() {
        setUpBackgroundView()
        setUpRotationBaseViewGestureRecognizerForDismiss()
        rotationBaseView.addSubview(sheetBackgroundView)
        rotationBaseView.addSubview(sheetView)
        addSubview(rotationBaseView)

        sheetView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualTo(safeAreaLayoutGuide)
        }

        sheetBackgroundView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.top.equalTo(sheetView)
        }

        rotationBaseView.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(rotationBaseView.snp.width)
        }
    }

    func setUpBackgroundView() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap)))
    }

    func setUpRotationBaseViewGestureRecognizerForDismiss() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGestureRecognizer.delegate = self
        rotationBaseView.addGestureRecognizer(tapGestureRecognizer)
    }

    func updateBackgroundViewMaskedCorners() {
        let allCorner: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        let topCorner: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        if AppInfoUtil.isiPad {
            sheetBackgroundView.layer.maskedCorners = allCorner
        } else {
            sheetBackgroundView.layer.maskedCorners = orientation != .portraitUpsideDown ? topCorner : allCorner
        }
    }

    func rotateSheet(animated: Bool = true) {
        updateBackgroundViewMaskedCorners()
        remakeSheetViewConstraintsForOrientationChange()
        remakeSheetBackgroundViewConstraintsForOrientationChange()
        remakeSheetViewConstraintsIfPadUserInterfaceIdiom()

        let transform = { [weak self] in
            guard let self else { return }
            rotationBaseView.transform = .init(rotationAngle: rotateAngle)
            layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                transform()
            }
        } else {
            transform()
        }
    }

    func remakeSheetViewConstraintsForOrientationChange() {
        guard !AppInfoUtil.isiPad else { return }
        if isLandscape {
            let leadingInset = orientation == .landscapeRight ? safeAreaInsets.bottom : .zero
            let trailingInset = orientation == .landscapeLeft ? safeAreaInsets.bottom : .zero
            sheetView.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalToSuperview().inset(leadingInset)
                $0.trailing.equalToSuperview().inset(trailingInset)
                $0.bottom.equalToSuperview()
            }
        } else {
            if orientation == .portraitUpsideDown {
                sheetView.snp.remakeConstraints {
                    $0.horizontalEdges.equalToSuperview()
                    $0.top.equalToSuperview().inset(safeAreaInsets.bottom)
                    $0.bottom.lessThanOrEqualToSuperview()
                    $0.height.equalTo(rotationBaseView).priority(.low)
                }
            } else {
                sheetView.snp.remakeConstraints {
                    $0.horizontalEdges.equalToSuperview()
                    $0.top.greaterThanOrEqualToSuperview()
                    $0.bottom.equalTo(safeAreaLayoutGuide)
                    $0.height.equalTo(rotationBaseView).priority(.low)
                }
            }
        }
    }

    func remakeSheetBackgroundViewConstraintsForOrientationChange() {
        guard !AppInfoUtil.isiPad else { return }
        if orientation == .portraitUpsideDown {
            sheetBackgroundView.snp.remakeConstraints {
                $0.horizontalEdges.top.equalToSuperview()
                $0.bottom.equalTo(sheetView)
            }
        } else {
            sheetBackgroundView.snp.remakeConstraints {
                $0.horizontalEdges.bottom.equalToSuperview()
                $0.top.equalTo(sheetView)
            }
        }
    }

    func remakeRotationBaseViewConstraintsIfPadUserInterfaceIdiom() {
        guard let sourceView = sourceView, AppInfoUtil.isiPad else { return }
        rotationBaseView.snp.remakeConstraints {
            $0.trailing.equalTo(sourceView)
            $0.bottom.equalTo(sourceView.snp.top).offset(-16)
            $0.size.equalTo(400)
        }
    }

    func remakeSheetViewConstraintsIfPadUserInterfaceIdiom() {
        guard AppInfoUtil.isiPad else { return }

        switch orientation {
        case .portrait, .landscapeRight:
            sheetBackgroundView.snp.remakeConstraints {
                $0.horizontalEdges.bottom.equalToSuperview()
                $0.top.equalTo(sheetView)
            }
            sheetView.snp.remakeConstraints {
                $0.horizontalEdges.bottom.equalToSuperview()
                $0.top.greaterThanOrEqualToSuperview()
            }

        case .portraitUpsideDown, .landscapeLeft:
            sheetBackgroundView.snp.remakeConstraints {
                $0.horizontalEdges.top.equalToSuperview()
                $0.bottom.equalTo(sheetView)
            }
            sheetView.snp.remakeConstraints {
                $0.horizontalEdges.top.equalToSuperview()
                $0.bottom.lessThanOrEqualToSuperview()
            }

        default:
            break
        }
    }

    func moveSheet(
        for visibility: SheetVisibility,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let transform: () -> Void
        if AppInfoUtil.isiPad {
            transform = { [weak self] in
                guard let self else { return }
                backgroundView.alpha = visibility == .show ? 1.0 : 0.0
                rotationBaseView.alpha = visibility == .show ? 1.0 : 0.0
            }
        } else {
            let sheetHeight = sheetView.frame.height
            let negateAtLandscapeRight = orientation == .landscapeRight ? -1.0 : 1.0
            let negateAtPortraitUpsideDown = orientation == .portraitUpsideDown ? -1.0 : 1.0
            let negateAtShowSheet = visibility == .show ? -1.0 : 1.0
            let negate = negateAtLandscapeRight * negateAtPortraitUpsideDown * negateAtShowSheet
            let x = (isLandscape ? sheetHeight : .zero) * negate
            let y = (isLandscape ? .zero : sheetHeight) * negate

            transform = { [weak self] in
                guard let self else { return }
                backgroundView.alpha = visibility == .show ? 1.0 : 0.0
                let beforeTransform = rotationBaseView.transform
                rotationBaseView.transform = beforeTransform.translatedBy(x: x, y: y)
            }
        }

        if animated {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                transform()
            } completion: { _ in
                completion?()
            }
        } else {
            transform()
            completion?()
        }
    }

    var isLandscape: Bool {
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            true
        case .portrait, .portraitUpsideDown:
            false
        default:
            false
        }
    }

    @objc
    func handleBackgroundTap() {
        dismiss(completion: dismissCompletion)
    }
}

extension BlackboardSettingsView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard rotationBaseView.gestureRecognizers?.contains(gestureRecognizer) ?? false else { return true }
        // rotationBaseView.subviews ではタップを反応させない
        return touch.view == rotationBaseView
    }
}

// MARK: for UI test
private extension BlackboardSettingsView {
    func setAccessibilityIdentifiers() {
        viewAccessibilityIdentifier = .blackboardSettingsView
    }
}

extension BlackboardSettingsView.OutputHandlers {
    func handle(_ configuration: BlackboardSettingsSegmentConfiguration) {
        switch configuration.value {
        case .blackboardVisibility(let value):
            blackboardVisibilityDidChangeHandler(value == .show)
        case .rotationLock(let value):
            rotationLockDidChangeHandler(value == .lock)
        case .sizeType(let value):
            sizeTypeDidChangeHandler(value)
        case .photoQuality(let value):
            photoQualityDidChangeHandler(value)
        case .photoFormat(let value):
            photoFormatDidChangeHandler(value)
        }
    }
}

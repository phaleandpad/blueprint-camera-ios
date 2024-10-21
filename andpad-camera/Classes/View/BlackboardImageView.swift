//
//  BlackboardImageView.swift
//  andpad-camera
//
//  Created by daisuke on 2018/06/04.
//

import UIKit

final class BlackboardImageView: BlackboardBaseView {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private var dragHandles: [BlackboardHandleView]!

    private var defaultImage: UIImage!

    override func awakeFromNib() {
        super.awakeFromNib()

        dragHandles.forEach {
            $0.viewAccessibilityIdentifier = .blackboardDragHandle
        }
    }

    override func resizeEnabledDidChange() {
        super.resizeEnabledDidChange()
        updateDragHandlesVisibility()
    }
}

extension BlackboardImageView {
    func configure(defaultImage: UIImage) {
        self.defaultImage = defaultImage
    }

    func configure(orientation: UIDeviceOrientation) {
        self.orientation = orientation
        self.rotateWhenDeviceOrientationIsLandscape(orientation: orientation)

        switch orientation {
        case .portrait:
            imageView.image = defaultImage
        case .portraitUpsideDown:
            imageView.image = defaultImage.imageRotatedByDegrees(deg: 180)
        case .landscapeRight:
            imageView.image = defaultImage.imageRotatedByDegrees(deg: -90)
        case .landscapeLeft:
            imageView.image = defaultImage.imageRotatedByDegrees(deg: 90)
        default:
            imageView.image = defaultImage
        }
    }
}

// MARK: - 黒板サイズ変更関連

private extension BlackboardImageView {
    /// ユーザー操作による黒板サイズの変更が可能かどうかによって、
    /// 黒板のドラッグハンドルの表示・非表示を切り替える
    @MainActor
    func updateDragHandlesVisibility() {
        dragHandles.forEach { $0.isHidden = !resizeEnabled }
    }
}

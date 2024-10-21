//
//  ModernBlackboardPreviewView.swift
//  andpad-camera
//
//  Created by msano on 2021/10/07.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

final class ModernBlackboardPreviewView: UIView {
    struct Dependency {
        let parentType: ParentType
    }
    
    enum ParentType {
        case createModernBlackboard
        case editModernBlackboard(ModernEditBlackboardViewController.EditableScope)
        
        var isHiddenSelectBlackboardButton: Bool {
            switch self {
            case .createModernBlackboard:
                return true
            case .editModernBlackboard(let scope):
                switch scope {
                case .all:
                    return false
                case .onlyBlackboardItems:
                    return true
                }
            }
        }
    }

    // IBOutlet
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var expandModeView: UIStackView!
    @IBOutlet private weak var shrinkModeView: UIView!
    @IBOutlet private weak var selectBlackboardButton: UIButton!
    @IBOutlet private weak var arrowButton: UIButton!
    @IBOutlet private weak var previewImageViewTopMargin: NSLayoutConstraint!
    
    private enum LayoutParams {
        static let selectBlackboardButtonHeight: CGFloat = 32
        static let previewImageViewTopMargin: CGFloat = 32
        static let previewImageViewTopMarginWithSelectBlackboardButton: CGFloat = 64
    }
}

extension ModernBlackboardPreviewView {
    var tapSelectBlackboardButton: Signal<Void> {
        selectBlackboardButton.rx.tap.asSignal()
    }
    
    var tapArrowButton: Signal<Void> {
        arrowButton.rx.tap.asSignal()
    }

    func updateImage(
        by modernBlackboardMaterial: ModernBlackboardMaterial,
        appearrance: ModernBlackboardAppearance,
        miniatureMapImageState: MiniatureMapImageState?
    ) {
        guard let modernBlackboardView = ModernBlackboardView(
            modernBlackboardMaterial,
            appearance: appearrance,
            miniatureMapImageState: miniatureMapImageState,
            displayStyle: .withPlaceholder
        ),
        let blackboardImage = modernBlackboardView.image else {
            assertionFailure()
            return
        }
        previewImageView.image = blackboardImage
    }
}

extension ModernBlackboardPreviewView: BlackboardPreviewExpandable {
    func calculateNegativeTopMarginForShrinkMode(currentPreviewHeight: CGFloat) -> CGFloat {
        -currentPreviewHeight + LayoutParams.selectBlackboardButtonHeight
    }

    func shrink() {
        shrinkModeView.isHidden = false
        shrinkModeView.alpha = 1.0
        expandModeView.alpha = 1.0
    }

    func expand() {
        expandModeView.alpha = 1.0
        shrinkModeView.alpha = 0.0
    }

    func doneExpand() {
        shrinkModeView.isHidden = true
    }
}

// MARK: - NibType
extension ModernBlackboardPreviewView: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernBlackboardPreviewView: NibInstantiatable {
    func inject(_ dependency: Dependency) {
        selectBlackboardButton.isHidden = dependency.parentType.isHiddenSelectBlackboardButton
        previewImageViewTopMargin.constant = selectBlackboardButton.isHidden
            ? LayoutParams.previewImageViewTopMargin
            : LayoutParams.previewImageViewTopMarginWithSelectBlackboardButton
    }
}

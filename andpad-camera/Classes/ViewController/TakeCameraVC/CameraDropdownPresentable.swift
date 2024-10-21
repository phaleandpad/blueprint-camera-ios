//
//  CameraSelectionPopoverTransition.swift
//  andpad-camera
//
//  Created by Nguyen Ngoc Tam on 7/9/24.
//

import UIKit
import SwiftUI

protocol CameraDropdownPresentable: UIViewController, UIViewControllerTransitioningDelegate {
    var transitionAnimator: CameraDropdownTransitioning? { get set }
    
    func present(
        on viewController: UIViewController,
        sourceRect: CGRect,
        anchorRelation: CameraDropdownTransitioning.AnchorRelation,
        animated: Bool,
        completion: (() -> Void)?
    )
}

extension CameraDropdownPresentable {
    func present(
        on viewController: UIViewController,
        sourceRect: CGRect,
        anchorRelation: CameraDropdownTransitioning.AnchorRelation,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        transitionAnimator = CameraDropdownTransitioning(
            sourceRect: sourceRect,
            presentingAnchor: anchorRelation,
            tapHandler: { [weak self] in
                guard let self else { return }
                self.dismiss(animated: true)
            }
        )
        transitioningDelegate = self
        modalPresentationStyle = .custom
        
        viewController.present(
            self,
            animated: animated,
            completion: completion
        )
    }
}

class CameraDropdownHostingViewController<Content: View>: UIHostingController<Content>, CameraDropdownPresentable {
    var transitionAnimator: CameraDropdownTransitioning?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // The dropdown should follow the same orientation of it's presenting viewController
        presentingViewController?.supportedInterfaceOrientations ?? .all
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        transitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        transitionAnimator
    }
}

class CameraDropdownViewController: UIViewController, CameraDropdownPresentable {
    var transitionAnimator: CameraDropdownTransitioning?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // The dropdown should follow the same orientation of it's presenting viewController
        presentingViewController?.supportedInterfaceOrientations ?? .all
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        transitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        transitionAnimator
    }
}

final class CameraDropdownTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    enum Position {
        case top
        case bottom
    }
    
    enum Alignment {
        case leading
        case center
        case trailing
    }
    
    struct AnchorRelation {
        let postion: Position
        let alignment: Alignment
        let offset: UIOffset
        
        init(
            postion: Position = .top,
            alignment: Alignment = .leading,
            offset: UIOffset = .zero
        ) {
            self.postion = postion
            self.alignment = alignment
            self.offset = offset
        }
    }
    
    private let sourceRect: CGRect
    private let presentingAnchor: AnchorRelation
    private let tapHandler: (() -> Void)?
    
    private lazy var containerTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnContainerView))
    
    init(
        sourceRect: CGRect,
        presentingAnchor: AnchorRelation,
        tapHandler: (() -> Void)? = nil
    ) {
        self.sourceRect = sourceRect
        self.presentingAnchor = presentingAnchor
        self.tapHandler = tapHandler
    }
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        guard let transitionContext else {
            return 0.0
        }
        
        return transitionContext.isAnimated ? 0.35 : 0.0
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        let isPresenting = fromViewController === toViewController?.presentingViewController
        let duration = transitionDuration(using: transitionContext)
        
        if isPresenting {
            guard let toViewController else {
                assertionFailure("toViewController should not be nil during the transition!")
                transitionContext.completeTransition(false)
                return
            }
            
            transitionContext.containerView.addSubview(toViewController.view)
            transitionContext.containerView.addGestureRecognizer(containerTapGesture)
            
            toViewController.view.frame = calculatePresentingViewFrame(
                for: toViewController,
                transitionContext: transitionContext
            )
            toViewController.view.alpha = 0
            
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: .curveEaseInOut
            ) {
                toViewController.view.alpha = 1
            } completion: { completed in
                transitionContext.completeTransition(completed)
            }
        } else {
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: .curveEaseInOut
            ) {
                fromViewController?.view?.alpha = 0
            } completion: { completed in
                transitionContext.completeTransition(completed)
            }
        }
    }
    
    @objc func didTapOnContainerView() {
        tapHandler?()
    }
}

extension CameraDropdownTransitioning {
    private func calculatePresentingViewFrame(
        for toViewController: UIViewController,
        transitionContext: any UIViewControllerContextTransitioning
    ) -> CGRect {
        var frame = toViewController.view.frame
        let offset = presentingAnchor.offset
        
        // Calculate size
        if toViewController.preferredContentSize == .zero {
            frame.size = transitionContext.finalFrame(for: toViewController).size
        } else {
            frame.size = toViewController.preferredContentSize
        }
        
        // Calculate origin
        switch presentingAnchor.postion {
        case .top:
            frame.origin.y = sourceRect.minY - frame.height + offset.vertical
        case .bottom:
            frame.origin.y = sourceRect.maxY + offset.vertical
        }
        
        switch presentingAnchor.alignment {
        case .leading:
            frame.origin.x = sourceRect.minX + offset.horizontal
        case .trailing:
            frame.origin.x = sourceRect.maxX - frame.width + offset.horizontal
        case .center:
            frame.origin.x = sourceRect.minX - (frame.width - sourceRect.width) / 2 + offset.horizontal
        }
        
        return frame
    }
}

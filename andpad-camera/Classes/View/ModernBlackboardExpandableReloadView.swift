//
//  ModernBlackboardExpandableReloadView.swift
//  andpad-camera-andpad-camera
//
//  Created by msano on 2022/12/20.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

public final class ModernBlackboardExpandableReloadView: UIView {
    
    private var searchQuery: ModernBlackboardSearchQuery?
    
    public struct Dependency {
        public init() {}
    }
    
    public enum LayoutParams {
        static var buttonFontSize: CGFloat = 15
        public static var expandViewHeight: CGFloat = 112
        public static var shrinkViewHeight: CGFloat = 0
    }
    
    // IBOutlet
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var updateButton: UIButton!

    public var tappedCancelButtonSignal: Signal<Void> {
        cancelButton.rx.tap.asSignal()
    }
    
    public var tappedUpdateButtonSignal: Signal<ModernBlackboardSearchQuery?> {
        updateButton.rx.tap.asSignal()
            .map { [weak self] in self?.searchQuery }
    }
    
    public func set(_ searchQuery: ModernBlackboardSearchQuery?) {
        self.searchQuery = searchQuery
    }
}

// MARK: - private
extension ModernBlackboardExpandableReloadView {
    private func configureView() {
        if #available(iOS 15.0, *) {
            let font: UIFont = .systemFont(ofSize: LayoutParams.buttonFontSize, weight: .semibold)
            var container = AttributeContainer()
            container.font = font
            cancelButton.configuration?.attributedTitle = AttributedString(
                cancelButton.titleLabel?.text ?? "",
                attributes: container
            )
            updateButton.configuration?.attributedTitle = AttributedString(
                updateButton.titleLabel?.text ?? "",
                attributes: container
            )
            cancelButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = font
                return outgoing
            }
            updateButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = font
                return outgoing
            }
        } else {
            cancelButton.titleLabel?.font = .systemFont(ofSize: LayoutParams.buttonFontSize, weight: .semibold)
            updateButton.titleLabel?.font = .systemFont(ofSize: LayoutParams.buttonFontSize, weight: .semibold)
        }
    }
}

// MARK: - NibType
extension ModernBlackboardExpandableReloadView: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernBlackboardExpandableReloadView: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        configureView()
    }
}

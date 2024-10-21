//
//  AppUpdateView.swift
//  andpad-camera
//
//  Created by msano on 2022/10/19.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

public final class AppUpdateView: UIView {
    public struct Dependency {
        public init() {}
    }

    // IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var updateButton: UIButton!

    public var tappedUpdateButtonSignal: Signal<Void> {
        updateButton.rx.tap.asSignal()
    }
    
    public static var viewHeight: CGFloat {
        LayoutParams.defaultViewHeight + safeAreaBottomInset
    }
    
    public static var defaultViewHeight: CGFloat {
        LayoutParams.defaultViewHeight
    }
}

// MARK: - private
extension AppUpdateView {
    private enum LayoutParams {
        static var defaultViewHeight: CGFloat = 66
    }
    
    private static var safeAreaBottomInset: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
    private func configureView() {
        titleLabel.attributedText = NSAttributedString(string: L10n.AppUpdateView.title)
        updateButton.setTitle(L10n.AppUpdateView.update, for: .normal)
        if #available(iOS 15.0, *) {
            let font: UIFont = .systemFont(ofSize: 14, weight: .semibold)
            var container = AttributeContainer()
            container.font = font
            updateButton.configuration?.attributedTitle = AttributedString(
                updateButton.titleLabel?.text ?? "",
                attributes: container
            )
            updateButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = font
                return outgoing
            }
        } else {
            updateButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        }
    }
}

// MARK: - NibType
extension AppUpdateView: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension AppUpdateView: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        configureView()
    }
}

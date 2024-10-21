//
//  ModernBlackboardPreviewWebView.swift
//  andpad-camera-andpad-camera
//
//  Created by 栗山徹 on 2024/08/28.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa
import WebKit

/// 拡大・縮小処理に必要な I/F だけ定義した protocol。
///
/// - Note: レイアウト自由化により ModernBlackboardPreviewWebView に１本化されるため、本 protocol は ModernBlackboardPreviewWebView に定義します。
protocol BlackboardPreviewExpandable {
    /// プレビュー画面のshrinkモード時のネガティブマージンを計算する。
    /// shrinkモードでは、プレビュー画面の高さは固定され、top制約は0から
    /// プレビュー画面の高さとshrinkモードの高さとの差に応じて負の値に設定される。
    ///
    /// - Parameter currentPreviewHeight: 動的に変化するプレビュー画面の現在の高さ
    /// - Returns: 計算されたネガティブマージン
    func calculateNegativeTopMarginForShrinkMode(currentPreviewHeight: CGFloat) -> CGFloat
    func shrink()
    func expand()
    func doneExpand()
}

final class ModernBlackboardPreviewWebView: UIView, BlackboardWebViewConfigurable {
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
    @IBOutlet private weak var previewWebView: UIView!
    @IBOutlet private weak var expandModeView: UIView!
    @IBOutlet private weak var shrinkModeView: UIView!
    @IBOutlet private weak var selectBlackboardButton: UIButton!
    @IBOutlet private weak var arrowButton: UIButton!
    @IBOutlet private weak var previewImageViewTopMargin: NSLayoutConstraint!

    private var webView: WKWebView?

    private enum LayoutParams {
        static let selectBlackboardButtonHeight: CGFloat = 32
        static let previewImageViewTopMargin: CGFloat = 32
        static let previewImageViewTopMarginWithSelectBlackboardButton: CGFloat = 64
    }

    /// 黒板プレビューの表示サイズ。
    @MainActor
    var previewWebViewSize: CGSize {
        previewWebView.frame.size
    }

    private func configureView(_ dependency: Dependency) {
        selectBlackboardButton.setTitle(L10n.Blackboard.Edit.Preview.SelectBlackboardButton.title, for: .normal)
        selectBlackboardButton.isHidden = dependency.parentType.isHiddenSelectBlackboardButton

        previewImageViewTopMargin.constant = selectBlackboardButton.isHidden
            ? LayoutParams.previewImageViewTopMargin
            : LayoutParams.previewImageViewTopMarginWithSelectBlackboardButton

        webView = createAndConfigureBlackboardWebView()
        guard let webView else { return }
        previewWebView.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        webView.isUserInteractionEnabled = false
    }
}

extension ModernBlackboardPreviewWebView {
    var tapSelectBlackboardButton: Signal<Void> {
        selectBlackboardButton.rx.tap.asSignal()
    }

    var tapArrowButton: Signal<Void> {
        arrowButton.rx.tap.asSignal()
    }

    func updateLayout(query: String) {
        guard let webView else { return }
        blackboardWebView(webView, loadHTMLWithQuery: query)
    }
}

extension ModernBlackboardPreviewWebView: BlackboardPreviewExpandable {
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
extension ModernBlackboardPreviewWebView: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernBlackboardPreviewWebView: NibInstantiatable {
    func inject(_ dependency: Dependency) {
        configureView(dependency)
    }
}

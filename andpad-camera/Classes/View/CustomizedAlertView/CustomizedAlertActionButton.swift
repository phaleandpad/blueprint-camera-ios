//
//  CustomizedAlertActionButton.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2023/11/08.
//

import SnapKit
import UIKit

// MARK: - CustomizedAlertActionButton

/// カスタマイズされたアラートのアクションボタンクラス
final class CustomizedAlertActionButton: UIButton {
    private var action: CustomizedAlertAction
    private var dismiss: () -> Void

    /// 初期化
    /// - Parameters:
    ///   - action: アクション
    ///   - dismiss: アクションボタンが閉じられるときのハンドラー
    init(customAlertAction action: CustomizedAlertAction, dismiss: @escaping () -> Void) {
        self.action = action
        self.dismiss = dismiss
        super.init(frame: .zero)

        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .systemGray.withAlphaComponent(0.2) : .clear
        }
    }

    private func setUpViews() {
        setTitleColor(action.style == .destructive ? .red : .systemBlue, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: action.style == .cancel ? .semibold : .regular)
        titleLabel?.numberOfLines = 1

        setTitle(action.title, for: .normal)
        // FIXME: Minimum Deployment Target を iOS14 にあげる対応が終わったら条件文削除
        if #available(iOS 14, *) {
            addAction(UIAction { [weak self] _ in
                guard let self else {
                    return
                }
                self.action.handler?(self.action)
                self.dismiss()
            }, for: .touchUpInside)
        }
    }
}

/*
  Xcode 15 から使えます

 // MARK: - Previews

 @available(iOS 17, *)
 #Preview {
     let viewController = UIViewController()
     let button = CustomizedAlertActionButton(customAlertAction: .init(title: "ボタン", style: .default), dismiss: {})
     viewController.view.addSubview(button)
     button.snp.makeConstraints { make in
         make.center.equalToSuperview()
         make.height.equalTo(44)
         make.width.equalTo(270)
     }
     button.isHighlighted = true
     return viewController
 }

  */

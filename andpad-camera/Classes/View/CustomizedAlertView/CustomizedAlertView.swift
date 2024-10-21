//
//  CustomizedAlertView.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2023/11/08.
//

import SnapKit
import UIKit

// MARK: - CustomizedAlertView

/// カスタマイズされたアラートビュークラス
///
/// このクラスは、画面の向きをポートレートに固定したまま、
/// アラートの向きの回転を可能にするために作成されました。
///
/// 見た目は、iOS15〜17の標準アラートの見た目に近づけて実装されています。
///
/// 標準アラートだと、画面の向きと同じ向きにしか表示できませんが、
/// `UIView` であれば、 `CGAffineTransform` などを利用して、
/// 画面の向きとは異なる向きに回転させることができます。
///
/// アラートの向きを画面の向きとは異なる向きに回転させる必要がない場合は、
/// 標準アラートを使用してください。
///
/// - Usage:
///
///  ```
///  func didTapAlertButton() {
///      let alertView = CustomizedAlertView(title: "タイトル", message: "メッセージ")
///
///      let button1Action = CustomizedAlertAction(title: "ボタン１", style: .default) {
///          print("ボタン１が押されました")
///      }
///      let button2Action = CustomizedAlertAction(title: "ボタン２", style: .destructive) {
///          print("ボタン２が押されました")
///      }
///      let cancelAction = CustomizedAlertAction(title: "キャンセル", style: .cancel) {
///          print("キャンセルが押されました")
///      }
///
///      alertView.addAction(button1Action)
///      alertView.addAction(button2Action)
///      alertView.addAction(cancelAction)
///
///      alertView.show(in: view, initialRotationAngle: .pi / 2)
///  }
///    ```
final class CustomizedAlertView: UIView {
    // MARK: Private Properties

    /// タイトルラベルとメッセージラベルを包含するビュー
    private let titleMessageView: UIView = {
        let view = UIView()
        return view
    }()

    /// タイトルラベル
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.baselineAdjustment = .alignBaselines
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    /// メッセージラベル
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.baselineAdjustment = .alignBaselines
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    /// アクションボタンビュー
    private let actionButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    /// 磨りガラス効果を与えるビュー
    private let blurEffectedView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.clipsToBounds = true
        return blurEffectView
    }()

    /// 背景ビュー
    private let backgroundView = UIView()

    // MARK: Initializers

    /// 初期化
    /// - Parameters:
    ///   - title: タイトル
    ///   - message: メッセージ
    init(title: String, message: String? = nil) {
        super.init(frame: .zero)
        setupViews(title: title, message: message)
        setupLayouts()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private Functions

    /// ビューを設定する
    /// - Parameters:
    ///   - title: タイトル
    ///   - message: メッセージ
    private func setupViews(title: String, message: String?) {
        // アラートビューのスタイル設定
        layer.cornerRadius = 12
        layer.masksToBounds = true

        // タイトルラベルの設定
        titleLabel.text = title

        // メッセージラベルの設定（メッセージがある場合のみ）
        messageLabel.text = message
        // メッセージがnilの場合は非表示
        messageLabel.isHidden = message == nil

        addSubview(blurEffectedView)
        addSubview(titleMessageView)
        titleMessageView.addSubview(titleLabel)
        titleMessageView.addSubview(messageLabel)
        addSubview(actionButtonStackView)
    }

    /// 制約を設定する
    private func setupLayouts() {
        snp.makeConstraints { make in
            make.width.equalTo(270)
            make.height.greaterThanOrEqualTo(0)
            make.height.lessThanOrEqualTo(705)
        }

        blurEffectedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleMessageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.firstBaseline.equalToSuperview().offset(36)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }

        messageLabel.snp.makeConstraints { make in
            make.firstBaseline.equalTo(titleLabel.snp.lastBaseline).offset(20)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.lastBaseline.equalToSuperview().offset(-24)
        }

        actionButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(titleMessageView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    /// アクションボタンビューを生成する
    /// - Parameter action: アクション
    /// - Returns: アクションボタンビュー
    private func actionButtonView(action: CustomizedAlertAction) -> UIView {
        let actionButtonView = UIView()

        let topBorderView = UIView()
        topBorderView.backgroundColor = .separator
        // 1物理ピクセルの厚さを計算
        let borderDepth = 1 / traitCollection.displayScale

        let actionButton = CustomizedAlertActionButton(customAlertAction: action, dismiss: dismiss)

        actionButtonView.addSubview(topBorderView)
        actionButtonView.addSubview(actionButton)

        topBorderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(borderDepth)
        }
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(topBorderView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }

        return actionButtonView
    }

    /// アラートビューを閉じる
    private func dismiss() {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.alpha = 0
                self.backgroundView.backgroundColor = .clear
            },
            completion: { [weak self] _ in
                self?.backgroundView.removeFromSuperview()
                self?.removeFromSuperview()
            }
        )
    }
}

// MARK: - Internal Functions

extension CustomizedAlertView {
    /// アラートを表示する
    /// - Parameters:
    ///   - view: アラートを乗せるビュー
    ///   - initialRotationAngle: 初期表示時の回転角度〔ラジアン〕
    func show(in view: UIView, initialRotationAngle: CGFloat) {
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(self)
        snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // アラートを透明にしてスケールを大きく設定
        alpha = 0
        let scaleAffine = CGAffineTransform(scaleX: 1.2, y: 1.2)
        let rotationAngleAffine = CGAffineTransform(rotationAngle: initialRotationAngle)
        transform = scaleAffine.concatenating(rotationAngleAffine)
        backgroundView.backgroundColor = .clear

        // アニメーションでフェードアウトとスケールを元に戻す
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            let scaleAffine = CGAffineTransform(scaleX: 1.0, y: 1.0)
            let rotationAngleAffine = CGAffineTransform(rotationAngle: initialRotationAngle)
            self.transform = scaleAffine.concatenating(rotationAngleAffine)
            self.backgroundView.backgroundColor = .black.withAlphaComponent(0.2)
        }
    }

    /// アクションを追加する
    func addAction(_ action: CustomizedAlertAction) {
        let actionButtonView = actionButtonView(action: action)
        actionButtonStackView.addArrangedSubview(actionButtonView)
    }
}

/*
  Xcode 15 から使えます

 // MARK: - Previews

 @available(iOS 17, *)
 #Preview("ボタン１つ") {
     let alertView = CustomizedAlertView(title: "タイトル", message: "メッセージ")
     let okAction = CustomizedAlertAction(title: "OK", style: .default)
     alertView.addAction(okAction)
     return alertView
 }

 @available(iOS 17, *)
 #Preview("ボタン２つ") {
     let alertView = CustomizedAlertView(title: "タイトル", message: "メッセージ")
     let deleteAction = CustomizedAlertAction(title: "削除", style: .destructive)
     let cancelAction = CustomizedAlertAction(title: "キャンセル", style: .cancel)
     alertView.addAction(deleteAction)
     alertView.addAction(cancelAction)
     return alertView
 }

 @available(iOS 17, *)
 #Preview("ボタン３つ") {
     let alertView = CustomizedAlertView(title: "タイトル", message: "メッセージ")
     let option1ButtonAction = CustomizedAlertAction(title: "オプション１", style: .default)
     let option2ButtonAction = CustomizedAlertAction(title: "オプション２", style: .default)
     let cancelButtonAction = CustomizedAlertAction(title: "キャンセル", style: .cancel)
     alertView.addAction(option1ButtonAction)
     alertView.addAction(option2ButtonAction)
     alertView.addAction(cancelButtonAction)
     return alertView
 }

 */

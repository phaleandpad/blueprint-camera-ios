//
//  UIAlertController+Extension.swift
//  andpad-camera
//
//  Created by msano on 2020/11/18.
//

import UIKit

extension UIAlertController {
    convenience init(with message: String) {
        self.init(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        addAction(
            UIAlertAction(
                title: L10n.Common.ok,
                style: .default
            )
        )
    }
}

// MARK: - common alarts (public)
extension UIAlertController {
    public static func moveAppStoreAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.Common.Alert.Title.appUpdate,
            message: L10n.Common.Alert.Description.appUpdate,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.Alert.UpdateButton.appUpdate,
                style: .default,
                handler: { _ in
                    guard let url = AppInfoUtil.getMainAppStoreURL,
                          UIApplication.shared.canOpenURL(url) else { return }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            )
        )
        alert.addAction(
            .init(
                title: L10n.Common.cancel,
                style: .cancel,
                handler: nil
            )
        )
        return alert
    }
}

// MARK: - common alarts
extension UIAlertController {
    static func commonBlackboardNetworkErrorAlert(
        retryHandler: @escaping ((UIAlertAction) -> Void),
        destructiveHandler: @escaping ((UIAlertAction) -> Void)
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.Common.error,
            message: L10n.Common.Error.failToConnectNetwork,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.retry,
                style: .default,
                handler: retryHandler
            )
        )
        alert.addAction(
            .init(
                title: L10n.Blackboard.Alert.Button.destorySelectingBlackboard,
                style: .destructive,
                handler: destructiveHandler
            )
        )
        return alert
    }
    
    static func commonBlackboardNetworkErrorAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.Common.error,
            message: L10n.Common.Error.failToConnectNetwork,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.ok,
                style: .default,
                handler: nil
            )
        )
        return alert
    }
    
    static func commonBlackboardValidateErrorAlert(okHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.Blackboard.Alert.Title.cannotSaveBlackboard,
            message: L10n.Blackboard.Alert.Description.cannotSaveBlackboard,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.ok,
                style: .default,
                handler: okHandler
            )
        )
        return alert
    }
    
    static func postNewBlackboardNetworkErrorAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.Blackboard.Error.FailToCreateBlackboard.alertTitle,
            message: L10n.Blackboard.Error.FailToCreateBlackboard.alertDescription,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.ok,
                style: .default,
                handler: nil
            )
        )
        return alert
    }
    
    static func destroyEditingBlackboardAlert(okHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.Blackboard.Alert.Title.destroyEditedBlackboard,
            message: L10n.Blackboard.Alert.Description.destroyEditedBlackboard,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.destroy,
                style: .default,
                handler: okHandler
            )
        )
        alert.addAction(
            .init(
                title: L10n.Common.back,
                style: .cancel,
                handler: nil
            )
        )
        return alert
    }
    
    static func duplicateBlackboardAlert(
        viewType: DuplicateBlackboardAlertViewType,
        confirmBlackboardHandler: @escaping ((UIAlertAction) -> Void)
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.Blackboard.Alert.Title.cannotSaveDuplicatedBlackboard,
            message: nil,
            preferredStyle: .alert
        )
        
        switch viewType {
        case .createModernBlackboard, .editModernBlackboard:
            alert.addAction(
                .init(
                    title: L10n.Blackboard.Alert.ConfirmButton.cannotSaveDuplicatedBlackboard,
                    style: .default,
                    handler: confirmBlackboardHandler
                )
            )
        case .editModernBlackboardByCamera:
            alert.addAction(
                .init(
                    title: L10n.Blackboard.Alert.TakeCameraButton.cannotSaveDuplicatedBlackboard,
                    style: .default,
                    handler: confirmBlackboardHandler
                )
            )
        }
        
        alert.addAction(
            .init(
                title: L10n.Blackboard.Alert.CancelButton.cannotSaveDuplicatedBlackboard,
                style: .cancel,
                handler: nil
            )
        )
        return alert
    }

    static func overwriteOrCreateNewAlert(
        overwriteHandler: @escaping ((UIAlertAction) -> Void),
        createNewHandler: @escaping ((UIAlertAction) -> Void)
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.Blackboard.Alert.Title.overwriteOrCopyNewBlackboard,
            message: L10n.Blackboard.Alert.Message.overwriteOrCopyNewBlackboard,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Blackboard.Alert.OverwriteButton.overwriteOrCopyNewBlackboard,
                style: .default,
                handler: overwriteHandler
            )
        )
        alert.addAction(
            .init(
                title: L10n.Blackboard.Alert.CopyNewButton.overwriteOrCopyNewBlackboard,
                style: .default,
                handler: createNewHandler
            )
        )
        alert.addAction(
            .init(
                title: L10n.Common.cancel,
                style: .cancel,
                handler: nil
            )
        )
        return alert
    }
    
    static func updateBlackboardByAdminActionAlert(
        okHandler: @escaping ((UIAlertAction) -> Void),
        cancelHandler: @escaping ((UIAlertAction) -> Void)
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Blackboard.Alert.Message.updateBlackboardByAdminAction,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Blackboard.Alert.OkButton.updateBlackboardByAdminAction,
                style: .default,
                handler: okHandler
            )
        )
        alert.addAction(
            .init(
                title: L10n.Common.cancel,
                style: .cancel,
                handler: cancelHandler
            )
        )
        return alert
    }
    
    static func willSelectNewLayoutAlert(okHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        // 呼び出し元に応じて、表示文言を変更させる
        let alert = UIAlertController(
            title: L10n.Blackboard.Alert.Title.doChangeLayout,
            message: L10n.Blackboard.Alert.Desc.doChangeLayout,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.change,
                style: .default,
                handler: okHandler
            )
        )
        alert.addAction(
            .init(
                title: L10n.Common.cancel,
                style: .cancel,
                handler: nil
            )
        )
        return alert
    }
    
    static func blackboardEmptyResponseAlert(
        retryHandler: @escaping ((UIAlertAction) -> Void),
        destructiveHandler: @escaping ((UIAlertAction) -> Void)
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Common.cannotShowZeroData,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.retry,
                style: .default,
                handler: retryHandler
            )
        )
        alert.addAction(
            .init(
                title: L10n.Blackboard.Alert.Button.destorySelectingBlackboard,
                style: .destructive,
                handler: destructiveHandler
            )
        )
        return alert
    }
    
    static func cannotUseBlackboardHistoryAlert() -> UIAlertController {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Blackboard.Error.CannotUseHistoryFunction.alertDescription,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.ok,
                style: .default,
                handler: nil
            )
        )
        return alert
    }

    static func editConstructionNameInBlackboardEditAlert(okHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let alert = UIAlertController(
            title: L10n.Blackboard.Alert.Title.editConstructionNameInBlackboardEdit,
            message: L10n.Blackboard.Alert.Message.editConstructionNameInBlackboardEdit,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Blackboard.Alert.EditButton.editConstructionNameInBlackboardEdit,
                style: .default,
                handler: okHandler
            )
        )
        alert.addAction(
            .init(
                title: L10n.Common.cancel,
                style: .cancel,
                handler: nil
            )
        )
        return alert
    }

    /// OKボタン付きのアラート
    /// - Parameter error: AndpadCameraError
    /// - Returns: アラート
    static func errorAlertWithOKButton(error: AndpadCameraError) -> UIAlertController {
        let alert = UIAlertController(
            title: error.errorDescription,
            message: error.failureReason,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.ok,
                style: .default,
                handler: nil
            )
        )
        return alert
    }

    /// 再試行ボタンとキャンセルボタン付きのアラート
    /// - Parameters:
    ///   - error: AndpadCameraError
    ///   - retryHandler: 再試行ボタンタップ時のハンドラー
    ///   - cancelHandler: キャンセルボタンタップ時のハンドラー
    /// - Returns: アラート
    static func errorAlertWithRetryButton(
        error: AndpadCameraError,
        retryHandler: @escaping ((UIAlertAction) -> Void),
        cancelHandler: @escaping ((UIAlertAction) -> Void)
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: error.errorDescription,
            message: error.failureReason,
            preferredStyle: .alert
        )
        alert.addAction(
            .init(
                title: L10n.Common.retry,
                style: .default,
                handler: retryHandler
            )
        )
        alert.addAction(
            .init(
                title: L10n.Common.cancel,
                style: .destructive,
                handler: cancelHandler
            )
        )
        return alert
    }
}

// MARK: enum
extension UIAlertController {
    enum DuplicateBlackboardAlertViewType {
        /// 新規作成画面
        case createModernBlackboard
        
        /// 黒板編集画面
        case editModernBlackboard
        
        // 撮影編集画面（カメラ内での呼び出し）
        case editModernBlackboardByCamera
    }
}

// MARK: for iPad
extension UIAlertController {
    // NOTE: iPadでactionSheet表示できるよう設定する
    public func configurePopoverForIPadIfNeeded(parentView: UIView) {
        guard self.preferredStyle == .actionSheet else { return }
        popoverPresentationController?.sourceView = parentView
        popoverPresentationController?.sourceRect = .init(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height,
            width: 0,
            height: 0
        )
    }
}

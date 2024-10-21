//
//  AndpadCameraError.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/01/15.
//

/// andpad-cameraライブラリで発生したエラー
enum AndpadCameraError: LocalizedError {
    /// ネットワークエラー
    case network
    /// 処理を完了できなかった場合のエラー
    case operationCouldNotBeCompleted

    var errorDescription: String? {
        switch self {
        case .network:
            return L10n.Common.error
        case .operationCouldNotBeCompleted:
            return L10n.Common.Error.operationCouldNotBeCompleted
        }
    }

    var failureReason: String? {
        switch self {
        case .network:
            return L10n.Common.Error.failToConnectNetwork
        case .operationCouldNotBeCompleted:
            return nil
        }
    }
}

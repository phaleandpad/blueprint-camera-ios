//
//  AndpadAnalyticsCameraProtocol.swift
//  andpad-camera
//
//  Created by msano on 2023/04/24.
//

// MARK: - AndpadAnalyticsCameraProtocol
public protocol AndpadAnalyticsCameraProtocol {
    func sendLogEvent(cameraEventTargetView: AndpadAnalyticsCameraEvents.TargetView)
}

// MARK: - AndpadAnalyticsCameraEvents
public enum AndpadAnalyticsCameraEvents {}
    
// MARK: - AndpadAnalyticsCameraEvents (TargetView)
public extension AndpadAnalyticsCameraEvents {
    enum TargetView {
        /// 撮影（カメラ）画面
        case takeCamera(TakeCameraAction)
        
        // TODO: 以下ケースはいずれも撮影履歴リリース時に用意する予定
        
        /// 未アップロード画面（通常モード）
        case photoHistoriesWithNormalMode(PhotoHistoriesWithNormalModeAction)
        
        /// 未アップロード画面（選択モード）
        case photoHistoriesWithSelectMode(PhotoHistoriesWithSelectModeAction)
        
        /// 未アップロード画面からの写真詳細
        case photoDetailFromPhotoHistories(PhotoDetailFromPhotoHistoriesAction)
    }
}

// MARK: - AndpadAnalyticsCameraEvents (Action)
public extension AndpadAnalyticsCameraEvents {
    enum TakeCameraAction {
        case tapDestroyButton
        case tapUploadButton
        case tapCancelButton
        case tapNextButton
    }

    enum PhotoHistoriesWithNormalModeAction {
        // TODO: 撮影履歴リリース時に用意する予定
    }

    enum PhotoHistoriesWithSelectModeAction {
        // TODO: 撮影履歴リリース時に用意する予定
    }

    enum PhotoDetailFromPhotoHistoriesAction {
        // TODO: 撮影履歴リリース時に用意する予定
    }
}

//
//  MiniatureMapImageState.swift
//  andpad-camera
//
//  Created by msano on 2022/08/17.
//

import AndpadUIComponent

// MARK: - MiniatureMapImageState
public enum MiniatureMapImageState {
    
    /// 豆図画像ロード前
    case beforeLoading
    
    /// 豆図画像ロード成功
    case loadSuccessful(UIImage)
    
    /// 豆図画像ロード失敗
    case loadFailed
    
    /// 豆図画像のURLが無い
    case noURL(useCameraView: Bool)
    
    fileprivate var image: UIImage {
        switch self {
        case .beforeLoading:
            return Asset.miniatureMapBeforeLoading.image
        case .loadSuccessful(let image):
            return image
        case .loadFailed:
            return Asset.miniatureMapLoadFailed.image
        case .noURL(let useCameraView):
            return useCameraView
                ? .init() // カメラ画面に限り空の画像を渡す
                : Asset.miniatureMapNoUrl.image
        }
    }
    
    /// 豆図画像を取得できているか
    var hasMiniatureMapImage: Bool {
        guard case .loadSuccessful = self else { return false }
        return true
    }
}

// MARK: - MiniatureMapImageViewAppearance
struct MiniatureMapImageViewAppearance {
    
    let state: MiniatureMapImageState
    private let isShowImageIntoBlackboard: Bool
    
    /// イニシャライズ
    ///
    /// - Parameters:
    ///   - state: 豆図画像の取得状況
    ///   - isShowImageIntoBlackboard: 豆図画像は黒板イメージ内で描画するか
    ///
    init(
        state: MiniatureMapImageState,
        isShowImageIntoBlackboard: Bool = true
    ) {
        self.state = state
        self.isShowImageIntoBlackboard = isShowImageIntoBlackboard
    }
    
    var image: UIImage {
        guard !state.hasMiniatureMapImage,
              let imageResizeRatio else { return state.image }
        // 黒板に描画する場合で、ratioがセットされていればリサイズ
        return state.image.resize(
            size: .init(
                width: state.image.size.width * imageResizeRatio,
                height: state.image.size.height * imageResizeRatio
            )
        ) ?? state.image
    }
    
    var contentMode: UIView.ContentMode {
        switch state {
        case .beforeLoading, .loadFailed, .noURL:
            return .center
        case .loadSuccessful:
            return .scaleAspectFit
        }
    }
    
    var backgroundColor: UIColor {
        switch state {
        case .beforeLoading:
            return isShowImageIntoBlackboard
                ? .gray999.withAlphaComponent(0.3)
                : .clear
        case .loadSuccessful:
            return .clear
        case .loadFailed:
            return isShowImageIntoBlackboard
                ? .black.withAlphaComponent(0.4)
                : .black.withAlphaComponent(0.08)
        case .noURL:
            return .clear
        }
    }
    
    var tintColor: UIColor? {
        switch state {
        case .beforeLoading, .loadSuccessful:
            return nil
        case .loadFailed, .noURL:
            return isShowImageIntoBlackboard
                ? nil
                : .tsukuri.system.secondaryTextOnBackground
        }
    }
}

// MARK: - private
extension MiniatureMapImageViewAppearance {
    /// 画像のリサイズ率
    private var imageResizeRatio: CGFloat? {
        switch state {
        case .loadSuccessful:
             return nil
        case .beforeLoading, .loadFailed, .noURL:
            return isShowImageIntoBlackboard ? 2 : 1.2
        }
    }
}

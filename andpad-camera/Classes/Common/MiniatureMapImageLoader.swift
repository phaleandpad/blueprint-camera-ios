//
//  MiniatureMapImageLoader.swift
//  andpad-camera
//
//  Created by msano on 2022/08/17.
//

import Nuke

public enum MiniatureMapImageLoader {
    public static func load(
        imageUrl: URL,
        shouldCheckNetworkStatusBeforeLoading: Bool = false,
        completion: @escaping (MiniatureMapImageState) -> Void
    ) {
        func loadImage(
            imageUrl: URL,
            completion: @escaping (MiniatureMapImageState) -> Void
        ) {
            ImagePipeline.shared.loadImage(with: getImageRequest(with: imageUrl)) { result in
                switch result {
                case .success(let response):
                    completion(.loadSuccessful(response.image))
                case .failure(let error):
                    AndpadCameraConfig.logger.nonFatalError(
                        domain: "MiniatureMapImageLoaderError",
                        additionalUserInfo: [
                            NSLocalizedDescriptionKey: error.localizedDescription,
                            "Message": error.description
                        ]
                    )
                    completion(.loadFailed)
                }
            }
        }
        
        guard shouldCheckNetworkStatusBeforeLoading,
              NetworkReachabilityHandler.shared.isOffline else {
            loadImage(imageUrl: imageUrl, completion: completion)
            return
        }
        // オフライン時は、（キャッシュデータがあったとしても）取得失敗扱いとする
        AndpadCameraConfig.logger.nonFatalError(
            domain: "MiniatureMapImageLoaderOfflineError",
            message: "オフラインのため取得失敗"
        )
        completion(.loadFailed)
    }
}

// MARK: - private
extension MiniatureMapImageLoader {
    private static func getImageRequest(with url: URL) -> ImageRequest {
        .init(
            url: url,
            processors: [],
            priority: .high,
            options: [.reloadIgnoringCachedData],
            userInfo: nil
        )
    }
}

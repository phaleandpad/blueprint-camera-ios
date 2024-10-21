//
//  ImagePrefetcherHandler.swift
//  andpad-camera
//
//  Created by msano on 2022/09/09.
//

import Nuke

public struct ImagePrefetcherHandler {
    // NOTE: 画面ごとに作成が必要　`You typically create one ImagePrefetcher per screen.`
    // https://github.com/kean/Nuke/blob/cb7be6d9ba8579b245cac71d7a863384502ecd89/Sources/Nuke/Nuke.docc/Performance/prefetching.md
    private let prefetcher = ImagePrefetcher()
    
    public init() {}
}

// MARK: - prefetching
extension ImagePrefetcherHandler {
    public func startPrefetching(_ urls: [URL]) {
        prefetcher.startPrefetching(with: urls)
    }
    
    public func stopPrefetching(_ urls: [URL]) {
        prefetcher.stopPrefetching(with: urls)
    }
}

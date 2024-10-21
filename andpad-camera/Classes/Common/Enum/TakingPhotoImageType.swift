//
//  TakingPhotoImageType.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/06/27.
//

import Foundation

public enum TakingPhotoImageType: String, Sendable {
    case jpeg
    case svg
}

extension TakingPhotoImageType {
    public init(takingPhotoImageType: String?) {
        guard
            let takingPhotoImageType,
            let takingPhotoImageTypeValue = TakingPhotoImageType(rawValue: takingPhotoImageType)
        else {
            // デフォルトを svg 追加前の既存の撮影形式 jpeg とする
            self = .jpeg
            return
        }
        self = takingPhotoImageTypeValue
    }
}

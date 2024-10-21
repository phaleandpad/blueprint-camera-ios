//
//  ModernBlackboardCameraStorageStub.swift
//  andpad-camera_Example
//
//  Created by 成瀬 未春 on 2024/05/09.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import andpad_camera
import Foundation

class ModernBlackboardCameraStorageStub: ModernBlackboardCameraStorageProtocol {
    private var blackboardSettingsReadFlags: [Int: Bool] = [:]

    func getBlackboardSettingsReadFlag(for orderID: Int) -> Bool {
        return blackboardSettingsReadFlags[orderID] ?? false
    }

    func setBlackboardSettingsReadFlag(for orderID: Int, isRead: Bool) {
        blackboardSettingsReadFlags[orderID] = isRead
    }

    func deleteBlackboardSettingsReadFlags() {
        // Exampleアプリで使わないので実装不要
    }
}

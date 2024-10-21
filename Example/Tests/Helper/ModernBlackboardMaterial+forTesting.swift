//
//  ModernBlackboardMaterial+forTesting.swift
//  andpad-camera_Tests
//
//  Created by 成瀬 未春 on 2024/05/30.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import andpad_camera

extension ModernBlackboardMaterial {
    static func forTesting(
        id: Int,
        blackboardTemplateID: Int,
        layoutTypeID: Int,
        photoCount: Int,
        blackboardTheme: ModernBlackboardAppearance.Theme,
        items: [Item] = [],
        blackboardTrees: [TreeItem] = [],
        miniatureMap: MiniatureMap? = nil,
        originalBlackboardID: Int? = nil
    ) -> Self {
        .init(
            id: id,
            blackboardTemplateID: blackboardTemplateID,
            layoutTypeID: layoutTypeID,
            photoCount: photoCount,
            blackboardTheme: blackboardTheme,
            items: items,
            blackboardTrees: blackboardTrees,
            miniatureMap: miniatureMap,
            originalBlackboardID: originalBlackboardID
        )
    }

    static func forTesting(
        id: Int,
        blackboardTemplateID: Int,
        layoutTypeID: Int,
        photoCount: Int,
        blackboardTheme: ModernBlackboardAppearance.Theme,
        itemProtocols: [BlackboardItemProtocol],
        blackboardTrees: [TreeItem],
        miniatureMap: MiniatureMap?,
        snapshotData: SnapshotData? = nil,
        shouldForceUpdateConstructionName: Bool = false,
        createdUser: User? = nil,
        updatedUser: User? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        isDuplicated: Bool = false,
        position: Int? = nil,
        originalBlackboardID: Int? = nil
    ) -> Self {
        .init(
            id: id,
            blackboardTemplateID: blackboardTemplateID,
            layoutTypeID: layoutTypeID,
            photoCount: photoCount,
            blackboardTheme: blackboardTheme,
            itemProtocols: itemProtocols,
            blackboardTrees: blackboardTrees,
            miniatureMap: miniatureMap,
            snapshotData: snapshotData,
            shouldForceUpdateConstructionName: shouldForceUpdateConstructionName,
            createdUser: createdUser,
            updatedUser: updatedUser,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDuplicated: isDuplicated,
            position: position,
            originalBlackboardID: originalBlackboardID
        )
    }
}

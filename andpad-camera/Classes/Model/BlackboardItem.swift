//
//  BlackboardItem.swift
//  andpad-camera
//
//  Created by Michitoshi.Tabata on 2020/04/16.
//

import Foundation

enum BlackboardItemType {
    /// 案件名、項目内容、設定された施工者名
    case textField
    /// 備考欄
    case textArea
    /// 撮影日
    case date
    case memoStyle
    case theme
    case alpha

    func height() -> CGFloat {
        switch self {
        case .textField, .date:
            return 80.0
        case .textArea:
            return 150.0
        case .memoStyle:
            return 242.0
        case .theme:
            return 96.0
        case .alpha:
            return 90.0
        }
    }
}

public enum BlackboardKey {
    case constractionName
    case constractionPlace
    case constractionPlayer
    case constractionCategory
    case constructionState
    case constructionPhotoClass
    case photoTitle
    case inspectionReportTitle
    case inspectionItem
    case inspectionTitle
    case inspectionPoint
    case inspector
    case client
    case detail
    case date
    case memo
    case alpha

    func defaultType() -> BlackboardItemType? {
        switch self {
        case .constractionName,
             .constractionPlace,
             .constractionPlayer,
             .constractionCategory,
             .constructionState,
             .constructionPhotoClass,
             .photoTitle,
             .detail,
             .inspectionReportTitle,
             .inspectionItem,
             .inspectionTitle,
             .inspectionPoint,
             .inspector,
             .client:
            return .textField
        case .date:
            return .date
        case .memo:
            return .textArea
        case .alpha:
            return .alpha
        }
    }

    func defaultName() -> String {
        switch self {
        case .constractionName:
            return L10n.Blackboard.DefaultName.constractionName
        case .constractionPlace:
            return L10n.Blackboard.DefaultName.constractionPlace
        case .constractionPlayer:
            return L10n.Blackboard.DefaultName.constractionPlayer
        case .constractionCategory:
            return L10n.Blackboard.DefaultName.constractionCategory
        case .constructionState:
            return L10n.Blackboard.DefaultName.constructionState
        case .constructionPhotoClass:
            return L10n.Blackboard.DefaultName.constructionPhotoClass
        case .photoTitle:
            return L10n.Blackboard.DefaultName.photoTitle
        case .detail:
            return L10n.Blackboard.DefaultName.detail
        case .inspectionReportTitle:
            return L10n.Blackboard.DefaultName.inspectionReportTitle
        case .inspectionItem:
            return L10n.Blackboard.DefaultName.inspectionItem
        case .inspectionTitle:
            return L10n.Blackboard.DefaultName.inspectionTitle
        case .inspectionPoint:
            return L10n.Blackboard.DefaultName.inspectionPoint
        case .inspector:
            return L10n.Blackboard.DefaultName.inspector
        case .client:
            return L10n.Blackboard.DefaultName.client
        case .date:
            return L10n.Blackboard.DefaultName.date
        case .memo:
            return L10n.Blackboard.DefaultName.memo
        case .alpha:
            return L10n.Blackboard.DefaultName.alpha
        }
    }
}

final class BlackboardItem {
    let key: BlackboardKey
    let name: String
    let value: String?

    // 優先タイプ（ = 指定がある場合は、こちらの値を適用）
    private let prioritizedType: BlackboardItemType?
    private let potision: Int?

    init(key: BlackboardKey) {
        self.key = key
        self.name = key.defaultName()
        value = nil
        prioritizedType = key.defaultType()
        potision = nil
    }

    init(
        key: BlackboardKey,
        name: String
    ) {
        self.key = key
        self.name = name
        value = nil
        prioritizedType = key.defaultType()
        potision = nil
    }

    init(
        key: BlackboardKey,
        type: BlackboardItemType?,
        value: String?,
        name: String,
        potision: Int?
    ) {
        self.key = key
        self.name = name
        self.value = value
        prioritizedType = type ?? key.defaultType()
        self.potision = potision
    }
}

extension BlackboardItem {
    var type: BlackboardItemType? {
        prioritizedType ?? key.defaultType()
    }
}

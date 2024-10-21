//
//  BlackBoard.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/25.
//

import Foundation

public struct BlackBoard {
    public let constractionName: String

    public let constractionPlace: String

    public let constractionPlayer: String

    public let constractionCategory: String

    public let constractionState: String

    public let constractionPhotoClass: String

    public let photoTitle: String

    public let detail: String

    public let memo: String

    public let initFrame: CGRect?

    public let date: Date

    public let inspectionReportTitle: String

    public let inspectionItem: String

    public let inspectionTitle: String

    public let inspectionPoint: String

    public let inspector: String

    public let client: String

    public let type: BlackBoardType

    public let alpha: CGFloat

    public init(
        constractionName: String,
        constractionPlace: String,
        constractionPlayer: String,
        memo: String,
        constractionCategory: String,
        constractionState: String,
        constractionPhotoClass: String,
        photoTitle: String,
        detail: String,
        date: Date = Date(),
        inspectionReportTitle: String,
        inspectionItem: String,
        inspectionTitle: String,
        inspectionPoint: String,
        inspector: String,
        client: String,
        initFrame: CGRect? = nil,
        type: BlackBoardType,
        alpha: CGFloat = 1.0
    ) {
        self.constractionName = constractionName
        self.constractionPlace = constractionPlace
        self.constractionPlayer = constractionPlayer
        self.memo = memo
        self.constractionCategory = constractionCategory
        self.constractionState = constractionState
        self.constractionPhotoClass = constractionPhotoClass
        self.photoTitle = photoTitle
        self.detail = detail
        self.initFrame = initFrame
        self.date = date
        self.inspectionReportTitle = inspectionReportTitle
        self.inspectionItem = inspectionItem
        self.inspectionTitle = inspectionTitle
        self.inspectionPoint = inspectionPoint
        self.inspector = inspector
        self.client = client
        self.type = type
        self.alpha = alpha
    }
}

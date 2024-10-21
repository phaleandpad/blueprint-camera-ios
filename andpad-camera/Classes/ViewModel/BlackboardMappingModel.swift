//
//  BlackboardMappingModel.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/24.
//

import Foundation

open class BlackboardMappingModel {

    public var constractionName: String?

    public var constractionPlace: String?

    public var memo: String?

    public var constractionPlayer: String?

    public var constractionCategory: String?

    public var constractionState: String?

    public var constractionPhotoClass: String?

    public var photoTitle: String?

    public var detail: String?

    public var inspectionReportTitle: String?

    public var inspectionItem: String?

    public var inspectionTitle: String?

    public var inspectionPoint: String?

    public var inspector: String?

    public var client: String?

    public var date: Date?

    public var initFrame: CGRect?

    public var type: BlackBoardType?

    public var alpha: CGFloat = 1.0

    public func setModel(model: BlackBoard?) {
        self.constractionName = model?.constractionName
        self.constractionPlace = model?.constractionPlace
        self.memo = model?.memo
        self.constractionPlayer = model?.constractionPlayer
        self.constractionCategory = model?.constractionCategory
        self.constractionState = model?.constractionState
        self.constractionPhotoClass = model?.constractionPhotoClass
        self.photoTitle = model?.photoTitle
        self.detail = model?.detail
        self.date = model?.date
        self.inspectionReportTitle = model?.inspectionReportTitle
        self.inspectionItem = model?.inspectionItem
        self.inspectionTitle = model?.inspectionTitle
        self.inspectionPoint = model?.inspectionPoint
        self.inspector = model?.inspector
        self.client = model?.client
        self.initFrame = model?.initFrame
        self.type = model?.type
        self.alpha = model?.alpha ?? 1.0
    }

    public func toModel() -> BlackBoard {
        return BlackBoard(
            constractionName: constractionName ?? "",
            constractionPlace: constractionPlace ?? "",
            constractionPlayer: constractionPlayer ?? "",
            memo: memo ?? "",
            constractionCategory: constractionCategory ?? "",
            constractionState: constractionState ?? "",
            constractionPhotoClass: constractionPhotoClass ?? "",
            photoTitle: photoTitle ?? "",
            detail: detail ?? "",
            date: date ?? Date(),
            inspectionReportTitle: inspectionReportTitle ?? "",
            inspectionItem: inspectionItem ?? "",
            inspectionTitle: inspectionTitle ?? "",
            inspectionPoint: inspectionPoint ?? "",
            inspector: inspector ?? "",
            client: client ?? "",
            initFrame: initFrame,
            type: self.type ?? BlackBoardType.case0,
            alpha: alpha
        )
    }
}

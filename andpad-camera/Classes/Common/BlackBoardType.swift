//
//  BlackBoardType.swift
//  andpad-camera
//
//  Created by Toshihiro Taniguchi on 2018/04/17.
//

import UIKit

// swiftlint:disable:next convenience_type
class BlackBoardTypeManager {
    static var inspectionTemplateEnabled = false
    
    static func getType() -> [BlackBoardType] {
        if inspectionTemplateEnabled {
            return [
                .inspectionCase0,
                .inspectionCase1,
                .inspectionCase2,
                .inspectionCase3,
                .inspectionCase4,
                .inspectionCase5,
                .inspectionCase6,
                .inspectionCase7,
                .inspectionCase8,
                .inspectionCase9,
                .case0,
                .case1,
                .case2,
                .case3,
                .case4,
                .case5,
                .case6,
                .case7,
                .case8,
                .case9,
                .case10
            ]
        } else {
            return [
                .case0,
                .case1,
                .case2,
                .case3,
                .case4,
                .case5,
                .case6,
                .case7,
                .case8,
                .case9,
                .case10
            ]
        }
    }
}

public enum BlackBoardType {
    case image

    case case0 // デフォルト normal2と同じ
    case case1
    case case2
    case case3
    case case4
    case case5
    case case6
    case case7
    case case8
    case case9
    case case10

    case inspectionCase0
    case inspectionCase1
    case inspectionCase2
    case inspectionCase3
    case inspectionCase4
    case inspectionCase5
    case inspectionCase6
    case inspectionCase7
    case inspectionCase8
    case inspectionCase9

    func getFrame() -> CGRect {
        return CGRect(x: 0.0, y: 0.0, width: 300, height: 230)
    }

    func getActualFrame() -> CGRect {
        return CGRect(x: 0.0, y: 0.0, width: 310, height: 240)
    }

    public init?(with string: String) {
        switch string {
        case  "Case0":
            self = .case0
        case "Case1":
            self = .case1
        case "Case2":
            self = .case2
        case "Case3":
            self = .case3
        case "Case4":
            self = .case4
        case "Case5":
            self = .case5
        case "Case6":
            self = .case6
        case "Case7":
            self = .case7
        case "Case8":
            self = .case8
        case "Case9":
            self = .case9
        case "Case10":
            self = .case10
        case "InspectionCase0":
            self = .inspectionCase0
        case "InspectionCase1":
            self = .inspectionCase1
        case "InspectionCase2":
            self = .inspectionCase2
        case "InspectionCase3":
            self = .inspectionCase3
        case "InspectionCase4":
            self = .inspectionCase4
        case "InspectionCase5":
            self = .inspectionCase5
        case "InspectionCase6":
            self = .inspectionCase6
        case "InspectionCase7":
            self = .inspectionCase7
        case "InspectionCase8":
            self = .inspectionCase8
        case "InspectionCase9":
            self = .inspectionCase9
        case "BlackboardImageView":
            self = .image
        default:
            return nil
        }
    }

    public func getNibName() -> String {
        switch self {
        case .case0:
            return "Case0"
        case .case1:
            return "Case1"
        case .case2:
            return "Case2"
        case .case3:
            return "Case3"
        case .case4:
            return "Case4"
        case .case5:
            return "Case5"
        case .case6:
            return "Case6"
        case .case7:
            return "Case7"
        case .case8:
            return "Case8"
        case .case9:
            return "Case9"
        case .case10:
            return "Case10"
        case .inspectionCase0:
            return "InspectionCase0"
        case .inspectionCase1:
            return "InspectionCase1"
        case .inspectionCase2:
            return "InspectionCase2"
        case .inspectionCase3:
            return "InspectionCase3"
        case .inspectionCase4:
            return "InspectionCase4"
        case .inspectionCase5:
            return "InspectionCase5"
        case .inspectionCase6:
            return "InspectionCase6"
        case .inspectionCase7:
            return "InspectionCase7"
        case .inspectionCase8:
            return "InspectionCase8"
        case .inspectionCase9:
            return "InspectionCase9"
        case .image:
            return "BlackboardImageView"
        }
    }

    var isInspection: Bool {
        switch self {
        case .inspectionCase0, .inspectionCase1, .inspectionCase2, .inspectionCase3, .inspectionCase4,
             .inspectionCase5, .inspectionCase6, .inspectionCase7, .inspectionCase8, .inspectionCase9:
            return true
        default:
            return false
        }
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    func getItems() -> [BlackboardItem] {
        func generateBlackboardItemByLayout(
            by items: [ModernBlackboardLayout.Item],
            key: BlackboardKey,
            position: Int,
            type: BlackboardItemType
        ) -> BlackboardItem? {
            let item = items.first(where: { $0.position == position })
            guard let item else {
                return nil
            }
            return BlackboardItem(
                key: key,
                type: type,
                value: nil,
                name: item.itemName,
                potision: position
            )
        }

        func generateBlackboardItemByMaterial(
            by items: [ModernBlackboardMaterial.Item],
            key: BlackboardKey,
            position: Int,
            type: BlackboardItemType
        ) -> BlackboardItem? {
            let item = items.first(where: { $0.position == position })
            guard let item else {
                return nil
            }
            return BlackboardItem(
                key: key,
                type: type,
                value: item.body,
                name: item.itemName,
                potision: position
            )
        }

        switch self {
        case .case0:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .constractionCategory),
                BlackboardItem(key: .constractionPlace, name: "測点"),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .date),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case1:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case2:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .constractionPlace),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case3:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .constractionCategory),
                BlackboardItem(key: .constractionPlace, name: "測点"),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case4:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .constractionPlace),
                BlackboardItem(key: .constructionState),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case5:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .constractionPlace),
                BlackboardItem(key: .constructionPhotoClass),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case6:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .date),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case7:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .photoTitle),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case8:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .detail),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .date),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case9:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .constructionState),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .date),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .case10:
            return [
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .date),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase0:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .inspectionReportTitle),
                BlackboardItem(key: .inspectionTitle),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .date),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase1:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .inspectionReportTitle),
                BlackboardItem(key: .inspectionItem),
                BlackboardItem(key: .date),
                BlackboardItem(key: .inspector),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase2:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .inspectionReportTitle),
                BlackboardItem(key: .inspectionItem),
                BlackboardItem(key: .date),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .inspector),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase3:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .inspectionItem),
                BlackboardItem(key: .inspectionPoint),
                BlackboardItem(key: .date),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .inspector),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase4:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .client),
                BlackboardItem(key: .inspectionPoint),
                BlackboardItem(key: .date),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .inspector),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase5:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .client),
                BlackboardItem(key: .inspectionItem),
                BlackboardItem(key: .date),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .inspector),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase6:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .inspectionReportTitle),
                BlackboardItem(key: .inspectionTitle),
                BlackboardItem(key: .inspectionPoint),
                BlackboardItem(key: .date),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase7:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .inspectionReportTitle),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .date),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase8:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .inspectionTitle),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .date),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .alpha)
            ]
        case .inspectionCase9:
            return [
                BlackboardItem(key: .constractionName),
                BlackboardItem(key: .inspectionItem),
                BlackboardItem(key: .memo),
                BlackboardItem(key: .date),
                BlackboardItem(key: .constractionPlayer),
                BlackboardItem(key: .alpha)
            ]
        case .image:
            return []
        }
    }

    // swiftlint:disable:next todo
    // FIXME ViewModelで隠蔽する
    func getValues(viewModel: BlackboardMappingModel) -> [Any?] {
        let items = getItems()
        var values = [Any?](repeating: nil, count: items.count)
        items.enumerated().forEach { index, elm in
            switch elm.key {
            case .constractionName:
                values[index] = viewModel.constractionName
            case .constractionPlace:
                values[index] = viewModel.constractionPlace
            case .constractionPlayer:
                values[index] = viewModel.constractionPlayer
            case .constractionCategory:
                values[index] = viewModel.constractionCategory
            case .constructionState:
                values[index] = viewModel.constractionState
            case .constructionPhotoClass:
                values[index] = viewModel.constractionPhotoClass
            case .photoTitle:
                values[index] = viewModel.photoTitle
            case .detail:
                values[index] = viewModel.detail
            case .inspectionReportTitle:
                values[index] = viewModel.inspectionReportTitle
            case .inspectionItem:
                values[index] = viewModel.inspectionItem
            case .inspectionTitle:
                values[index] = viewModel.inspectionTitle
            case .inspectionPoint:
                values[index] = viewModel.inspectionPoint
            case .inspector:
                values[index] = viewModel.inspector
            case .client:
                values[index] = viewModel.client
            case .date:
                values[index] = viewModel.date?.asDateString()
            case .memo:
                values[index] = viewModel.memo
            case .alpha:
                values[index] = viewModel.alpha
            }
        }
        return values
    }

    // swiftlint:disable:next todo
    // FIXME: ViewModelで隠蔽する
    func setViewModelParams(
        _ viewModel: BlackboardMappingModel,
        items: [BlackboardItem],
        values: [Any?]
    ) {
        items.enumerated().forEach { index, elm in
            switch elm.key {
            case .constractionName:
                viewModel.constractionName = values[index] as? String
            case .constractionPlace:
                viewModel.constractionPlace = values[index] as? String
            case .constractionPlayer:
                viewModel.constractionPlayer = values[index] as? String
            case .constractionCategory:
                viewModel.constractionCategory = values[index] as? String
            case .constructionState:
                viewModel.constractionState = values[index] as? String
            case .constructionPhotoClass:
                viewModel.constractionPhotoClass = values[index] as? String
            case .photoTitle:
                viewModel.photoTitle = values[index] as? String
            case .detail:
                viewModel.detail = values[index] as? String
            case .date:
                viewModel.date = (values[index] as? String)?.asDateFromDateString()
            case .inspectionReportTitle:
                viewModel.inspectionReportTitle = values[index] as? String
            case .inspectionItem:
                viewModel.inspectionItem = values[index] as? String
            case .inspectionTitle:
                viewModel.inspectionTitle = values[index] as? String
            case .inspectionPoint:
                viewModel.inspectionPoint = values[index] as? String
            case .inspector:
                viewModel.inspector = values[index] as? String
            case .client:
                viewModel.client = values[index] as? String
            case .memo:
                viewModel.memo = values[index] as? String
            case .alpha:
                viewModel.alpha = (values[index] as? CGFloat) ?? 1.0
            }
        }
    }

    func getTemplateImage(view: UIView? = nil, isHiddenValues: Bool) -> UIImage? {
        guard let newView = BlackBoardView.getView(type: self),
              let blackboardView = newView as? BlackBoardView else {
            return nil
        }

        if let view {
            view.addSubview(blackboardView)
        }

        // UIImage出力
        if isHiddenValues {
            blackboardView.hideValues()
        }

        do {
            let image = try blackboardView.toImage()
            if isHiddenValues {
                blackboardView.showValues()
            }

            blackboardView.removeFromSuperview()
            return image
        } catch {
            print(error)
            return nil
        }
    }
}

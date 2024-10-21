//
//  BlackboardFilterConditionsHistoryLabelsView.swift
//  andpad-camera
//
//  Created by msano on 2022/01/17.
//

import Instantiate
import InstantiateStandard

final class BlackboardFilterConditionsHistoryLabelsView: UIView {
    struct Dependency {
        let type: ViewType
        let content: String
    }
    
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
}

extension BlackboardFilterConditionsHistoryLabelsView {
    private func configureView(type: ViewType, content: String) {
        titleImageView.image = type.titleImage
        titleLabel.text = type.title
        contentLabel.text = content
    }
}

// MARK: - ViewType
extension BlackboardFilterConditionsHistoryLabelsView {
    enum ViewType {
        case photo
        case blackboardItem
        case memo
        case freeword
        
        var titleImage: UIImage {
            switch self {
            case .photo:
                return Asset.iconCommonGreyPhoto.image
            case .blackboardItem:
                return Asset.iconCommonGreyBoard.image
            case .memo:
                return Asset.iconCommonGreyDocument.image
            case .freeword:
                return Asset.iconCommonGreySearchGlossy.image
            }
        }
        
        var title: String {
            switch self {
            case .photo:
                return L10n.Blackboard.Filter.existPhoto
            case .blackboardItem:
                return L10n.Blackboard.Filter.item
            case .memo:
                return L10n.Blackboard.Filter.memo
            case .freeword:
                return L10n.Blackboard.Filter.freeword
            }
        }
    }
}

// MARK: - NibType
extension BlackboardFilterConditionsHistoryLabelsView: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension BlackboardFilterConditionsHistoryLabelsView: NibInstantiatable {
    func inject(_ dependency: Dependency) {
        configureView(
            type: dependency.type,
            content: dependency.content
        )
    }
}

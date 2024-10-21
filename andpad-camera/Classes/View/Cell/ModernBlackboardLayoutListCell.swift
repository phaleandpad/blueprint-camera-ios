//
//  ModernBlackboardLayoutListCell.swift
//  andpad-camera
//
//  Created by msano on 2022/04/01.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

final class ModernBlackboardLayoutListCell: UICollectionViewCell {
    struct Dependency {
        let layoutName: String
        let blackboardImageLoader: any ImageLazyLoading
    }

    // IBOutlet
    @IBOutlet private weak var layoutImageView: UIImageView!
    @IBOutlet private weak var layoutNameLabel: UILabel!
}

// MARK: - private
extension ModernBlackboardLayoutListCell {
    private func configureCell(layoutName: String, blackboardImageLoader: any ImageLazyLoading) {
        layoutNameLabel.text = layoutName
        layoutImageView.image = blackboardImageLoader.load()
    }
}

// MARK: - NibType
extension ModernBlackboardLayoutListCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension ModernBlackboardLayoutListCell: Reusable {
    func inject(_ dependency: Dependency) {
        configureCell(
            layoutName: dependency.layoutName,
            blackboardImageLoader: dependency.blackboardImageLoader
        )
    }
}

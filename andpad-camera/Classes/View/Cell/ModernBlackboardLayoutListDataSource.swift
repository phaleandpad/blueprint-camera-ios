//
//  ModernBlackboardLayoutListDataSource.swift
//  andpad-camera
//
//  Created by msano on 2022/04/01.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

// MARK: - ModernBlackboardLayoutListDataSource
final class ModernBlackboardLayoutListDataSource: RxCollectionViewSectionedReloadDataSource<ModernBlackboardLayoutListDataSource.Section> {
    var tappedEmptyViewHandler: (() -> Void)?

    convenience init() {

        // MARK: - configureCell
        let configureCell: ModernBlackboardLayoutListDataSource.ConfigureCell = { _, collectionView, indexPath, item in
            let cell = ModernBlackboardLayoutListCell.dequeue(
                from: collectionView,
                for: indexPath,
                with: .init(layoutName: item.layoutName, blackboardImageLoader: item.blackboardImageLoader)
            )
            return cell
        }
        
        // MARK: - configureSupplementaryView
        let configureSupplementaryView: ConfigureSupplementaryView? = { _, collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
            return ModernBlackboardLayoutListHeaderView.dequeue(
                from: collectionView,
                of: UICollectionView.elementKindSectionHeader,
                for: indexPath,
                with: .init()
            )
        }
        
        self.init(
            configureCell: configureCell,
            configureSupplementaryView: configureSupplementaryView
        )
    }
}

// MARK: - UICollectionViewDelegate
extension ModernBlackboardLayoutListDataSource: UICollectionViewDelegate {}

// MARK: - Section
extension ModernBlackboardLayoutListDataSource {
    struct Section: SectionModelType {
        typealias Item = (
            layoutPattern: ModernBlackboardContentView.Pattern,
            layoutName: String,
            blackboardImageLoader: any ImageLazyLoading
        )

        var items: [Item]
        
        init(
            original: ModernBlackboardLayoutListDataSource.Section,
            items: [Item]
        ) {
            self = original
            self.items = items
        }
        
        init(items: [Item]) {
            self.items = items
        }
    }
}

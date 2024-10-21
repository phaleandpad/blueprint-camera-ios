//
//  UICollectionView+Extension.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2020/12/23.
//

import UIKit

extension UICollectionView {
    
    func register(_ cellType: UICollectionViewCell.Type) {
        register(
            cellType,
            forCellWithReuseIdentifier: .init(describing: cellType)
        )
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(
        _ cellType: T.Type,
        for indexPath: IndexPath
    ) -> T {

        if let cell = dequeueReusableCell(
            withReuseIdentifier: .init(describing: cellType),
            for: indexPath
        ) as? T {
            return cell
        }

        fatalError("Not registered cell.")
    }

    func selectItemProgrammatically(
        at indexPath: IndexPath,
        animated: Bool,
        scrollPosition: UICollectionView.ScrollPosition
    ) {
        // Note: selectItem does not cause any selection-related delegate methods to be called.

        selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        delegate?.collectionView?(self, didSelectItemAt: indexPath)
    }

    func deselectItemProgrammatically(
        at indexPath: IndexPath,
        animated: Bool
    ) {
        // Note: deselectItem does not cause any selection-related delegate methods to be called.

        deselectItem(at: indexPath, animated: animated)
        delegate?.collectionView?(self, didDeselectItemAt: indexPath)
    }
}

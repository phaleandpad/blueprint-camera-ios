//
//  ThumbnailImageScrollView.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2020/11/16.
//

import EasyPeasy
import UIKit

final class ThumbnailImageScrollView: UIView {

    private typealias Cell = WrapperCollectionViewCell<PreviewImageView>

    private let maximumImageSize: CGSize = {
        let scale = UIScreen.main.scale

        return .init(
            width: 88.0 * scale,
            height: 88.0 * scale
        )
    }()

    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 8.0
        flowLayout.minimumInteritemSpacing = 8.0

        return .init(
            frame: .zero,
            collectionViewLayout: flowLayout
        )
    }()

    var imageKeys: [DiskImageStore.Key] = []

    var didSelectImage: (Int) -> Void = { _ in }
    private let imageStore: DiskImageStore

    init(imageStore: DiskImageStore) {
        self.imageStore = imageStore

        super.init(frame: .zero)

        collectionView.backgroundColor = .white

        collectionView.isDirectionalLockEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = true

        collectionView.register(Cell.self)

        collectionView.delegate = self
        collectionView.dataSource = self

        setAccessibilityIdentifiers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(collectionView)

        collectionView.easy.layout(Edges())
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let length = bounds.size.height
        flowLayout.estimatedItemSize = .init(width: length, height: length)
    }

    func set(imageKeys: [DiskImageStore.Key]) {
        self.imageKeys = imageKeys
        collectionView.reloadData()
    }

    func move(to index: Int) {
        let indexPath = IndexPath(item: index, section: 0)

        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.deselectItemProgrammatically(
                at: selectedIndexPath, animated: true
            )
        }
        
        collectionView.selectItemProgrammatically(
            at: indexPath,
            animated: true,
            scrollPosition: .left
        )
    }

    func remove(at index: Int) {

        guard index < imageKeys.count else {
            assertionFailure("Invalid index")
            return
        }

        collectionView.performBatchUpdates({
            imageKeys.remove(at: index)
            collectionView.deleteItemsAtIndexPaths(
                [.init(item: index, section: 0)],
                animationStyle: .automatic
            )
        })
    }

    private func setAccessibilityIdentifiers() {
        collectionView.viewAccessibilityIdentifier = .photoPreviewThumbnailImageScrollView
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ThumbnailImageScrollView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageKeys.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(Cell.self, for: indexPath)
        let key = imageKeys[indexPath.item]

        imageStore.resizedImage(for: key, targetSize: maximumImageSize) { image in
            DispatchQueue.main.async {
                cell.update {
                    $0.layer.opacity = cell.isSelected ? 1.0 : 0.5
                    $0.image = image
                }
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectImage(indexPath.item)

        (collectionView.cellForItem(at: indexPath) as? Cell)?.update {
            $0.layer.opacity = 1.0
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? Cell)?.update {
            $0.layer.opacity = 0.5
        }
    }
}

extension ThumbnailImageScrollView {
    private final class PreviewImageView: UIImageView, WrappableView {

        static func makeForWrapper() -> Self {
            let view = Self()

            view.backgroundColor = .white
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill

            return view
        }

        func prepareForReuse() {
            image = nil
        }
    }
}

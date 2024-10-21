//
//  MainImageScrollView.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2020/11/16.
//

import EasyPeasy
import UIKit

final class MainImageScrollView: UIView {

    private typealias Cell = WrapperCollectionViewCell<PreviewImageView>

    static let maximumImageSize: CGSize = {
        let screenSize = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale

        return .init(
            width: screenSize.width * scale,
            height: screenSize.height * scale
        )
    }()

    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0

        return .init(
            frame: .zero,
            collectionViewLayout: flowLayout
        )
    }()

    private var imageKeys: [DiskImageStore.Key] = []
    var currentPage: Int {
        if bounds.width == 0 {
            return 0
        }

        return Int((collectionView.contentOffset.x + (0.5 * bounds.width)) / bounds.width)
    }

    private weak var imageStore: DiskImageStore?

    init(imageStore: DiskImageStore) {
        self.imageStore = imageStore

        super.init(frame: .zero)

        collectionView.backgroundColor = .white

        collectionView.isPagingEnabled = true
        collectionView.isDirectionalLockEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = true

        collectionView.register(Cell.self)

        collectionView.dataSource = self

        setAccessibilityIdentifiers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDelegate(_ delegate: UIScrollViewDelegate?) {
        (collectionView as UIScrollView).delegate = delegate
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

        flowLayout.estimatedItemSize = bounds.size
    }

    func set(imageKeys: [DiskImageStore.Key]) {
        self.imageKeys = imageKeys
        collectionView.reloadData()
    }

    func move(to index: Int) {

        // Note: Workaround of scroll bug for iOS14
        collectionView.isPagingEnabled = false
        
        collectionView.scrollToItem(
            at: .init(item: index, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
        
        collectionView.isPagingEnabled = true
    }

    func removeCurrentImage() {

        let targetIndex = currentPage
        guard targetIndex < imageKeys.count else {
            assertionFailure("Invalid index")
            return
        }

        collectionView.performBatchUpdates({
            imageKeys.remove(at: targetIndex)
            collectionView.deleteItemsAtIndexPaths(
                [.init(item: targetIndex, section: 0)],
                animationStyle: .automatic
            )
        })
    }

    private func setAccessibilityIdentifiers() {
        collectionView.viewAccessibilityIdentifier = .photoPreviewMainImageScrollView
    }
}

extension MainImageScrollView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageKeys.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(Cell.self, for: indexPath)
        let key = imageKeys[indexPath.item]

        imageStore?.resizedImage(for: key, targetSize: Self.maximumImageSize) { image in
            DispatchQueue.main.async {
                cell.update { $0.image = image }
            }
        }

        return cell
    }
}

extension MainImageScrollView {
    private final class PreviewImageView: UIImageView, WrappableView {

        static func makeForWrapper() -> Self {
            let view = Self()

            view.backgroundColor = .white
            view.contentMode = .scaleAspectFit

            return view
        }

        func prepareForReuse() {
            image = nil
        }
    }
}

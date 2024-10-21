//
//  ModernBlackboardLayoutListViewController.swift
//  andpad-camera
//
//  Created by msano on 2022/04/01.
//

import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift

final class ModernBlackboardLayoutListViewController: UIViewController {
    typealias ViewModel = ModernBlackboardLayoutListViewModel
    
    private let disposeBag = DisposeBag()
    
    private let willDismissRelay = PublishRelay<Void>()
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    struct Dependency {
        let viewModel: ViewModel
    }

    private var viewModel: ViewModel!
    
    // subscribe対象
    var selectNewLayoutPatternSignal: Signal<ModernBlackboardContentView.Pattern> {
        selectNewLayoutPatternRelay.asSignal()
    }
    private let selectNewLayoutPatternRelay = PublishRelay<ModernBlackboardContentView.Pattern>()
    
    // MARK: - LayoutParams
    private enum LayoutParams {
        // CollectionView
        static let collectionViewMinimumInteritemSpacing: CGFloat = 16
        static let collectionViewDefaultSectionInset: UIEdgeInsets = .init(
            top: 0,
            left: 16,
            bottom: 16,
            right: 16
        )
        
        // Cell
        static let cellMaxWidth: CGFloat = 300
        static let cellHeight: CGFloat = 60
        static let cellHeightWithoutBlackboardImage: CGFloat = 22
        
        static let cellSpacerWidth: CGFloat = 16
        static let cellCountIntoColumn: CGFloat = 2
        static let cellSpacerCount: CGFloat = cellCountIntoColumn - 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addBinding()
        viewModel.inputPort.accept(.viewDidLoad)
    }
}

// MARK: - private
extension ModernBlackboardLayoutListViewController {
    private func configureView() {
        // configure NavigationBar
        title = viewModel.title
        navigationController?.navigationBar.setModalBar()
        
        let leftBarCancelButton: UIBarButtonItem = .init(
            image: Asset.iconCancel.image,
            style: .plain,
            target: self,
            action: nil
        )
        navigationItem.setLeftBarButton(leftBarCancelButton, animated: true)
        navigationItem.leftBarButtonItem?.tintColor = .hexStr("6A6A6A", alpha: 1.0)
        navigationItem.backBarButtonItem = ModernBlackboardNavigationController.plainBackButton
        
        // configure CollectionView
        collectionView.registerNib(type: ModernBlackboardLayoutListCell.self)
        collectionView.registerNib(
            type: ModernBlackboardLayoutListHeaderView.self,
            forSupplementaryViewOf: UICollectionView.elementKindSectionHeader
        )
        
        collectionView.rx.setDelegate(viewModel.dataSource)
            .disposed(by: disposeBag)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = .init(
                width: .zero,
                height: ModernBlackboardLayoutListHeaderView.viewHeight
            )
            layout.minimumInteritemSpacing = LayoutParams.collectionViewMinimumInteritemSpacing
            layout.sectionInset = LayoutParams.collectionViewDefaultSectionInset
            layout.itemSize = getCellSize(layout: layout)
            collectionView.setCollectionViewLayout(layout, animated: true)
        }
    }
    
    private func getCellSize(layout: UICollectionViewFlowLayout) -> CGSize {
        // width算出
        let allCellSpaces = LayoutParams.cellSpacerWidth * LayoutParams.cellSpacerCount
        let preferredWidth = (UIScreen.main.bounds.width - allCellSpaces - layout.sectionInset.left - layout.sectionInset.right) / LayoutParams.cellCountIntoColumn
        
        // 必要があればsectionInsetを更新
        updateSectionInsetIfNeeded(
            layout: layout,
            horizontalIncrement: preferredWidth - LayoutParams.cellMaxWidth
        )
        
        // 最大幅を超えたら丸める
        let width = min(preferredWidth, LayoutParams.cellMaxWidth)
        
        // widthを元にheight算出（aspect比 30:23を考慮）
        let height: CGFloat = (width / 30 * 23) + LayoutParams.cellHeightWithoutBlackboardImage

        return .init(width: width, height: height)
    }
    
    private func updateSectionInsetIfNeeded(layout: UICollectionViewFlowLayout, horizontalIncrement: CGFloat) {
        guard horizontalIncrement > 0 else { return }
        layout.sectionInset.left += horizontalIncrement
        layout.sectionInset.right += horizontalIncrement
    }

    private func addBinding() {
        // bind NabvigationBar
        navigationItem.leftBarButtonItem?.rx.tap
            .map({ ViewModel.Input.didTapCancelButton })
            .bind(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)

        // bind CollectionView
        viewModel.items
            .bind(to: collectionView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .map { [weak self] in self?.viewModel.dataSource[$0] }
            .compactMap { $0 }
            .map { ViewModel.Input.didTapCell($0) }
            .bind(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        viewModel.outputPort
            .bind(onNext: { [weak self] event in
                switch event {
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                case .selectNewLayout(let layoutItem):
                    self?.selectNewLayoutPatternRelay.accept(layoutItem.layoutPattern)
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - NibType
extension ModernBlackboardLayoutListViewController: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernBlackboardLayoutListViewController: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}

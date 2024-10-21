//
//  ModernBlackboardListViewController.swift
//  andpad-camera
//
//  Created by msano on 2022/01/05.
//

import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift
import UIKit
import AndpadUIComponent

public final class ModernBlackboardListViewController: UIViewController {
    
    enum TappedButtonType {
        case blackboardImage
        case edit
        case takePhoto
    }
    
    // subscribe対象
    var didTapBlackboardImageButtonSignal: Signal<ModernBlackboardMaterial> {
        didTapBlackboardImageButtonRelay.asSignal()
    }
    var didTapEditButtonSignal: Signal<ModernBlackboardMaterial> {
        didTapEditButtonRelay.asSignal()
    }
    var didTapTakePhotoButtonSignal: Signal<ModernBlackboardMaterial> {
        didTapTakePhotoButtonRelay.asSignal()
    }
    let disposeBag = DisposeBag()
    
    private let willDismissRelay = PublishRelay<Void>()
    
    public struct Dependency {
        let viewModel: ModernBlackboardListViewModel
        
        public init(viewModel: ModernBlackboardListViewModel) {
            self.viewModel = viewModel
        }
    }
    
    private enum Const {
        static let animateAppUpdateViewDuration: TimeInterval = 0.5
        static let animateAppUpdateViewCurve: UIView.AnimationCurve = .easeInOut
    }

    var cancelResultHandler: ((ModernBlackboardListViewModel.CancelResult) -> Void)?

    private var viewModel: ModernBlackboardListViewModel!
    
    private let didTapBlackboardImageButtonRelay = PublishRelay<ModernBlackboardMaterial>()
    private let didTapEditButtonRelay = PublishRelay<ModernBlackboardMaterial>()
    private let didTapTakePhotoButtonRelay = PublishRelay<ModernBlackboardMaterial>()
    
    private let filterHeaderView = ModernBlackboardFilterHeaderView(with: .init(searchQuery: nil))
    private let sortHeaderView = ModernBlackboardListSortView(with: .init(sortState: .idASC, total: 0))
    private let tableFooterView = UIView(frame: .init(origin: .zero, size: .zero))

    private let leftBarCancelButton: UIBarButtonItem = .init(
        image: Asset.iconCancel.image,
        style: .plain,
        target: ModernBlackboardListViewController.self,
        action: nil
    )
    private let imagePrefetcher = ImagePrefetcherHandler()

    // IBOutlet
    @IBOutlet private weak var filterHeaderContainerView: UIView!
    @IBOutlet private weak var tableView: ModernBlackboardListTableView!
    @IBOutlet private weak var appUpdateContainerView: UIView!
    @IBOutlet private weak var appUpdateContainerViewHeightConstraint: NSLayoutConstraint!
    // swiftlint:disable:next identifier_name
    @IBOutlet private weak var appUpdateContainerViewBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var offlineModeBar: OfflineModeBar!
    
    private lazy var appUpdateView: AppUpdateView = {
        let view = AppUpdateView(with: .init())
        appUpdateContainerView.addSubview(view)
        
        // add lazy binding
        view.tappedUpdateButtonSignal
            .map { ModernBlackboardListViewModel.Input.didTapAppUpdateButton }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        return view
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addBinding()

        viewModel.inputPort.accept(.viewDidLoad)
    }
}

// MARK: - private
extension ModernBlackboardListViewController {
    private func configureView() {
        overrideUserInterfaceStyle = .light
        
        // configure NavigationBar
        title = viewModel.title
        navigationController?.navigationBar.setModalBar()
        
        navigationItem.setLeftBarButton(leftBarCancelButton, animated: true)
        navigationItem.leftBarButtonItem?.tintColor = .hexStr("6A6A6A", alpha: 1.0)
        navigationItem.backBarButtonItem = ModernBlackboardNavigationController.plainBackButton
        
        // configure FilterHeaderView
        filterHeaderContainerView.addSubview(filterHeaderView)
        filterHeaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // configure TableView
        tableView.registerNib(type: ModernBlackboardListCell.self)
        tableView.registerNib(type: ModernBlackboardListEmptyWithFilteringView.self)
        tableView.rx.setDelegate(viewModel.dataSource)
            .disposed(by: disposeBag)
        
        tableView.tableFooterView = tableFooterView
        tableFooterView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(0)
        }
        
        tableView.tableHeaderView = sortHeaderView
        sortHeaderView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(ModernBlackboardListSortView.viewHeight)
        }
        
        tableView.refreshControl = UIRefreshControl()
    }

    private func addBinding() {
        // bind NavigationBar
        leftBarCancelButton.rx.tap
            .map({ ModernBlackboardListViewModel.Input.didTapCancelButton })
            .bind(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        // bind filter headerView
        filterHeaderView
            .updateSearchQuerySignal
            .skip(1)
            .map({ ModernBlackboardListViewModel.Input.updateSearchQuery($0) })
            .emit(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        filterHeaderView
            .tapFilterButtonSignal
            .map { ModernBlackboardListViewModel.Input.didTapFilterButton }
            .emit(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        // bind sort headerView
        sortHeaderView
            .changedSortStateSignal
            .skip(1)
            .map({ ModernBlackboardListViewModel.Input.receiveSortState($0) })
            .emit(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        // bind TableView
        viewModel.items
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        tableView.tappedBlackboardImageButtonRelay
            .asSignal()
            .emit(to: didTapBlackboardImageButtonRelay)
            .disposed(by: disposeBag)
        
        tableView.tappedEditButtonRelay
            .asSignal()
            .emit(to: didTapEditButtonRelay)
            .disposed(by: disposeBag)
        
        tableView.tappedTakePhotoButtonRelay
            .asSignal()
            .emit(to: didTapTakePhotoButtonRelay)
            .disposed(by: disposeBag)

        tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .compactMap { [weak self] in self?.tableView.refreshControl?.isRefreshing }
            .filter { $0 }
            .do(onNext: { [weak self] _ in
                // [workaround] 稀にrefreshControlが終わらないことがあるため、好ましくないが2秒後には終了させる
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            })
            .map { _ in ModernBlackboardListViewModel.Input.pullToRefresh }
            .bind(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        tableView.rx.prefetchRows
            .map { ModernBlackboardListViewModel.Input.prefetchRows($0) }
            .bind(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        tableView.rx.cancelPrefetchingForRows
            .map { ModernBlackboardListViewModel.Input.cancelPrefetchingForRows($0) }
            .bind(to: viewModel.inputPort)
            .disposed(by: disposeBag)

        viewModel.dataSource.scrolledDownSignal
            .map { ModernBlackboardListViewModel.Input.scrolledDown }
            .emit(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        viewModel.dataSource.isScrollEnabledSignal
            // omit bypassing view model
            .emit(onNext: { [weak self] in
                self?.tableView.isScrollEnabled = $0
            })
            .disposed(by: disposeBag)

        viewModel.outputPort
            .bind(onNext: { [weak self] event in
                guard let self else { return }
                switch event {
                case .doneFetching:
                    self.tableView.refreshControl?.endRefreshing()
                    self.filterHeaderView.enablePhotoConditionButton()
                    self.sortHeaderView.enableSortButton()
                case .pop:
                    self.navigationController?.popViewController(animated: true)
                case .dismiss(let cancelResult):
                // xボタン押下時の挙動（裏に編集画面がある場合はそれも閉じる）
                //  -> しかし今のままだと2重3重に同種のVCを重ねることができてしまうので、ちょっと対策考えないとまずい
                    if let cancelResult {
                        cancelResultHandler?(cancelResult)
                    }
                    guard self.hasEditBlackboardViewController else {
                        self.dismiss(animated: true)
                        return
                    }
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                case .presentFilterConditions(let args):
                    self.present(
                        UINavigationController(
                            rootViewController: AppDependencies.shared.modernBlackboardFilterConditionsViewController(args)
                        ),
                        animated: true
                    )
                    
                case .push(let viewController):
                    self.navigationController?.pushViewController(
                        viewController,
                        animated: true
                    )
                case .showLoadingView:
                    self.showLoading()
                case .hideLoadingView:
                    self.hideLoading()
                case .showErrorMessage(let error):
                    present(
                        UIAlertController.errorAlertWithRetryButton(
                            error: error,
                            retryHandler: { [weak self] _ in
                                self?.viewModel.inputPort.accept(.didTapRetryRequestButton)
                            },
                            cancelHandler: { [weak self] _ in
                                self?.viewModel.inputPort.accept(.didTapDestructiveButton)
                            }
                        ),
                        animated: true
                    )
                case .changeFilterButtonState(let hasSearchQuery):
                    guard let item = self.navigationItem.rightBarButtonItem,
                          item.isEnabled else { return }
                    let image = FilterIconState(hasSearchQuery).image
                    self.navigationItem.rightBarButtonItem?.image = image
                case .changeShowingFilterHeaderContainerView(let isHidden):
                    self.filterHeaderContainerView.isHidden = isHidden
                    self.filterHeaderContainerView.snp.remakeConstraints { make in
                        make.height.equalTo(isHidden ? 0 : ModernBlackboardFilterHeaderView.viewHeight)
                    }
                    self.view.layoutIfNeeded()
                case .changeShowingSortHeaderView(let isHidden):
                    self.sortHeaderView.isHidden = isHidden
                    self.sortHeaderView.snp.updateConstraints { make in
                        make.height.equalTo(isHidden ? 0 : ModernBlackboardListSortView.viewHeight)
                    }
                    self.view.layoutIfNeeded()
                case .startPrefetching(let urls):
                    self.imagePrefetcher.startPrefetching(urls)
                case .stopPrefetching(let urls):
                    self.imagePrefetcher.stopPrefetching(urls)
                case .updateTotalLabel(let total):
                    self.sortHeaderView.updateTotalLabel(total)
                case .updateSearchQuery(let searchQuery):
                    self.filterHeaderView.update(searchQuery: searchQuery)
                case .showAppStoreAlert:
                    self.present(
                        UIAlertController.moveAppStoreAlert(),
                        animated: true
                    )
                case .showAppUpdateView:
                    self.showAppUpdateView()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isOfflineMode
            .subscribe(onNext: { [weak self] isOfflineMode in
                guard let self else { return }
                offlineModeBar.isHidden = !isOfflineMode
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - private (for present / dismiss logic)
extension ModernBlackboardListViewController {
    /// 黒板編集画面が既にスタックされているか / 否か
    private var hasEditBlackboardViewController: Bool {
        self.hasAlreadyStacked(
            vcType: ModernEditBlackboardViewController.self,
            findType: .presenting
        )
    }
}

// MARK: - private (for filtering)
extension ModernBlackboardListViewController {
    private enum FilterIconState {
        case filtered
        case notFiltered
        
        init(_ hasSearchQuery: Bool) {
            self = hasSearchQuery ? .filtered : .notFiltered
        }
        
        var image: UIImage {
            switch self {
            case .filtered:
                return Asset.iconFilterOn.image
            case .notFiltered:
                return Asset.iconFilterOff.image
            }
        }
        
        var barButtonItem: UIBarButtonItem {
            return .init(
                image: image,
                style: .plain,
                target: nil,
                action: nil
            )
        }
    }
}

// MARK: private (AppUpdateView)
extension ModernBlackboardListViewController {
    /// AppUpdateViewを表示する
    private func showAppUpdateView() {
        /// 1度だけAppUpdateViewを生成、追加する
        func addAppUpdateViewIfNeeded() {
            guard appUpdateContainerView.subviews.isEmpty else { return }
            appUpdateContainerView.addSubview(appUpdateView)
            
            appUpdateView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            appUpdateContainerViewHeightConstraint.constant = AppUpdateView.viewHeight
            appUpdateContainerViewBottomMarginConstraint.constant = -AppUpdateView.viewHeight
            
            // NOTE: AppUpdateView表示分、リスト下部にも余裕を持たせる
            // （原因不明だが）tableFooterViewの制約更新後、tableHeaderViewの制約更新（ = ただしこちらは制約の内容を変えていない）を行わないと
            // 「ソートボタンが押下できなくなる」事象が発生するため、このようにしている
            tableFooterView.snp.updateConstraints { make in
                make.height.equalTo(AppUpdateView.viewHeight)
            }
            sortHeaderView.snp.updateConstraints { make in
                make.height.equalTo(ModernBlackboardListSortView.viewHeight) // 初期表示時と同じ制約を付け直す
            }
            
            view.layoutIfNeeded()
        }
        
        addAppUpdateViewIfNeeded()
        
        // expand view (with animation)
        let expandPreviewAnimator = UIViewPropertyAnimator(
            duration: Const.animateAppUpdateViewDuration,
            curve: Const.animateAppUpdateViewCurve
        )
        expandPreviewAnimator.addAnimations { [weak self] in
            self?.appUpdateContainerViewBottomMarginConstraint.constant = 0
            self?.view.layoutIfNeeded()
        }
        expandPreviewAnimator.startAnimation()
    }
}

// MARK: - NibType
extension ModernBlackboardListViewController: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernBlackboardListViewController: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}

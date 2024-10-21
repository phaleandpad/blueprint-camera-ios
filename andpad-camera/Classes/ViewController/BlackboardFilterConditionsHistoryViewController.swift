//
//  BlackboardFilterConditionsHistoryViewController.swift
//  andpad-camera
//
//  Created by msano on 2022/01/17.
//

import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift
import AndpadUIComponent

final class BlackboardFilterConditionsHistoryViewController: UIViewController {
    typealias ViewModel = BlackboardFilterConditionsHistoryViewModel
    typealias TableView = BlackboardFilterConditionsHistoryTableView
    typealias SearchQuery = ModernBlackboardSearchQuery
    
    public struct Dependency {
        let viewModel: ViewModel
        
        public init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
    }
    
    private var viewModel: ViewModel!

    private let disposeBag = DisposeBag()

    // IBOutlet
    @IBOutlet private weak var tableView: TableView!
    @IBOutlet private weak var emptyView: BlackboardFilterConditionsHistoryEmptyView!
    
    var willDismissByHistoryHandler: ((SearchQuery?) -> Void)?
    
    // life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addBinding()

        viewModel.inputPort.accept(.viewDidLoad)
    }
}

extension BlackboardFilterConditionsHistoryViewController {
    private func configureView() {
        overrideUserInterfaceStyle = .light
        
        title = viewModel.title
        navigationController?.navigationBar.setModalBar()
        
        tableView.registerNib(type: BlackboardFilterConditionsHistoryCell.self)
        tableView.rx.setDelegate(viewModel.dataSource)
            .disposed(by: disposeBag)

        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset.top = TableView.adjustTopMargin
        tableView.scrollIndicatorInsets.top = .leastNonzeroMagnitude
    }
    
    private func addBinding() {
        // bind TableView
        viewModel.items
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .compactMap { [weak self] in self?.viewModel.dataSource[$0] }
            .map { ViewModel.Input.didTapCell($0) }
            .bind(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        tableView.tappedDeleteButtonRelay
            .map { ViewModel.Input.didTapDeleteButton($0) }
            .bind(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        viewModel.outputPort
            .bind(onNext: { [weak self] event in
                switch event {
                case .dismiss(let searchQuery):
                    self?.willDismissByHistoryHandler?(searchQuery)
                    self?.dismiss(animated: true, completion: nil)
                case .showLoadingView:
                    self?.showLoading()
                case .hideLoadingView:
                    self?.hideLoading()
                case .changeEmptyViewState(let isHidden):
                    self?.emptyView.isHidden = isHidden
                case .showSimpleErrorAlert(let title, let message):
                    self?.showAlert(
                        title: title,
                        message: message,
                        handler: nil
                    )
                case .showErrorAlert(let title, let message):
                    self?.showAlert(
                        title: title,
                        message: message,
                        handler: { [weak self] _ in self?.viewModel.inputPort.accept(.didTapAcceptButtonInErrorAlert) }
                    )
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - NibType
extension BlackboardFilterConditionsHistoryViewController: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension BlackboardFilterConditionsHistoryViewController: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}

// MARK: - BlackboardFilterConditionsHistoryEmptyView
final class BlackboardFilterConditionsHistoryEmptyView: UIView {}

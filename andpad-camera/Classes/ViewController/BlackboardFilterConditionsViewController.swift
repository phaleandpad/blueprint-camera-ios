//
//  BlackboardFilterConditionsViewController.swift
//  andpad
//
//  Created by msano on 2021/04/15.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift
import SnapKit
import AndpadUIComponent

public final class BlackboardFilterConditionsViewController: UIViewController {
    typealias ViewModel = BlackboardFilterConditionsViewModel
    typealias SearchQuery = ModernBlackboardSearchQuery
    
    public struct Dependency {
        let viewModel: ViewModel
        let willDismissHandler: ((SearchQuery?) -> Void)
        let willDismissByCancelButtonHandler: (() -> Void)
        let willDismissByHistoryHandler: ((SearchQuery?) -> Void)
    }
    
    private var viewModel: ViewModel!
    private let disposeBag = DisposeBag()

    private var _willDismissHandler: ((SearchQuery?) -> Void) = { _ in }
    private var _willDismissByCancelButtonHandler: (() -> Void) = {}
    private var _willDismissByHistoryHandler: ((SearchQuery?) -> Void) = { _ in }
    var willDismissHandler: ((SearchQuery?) -> Void) { _willDismissHandler }
    var willDismissByCancelButtonHandler: (() -> Void) { _willDismissByCancelButtonHandler }
    var willDismissByHistoryHandler: ((SearchQuery?) -> Void) { _willDismissByHistoryHandler }
    
    // IBOutlet
    @IBOutlet private weak var tableView: BlackboardFilterConditionsTableView!
    @IBOutlet private weak var buttonContainerView: UIView!

    private var buttonView: BlackboardFilterConditionsButtonView? {
        didSet {
            guard let buttonView else { return }
            buttonContainerView.addSubview(buttonView)
            buttonView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private let subtitleView: BlackboardFilterConditionsSubtitleView = .init(with: .init())
    
    // life cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addBinding()

        viewModel.inputPort.accept(.viewDidLoad)
    }
}

// MARK: - private
extension BlackboardFilterConditionsViewController {
    private func configureView() {
        overrideUserInterfaceStyle = .light
        
        // configure NavigationBar
        title = viewModel.title
        
        navigationController?.navigationBar.useStandardLikeBar()
        
        let leftBarCancelButton: UIBarButtonItem = .init(
            image: Asset.iconCancel.image,
            style: .plain,
            target: self,
            action: nil
        )
        navigationItem.setLeftBarButton(leftBarCancelButton, animated: true)
        navigationItem.leftBarButtonItem?.tintColor = .hexStr("6A6A6A", alpha: 1.0)
        navigationItem.backBarButtonItem = ModernBlackboardNavigationController.plainBackButton

        // configure TableView
        tableView.registerNib(type: BlackboardFilterConditionCell.self)
        tableView.registerNib(type: BlackboardFilterConditionSeparatorCell.self)
        tableView.register(type: BlackboardFilterConditionsShowAllBlackboardItemsButtonCell.self)
        tableView.registerNib(type: BlackboardFreewordConditionCell.self)
        tableView.register(type: BlackboardFilterConditionsTableSectionHeaderView.self)
        tableView.rx.setDelegate(viewModel.dataSource)
            .disposed(by: disposeBag)
        
        // （SubtitleView内のボタンタップが効かなくなるので）メインスレッドで代入
        DispatchQueue.main.async { [weak self] in self?.tableView.tableHeaderView = self?.subtitleView }

        // NOTE: tableview下部に少しマージンを空けるためView追加
        let adjustTopMarginFooterView = UIView(
            frame: .init(
                origin: .zero,
                size: .init(
                    width: tableView.frame.width,
                    height: FOOTER_HEIGHT
                )
            )
        )
        tableView.tableFooterView = adjustTopMarginFooterView

        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension

        // configure ButtonView
        buttonView = .instantiate(with: .init(viewType: .parent))
    }
    
    private func receiveKeyboardNotification(_ notification: Notification) {
        func updateContentInset(bottom value: CGFloat) {
            tableView.contentInset = .init(
                top: tableView.contentInset.top,
                left: tableView.contentInset.left,
                bottom: value,
                right: tableView.contentInset.right
            )
        }
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            guard let userInfo = notification.userInfo,
                  let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else {
                return
            }
            updateContentInset(bottom: keyboardHeight)
        case UIResponder.keyboardWillHideNotification:
            updateContentInset(bottom: .zero)
        default:
            break
        }

        UIView.animate(
            withDuration: 0.25,
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }
        )
    }

    private func addBinding() {
        // bind NavigationBar
        navigationItem.leftBarButtonItem?.rx.tap
            .map { ViewModel.Input.didTapDismissButton }
            .bind(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)

        // bind TableView
        viewModel.items
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .map { self.viewModel.dataSource[$0] }
            .map { ViewModel.Input.didTapCell($0) }
            .bind(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)

        tableView.updateFreewordRelay
            .asObservable()
            .map { ViewModel.Input.updateFreeword($0) }
            .bind(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        subtitleView.tappedSearchHistoryButton
            .map { ViewModel.Input.didTapSearchHistoryButton }
            .emit(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)

        tableView.didTapShowAllBlackboardItemsButtonRelay
            .asObservable()
            .map { ViewModel.Input.didTapShowAllBlackboardItemsButton }
            .bind(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)

        // bind ButtonView
        buttonView?.tappedClearButton
            .map { ViewModel.Input.didTapClearButton }
            .emit(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)
        
        buttonView?.tappedFilterButton
            .map { ViewModel.Input.didTapFilterButton }
            .emit(to: self.viewModel.inputPort)
            .disposed(by: disposeBag)

        // bind KeyboardNotification
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.receiveKeyboardNotification($0) })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.receiveKeyboardNotification($0) })
            .disposed(by: disposeBag)

        // bind Outputs by ViewModel
        viewModel.outputPort
            .bind(onNext: { [weak self] event in
                switch event {
                case .dismiss(let searchQuery):
                    self?.willDismissHandler(searchQuery)
                    self?.navigationController?.dismiss(animated: true)
                case .dismissByCancelButton:
                    self?.willDismissByCancelButtonHandler()
                    self?.navigationController?.dismiss(animated: true)
                case .pushMultiSelectViewController(let arguments):
                    let viewController = AppDependencies.shared.modernBlackboardFilterMultiSelectViewController(arguments)
                    self?.navigationController?.pushViewController(
                        viewController,
                        animated: true
                    )
                case .pushSingleSelectViewController(let arguments):
                    let viewController = AppDependencies.shared.modernBlackboardFilterSingleSelectViewController(arguments)
                    self?.navigationController?.pushViewController(
                        viewController,
                        animated: true
                    )
                case .pushHistoryViewController(let arguments):
                    guard let viewController = AppDependencies.shared.modernBlackboardFilterConditionsHistoryViewController(arguments) else {
                        print("[failure] 必要なオプションがセットされていないため、黒板履歴画面を生成できません。 \n[failure] オプション 'useHistoryView' をセットしてください。")
                        self?.present(UIAlertController.cannotUseBlackboardHistoryAlert(), animated: true)
                        return
                    }
                    viewController.willDismissByHistoryHandler = self?.willDismissByHistoryHandler
                    self?.navigationController?.pushViewController(
                        viewController,
                        animated: true
                    )
                case .showClearAlert(let handler):
                    self?.showClearAlert(with: handler)
                case .showDiscardConditionAlert(let handler):
                    self?.showDiscardConditionsAlert(with: handler)
                case .showLoadingView:
                    self?.showLoading()
                case .hideLoadingView:
                    self?.hideLoading()
                case .showErrorMessage(let error):
                    self?.present(
                        UIAlertController.errorAlertWithOKButton(error: error),
                        animated: true
                    )
                case .showZeroResponseMessage:
                    self?.showZeroResponseAlert()
                case .updateCounter(let count):
                    self?.buttonView?.updateCounter(by: count)
                case .changeClearButtonState(let isEnable):
                    self?.buttonView?.changeClearButtonState(isEnable: isEnable)
                case .showEmptyAlert:
                    self?.showEmptyAlert()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - private (alert)
private extension BlackboardFilterConditionsViewController {
     func showZeroResponseAlert() {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Blackboard.Error.emptyItem,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: L10n.Common.ok,
            style: .default,
            handler: nil
        )
        alert.addAction(okAction)

        present(alert, animated: true)
    }

    func showClearAlert(
        with clearHandler: @escaping ((UIAlertAction) -> Void)
    ) {
        let alert = UIAlertController(
            title: "",
            message: L10n.Blackboard.Filter.Clear.clearTextConfirmMessage,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: L10n.Common.cancel, style: .default))
        alert.addAction(
            .init(
                title: L10n.Blackboard.Filter.Clear.clearText,
                style: .default,
                handler: clearHandler
            )
        )
        present(alert, animated: true)
    }

    func showDiscardConditionsAlert(
        with discardConditionsHandler: @escaping ((UIAlertAction) -> Void)
    ) {
        let alert = UIAlertController(
            title: L10n.Blackboard.Filter.EditAlert.title,
            message: L10n.Blackboard.Filter.EditAlert.message,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: L10n.Common.back, style: .default))
        alert.addAction(
            .init(
                title: L10n.Blackboard.Filter.EditAlert.destruction,
                style: .destructive,
                handler: discardConditionsHandler
            )
        )
        present(alert, animated: true)
    }

    func showEmptyAlert() {
        let alert = UIAlertController(
            title: L10n.Blackboard.Alert.Title.emptyBlackboard,
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: L10n.Common.close, style: .default))
        let clearAction = UIAlertAction(title: L10n.Blackboard.Alert.Button.clearCondition, style: .default, handler: { [weak self] _ in
            self?.viewModel.inputPort.accept(.didTapAcceptButtonInClearAlert)
        })
        alert.addAction(clearAction)
        alert.preferredAction = clearAction
        present(alert, animated: true)
    }
}

// MARK: - NibType
extension BlackboardFilterConditionsViewController: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension BlackboardFilterConditionsViewController: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        viewModel = dependency.viewModel
        _willDismissHandler = dependency.willDismissHandler
        _willDismissByCancelButtonHandler = dependency.willDismissByCancelButtonHandler
        _willDismissByHistoryHandler = dependency.willDismissByHistoryHandler
    }
}

// MARK: - BlackboardFilterConditionsTableView
final class BlackboardFilterConditionsTableView: UITableView {
    let updateFreewordRelay = PublishRelay<String>()
    let didTapShowAllBlackboardItemsButtonRelay = PublishRelay<Void>()
}

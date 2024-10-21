//
//  BlackboardFilterMultiSelectViewController.swift
//  andpad
//
//  Created by 佐藤俊輔 on 2021/04/13.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift

final class BlackboardFilterMultiSelectViewController: UIViewController {
    fileprivate enum Section: Int, CaseIterable {
        case hideContentNotice
        case contents
        case indicator
    }

    struct Dependency {
        let viewModel: BlackboardFilterMultiSelectViewModel
        let filterDoneHandler: ((String, [String]) -> Void)
    }
    
    var filterDoneHandler: ((String, [String]) -> Void)?

    private var viewModel: BlackboardFilterMultiSelectViewModel!
    private var blackboardItemBody: String!
    private let dataSource = BlackboardFilterMultiSelectDataSource()

    private let bag = DisposeBag()

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonContainerView: UIView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private static let tableViewContentTopMargin: CGFloat = 24.0
    
    private var buttonView: BlackboardFilterConditionsButtonView? {
        didSet {
            guard let buttonView else { return }
            buttonContainerView.addSubview(buttonView)
            buttonView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchBar()
        setupTableView()
        setupBindings()
        Task<_, Never> {
            await viewModel.viewDidLoad()
        }
    }
}

// MARK: - private
extension BlackboardFilterMultiSelectViewController {
    private func setupNavigationBar() {
        navigationItem.title = viewModel.item.blackboardItemBody
        navigationController?.navigationBar.setModalBar()
    }

    private func setupSearchBar() {
        searchBar.snp.makeConstraints { make in
            make.width.equalToSuperview()
         
            if #available(iOS 15.0, *) {
                make.top.equalToSuperview()
            // NOTE: iOS14だとsearchBarがnabigationBarに隠れてしまうため、top側の制約を設定し直す。
            } else {
                make.top.equalTo(view.safeAreaLayoutGuide)
            }
        }
        
        searchBar.placeholder = L10n.Blackboard.Filter.Title.searchForBlackboardItem

        if let textField = searchBar.textField {
            textField.textColor = .textColor
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(type: BlackboardFilterSelectCell.self)
        tableView.registerNib(type: IndicatorCell.self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(
            BlackboardHideContentNoticeCell.self,
            forCellReuseIdentifier: BlackboardHideContentNoticeCell.reuseIdentifier
        )
        tableView.separatorInset = .zero
        tableView.estimatedSectionHeaderHeight = 68
        
        self.buttonView = .init(with: .init(viewType: .child))

        if #unavailable(iOS 15.0) {
            // NOTE: iOS 14 で不要なセパレータが表示されるのを回避するために透明なViewをtableFooterViewにセットする。
            let dummyEmptyView = UIView()
            dummyEmptyView.backgroundColor = .clear
            tableView.tableFooterView = dummyEmptyView
         }
    }

    private func tappedFilterDoneButton() {
        filterDoneHandler?(
            viewModel.item.blackboardItemBody,
            viewModel.item.selectedContents
        )
        navigationController?.popViewController(animated: true)
    }

    private func setupBindings() {
        viewModel
            .itemRelay
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        viewModel
            .showErrorMessage
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.present(
                    UIAlertController.errorAlertWithOKButton(error: error),
                    animated: true
                )
            }
            .disposed(by: bag)

        viewModel
            .keywordSearchWillStart
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let self else { return }
                self.view.endEditing(true)
            }
            .disposed(by: bag)
        
        viewModel
            .itemRelay
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.buttonView?.changeClearButtonState(isEnable: !$0.selectedContents.isEmpty)
            })
            .disposed(by: bag)

        searchBar.rx.searchButtonClicked
            .subscribe { _ in
                Task<_, Never> { @MainActor [weak self] in
                    guard let self else { return }
                    let text = searchBar.text
                    await viewModel.searchButtonClicked(text)
                }
            }
            .disposed(by: bag)
        
        buttonView?.tappedClearButton
            .emit(onNext: { [weak self] in self?.viewModel.tappedClearButton() })
            .disposed(by: bag)
        
        buttonView?.tappedFilterButton
            .emit(onNext: { [weak self] in self?.tappedFilterDoneButton() })
            .disposed(by: bag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.receiveKeyboardNotification($0) })
            .disposed(by: bag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.receiveKeyboardNotification($0) })
            .disposed(by: bag)
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
        
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            guard let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return }
            updateContentInset(bottom: keyboardHeight)
        case UIResponder.keyboardWillHideNotification:
            updateContentInset(bottom: .zero)
        default:
            break
        }

        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }
        )
    }
}

// MARK: - UITableViewDelegate
extension BlackboardFilterMultiSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.section {
        case Section.contents.rawValue:
            viewModel.contentCellSelected(indexPath.row)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == Section.indicator.rawValue {
            Task<_, Never> {
                await viewModel.scrolledDown()
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard BlackboardFilterMultiSelectViewController.Section.hideContentNotice.rawValue == section,
                viewModel.isContentEmpty else {
            return nil
        }
        return BlackboardFilterNoMatchView(
            with: .init(tappedHandler: { [weak self] in self?.searchBar.becomeFirstResponder() })
        )
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #unavailable(iOS 15.0) {
            // NOTE: iOS 14の場合はempty時のヘッダ表示時以外はセクションヘッダを非表示(高さ0)にする
            guard BlackboardFilterMultiSelectViewController.Section.hideContentNotice.rawValue == section,
                    viewModel.isContentEmpty else {
                return 0
            }
            return UITableView.automaticDimension
        }
        return viewModel.isContentEmpty ? UITableView.automaticDimension : CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UITableViewDataSource, RxTableViewDataSourceType
final class BlackboardFilterMultiSelectDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {

    typealias Element = BlackboardFilterMultiSelectViewModel.Item

    var item: BlackboardFilterMultiSelectViewModel.Item = BlackboardFilterMultiSelectItem()

    func numberOfSections(in tableView: UITableView) -> Int {
        return BlackboardFilterMultiSelectViewController.Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case BlackboardFilterMultiSelectViewController.Section.hideContentNotice.rawValue:
            return item.shouldShowHideContentNotice ? 1 : 0
        case BlackboardFilterMultiSelectViewController.Section.contents.rawValue:
            return item.contents.count
        case BlackboardFilterMultiSelectViewController.Section.indicator.rawValue:
            return item.fetchedAll ? 0 : 1
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case  BlackboardFilterMultiSelectViewController.Section.hideContentNotice.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: BlackboardHideContentNoticeCell.reuseIdentifier, for: indexPath) as! BlackboardHideContentNoticeCell
            return cell
        case BlackboardFilterMultiSelectViewController.Section.contents.rawValue:
            let body = item.contents[indexPath.row].body
            let cell = BlackboardFilterSelectCell.dequeue(
                from: tableView,
                for: indexPath,
                with: .init(
                    text: body.isEmpty
                    ? L10n.Blackboard.Filter.selectEmptyItem(item.blackboardItemBody)
                    : body
                )
            )
            item.isSelected(at: indexPath.row)
                ? cell.setSelect(mode: .multi)
                : cell.setDeselect(mode: .multi)
            return cell
        case BlackboardFilterMultiSelectViewController.Section.indicator.rawValue:
            return IndicatorCell.dequeue(
                from: tableView,
                for: indexPath,
                with: .init()
            )
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<BlackboardFilterMultiSelectViewModel.Item>) {
        Binder(self) { dataSource, element in
            dataSource.item = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}

// MARK: - NibType
extension BlackboardFilterMultiSelectViewController: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension BlackboardFilterMultiSelectViewController: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        viewModel = dependency.viewModel
        filterDoneHandler = dependency.filterDoneHandler
    }
}

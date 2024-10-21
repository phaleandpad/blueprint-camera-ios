//
//  BlackboardFilterSingleSelectViewController.swift
//  andpad
//
//  Created by 佐藤俊輔 on 2021/04/16.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift

// MARK: - BlackboardFilterSingleSelectContentsProtocol
//　MEMO: 文字列が識別子となる手抜きのもの
protocol BlackboardFilterSingleSelectContentsProtocol {
    var title: String { get }
    var items: [String] { get }
}

// MARK: - BlackboardFilterSinglePhoto
struct BlackboardFilterSinglePhoto: BlackboardFilterSingleSelectContentsProtocol {
    let title = L10n.Blackboard.Filter.existPhoto

    let items = [
        L10n.Blackboard.Filter.Photo.all,
        L10n.Blackboard.Filter.Photo.onlyWithPhotos,
        L10n.Blackboard.Filter.Photo.onlyWithoutPhotos
    ]
}

// MARK: - BlackboardFilterSingleSelectViewController
final class BlackboardFilterSingleSelectViewController: UIViewController {

    fileprivate enum Section: Int, CaseIterable {
        case contents
    }
    
    struct Dependency {
        let viewModel: BlackboardFilterSingleSelectViewModel
        let filterDoneHandler: ((String?) -> Void)
    }
    
    private var viewModel: BlackboardFilterSingleSelectViewModel!
    private let dataSource = BlackboardFilterSingleSelectDataSource()

    private let bag = DisposeBag()

    @IBOutlet private weak var tableView: UITableView!

    private var _filterDoneHandler: ((String?) -> Void) = { _ in }
    
    var filterDoneHandler: ((String?) -> Void) {
        _filterDoneHandler
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupBindings()
    }
}

// MARK: - private
extension BlackboardFilterSingleSelectViewController {
    private func setupNavigationBar() {
        navigationItem.title = viewModel.blackboardFilterSingleSelectContents.title
        navigationController?.navigationBar.setModalBar()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(type: BlackboardFilterSelectCell.self)
        tableView.separatorInset = UIEdgeInsets.zero
    }

    private func setupBindings() {
        viewModel
            .itemRelay
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        viewModel
            .doneSelectCellObservable
            .subscribe(onNext: { [weak self] in self?.willPopWithSelectedContent() })
            .disposed(by: bag)
    }
    
    private func willPopWithSelectedContent() {
        filterDoneHandler(viewModel.item.selectedContent)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension BlackboardFilterSingleSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        switch indexPath.section {
        case Section.contents.rawValue:
            viewModel.contentCellSelected(indexPath.row)
        default:
            break
        }
    }
}

// MARK: - NibType
extension BlackboardFilterSingleSelectViewController: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension BlackboardFilterSingleSelectViewController: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        self.viewModel = dependency.viewModel
        self._filterDoneHandler = dependency.filterDoneHandler
    }
}

// MARK: - BlackboardFilterSingleSelectDataSource
final class BlackboardFilterSingleSelectDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {

    typealias Element = BlackboardFilterSingleSelectViewModel.Item

    var item: BlackboardFilterSingleSelectViewModel.Item = BlackboardFilterSingleSelectItem(contents: [], selectedContent: nil)

    func numberOfSections(in tableView: UITableView) -> Int {
        return BlackboardFilterSingleSelectViewController.Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case BlackboardFilterSingleSelectViewController.Section.contents.rawValue:
            return item.contents.count
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case BlackboardFilterSingleSelectViewController.Section.contents.rawValue:
            let cell = BlackboardFilterSelectCell.dequeue(
                from: tableView,
                for: indexPath,
                with: .init(text: item.contents[indexPath.row])
            )
            item.selectedContent == item.contents[indexPath.row]
                ? cell.setSelect(mode: .single)
                : cell.setDeselect(mode: .single)
            return cell
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<BlackboardFilterSingleSelectViewModel.Item>) {
        Binder(self) { dataSource, element in
            dataSource.item = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}

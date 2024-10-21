//
//  BlackboardFilterConditionsDataSource.swift
//  andpad
//
//  Created by msano on 2021/04/15.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

// MARK: - BlackboardFilterConditionsDataSource
final class BlackboardFilterConditionsDataSource: RxTableViewSectionedReloadDataSource<BlackboardFilterConditionsDataSource.Section> {
    private let updateSearchCounterRelay: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    private let updateFreewordRelay = PublishRelay<String>()
    
    convenience init() {
        self.init { dataSource, tableView, indexPath, model in
            switch dataSource[indexPath] {
            case .photo, .pinnedBlackboardItem, .unpinnedBlackboardItem:
                return BlackboardFilterConditionCell.dequeue(
                    from: tableView,
                    for: indexPath,
                    with: .init(modelType: model)
                )
            case .blackboardItemsSeparator:
                return BlackboardFilterConditionSeparatorCell.dequeue(
                    from: tableView,
                    for: indexPath
                )
            case .showAllBlackboardItemsButton:
                let cell = BlackboardFilterConditionsShowAllBlackboardItemsButtonCell.dequeue(
                    from: tableView,
                    for: indexPath
                )
                if let tableView = tableView as? BlackboardFilterConditionsTableView {
                    cell.showAllBlackboardItemsButton.rx.tap
                        .asDriver()
                        .drive(onNext: { _ in
                            tableView.didTapShowAllBlackboardItemsButtonRelay.accept(())
                        })
                        .disposed(by: cell.disposeBag)
                }
                return cell
            case .freeword:
                let freewordConditionCell = BlackboardFreewordConditionCell.dequeue(
                    from: tableView,
                    for: indexPath,
                    with: .init(modelType: model)
                )

                if let tableView = tableView as? BlackboardFilterConditionsTableView {
                    freewordConditionCell
                        .postInputedTextObservable
                        .bind(to: tableView.updateFreewordRelay)
                        .disposed(by: freewordConditionCell.disposeBag)
                }
                return freewordConditionCell
            }
        }
    }
}

extension BlackboardFilterConditionsDataSource {
    func updateSearchCounter(with total: Int?) {
        guard let total else { return }
        updateSearchCounterRelay.accept(total)
    }
}

// MARK: - subscription
extension BlackboardFilterConditionsDataSource {
    var updateSearchCounterDriver: Driver<Int?> {
        updateSearchCounterRelay.asDriver()
    }
}

// MARK: - BlackboardFilterConditionsDataSource + UITableViewDelegate

extension BlackboardFilterConditionsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // セクションヘッダーにタイトルが設定されている場合、カスタマイズしたビューを返す
        let title = sectionModels[section].title
        if title.isEmpty {
            return nil
        }
        return BlackboardFilterConditionsTableSectionHeaderView.dequeue(
            from: tableView,
            with: .init(title: title)
        )
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.sectionModels.count > section else {
            // 画面表示時に `Index out of range` によるクラッシュが発生しないようにする
            return .leastNormalMagnitude
        }
        return sectionModels[section].title.isEmpty ? CGFloat.leastNormalMagnitude : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        // これはあくまで推定値で、実際の内容に基づいて変動する
        return 60
    }
}

// MARK: - Section

extension BlackboardFilterConditionsDataSource {
    enum Section {
        case photo(items: [ConditionModelType])
        case blackboardItem(title: String, items: [ConditionModelType])
        case freeword(title: String, items: [ConditionModelType])
    }
}

// MARK: - BlackboardFilterConditionsDataSource.Section + SectionModelType

extension BlackboardFilterConditionsDataSource.Section: SectionModelType {
    typealias Item = ConditionModelType

    var items: [ConditionModelType] {
        switch self {
        case .photo(let items):
            return items
        case .blackboardItem(_, let items):
            return items
        case .freeword(_, let items):
            return items
        }
    }

    init(original: BlackboardFilterConditionsDataSource.Section, items: [Item]) {
        switch original {
        case .photo:
            self = .photo(items: items)
        case .blackboardItem(let title, _):
            self = .blackboardItem(title: title, items: items)
        case .freeword(let title, _):
            self = .freeword(title: title, items: items)
        }
    }
}

extension BlackboardFilterConditionsDataSource.Section {
    var title: String {
        switch self {
        case .photo:
            return ""
        case .blackboardItem(let title, _):
            return title
        case .freeword(let title, _):
            return title
        }
    }
}

//
//  BlackboardFilterConditionsHistoryDataSource.swift
//  andpad-camera
//
//  Created by msano on 2022/01/17.
//

import RxCocoa
import RxDataSources
import RxSwift

// MARK: - BlackboardFilterConditionsHistoryDataSource
final class BlackboardFilterConditionsHistoryDataSource: RxTableViewSectionedReloadDataSource<BlackboardFilterConditionsHistoryDataSource.Section> {
    
    convenience init() {
        let configureCell: BlackboardFilterConditionsHistoryDataSource.ConfigureCell = { _, tableView, indexPath, item in
            let historyCell = BlackboardFilterConditionsHistoryCell.dequeue(
                from: tableView,
                for: indexPath,
                with: .init(history: item)
            )
            guard let tableView = tableView as? BlackboardFilterConditionsHistoryTableView else {
                preconditionFailure("BlackboardFilterConditionsHistoryTableViewへのキャストに失敗しています")
            }

            historyCell.tappedDeleteButton
                .emit(to: tableView.tappedDeleteButtonRelay)
                .disposed(by: historyCell.disposeBag)
            return historyCell
        }
        
        self.init(configureCell: configureCell)
    }
}

// MARK: - UITableViewDelegate
extension BlackboardFilterConditionsHistoryDataSource: UITableViewDelegate {}

// MARK: - Section
extension BlackboardFilterConditionsHistoryDataSource {
    struct Section: SectionModelType {
        typealias Item = BlackboardFilterConditionsHistory

        var items: [Item]

        init(
            original: BlackboardFilterConditionsHistoryDataSource.Section,
            items: [Item]
        ) {
            self = original
            self.items = items
        }

        init(
            items: [Item]
        ) {
            self.items = items
        }
    }
}

// MARK: - BlackboardFilterConditionsTableView
final class BlackboardFilterConditionsHistoryTableView: UITableView {
    let tappedDeleteButtonRelay = PublishRelay<BlackboardFilterConditionsHistory>()
    
    static let adjustTopMargin: CGFloat = 8.0
}

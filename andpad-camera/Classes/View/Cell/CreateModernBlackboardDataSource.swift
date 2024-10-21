//
//  CreateModernBlackboardDataSource.swift
//  andpad-camera
//
//  Created by msano on 2022/04/06.
//

import RxSwift
import RxCocoa
import RxDataSources

// MARK: - CreateModernBlackboardDataSource
final class CreateModernBlackboardDataSource: RxTableViewSectionedReloadDataSource<CreateModernBlackboardDataSource.Section> {
    private let scrolledDownRelay: PublishRelay<Void> = .init()
    private let isScrollEnabledRelay: PublishRelay<Bool> = .init()

    var tappedEmptyViewHandler: (() -> Void)?
    
    private static let cannotFoundCellDependencyAssert = "[failure] cell dependencyが存在しません"

    convenience init() {

        // MARK: - configureCell
        let configureCell: CreateModernBlackboardDataSource.ConfigureCell = { _, tableView, indexPath, item in
            guard let tableView = tableView as? TouchableTableView else { return UITableViewCell() }

            switch item {
            case .errors(let dependency):
                guard let dependency else {
                    assertionFailure(CreateModernBlackboardDataSource.cannotFoundCellDependencyAssert)
                    return UITableViewCell()
                }
                let cell = ModernEditBlackboardErrorCell.dequeue(
                    from: tableView,
                    for: indexPath,
                    with: dependency
                )
                cell.updateCellHeightSignal
                    .emit(to: tableView.updateErrorCellHeightRelay)
                    .disposed(by: cell.disposeBag)
                cell.tapSelectLayoutButtonSignal
                    .emit(to: tableView.tapSelectLayoutButtonRelay)
                    .disposed(by: cell.disposeBag)
                
                return cell
            case .blackboardItems(let dependency):
                guard let dependency else {
                    assertionFailure(CreateModernBlackboardDataSource.cannotFoundCellDependencyAssert)
                    return UITableViewCell()
                }
                let cell = ModernBlackboardItemInputsCell.dequeue(
                    from: tableView,
                    for: indexPath,
                    with: dependency
                )
                cell.updateBlackboardItemsSignal
                    .emit(to: tableView.updateBlackboardItemsRelay)
                    .disposed(by: cell.disposeBag)
                cell.updateCellHeightSignal
                    .emit(to: tableView.updateItemInputsCellHeightRelay)
                    .disposed(by: cell.disposeBag)
                
                cell.updateCellHeightSignal
                    // NOTE: わかりづらいですが、初回のセル生成時に下記performBatchUpdatesも走ると
                    // このセルの高さを0としてheightForRowAtが評価されてしまうので、一回skipします
                    .skip(1)
                    .emit(onNext: {
                        if tableView.updateItemInputsCellHeightRelay.value != nil, $0 > 0 {
                            tableView.performBatchUpdates(
                                {
                                    cell.setNeedsLayout()
                                    cell.layoutIfNeeded()
                                },
                                completion: nil
                            )
                        }
                    })
                    .disposed(by: cell.disposeBag)

                return cell
            }
        }
        
        self.init(configureCell: configureCell)
    }

    var scrolledDownSignal: Signal<Void> {
        scrolledDownRelay.asSignal()
    }
    
    var isScrollEnabledSignal: Signal<Bool> {
        isScrollEnabledRelay.asSignal()
    }
}

// MARK: - UITableViewDelegate
extension CreateModernBlackboardDataSource: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height) else {
            return
        }
        scrolledDownRelay.accept(())
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableView = tableView as? TouchableTableView else { return .zero }
        
        let cellData = CellData(indexPath: indexPath)
        switch tableView.type {
        case .create:
            switch cellData {
            case .errors:
                return tableView.updateErrorCellHeightRelay.value ?? .zero
            case .blackboardItems:
                return tableView.updateItemInputsCellHeightRelay.value ?? UITableView.automaticDimension
            default:
                return UITableView.automaticDimension
            }
        case .edit:
            fatalError()
        }
    }
}

// MARK: - Section
extension CreateModernBlackboardDataSource {
    struct Section: SectionModelType {
        typealias Item = CellData

        var items: [Item]
        
        init(
            original: CreateModernBlackboardDataSource.Section,
            items: [Item]
        ) {
            self = original
            self.items = items
        }
        
        init(items: [Item]) {
            self.items = items
        }
    }
}

// MARK: - CellData
extension CreateModernBlackboardDataSource {
    enum CellData {
        case errors(ModernEditBlackboardErrorCell.Dependency?)
        case blackboardItems(ModernBlackboardItemInputsCell.Dependency?)
        
        init?(indexPath: IndexPath) {
            switch indexPath.row {
            case 0:
                self = .errors(nil)
            case 1:
                self = .blackboardItems(nil)
            default:
                return nil
            }
        }
    }
}

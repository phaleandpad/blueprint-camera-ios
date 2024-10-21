//
//  ModernEditBlackboardDataSource.swift
//  andpad-camera
//
//  Created by msano on 2022/01/26.
//

import RxSwift
import RxCocoa
import RxDataSources

// MARK: - ModernEditBlackboardDataSource
final class ModernEditBlackboardDataSource: RxTableViewSectionedReloadDataSource<ModernEditBlackboardDataSource.Section> {
    private let scrolledDownRelay: PublishRelay<Void> = .init()
    private let isScrollEnabledRelay: PublishRelay<Bool> = .init()

    var tappedEmptyViewHandler: (() -> Void)?
    
    private static let cannotFoundCellDependencyAssert = "[failure] cell dependencyが存在しません"

    convenience init() {

        // MARK: - configureCell
        let configureCell: ModernEditBlackboardDataSource.ConfigureCell = { _, tableView, indexPath, item in
            guard let tableView = tableView as? TouchableTableView else { return UITableViewCell() }

            switch item {
            case .errors(let dependency):
                guard let dependency = dependency else {
                    assertionFailure(ModernEditBlackboardDataSource.cannotFoundCellDependencyAssert)
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
                guard let dependency = dependency else {
                    assertionFailure(ModernEditBlackboardDataSource.cannotFoundCellDependencyAssert)
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
                cell.constructionNameDidTapSignal
                    .emit(to: tableView.constructionNameDidTapRelay)
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
            case .miniatureMap(let state):
                let state = state ?? .beforeLoading
                let cell = EditMiniatureMapCell.dequeue(
                    from: tableView,
                    for: indexPath,
                    with: .init(
                        state: state,
                        parentViewType: .edit
                    )
                )
                cell.tapButtonSignal
                    .emit(to: tableView.tapMiniatureMapButtonRelay)
                    .disposed(by: cell.disposeBag)
                
                return cell
            case .memoStyle(let dependency):
                guard let dependency = dependency else {
                    assertionFailure(ModernEditBlackboardDataSource.cannotFoundCellDependencyAssert)
                    return UITableViewCell()
                }
                let cell = ModernMemoStyleCell.dequeue(
                    from: tableView,
                    for: indexPath,
                    with: dependency
                )
                cell.updateMemoStyleSignal
                    .emit(to: tableView.updateMemoStyleRelay)
                    .disposed(by: cell.disposeBag)
                tableView.canEditBlackboardStyle = cell.canEditBlackboardStyle
                cell.isHidden = !cell.canEditBlackboardStyle
                return cell
            case .theme(let dependency):
                guard let dependency = dependency else {
                    assertionFailure(ModernEditBlackboardDataSource.cannotFoundCellDependencyAssert)
                    return UITableViewCell()
                }
                let cell = ModernThemeCell.dequeue(
                    from: tableView,
                    for: indexPath,
                    with: dependency
                )
                cell.updateThemeSignal
                    .emit(to: tableView.updateThemeRelay)
                    .disposed(by: cell.disposeBag)
                tableView.canEditBlackboardStyle = cell.canEditBlackboardStyle
                cell.isHidden = !cell.canEditBlackboardStyle
                return cell
            case .alpha(let dependency):
                guard let dependency = dependency else {
                    assertionFailure(ModernEditBlackboardDataSource.cannotFoundCellDependencyAssert)
                    return UITableViewCell()
                }
                let cell = ModernBlackboardAlphaCell.dequeue(
                    from: tableView,
                    for: indexPath,
                    with: dependency
                )
                cell.onValueChangedSignal
                    .emit(to: tableView.updateAlphaRelay)
                    .disposed(by: cell.disposeBag)
                cell.isHidden = !cell.canEditBlackboardStyle
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
extension ModernEditBlackboardDataSource: UITableViewDelegate {
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
            fatalError()
        case .edit(let editableScope):
            switch editableScope {
            case .all:
                switch cellData {
                case .errors:
                    return tableView.updateErrorCellHeightRelay.value ?? .zero
                case .blackboardItems:
                    return tableView.updateItemInputsCellHeightRelay.value ?? UITableView.automaticDimension
                case .miniatureMap:
                    guard tableView.hasMiniatureMap else { return .zero }
                    return cellData?.fixedCellHeight ?? .zero
                case .memoStyle, .alpha:
                    guard tableView.canEditBlackboardStyle else { return .zero }
                    return UITableView.automaticDimension
                case .theme:
                    guard tableView.canEditBlackboardStyle else { return .zero }
                    return  cellData?.fixedCellHeight ?? UITableView.automaticDimension
                case .none:
                    return cellData?.fixedCellHeight ?? UITableView.automaticDimension
                }
            case .onlyBlackboardItems:
                switch cellData {
                case .errors:
                    return tableView.updateErrorCellHeightRelay.value ?? .zero
                case .blackboardItems:
                    return tableView.updateItemInputsCellHeightRelay.value ?? UITableView.automaticDimension
                case .miniatureMap:
                    guard tableView.hasMiniatureMap else { return .zero }
                    return cellData?.fixedCellHeight ?? .zero
                case .memoStyle, .theme, .alpha, .none:
                    return .zero
                }
            }
        }
    }
}

// MARK: - Section
extension ModernEditBlackboardDataSource {
    struct Section: SectionModelType {
        typealias Item = CellData

        var items: [Item]
        
        init(
            original: ModernEditBlackboardDataSource.Section,
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
extension ModernEditBlackboardDataSource {
    enum CellData {
        case errors(ModernEditBlackboardErrorCell.Dependency?)
        case blackboardItems(ModernBlackboardItemInputsCell.Dependency?)
        case miniatureMap(MiniatureMapImageState?)
        case memoStyle(ModernMemoStyleCell.Dependency?)
        case theme(ModernThemeCell.Dependency?)
        case alpha(ModernBlackboardAlphaCell.Dependency?)
        
        init?(indexPath: IndexPath) {
            switch indexPath.row {
            case 0:
                self = .errors(nil)
            case 1:
                self = .blackboardItems(nil)
            case 2:
                self = .miniatureMap(nil)
            case 3:
                self = .memoStyle(nil)
            case 4:
                self = .theme(nil)
            case 5:
                self = .alpha(nil)
            default:
                return nil
            }
        }
        
        var fixedCellHeight: CGFloat? {
            switch self {
            case .errors:
                return nil
            case .blackboardItems:
                return nil
            case .miniatureMap:
                return 204.0
            case .memoStyle:
                return 242.0
            case .theme:
                return 96.0
            case .alpha:
                return 88.0
            }
        }
    }
}

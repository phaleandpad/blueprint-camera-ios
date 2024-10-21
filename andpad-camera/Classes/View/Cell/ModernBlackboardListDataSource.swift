//
//  ModernBlackboardListDataSource.swift
//  andpad-camera
//
//  Created by msano on 2022/01/05.
//

import RxCocoa
import RxDataSources
import RxSwift

// MARK: - ModernBlackboardListDataSource
final class ModernBlackboardListDataSource: RxTableViewSectionedReloadDataSource<ModernBlackboardListDataSource.Section> {
    private let scrolledDownRelay: PublishRelay<Void> = .init()
    private let isScrollEnabledRelay: PublishRelay<Bool> = .init()

    convenience init() {

        // MARK: - configureCell
        let configureCell: ModernBlackboardListDataSource.ConfigureCell = { _, tableView, indexPath, item in
            guard let tableView = tableView as? ModernBlackboardListTableView else { fatalError() }
            let cell = ModernBlackboardListCell.dequeue(
                from: tableView,
                for: indexPath,
                with: .init(
                    modernBlackboardMaterial: item.blackboardMaterial,
                    layoutType: .editAndTakePhoto,
                    dateFormatType: tableView.dateFormatType,
                    memoStyleArguments: item.memoStyleArguments,
                    isSelectedBlackboard: item.isSelectedBlackboard,
                    canHighlight: true,
                    // 選択用黒板一覧ではダウンロード済みマークは常に非表示
                    isDownloadedMarkHidden: true,
                    shouldShowMiniatureMapFromLocal: item.shouldShowMiniatureMapFromLocal,
                    useBlackboardGeneratedWithSVG: item.useBlackboardGeneratedWithSVG
                )
            )

            cell.tappedBlackboardImageButton
                .emit(to: tableView.tappedBlackboardImageButtonRelay)
                .disposed(by: cell.disposeBag)
            
            cell.tappedEditButton
                .emit(to: tableView.tappedEditButtonRelay)
                .disposed(by: cell.disposeBag)

            cell.tappedTakePhotoButton
                .emit(to: tableView.tappedTakePhotoButtonRelay)
                .disposed(by: cell.disposeBag)
            
            return cell
        }
        
        self.init(configureCell: configureCell)
    }

    var scrolledDownSignal: Signal<Void> {
        // NOTE: 短い時間に大量に呼ばれており、何度も呼ばれると ViewModel 側の状態管理に問題が生じることがわかった。
        // そのため、 throttle を入れて流すストリームを制限する。interval は他の throttle と同じ時間を設定した。
        scrolledDownRelay
            .throttle(
                DispatchTimeInterval.milliseconds(ThrottleConfiguration.enable.milliseconds),
                latest: false,
                scheduler: MainScheduler.instance
            )
            .asSignal(onErrorJustReturn: ())
    }
    
    var isScrollEnabledSignal: Signal<Bool> {
        isScrollEnabledRelay.asSignal()
    }
}

// MARK: - UITableViewDelegate
extension ModernBlackboardListDataSource: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height) else {
            return
        }
        scrolledDownRelay.accept(())
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard shouldShowEmptyView else { return nil }
        
        if sectionModels.contains(where: { $0.sectionType == .empty }) {
            let emptyView = UITableViewHeaderFooterView(frame: .init(origin: .zero, size: tableView.bounds.size))
            emptyView.addSubview(emptyLabel(tableViewBounds: tableView.bounds))
            return emptyView
        }
        
        if sectionModels.contains(where: { $0.sectionType == .emptyWithFiltering }) {
            let emptyWithFilteringView = ModernBlackboardListEmptyWithFilteringView.dequeue(from: tableView, with: .init())
            return emptyWithFilteringView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard shouldShowEmptyView else { return .zero }
        
        if sectionModels.contains(where: { $0.sectionType == .empty }) {
            return tableView.bounds.height
        }
        if sectionModels.contains(where: { $0.sectionType == .emptyWithFiltering }) {
            return ModernBlackboardListEmptyWithFilteringView.viewHeight
        }
        return .zero
    }
}

// MARK: - private (empty label)
extension ModernBlackboardListDataSource {
    /// 「絞り込み条件なしで0件」の場合に利用するラベル
    private func emptyLabel(tableViewBounds: CGRect) -> UILabel {
        let label = UILabel(
            frame: .init(
                origin: .zero,
                size: .init(
                    width: tableViewBounds.width,
                    height: tableViewBounds.height - UIViewController.DEFAULT_NAVIGATIONBAR_HEIGHT
                )
            )
        )
        label.text = L10n.Blackboard.List.noBlackboardMessage
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray222
        label.backgroundColor = .white
        return label
    }
}

// MARK: - private (handle empty view)
extension ModernBlackboardListDataSource {
    private var shouldShowEmptyView: Bool {
        let shouldShowEmptyView = sectionModels
            .contains(where: { $0.sectionType == .empty || $0.sectionType == .emptyWithFiltering })
        isScrollEnabledRelay.accept(!shouldShowEmptyView) // sidekick
        return shouldShowEmptyView
    }
}

// MARK: - Section
extension ModernBlackboardListDataSource {
    struct Section: SectionModelType {
        typealias Item = BlackboardListCellItem

        let sectionType: SectionType
        var items: [Item]
        
        init(
            original: ModernBlackboardListDataSource.Section,
            items: [Item]
        ) {
            self = original
            self.items = items
        }

        init(
            sectionType: SectionType = .none,
            items: [Item]
        ) {
            self.sectionType = sectionType
            self.items = items
        }
    }
}

// MARK: - SectionType
extension ModernBlackboardListDataSource {
    enum SectionType {
        case empty
        case emptyWithFiltering
        case none
    }
}

// MARK: - BlackboardListCellItem
struct BlackboardListCellItem {
    let blackboardMaterial: ModernBlackboardMaterial
    let memoStyleArguments: ModernBlackboardMemoStyleArguments
    let isSelectedBlackboard: Bool
    /// 豆図画像をローカルから取得するかどうか
    let shouldShowMiniatureMapFromLocal: Bool
    /// SVGで生成された黒板を利用するかどうか
    let useBlackboardGeneratedWithSVG: Bool
}

// MARK: - ModernBlackboardListTableView
final class ModernBlackboardListTableView: UITableView {
    let tappedBlackboardImageButtonRelay = PublishRelay<ModernBlackboardMaterial>()
    let tappedEditButtonRelay = PublishRelay<ModernBlackboardMaterial>()
    let tappedTakePhotoButtonRelay = PublishRelay<ModernBlackboardMaterial>()
    
    var dateFormatType: ModernBlackboardCommonSetting.DateFormatType = .defaultValue
}

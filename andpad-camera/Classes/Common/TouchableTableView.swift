//
//  TouchableTableView.swift
//  andpad-camera
//
//  Created by msano on 2021/10/07.
//

import RxSwift
import RxCocoa

final class TouchableTableView: UITableView {
    let updateErrorCellHeightSignal: Signal<Void>
    let updateBlackboardItemsSignal: Signal<[ModernBlackboardMaterial.Item]>
    let updateMemoStyleSignal: Signal<ModernMemoStyleCell.SelectedValue>
    let updateThemeSignal: Signal<ModernBlackboardAppearance.Theme>
    let updateAlphaSignal: Signal<ModernBlackboardAppearance.AlphaLevel>
    let tapMiniatureMapButtonSignal: Signal<UIImage>
    let constructionNameDidTapSignal: Signal<Void>
    
    let updateErrorCellHeightRelay = BehaviorRelay<CGFloat?>(value: 0)
    let tapSelectLayoutButtonRelay = PublishRelay<Void>()
    let updateItemInputsCellHeightRelay = BehaviorRelay<CGFloat?>(value: 0)
    let constructionNameDidTapRelay = PublishRelay<Void>()
    
    let updateBlackboardItemsRelay = PublishRelay<[ModernBlackboardMaterial.Item]>()
    let updateMemoStyleRelay = PublishRelay<ModernMemoStyleCell.SelectedValue>()
    let updateThemeRelay = PublishRelay<ModernBlackboardAppearance.Theme>()
    let updateAlphaRelay = PublishRelay<ModernBlackboardAppearance.AlphaLevel>()
    let tapMiniatureMapButtonRelay = PublishRelay<UIImage>()
    
    var canEditBlackboardStyle = true
    var hasMiniatureMap = true
    var type: TableViewType = .create

    enum TableViewType {
        case create
        case edit(ModernEditBlackboardViewController.EditableScope)
    }
    
    required init?(coder: NSCoder) {
        updateErrorCellHeightSignal = updateErrorCellHeightRelay
            .compactMap { $0 }
            .filter { $0 > 0 }
            .distinctUntilChanged()
            .map { _ in () }
            .asSignal(onErrorJustReturn: ())
        updateBlackboardItemsSignal = updateBlackboardItemsRelay.asSignal()
        updateMemoStyleSignal = updateMemoStyleRelay.asSignal()
        updateThemeSignal = updateThemeRelay.asSignal()
        updateAlphaSignal = updateAlphaRelay.asSignal()
        tapMiniatureMapButtonSignal = tapMiniatureMapButtonRelay.asSignal()
        constructionNameDidTapSignal = constructionNameDidTapRelay.asSignal()
        super.init(coder: coder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
    }
}

extension TouchableTableView {
    func scrollToTop() {
        scrollToRow(at: .init(row: 0, section: 0), at: .none, animated: true)
   }
}

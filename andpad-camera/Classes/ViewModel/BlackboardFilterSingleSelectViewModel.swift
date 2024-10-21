//
//  BlackboardFilterSingleSelectViewModel.swift
//  andpad
//
//  Created by 佐藤俊輔 on 2021/04/16.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class BlackboardFilterSingleSelectItem {

    var contents: [String]
    var selectedContent: String?

    init(contents: [String], selectedContent: String?) {
        self.contents = contents
        self.selectedContent = selectedContent ?? contents.first ?? ""
    }

    func isSelected(at row: Int) -> Bool {
        let content = contents[row]
        return contents.contains(content)
    }

    func setSelect(_ content: String) {
        selectedContent = content
    }

    func reset() {
        // MEMO: 現状の仕様は一番最初のものをデフォルト値とする
        selectedContent = contents.first
    }
}

final class BlackboardFilterSingleSelectViewModel {

    typealias Item = BlackboardFilterSingleSelectItem

    var itemRelay: BehaviorRelay<Item>
    var item: BlackboardFilterSingleSelectItem

    let blackboardFilterSingleSelectContents: BlackboardFilterSingleSelectContentsProtocol
    private let doneSelectCellRelay = PublishRelay<Void>()

    init(
        blackboardFilterSingleSelectContents: BlackboardFilterSingleSelectContentsProtocol,
        currentContent: String?
    ) {
        self.blackboardFilterSingleSelectContents = blackboardFilterSingleSelectContents
        self.item = BlackboardFilterSingleSelectItem(
            contents: blackboardFilterSingleSelectContents.items,
            selectedContent: currentContent
        )
        self.itemRelay = BehaviorRelay<Item>(value: self.item)
    }
}

extension BlackboardFilterSingleSelectViewModel {
    func contentCellSelected(_ row: Int) {
        let selectedContent = item.contents[row]
        item.setSelect(selectedContent)
        itemRelay.accept(item)
        doneSelectCellRelay.accept(())
    }
    
    var doneSelectCellObservable: Observable<Void> {
        doneSelectCellRelay.asObservable()
    }
}

//
//  BlackboardFilterMultiSelectViewModel.swift
//  andpad
//
//  Created by 佐藤俊輔 on 2021/04/13.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import RxCocoa
import RxSwift

final class BlackboardFilterMultiSelectItem {
    var blackboardItemBody: String
    var contents: [ModernBlackboardConditionItemContent]
    var selectedContents: [String]
    var fetchedAll: Bool
    var shouldShowHideContentNotice: Bool

    init() {
        blackboardItemBody = ""
        contents = []
        selectedContents = []
        fetchedAll = false
        shouldShowHideContentNotice = false
    }

    func isSelected(at row: Int) -> Bool {
        let body = contents[row].body
        return selectedContents.contains(body)
    }
}

final class BlackboardFilterMultiSelectViewModel {

    typealias Item = BlackboardFilterMultiSelectItem

    var itemRelay: BehaviorRelay<Item>
    var item: BlackboardFilterMultiSelectItem

    var isContentEmpty = false

    var showErrorMessage = PublishRelay<AndpadCameraError>()
    var keywordSearchWillStart = PublishRelay<Void>()

    private var isFetching = false
    private var keyword: String?

    private let orderID: Int
    private let networkService: ModernBlackboardNetworkServiceProtocol

    private let requestLimitCount: Int = 20

    private let isOfflineMode: Bool

    private let filteringByPhoto: FilteringByPhotoType
    private let searchQuery: ModernBlackboardSearchQuery?

    ///  「0件の項目内容は非表示になっています」表示をするかどうか
    var shouldShowHideContentNotice: Bool {
        // オフラインモード時、検索結果0件時は表示しない
        if isOfflineMode || isContentEmpty {
            return false
        }

        // 前画面から絞り込み条件が指定された場合は表示する。
        if searchQuery != nil {
            return true
        }
        return false
    }

    private let bag = DisposeBag()

    init(
        networkService: ModernBlackboardNetworkServiceProtocol,
        orderID: Int,
        blackboardItemBody: String,
        initialSelectedContents: [String],
        isOfflineMode: Bool,
        filteringByPhoto: FilteringByPhotoType,
        searchQuery: ModernBlackboardSearchQuery?
    ) {
        self.orderID = orderID
        self.networkService = networkService
        self.searchQuery = searchQuery
        self.isOfflineMode = isOfflineMode
        self.filteringByPhoto = filteringByPhoto

        let item = BlackboardFilterMultiSelectItem()
        item.blackboardItemBody = blackboardItemBody
        item.selectedContents = initialSelectedContents
        self.item = item
        self.itemRelay = BehaviorRelay<Item>(value: self.item)
        self.item.shouldShowHideContentNotice = shouldShowHideContentNotice
    }
}

// MARK: - view action
extension BlackboardFilterMultiSelectViewModel {
    func viewDidLoad() async {
        await fetchBlackboardConditionItemContents()
    }

    func searchButtonClicked(_ text: String?) async {
        if isFetching {
            return
        }
        keywordSearchWillStart.accept(())
        keyword = text
        resetPaging()
        await fetchBlackboardConditionItemContents()
    }

    func tappedClearButton() {
        item.selectedContents = []
        itemRelay.accept(item)
    }

    func contentCellSelected(_ row: Int) {
        let selectedContent = item.contents[row].body
        // NOTE: APIの仕様上、選択肢の文字列が重複することが無いため、firstIndexで取得したIndexをそのまま使って問題ない。
        if let index = item.selectedContents.firstIndex(of: selectedContent) {
            item.selectedContents.remove(at: index)
        } else {
            item.selectedContents.append(selectedContent)
        }
        itemRelay.accept(item)
    }

    func scrolledDown() async {
        await fetchBlackboardConditionItemContents()
    }
}

// MARK: - private
private extension BlackboardFilterMultiSelectViewModel {
    func fetchBlackboardConditionItemContents() async {
        // すでに全て読み込み済みなら何もしない
        if item.fetchedAll { return }

        // 読み込み中なら何もしない
        if isFetching { return }

        defer {
            isFetching = false
        }

        isFetching = true

        do {
            let response = try await networkService.fetchFilteredBlackboardItemContents(
                orderID: orderID,
                offset: item.contents.count,
                limit: requestLimitCount,
                filteringByPhoto: filteringByPhoto,
                miniatureMapLayout: nil,
                searchQuery: searchQuery,
                blackboardItemBody: item.blackboardItemBody,
                keyword: keyword
            )

            guard let contents = response.data.objects else { return }
            isContentEmpty = contents.isEmpty
            item.fetchedAll = response.data.lastFlg ?? false
            item.shouldShowHideContentNotice = shouldShowHideContentNotice
            item.contents.append(contentsOf: contents.map { .init(body: $0.content) })
            itemRelay.accept(item)
        } catch {
            item.fetchedAll = true
            itemRelay.accept(item)
            showErrorMessage.accept(isOfflineMode ? .operationCouldNotBeCompleted : .network)
        }
    }
    
    func resetPaging() {
        item.contents = []
        item.fetchedAll = false
        itemRelay.accept(item)
    }
}

public struct ModernBlackboardConditionItemContent: Codable {
    public let body: String
    
    public init(body: String) {
        self.body = body
    }
}

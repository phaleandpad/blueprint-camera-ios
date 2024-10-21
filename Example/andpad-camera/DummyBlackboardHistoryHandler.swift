//
//  DummyBlackboardHistoryHandler.swift
//  andpad-camera_Example
//
//  Created by msano on 2022/01/18.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//

import andpad_camera
import RxSwift
import RxCocoa

// NOTE: ダミーの履歴ハンドラ
// 本来はローカルDBの黒板履歴データを操作（取得 / 保存 / 削除）するハンドラを擬似している
final class DummyBlackboardHistoryHandler {
    private var historyList: [BlackboardFilterConditionsHistory]

    init(historyList: [BlackboardFilterConditionsHistory] = []) {
        self.historyList = historyList
    }
}

// MARK: - BlackboardHistoryHandlerProtocol
extension DummyBlackboardHistoryHandler: BlackboardHistoryHandlerProtocol {
    func save(history: BlackboardFilterConditionsHistory) -> Completable {
        Completable.create { [weak self] completable in
            self?.historyList.insert(history, at: 0)
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func save(latestHistory: BlackboardFilterConditionsHistory?, orderID: Int) {
        // ダミーのため未対応
    }
    
    func getHistories(orderID: Int) -> Single<[BlackboardFilterConditionsHistory]> {
        Single.create { [weak self] single in
            single(.success(self?.historyList ?? []))
            return Disposables.create()
        }
    }
    
    func getLatestHistory(orderID: Int) -> Single<BlackboardFilterConditionsHistory?> {
        Single.create { single in
            single(.success(nil)) // ダミーのため未対応
            return Disposables.create()
        }
    }
    
    func delete(history: BlackboardFilterConditionsHistory) -> Completable {
        Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(DummyBlackboardHistoryHandlerError.unknown))
                return Disposables.create()
            }
            
            self.historyList = self.historyList.filter { !($0.orderID == history.orderID && $0.query == history.query) }
            completable(.completed)
            return Disposables.create()
        }
    }
}

// MARK: - ダミーの履歴リスト
extension DummyBlackboardHistoryHandler {
    /// 表示確認用の履歴リスト、使用は非推奨（あくまで表示確認にとどめること。こちらの履歴データによる絞り込みは、実際に運用している絞り込み条件と一致しなければ動かない可能性あり）
    static var dummyInitialHistoryList: [BlackboardFilterConditionsHistory] {
        [
            .init(
                id: "1",
                orderID: 1234,
                updatedAt: .init(),
                query: .init(
                    photoCondition: .hasPhoto,
                    conditionForBlackboardItems: [
                        .init(targetItemName: "工種", conditions: ["A"]),
                        .init(targetItemName: "工区", conditions: ["1工区"])
                    ],
                    freewords: "ダミーの履歴 1"
                )
            ),
            .init(
                id: "2",
                orderID: 1234,
                updatedAt: .init(),
                query: .init(
                    photoCondition: .all,
                    conditionForBlackboardItems: [
                        .init(targetItemName: "工種", conditions: ["A", "B"]),
                        .init(targetItemName: "工区", conditions: ["1工区"])
                    ],
                    freewords: "ダミーの履歴 2"
                )
            ),
            .init(
                id: "3",
                orderID: 1234,
                updatedAt: .init(),
                query: .init(
                    photoCondition: .all,
                    conditionForBlackboardItems: [
                        .init(targetItemName: "工種", conditions: ["A", "B", "C"]),
                        .init(targetItemName: "工区", conditions: ["1工区"])
                    ],
                    freewords: "ダミーの履歴 3"
                )
            ),
        ]
    }
}

// MARK: - DummyBlackboardHistoryHandlerError
enum DummyBlackboardHistoryHandlerError: Error {
    case unknown
}

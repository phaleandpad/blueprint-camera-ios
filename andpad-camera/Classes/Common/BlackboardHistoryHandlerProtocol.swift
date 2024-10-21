//
//  BlackboardHistoryHandlerProtocol.swift
//  andpad-camera
//
//  Created by msano on 2022/01/17.
//

import RxSwift
import RxRelay

public protocol BlackboardHistoryHandlerProtocol {
    func save(history: BlackboardFilterConditionsHistory) -> Completable
    func save(latestHistory: BlackboardFilterConditionsHistory?, orderID: Int)
    func getHistories(orderID: Int) -> Single<[BlackboardFilterConditionsHistory]>
    func getLatestHistory(orderID: Int) -> Single<BlackboardFilterConditionsHistory?>
    func delete(history: BlackboardFilterConditionsHistory) -> Completable
}

enum BlackboardHistoryHandlerError: Error {
    case uncorrectArguments
    case cannotInitLocalDB
    case cannotFindTargetData
    case failToHandleDB
    case unknown
}

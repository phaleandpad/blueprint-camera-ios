//
//  BlackboardFilterConditionsHistoryViewControllerTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2022/01/18.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick
import XCTest
import RxSwift
import RxCocoa

final class BlackboardFilterConditionsHistoryViewControllerTests: QuickSpec {

    typealias ViewModel = BlackboardFilterConditionsHistoryViewModel
    typealias ViewController = BlackboardFilterConditionsHistoryViewController
    
    override class func spec() {
        let someOrderID = 99999
        describe("画面表示時（test life cycle）") {
            context("黒板履歴ハンドラを所持しており、かつ履歴データを1つ以上取得できる場合") {
                it("画面がリスト表示され、空Viewは表示されない") {
                    // 履歴データを渡す
                    let handler = HistoryHandlerStub(historyList: HistoryHandlerStub.dummyInitialHistoryList)
                    let viewModel = makeViewModel(historyHandler: handler)
                    let viewController = makeViewCotroller(viewModel)
                    
                    let subviews = viewController.view.recursiveSubviews
                    let tableView = try XCTUnwrap(subviews.first(where: { $0 is BlackboardFilterConditionsHistoryTableView }) as? UITableView)
                    let emptyView = try XCTUnwrap(subviews.first(where: { $0 is BlackboardFilterConditionsHistoryEmptyView }) as? BlackboardFilterConditionsHistoryEmptyView)
                    
                    expect(tableView.numberOfRows(inSection: 0)).toEventually(equal(3))
                    expect(emptyView).toEventuallyNot(beNil())
                    expect(emptyView.isHidden).toEventually(beTrue())
                }
            }
            
            context("黒板履歴ハンドラを所持しており、かつ履歴データを1つも取得できない場合") {
                it("画面がリスト表示されず、空Viewは表示される") {
                    // 履歴データを渡さない
                    let handler = HistoryHandlerStub()
                    let viewModel = makeViewModel(historyHandler: handler)
                    let viewController = makeViewCotroller(viewModel)
                    
                    let subviews = viewController.view.recursiveSubviews
                    let tableView = try XCTUnwrap(subviews.first(where: { $0 is BlackboardFilterConditionsHistoryTableView }) as? UITableView)
                    let emptyView = try XCTUnwrap(subviews.first(where: { $0 is BlackboardFilterConditionsHistoryEmptyView }) as? BlackboardFilterConditionsHistoryEmptyView)
                    
                    expect(tableView.numberOfRows(inSection: 0)).toEventually(equal(0))
                    expect(emptyView).toEventuallyNot(beNil())
                    expect(emptyView.isHidden).toEventually(beFalse())
                }
            }
            
            context("黒板履歴ハンドラを所持していない場合") {
                it("ViewModelの生成に失敗し、故に画面も表示されない") {
                    let viewModel = BlackboardFilterConditionsHistoryViewModel(
                        orderID: someOrderID,
                        advancedOptions: [] // ここに黒板履歴ハンドラをセットせずにViewModel生成
                    )
                    expect(viewModel).to(beNil())
                }
            }
        }
        
        // MARK: - inner func
        
        func makeViewModel(historyHandler: BlackboardHistoryHandlerProtocol) -> ViewModel {
            let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption] = [
                .useHistoryView(.init(blackboardHistoryHandler: historyHandler))
            ]
            return .init(orderID: someOrderID, advancedOptions: advancedOptions)!
        }
        
        func makeViewCotroller(_ viewModel: BlackboardFilterConditionsHistoryViewModel) -> ViewController {
            .init(with: .init(viewModel: viewModel))
        }
    }
}

// MARK: - HistoryHandlerStub
extension BlackboardFilterConditionsHistoryViewControllerTests {
    final private class HistoryHandlerStub: BlackboardHistoryHandlerProtocol {
        private var historyList: [BlackboardFilterConditionsHistory]

        init(historyList: [BlackboardFilterConditionsHistory] = []) {
            self.historyList = historyList
        }
        
        func save(history: BlackboardFilterConditionsHistory) -> Completable {
            Completable.create { [weak self] completable in
                self?.historyList.insert(history, at: 0)
                completable(.completed)
                return Disposables.create()
            }
        }
        
        func save(latestHistory: BlackboardFilterConditionsHistory?, orderID: Int) {}
        
        func getHistories(orderID: Int) -> Single<[BlackboardFilterConditionsHistory]> {
            Single.create { [weak self] single in
                single(.success(self?.historyList ?? []))
                return Disposables.create()
            }
        }
        
        func getLatestHistory(orderID: Int) -> Single<BlackboardFilterConditionsHistory?> {
            Single.create { single in
                single(.success(nil))
                return Disposables.create()
            }
        }
        
        func delete(history: BlackboardFilterConditionsHistory) -> Completable {
            Completable.create { [weak self] completable in
                guard let self else {
                    completable(.error(HistoryHandlerStubError.unknown))
                    return Disposables.create()
                }
                
                self.historyList = self.historyList.filter { !($0.orderID == history.orderID && $0.query == history.query) }
                completable(.completed)
                return Disposables.create()
            }
        }
        
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
    
    private enum HistoryHandlerStubError: Error {
        case unknown
    }
}

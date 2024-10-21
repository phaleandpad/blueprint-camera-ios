//
//  ModernBlackboardListViewControllerTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2022/01/11.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick
import XCTest
import RxSwift
import RxCocoa

final class ModernBlackboardListViewControllerTests: QuickSpec {
    override class func spec() {
        
        let someSearchQueryFreeWord = "hoge"
        
        describe("画面表示時（test life cycle）") {
            beforeEach {
                AndpadCameraDependencies.shared.setup(
                    remoteConfigHandler: RemoteConfigHandlerStub(
                        useBlackboardGeneratedWithSVG: true
                    )
                )
            }
            context("黒板データを複数件取得した場合") {
                it("黒板データがリスト表示され、空Viewは表示されない") {
                    // arrange
                    let networkServiceStub = NetworkServiceStub(hasSomeBlackboardMaterials: true)
                    let modernBlackboardListViewModel = someBlackboardListViewModel(networkServiceStub)
                    let modernBlackboardListViewController = ModernBlackboardListViewController(
                        with: .init(viewModel: modernBlackboardListViewModel)
                    )
                    
                    // act
                    _ = modernBlackboardListViewController.view
                    let subviews = modernBlackboardListViewController.view.recursiveSubviews
                    guard let tableView = subviews.first(where:{ $0 is ModernBlackboardListTableView }) as? UITableView else {
                        fail()
                        return
                    }
                    let emptyView = tableView.delegate!.tableView!(tableView, viewForHeaderInSection: 0)
                    
                    // assert
                    expect(tableView.numberOfRows(inSection: 0)).toEventually(equal(6))
                    expect(emptyView).toEventually(beNil())
                }
            }
            
            context("黒板データを0件取得した場合") {
                it("黒板データがリスト表示されず、空Viewが表示される") {
                    // arrange
                    let networkServiceStub = NetworkServiceStub(hasSomeBlackboardMaterials: false)
                    let modernBlackboardListViewModel = someBlackboardListViewModel(networkServiceStub)
                    let modernBlackboardListViewController = ModernBlackboardListViewController(
                        with: .init(viewModel: modernBlackboardListViewModel)
                    )
                    
                    // act
                    _ = modernBlackboardListViewController.view
                    let subviews = modernBlackboardListViewController.view.recursiveSubviews
                    guard let tableView = subviews.first(where:{ $0 is ModernBlackboardListTableView }) as? UITableView else {
                        fail()
                        return
                    }
                    let emptyView = tableView.delegate!.tableView!(tableView, viewForHeaderInSection: 0)
                    
                    // assert
                    expect(tableView.numberOfRows(inSection: 0)).toEventually(equal(0))
                    expect(emptyView).toEventuallyNot(beNil())
                    expect(emptyView is ModernBlackboardListEmptyWithFilteringView).toEventually(beFalse())
                }
            }
            
            context("絞り込み条件付きで、黒板データを0件取得した場合") {
                it("黒板データがリスト表示されず、（絞り込み時用の）空Viewが表示される") {
                    // arrange
                    let networkServiceStub = NetworkServiceStub(hasSomeBlackboardMaterials: false)
                    let modernBlackboardListViewModel = someBlackboardListViewModel(networkServiceStub)
                    let modernBlackboardListViewController = ModernBlackboardListViewController(
                        with: .init(viewModel: modernBlackboardListViewModel)
                    )
                    modernBlackboardListViewModel.receiveNewSearchQuery(
                        .init(
                            conditionForBlackboardItems: [],
                            freewords: someSearchQueryFreeWord
                        ),
                        shouldSaveSearchQuery: false
                    )
                    
                    // act
                    _ = modernBlackboardListViewController.view
                    let subviews = modernBlackboardListViewController.view.recursiveSubviews
                    guard let tableView = subviews.first(where:{ $0 is ModernBlackboardListTableView }) as? UITableView else {
                        fail()
                        return
                    }
                    let emptyView = tableView.delegate!.tableView!(tableView, viewForHeaderInSection: 0)
                    
                    // assert
                    expect(tableView.numberOfRows(inSection: 0)).toEventually(equal(0))
                    expect(emptyView).toEventuallyNot(beNil())
                    // NOTE: （絞り込み時用の）空View = ModernBlackboardListEmptyWithFilteringView
                    expect(emptyView is ModernBlackboardListEmptyWithFilteringView).toEventually(beTrue())
                }
            }
        }

        func someBlackboardListViewModel(_ networkSerivce: ModernBlackboardNetworkServiceProtocol) -> ModernBlackboardListViewModel {
            .init(
                networkService: networkSerivce,
                orderID: 1,
                snapshotData: .init(userID: 999999, orderName: "hoge", clientName: "fuga", startDate: Date()),
                selectedBlackboard: nil,
                advancedOptions: []
            )
        }
    }
}

// MARK: - NetworkServiceStub
final fileprivate class NetworkServiceStub: ModernBlackboardNetworkServiceProtocol {
    private let hasSomeBlackboardMaterials: Bool
    private let getBlackboardResultRelay = PublishRelay<Void>()
    private let getBlackboardCommonSettingRelay = PublishRelay<Void>()
    
    init(hasSomeBlackboardMaterials: Bool) {
        self.hasSomeBlackboardMaterials = hasSomeBlackboardMaterials
    }
    
    var getBlackboardResultObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        getBlackboardResultRelay
            .asObservable()
            .map { [weak self] in
                return ResponseData(
                    data: .init(
                        object: nil,
                        objects: self!.hasSomeBlackboardMaterials
                            ? [
                                self!.someModernBlackboardMaterial,
                                self!.someModernBlackboardMaterial,
                                self!.someModernBlackboardMaterial,
                                self!.someModernBlackboardMaterial,
                                self!.someModernBlackboardMaterial,
                                self!.someModernBlackboardMaterial,
                            ]
                            : [],
                        lastFlg: true,
                        total:  6,
                        permissions: nil
                    )
                )
            }
    }
    
    var getBlackboardCommonSettingObservable: Observable<ResponseData<ModernBlackboardCommonSetting>> {
        getBlackboardCommonSettingRelay
            .flatMap { [weak self] in
                Observable.just(
                    ResponseData(
                        data: .init(
                            object: self!.someModernBlackboardCommonSetting,
                            objects: [],
                            lastFlg: false,
                            total: 1,
                            permissions: nil
                        )
                    )
                )
            }
    }
    
    func getBlackboardResult(
        with fetchingType: PagingFetchingType,
        orderID: Int,
        searchQuery: ModernBlackboardSearchQuery?,
        sortType: ModernBlackboardsSortType
    ) {
        getBlackboardResultRelay.accept(())
    }
    
    func getBlackboardCommonSetting(orderID: Int) {
        getBlackboardCommonSettingRelay.accept(())
    }
}

// MARK: - some object
extension NetworkServiceStub {
    var someModernBlackboardMaterial: ModernBlackboardMaterial {
        .forTesting(
            id: 123,
            blackboardTemplateID: 1234,
            layoutTypeID: 1,
            photoCount: 4,
            blackboardTheme: .init(themeCode: 1),
            items: [
                .init(itemName: "工事名", body: "construction name body", position: 1),
                .init(itemName: "工種", body: "物流調査", position: 2),
                .init(itemName: "工区", body: "1工区", position: 3),
            ],
            blackboardTrees: [
                .init(id: 1234, body: "レイアウト1"),
                .init(id: 1235, body: "物流調査"),
                .init(id: 1236, body: "1工区"),
            ],
            miniatureMap: nil
        )
    }
    
    var someModernBlackboardCommonSetting: ModernBlackboardCommonSetting {
        .init(
            defaultTheme: .black,
            canEditBlackboardStyle: true,
            remarkTextSize: "small",
            remarkHorizontalAlign: "left",
            remarkVerticalAlign: "top",
            dateFormatType: .withSlash,
            canEditDate: true,
            selectedConstructionPlayerName: "黒板に表示する施工者名デフォルト設定",
            constructionNameDisplayType: .orderName,
            customConstructionNameElements: [],
            constructionNameTitle: "自由な工事名",
            blackboardTransparencyType: .opaque,
            blackboardDefaultSizeRate: 100,
            preferredPhotoFormat: .jpeg
        )
    }
}

// MARK: - not implemented logic
extension NetworkServiceStub {
    var catchErrorDriver: Driver<ErrorInformation> {
        Driver.just(.init(error: NetworkServiceStubError.notImplemented))
    }
        
    var getBlackboardConditionItemsObservable: Observable<ResponseData<ModernBlackboardConditionItem>> {
        fatalError("not implemented.")
    }
    
    var getBlackboardConditionItemContentObservable: Observable<ResponseData<ModernBlackboardConditionItemContent>>{
        fatalError("not implemented.")
    }
    
    func getBlackboardConditionItems(orderID: Int) {
        fatalError("not implemented.")
    }
    
    func getBlackboardConditionItemContents(params: BlackboardConditionItemContentsParams, orderID: Int) {
        fatalError("not implemented.")
    }
    
    var appBaseRequestData: AppBaseRequestData {
        fatalError("not implemented.")
    }
    
    var showLoadingDriver: Driver<Void> {
        // not implemented.
        // do nothing (in this test case).
        Observable.just(()).asDriver(onErrorJustReturn: ())
    }
    
    var hideLoadingDriver: Driver<Void> {
        // not implemented.
        // do nothing (in this test case).
        Observable.just(()).asDriver(onErrorJustReturn: ())
    }
    
    func postNewBlackboard(blackboardMaterial: ModernBlackboardMaterial, type: PostBlackboardType, orderID: Int) {
        fatalError("not implemented.")
    }
    
    func putBlackboard(blackboardMaterial: ModernBlackboardMaterial, orderID: Int) {
        fatalError("not implemented.")
    }
    
    var postBlackboardObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        fatalError("not implemented.")
    }
    
    var putBlackboardObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        fatalError("not implemented.")
    }
    
    func getBlackboardDetail(throttleConfiguration: ThrottleConfiguration, orderID: Int, blackboardID: Int) {
        fatalError("not implemented.")
    }
    
    func getOrderPermissions(orderID: Int) {
        fatalError("not implemented.")
    }

    var getBlackboardDetailObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        fatalError("not implemented.")
    }
    
    var getOrderPermissionObservable: Observable<ResponseData<OrderAndPermissions>> {
        fatalError("not implemented.")
    }

    func fetchFilteredBlackboardItems(
        orderID: Int,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?
    ) async throws -> FetchFilteredBlackboardItemsResponse {
        fatalError("not implemented.")
    }

    func fetchFilteredBlackboardItemContents(
        orderID: Int,
        offset: Int?,
        limit: Int?,
        filteringByPhoto: FilteringByPhotoType,
        miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?,
        searchQuery: ModernBlackboardSearchQuery?,
        blackboardItemBody: String,
        keyword: String?
    ) async throws -> ResponseData<FilteredBlackboardItemContent> {
        fatalError("not implemented.")
    }
}

// MARK: - NetworkServiceStubError
fileprivate enum NetworkServiceStubError: Error {
    case notImplemented
}

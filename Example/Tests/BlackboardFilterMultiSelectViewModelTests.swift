//
//  BlackboardFilterMultiSelectViewModelTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2022/01/17.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import RxCocoa
import RxSwift
import RxTest
import RxBlocking
import XCTest

final class BlackboardFilterMultiSelectViewModelTests: XCTestCase {

    struct SomeError: Error {}

    private let someOrderID: Int = 99999
    private let someBlackboardItemBody = "some 工種"
    fileprivate static let someContents: [ModernBlackboardConditionItemContent] = [
        .init(body: "hoge"),
        .init(body: "fuga"),
        .init(body: "moga")
    ]

    private let isOfflineMode = false

    private var testScheduler: TestScheduler!
    private var itemObserver: TestableObserver<BlackboardFilterMultiSelectItem>!
    private var showErrorMessageObserver: TestableObserver<AndpadCameraError>!

    let filteringByPhoto: FilteringByPhotoType = .all
    let searchQuery: ModernBlackboardSearchQuery? = nil

    let bag = DisposeBag()

    override func setUpWithError() throws {
        testScheduler = TestScheduler(initialClock: 0)
        itemObserver = testScheduler.createObserver(BlackboardFilterMultiSelectItem.self)
        showErrorMessageObserver = testScheduler.createObserver(AndpadCameraError.self)
    }
    
    func testViewDidLoad_成功時() async throws {
        let networkServiceStub = NetworkServiceStub(
            doShowResponseError: false,
            isLastResponse: true
        )
        let viewModel = makeViewModel(networkServiceStub: networkServiceStub)
        
        viewModel
            .itemRelay
            .bind(to: itemObserver)
            .disposed(by: bag)
        viewModel
            .showErrorMessage
            .bind(to: showErrorMessageObserver)
            .disposed(by: bag)

        XCTAssertEqual(itemObserver.events.last!.value.element!.contents.count, 0)

        await viewModel.viewDidLoad()

        XCTAssertEqual(itemObserver.events.last!.value.element!.contents.count, Self.someContents.count)
        XCTAssertEqual(showErrorMessageObserver.events.count, 0)
    }

    func testViewDidLoad_エラー時()  async throws {
        let networkServiceStub = NetworkServiceStub(
            doShowResponseError: true,
            isLastResponse: true
        )
        let viewModel = makeViewModel(networkServiceStub: networkServiceStub)
        
        viewModel
            .itemRelay
            .bind(to: itemObserver)
            .disposed(by: bag)
        viewModel
            .showErrorMessage
            .bind(to: showErrorMessageObserver)
            .disposed(by: bag)

        XCTAssertEqual(itemObserver.events.last!.value.element!.contents.count, 0)

        await viewModel.viewDidLoad()

        XCTAssertEqual(itemObserver.events.last!.value.element!.contents.count, 0)
        XCTAssertEqual(showErrorMessageObserver.events.count, 1)
    }

    func testSearchButtonClicked() async throws {
        let networkServiceStub = NetworkServiceStub(
            doShowResponseError: false,
            isLastResponse: true
        )
        let viewModel = makeViewModel(networkServiceStub: networkServiceStub)

        viewModel
            .itemRelay
            .bind(to: itemObserver)
            .disposed(by: bag)

        await viewModel.viewDidLoad()

        await viewModel.searchButtonClicked("someSearchText")

        XCTAssertEqual(itemObserver.events.last!.value.element!.contents.count, Self.someContents.count)
        // MEMO: offsetが0 & 指定したkeyword を含むパラメータで正しくリクエストできていること
        XCTAssertEqual(networkServiceStub.fetchFilteredBlackboardItemContentsParams.keyword, "someSearchText")
        XCTAssertEqual(networkServiceStub.fetchFilteredBlackboardItemContentsParams.offset, 0)
    }

    func testClearCellSelected() async throws {
        let networkServiceStub = NetworkServiceStub(doShowResponseError: false, isLastResponse: true)
        let viewModel = makeViewModel(networkServiceStub: networkServiceStub)
        
        viewModel
            .itemRelay
            .bind(to: itemObserver)
            .disposed(by: bag)

        await viewModel.viewDidLoad()

        viewModel.contentCellSelected(0)

        XCTAssertEqual(itemObserver.events.last!.value.element!.selectedContents.count, 1)

        viewModel.tappedClearButton()

        XCTAssertEqual(itemObserver.events.last!.value.element!.selectedContents.count, 0)
    }

    func testContentCellSelected() async throws {
        let networkServiceStub = NetworkServiceStub(doShowResponseError: false, isLastResponse: true)
        let viewModel = makeViewModel(networkServiceStub: networkServiceStub)

        viewModel
            .itemRelay
            .bind(to: itemObserver)
            .disposed(by: bag)

        await viewModel.viewDidLoad()

        viewModel.contentCellSelected(0)

        XCTAssertEqual(itemObserver.events.last!.value.element!.selectedContents.count, 1)

        viewModel.contentCellSelected(0)

        XCTAssertEqual(itemObserver.events.last!.value.element!.selectedContents.count, 0)
    }

    func testScrolledDown_ページングが完了する時() async throws {
        let networkServiceStub = NetworkServiceStub(
            doShowResponseError: false,
            isLastResponse: true // ここ！！
        )
        let viewModel = makeViewModel(networkServiceStub: networkServiceStub)

        viewModel
            .itemRelay
            .bind(to: itemObserver)
            .disposed(by: bag)

        await viewModel.viewDidLoad()

        await viewModel.scrolledDown()

        // viewDidLoadの時点でページングが完了しているので、APIリクエストは scrolledDown() を実行してももう呼ばれない（ = contentsは増えない）
        XCTAssertEqual(viewModel.item.contents.count, Self.someContents.count)
    }

    func testScrolledDown_ページングが続く時() async throws {
        let networkServiceStub = NetworkServiceStub(
            doShowResponseError: false,
            isLastResponse: false // ここ！！
        )
        let viewModel = makeViewModel(networkServiceStub: networkServiceStub)

        viewModel
            .itemRelay
            .bind(to: itemObserver)
            .disposed(by: bag)

        await viewModel.viewDidLoad()

        await viewModel.scrolledDown()
        await viewModel.scrolledDown()
        await viewModel.scrolledDown()

        // viewDidLoad() / および scrolledDown() の実行回数分、contentsが増える
        XCTAssertEqual(viewModel.item.contents.count, Self.someContents.count * 4)
    }
    
    private func makeViewModel(
        networkServiceStub: NetworkServiceStub
    ) -> BlackboardFilterMultiSelectViewModel {
        .init(
            networkService: networkServiceStub,
            orderID: someOrderID,
            blackboardItemBody: someBlackboardItemBody,
            initialSelectedContents: [],
            isOfflineMode: isOfflineMode,
            filteringByPhoto: filteringByPhoto,
            searchQuery: searchQuery
        )
    }
}

// MARK: - NetworkServiceStub
final fileprivate class NetworkServiceStub: ModernBlackboardNetworkServiceProtocol {
    struct FetchFilteredBlackboardItemContentsParams {
        let orderID: Int
        let offset: Int?
        let limit: Int?
        let filteringByPhoto: FilteringByPhotoType
        let miniatureMapLayout: MiniatureMapLayoutTypeForFiltering?
        let searchQuery: ModernBlackboardSearchQuery?
        let blackboardItemBody: String
        let keyword: String?
    }

    var fetchFilteredBlackboardItemContentsParams = FetchFilteredBlackboardItemContentsParams(
        orderID: 0,
        offset: nil,
        limit: nil,
        filteringByPhoto: .all,
        miniatureMapLayout: nil,
        searchQuery: nil,
        blackboardItemBody: "",
        keyword: nil
    )

    private let doShowResponseError: Bool
    private let isLastResponse: Bool

    init(
        doShowResponseError: Bool, // レスポンスエラーを生じさせるか / 否か
        isLastResponse: Bool // ページングさせないか / させるか
    ) {
        self.doShowResponseError = doShowResponseError
        self.isLastResponse = isLastResponse
    }
    
    func getBlackboardResult(
        with fetchingType: PagingFetchingType,
        orderID: Int,
        searchQuery: ModernBlackboardSearchQuery?,
        sortType: ModernBlackboardsSortType
    ) {
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
    
    var catchErrorDriver: Driver<ErrorInformation> {
        fatalError("not implemented.")
    }
    
    var getBlackboardResultObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        fatalError("not implemented.")
    }
    
    var getBlackboardConditionItemsObservable: Observable<ResponseData<ModernBlackboardConditionItem>> {
        fatalError("not implemented.")
    }
    
    var getBlackboardConditionItemContentObservable: Observable<ResponseData<ModernBlackboardConditionItemContent>> {
        fatalError("not implemented.")
    }
    
    func getBlackboardCommonSetting(orderID: Int) {
        fatalError("not implemented.")
    }
    
    var getBlackboardCommonSettingObservable: Observable<ResponseData<ModernBlackboardCommonSetting>> {
        fatalError("not implemented.")
    }
    
    var showLoadingDriver: Driver<Void> {
        fatalError("not implemented.")
    }
    
    var hideLoadingDriver: Driver<Void> {
        fatalError("not implemented.")
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
        fetchFilteredBlackboardItemContentsParams = .init(
            orderID: orderID,
            offset: offset,
            limit: limit,
            filteringByPhoto: filteringByPhoto,
            miniatureMapLayout: miniatureMapLayout,
            searchQuery: searchQuery,
            blackboardItemBody: blackboardItemBody,
            keyword: keyword
        )
        guard !doShowResponseError else {
            throw NetworkServiceStubError.someResponseError
        }
        return ResponseData(
            data: .init(
                object: nil,
                objects: BlackboardFilterMultiSelectViewModelTests.someContents.map { .init(content: $0.body) },
                lastFlg: isLastResponse,
                total: 3,
                permissions: nil
            )
        )
    }
}

fileprivate enum NetworkServiceStubError: Error {
    case someResponseError
}

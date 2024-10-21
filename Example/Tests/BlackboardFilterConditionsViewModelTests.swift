//
//  BlackboardFilterConditionsViewModelTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2022/01/20.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import RxCocoa
import RxSwift
import RxTest
import RxBlocking
import Quick
import Nimble

// MARK: - BlackboardFilterConditionsViewModelTests

final class BlackboardFilterConditionsViewModelTests: QuickSpec {
    override class func spec() {
        let someUserID = 88888
        let someOrderID = 99999
        let someConditionItems: [ModernBlackboardConditionItem] = [
            .init(body: "hoge", priorityDisplay: true),
            .init(body: "fuga", priorityDisplay: true),
            .init(body: "moga", priorityDisplay: true)
        ]
        let someBlackboardMaterials: [ModernBlackboardMaterial] = [
            .forTesting(
                id: 1,
                blackboardTemplateID: 11,
                layoutTypeID: 1,
                photoCount: 2,
                blackboardTheme: .black,
                items: [
                    .init(itemName: "hoge", body: "hogeBody", position: 1),
                    .init(itemName: "fuga", body: "fugaBody", position: 2),
                    .init(itemName: "moga", body: "mogaBody", position: 3)
                ],
                blackboardTrees: [],
                miniatureMap: nil
            ),
            .forTesting(
                id: 2,
                blackboardTemplateID: 12,
                layoutTypeID: 2,
                photoCount: 0,
                blackboardTheme: .black,
                items: [
                    .init(itemName: "hoge", body: "hogeBody", position: 1),
                    .init(itemName: "fuga", body: "fugaBody", position: 2),
                    .init(itemName: "moga", body: "mogaBody", position: 3),
                    .init(itemName: "muga", body: "mugaBody", position: 4)
                ],
                blackboardTrees: [],
                miniatureMap: nil
            )
        ]

        let defaultItemCount = 1

        let isOfflineMode = false

        describe("life cycyle (by view controller)") {
            context("ViewModel生成時、APIレスポンスを正常に取得できた場合") {
                it("絞り込み項目データとしてパース、itemsに渡される") {
                    // arrange
                    let networkService = NetworkServiceStub(
                        conditionItems: someConditionItems,
                        blackboardMaterials: someBlackboardMaterials,
                        doShowResponseError: false,
                        isLastResponse: true
                    )
                    let viewModel = BlackboardFilterConditionsViewModel(
                        networkService: networkService,
                        userID: someUserID,
                        orderID: someOrderID,
                        searchQuery: nil,
                        advancedOptions: [],
                        isOfflineMode: isOfflineMode
                    )

                    // NOTE: ViewModelのインスタンスを生成したタイミングでは items にデータが入らない。
                    expect(filteredItemsCount(sections: viewModel.items.value)).to(equal(0))

                    // act
                    viewModel.inputPort.accept(.viewDidLoad)

                    // assert
                    // NOTE: ViewModel初期化時に itemへ値(空配列)が流れてしまうので、一度skipした後の値を待ち受けるようにする。
                    let itemsAfterViewDidLoad = try XCTUnwrap(try viewModel.items.skip(1).toBlocking().first())
                    expect(filteredItemsCount(sections: itemsAfterViewDidLoad)).to(equal(someConditionItems.count + defaultItemCount))
                }
            }
        }

        describe("絞り込み総数の更新") {
            context("ViewModel生成時、検索クエリを持たない場合") {
                var disposeBag: DisposeBag? = DisposeBag()

                afterEach {
                    disposeBag = nil
                }
                
                it("APIレスポンスを正常に取得後、絞り込み検索を行い、絞り込み総数の更新が行われる") {
                    // arrange
                    var blackboardsCounter: Int? = nil

                    let networkService = NetworkServiceStub(
                        conditionItems: someConditionItems,
                        blackboardMaterials: someBlackboardMaterials,
                        doShowResponseError: false,
                        isLastResponse: true
                    )
                    let viewModel = BlackboardFilterConditionsViewModel(
                        networkService: networkService,
                        userID: someUserID,
                        orderID: someOrderID,
                        searchQuery: nil,
                        advancedOptions: [],
                        isOfflineMode: isOfflineMode
                    )

                    // NOTE: ViewModelのインスタンスを生成したタイミングでは items にデータが入らない。
                    expect(filteredItemsCount(sections: viewModel.items.value)).to(equal(0))
                    expect(blackboardsCounter).to(beNil())

                    viewModel.outputPort
                        .bind(onNext: {
                            if case .updateCounter(let num) = $0 {
                                blackboardsCounter = num
                            }
                        })
                        .disposed(by: disposeBag!)

                    // act
                    viewModel.inputPort.accept(.viewDidLoad)

                    // assert
                    // NOTE: ViewModel初期化時に itemへ値(空配列)が流れてしまうので、一度skipした後の値を待ち受けるようにする。
                    let itemsAfterViewDidLoad = try XCTUnwrap(try viewModel.items.skip(1).toBlocking().first())
                    expect(filteredItemsCount(sections: itemsAfterViewDidLoad)).to(equal(someConditionItems.count + defaultItemCount))
                    expect(blackboardsCounter).toEventuallyNot(beNil())
                    expect(blackboardsCounter).toEventually(equal(someBlackboardMaterials.count))
                }
            }

            context("ViewModel生成時、検索クエリを持つ場合") {
                var disposeBag: DisposeBag? = DisposeBag()

                afterEach {
                    disposeBag = nil
                }

                it("APIレスポンスを正常に取得後、絞り込み検索を行い、絞り込み総数の更新が行われる") {
                    // arrange
                    var blackboardsCounter: Int? = nil

                    let networkService = NetworkServiceStub(
                        conditionItems: someConditionItems,
                        blackboardMaterials: someBlackboardMaterials,
                        doShowResponseError: false,
                        isLastResponse: true
                    )
                    let viewModel = BlackboardFilterConditionsViewModel(
                        networkService: networkService,
                        userID: someUserID,
                        orderID: someOrderID,
                        searchQuery: .init(conditionForBlackboardItems: [], freewords: "hoge"),
                        advancedOptions: [],
                        isOfflineMode: isOfflineMode
                    )

                    // NOTE: ViewModelのインスタンスを生成したタイミングでは items にデータが入らない。
                    expect(filteredItemsCount(sections: viewModel.items.value)).to(equal(0))
                    expect(blackboardsCounter).to(beNil())

                    viewModel.outputPort
                        .bind(onNext: {
                            if case .updateCounter(let num) = $0 {
                                blackboardsCounter = num
                            }
                        })
                        .disposed(by: disposeBag!)

                    // act
                    viewModel.inputPort.accept(.viewDidLoad)

                    // assert
                    // NOTE: ViewModel初期化時に itemへ値(空配列)が流れてしまうので、一度skipした後の値を待ち受けるようにする。
                    let itemsAfterViewDidLoad = try XCTUnwrap(try viewModel.items.skip(1).toBlocking().first())
                    expect(filteredItemsCount(sections: itemsAfterViewDidLoad)).to(equal(someConditionItems.count + defaultItemCount))
                    expect(blackboardsCounter).toEventuallyNot(beNil())
                    expect(blackboardsCounter).toEventually(equal(someBlackboardMaterials.count))
                }
            }
        }

        // 上記のテスト内で使用するメソッドのテストコード
        // テスト対象のメソッド: `func filteredItemsCount(sections: [BlackboardFilterConditionsViewModel.DataSource.Section]) -> Int`
        describe("絞り込み画面のセクションのデータから絞り込み項目の件数を取得する関数のテスト") {
            context("写真のみの場合に") {
                it("正しくカウントされること") {
                    let sections: [BlackboardFilterConditionsViewModel.DataSource.Section] = [
                        .photo(items: [.photo("test1"), .photo("test2")])
                    ]
                    expect(filteredItemsCount(sections: sections)).to(equal(2))
                }
            }

            context("ピン留めされた項目のみの場合に") {
                it("正しくカウントされること") {
                    let sections: [BlackboardFilterConditionsViewModel.DataSource.Section] = [
                        .blackboardItem(title: "title", items: [
                            .pinnedBlackboardItem(itemName: "itemName1", selectedConditions: [], isActive: true),
                            .pinnedBlackboardItem(itemName: "itemName2", selectedConditions: [], isActive: true)
                        ])
                    ]
                    expect(filteredItemsCount(sections: sections)).to(equal(2))
                }
            }

            context("ピン留めされていない項目のみの場合に") {
                it("正しくカウントされること") {
                    let sections: [BlackboardFilterConditionsViewModel.DataSource.Section] = [
                        .blackboardItem(title: "title", items: [
                            .unpinnedBlackboardItem(itemName: "itemName1", selectedConditions: [], isVisible: true, isActive: true),
                            .unpinnedBlackboardItem(itemName: "itemName2", selectedConditions: [], isVisible: false, isActive: true)
                        ])
                    ]
                    expect(filteredItemsCount(sections: sections)).to(equal(2))
                }
            }

            context("セパレーター項目のみの場合に") {
                it("0件としてカウントされること") {
                    let sections: [BlackboardFilterConditionsViewModel.DataSource.Section] = [
                        .blackboardItem(title: "", items: [.blackboardItemsSeparator])
                    ]
                    expect(filteredItemsCount(sections: sections)).to(equal(0))
                }
            }

            context("フリーワード項目のみの場合に") {
                it("0件としてカウントされること") {
                    let sections: [BlackboardFilterConditionsViewModel.DataSource.Section] = [
                        .freeword(title: "title", items: [.freeword("test1"), .freeword("test2")]),
                    ]
                    expect(filteredItemsCount(sections: sections)).to(equal(0))
                }
            }

            context("セクションが空の場合に") {
                it("0件としてカウントされること") {
                    let sections: [BlackboardFilterConditionsViewModel.DataSource.Section] = [
                    ]
                    expect(filteredItemsCount(sections: sections)).to(equal(0))
                }
            }

            context("すべての種類の組み合わせで") {
                it("正しくカウントされること") {
                    let sections: [BlackboardFilterConditionsViewModel.DataSource.Section] = [
                        .photo(items: [.photo("test")]),
                        .blackboardItem(title: "blackboard-title", items: [
                            .pinnedBlackboardItem(itemName: "itemName1", selectedConditions: [], isActive: true),
                            .blackboardItemsSeparator,
                            .unpinnedBlackboardItem(itemName: "itemName2", selectedConditions: [], isVisible: true, isActive: true)
                        ]),
                        .freeword(title: "freeword-title", items: [.freeword("test")]),
                    ]
                    expect(filteredItemsCount(sections: sections)).to(equal(3))
                }
            }
        }

        /// 絞り込み項目の件数
        ///
        /// 写真・ピン留めされた項目・その他の項目が対象
        /// - Parameter sections: 絞り込み画面のセクションのデータ
        /// - Returns: 絞り込み項目の件数
        func filteredItemsCount(sections: [BlackboardFilterConditionsViewModel.DataSource.Section]) -> Int {
            sections
                .flatMap { $0.items }
                .filter { item in
                    switch item {
                    case .photo, .pinnedBlackboardItem, .unpinnedBlackboardItem:
                        return true
                    case .blackboardItemsSeparator, .freeword, .showAllBlackboardItemsButton:
                        return false
                    }
                }
                .count
        }
    }
}

// MARK: - NetworkServiceStub

private final class NetworkServiceStub: ModernBlackboardNetworkServiceProtocol {
    private let getBlackboardResultRelay = PublishRelay<Void>()
    private let getBlackboardConditionItemsRelay = PublishRelay<Void>()
    private let getBlackboardConditionItemContentsRelay = PublishRelay<Void>()
    private let catchErrorRelay = PublishRelay<ErrorInformation>()
    
    private let doShowResponseError: Bool
    private let isLastResponse: Bool
    
    private let conditionItems: [ModernBlackboardConditionItem]
    private let blackboardMaterials: [ModernBlackboardMaterial]
    
    var getBlackboardContentsParams = BlackboardConditionItemContentsParams(
        offset: 0,
        limit: 0,
        type: .search,
        blackboardItemBody: "",
        keyword: nil
    )

    init(
        conditionItems: [ModernBlackboardConditionItem],
        blackboardMaterials: [ModernBlackboardMaterial],
        doShowResponseError: Bool, // レスポンスエラーを生じさせるか / 否か
        isLastResponse: Bool // ページングさせないか / させるか
    ) {
        self.conditionItems = conditionItems
        self.blackboardMaterials = blackboardMaterials
        self.doShowResponseError = doShowResponseError
        self.isLastResponse = isLastResponse
    }
    
    func getBlackboardResult(
        with fetchingType: PagingFetchingType,
        orderID: Int,
        searchQuery: ModernBlackboardSearchQuery?,
        sortType: ModernBlackboardsSortType
    ) {
        getBlackboardResultRelay.accept(())
    }
    
    func getBlackboardConditionItems(orderID: Int) {
        getBlackboardConditionItemsRelay.accept(())
    }
    
    func getBlackboardConditionItemContents(params: BlackboardConditionItemContentsParams, orderID: Int) {
        getBlackboardContentsParams = params
        getBlackboardConditionItemContentsRelay.accept(())
    }
    
    var appBaseRequestData: AppBaseRequestData {
        fatalError("not implemented.")
    }
    
    var catchErrorDriver: Driver<ErrorInformation> {
        catchErrorRelay.asDriver(onErrorJustReturn: .init(error: NetworkServiceStubError.someResponseError))
    }
    
    var getBlackboardResultObservable: Observable<ResponseData<ModernBlackboardMaterial>> {
        getBlackboardResultRelay.asObservable()
            .map { [weak self] in
                return .init(
                    data: .init(
                        object: nil,
                        objects: self!.blackboardMaterials,
                        lastFlg: true,
                        total: self!.blackboardMaterials.count,
                        permissions: nil
                    )
                )
            }
    }
    
    var getBlackboardConditionItemsObservable: Observable<ResponseData<ModernBlackboardConditionItem>> {
        getBlackboardConditionItemsRelay
            .asObservable()
            .map { [weak self] in
                .init(
                    data: .init(
                        object: nil,
                        objects: self!.conditionItems,
                        lastFlg: self!.isLastResponse,
                        total: 3,
                        permissions: nil
                    )
                )
            }
    }
    
    var getBlackboardConditionItemContentObservable: Observable<ResponseData<ModernBlackboardConditionItemContent>> {
        getBlackboardConditionItemContentsRelay
            .asObservable()
            .map { [weak self] in
                guard !self!.doShowResponseError else {
                    return ResponseData(
                        data: .init(
                            object: nil,
                            objects: nil,
                            lastFlg: nil,
                            total: 0,
                            permissions: nil
                        )
                    )
                }
                return ResponseData(
                    data: .init(
                        object: nil,
                        objects: [],
                        lastFlg: self!.isLastResponse,
                        total: 3,
                        permissions: nil
                    )
                )
            }
    }
    
    func catchError() {
        catchErrorRelay.accept(.init(error: NetworkServiceStubError.someResponseError))
    }

    fileprivate enum NetworkServiceStubError: Error {
        case someResponseError
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
        .init(data: .init(
            blackboardCount: blackboardMaterials.count,
            items: conditionItems.map { FilteredBlackboardItem(
                name: $0.body,
                shouldDisplayWithHighPriority: $0.priorityDisplay,
                blackboardExists: true
            ) }
        ))
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

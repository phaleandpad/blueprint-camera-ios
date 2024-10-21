//
//  AppDependencies.swift
//  andpad-camera-andpad-camera
//
//  Created by msano on 2020/11/11.
//

public struct AppDependencies {
    public static let shared = AppDependencies()
}

// MARK: - 黒板機能改修（for 建装工業）スコープは以下に記載していく
extension AppDependencies {
    // 新しく用意する新黒板用の編集画面
    public func modernEditBlackboardViewController(_ arguments: ModernEditBlackboardViewArguments) -> ModernEditBlackboardViewController {
        let apiManager = apiManager(
            isOfflineMode: arguments.isOfflineMode,
            userID: arguments.snapshotData.userID
        )
        return .init(
            with: .init(
                viewModel: .init(
                    networkService: ModernBlackboardNetworkService(appBaseRequestData: arguments.appBaseRequestData, apiManager: apiManager),
                    orderID: arguments.orderID,
                    snapshotData: arguments.snapshotData,
                    advancedOptions: arguments.advancedOptions,
                    modernBlackboardMaterial: arguments.modernblackboardMaterial,
                    blackboardViewAppearance: arguments.blackboardViewAppearance,
                    memoStyleArguments: arguments.memoStyleArguments,
                    editableScope: arguments.editableScope,
                    shouldResetBlackboardEditLoggingHandler: arguments.shouldResetBlackboardEditLoggingHandler,
                    isOfflineMode: arguments.isOfflineMode
                )
            )
        )
    }
    
    func modernBlackboardListViewController(_ arguments: BlackboardListViewArguments) -> ModernBlackboardListViewController {
        let apiManager = apiManager(
            isOfflineMode: arguments.isOfflineMode,
            userID: arguments.snapshotData.userID
        )
        return .init(
            with: .init(
                viewModel: .init(
                    networkService: ModernBlackboardNetworkService(appBaseRequestData: arguments.appBaseRequestData, apiManager: apiManager),
                    orderID: arguments.orderID,
                    snapshotData: arguments.snapshotData,
                    selectedBlackboard: arguments.selectedBlackboard,
                    advancedOptions: arguments.advancedOptions,
                    isOfflineMode: arguments.isOfflineMode
                )
            )
        )
    }
    
    func modernBlackboardLayoutListViewController() -> ModernBlackboardLayoutListViewController {
        // 画面表示中に表示内容の更新はないため、 Remote Config の値を画面表示前に一回だけ取得して差し込む
        // Note: Remote Config の値が取得できない場合のデフォルト値は他の画面と同じく false (表示統一前の表示) とする。
        let remoteConfig = AndpadCameraDependencies.shared.remoteConfigHandler
        let useBlackboardGeneratedWithSVG = remoteConfig?.fetchUseBlackboardGeneratedWithSVG() ?? false
        return .init(with: .init(viewModel: .init(useBlackboardGeneratedWithSVG: useBlackboardGeneratedWithSVG)))
    }
    
    public func createModernBlackboardViewController(_ arguments: CreateModernBlackboardViewArguments) -> CreateModernBlackboardViewController {
        return .init(
            with: .init(
                viewModel: .init(
                    networkService: ModernBlackboardNetworkService(appBaseRequestData: arguments.appBaseRequestData),
                    orderID: arguments.orderID,
                    snapshotData: arguments.snapshotData,
                    advancedOptions: arguments.advancedOptions,
                    blackboardViewAppearance: arguments.blackboardViewAppearance,
                    shouldResetBlackboardEditLoggingHandler: arguments.shouldResetBlackboardEditLoggingHandler
                )
            )
        )
    }
    
    public func modernBlackboardFilterConditionsViewController(_ arguments: ModernBlackboardFilterConditionsViewArguments) -> BlackboardFilterConditionsViewController {
        let apiManager = apiManager(
            isOfflineMode: arguments.isOfflineMode,
            userID: arguments.snapshotData.userID
        )
        return .init(
            with: .init(
                viewModel: .init(
                    networkService: ModernBlackboardNetworkService(appBaseRequestData: arguments.appBaseRequestData, apiManager: apiManager),
                    userID: arguments.snapshotData.userID,
                    orderID: arguments.orderID,
                    searchQuery: arguments.searchQuery,
                    advancedOptions: arguments.advancedOptions,
                    isOfflineMode: arguments.isOfflineMode
                ),
                willDismissHandler: arguments.willDismissHandler,
                willDismissByCancelButtonHandler: arguments.willDismissByCancelButtonHandler,
                willDismissByHistoryHandler: arguments.willDismissByHistoryHandler
            )
        )
    }
    
    func modernBlackboardFilterMultiSelectViewController(_ arguments: BlackboardFilterMultiSelectArguments) -> BlackboardFilterMultiSelectViewController {
        let apiManager = apiManager(
            isOfflineMode: arguments.isOfflineMode,
            userID: arguments.userID
        )
        return .init(
            with: .init(
                viewModel: .init(
                    networkService: ModernBlackboardNetworkService(appBaseRequestData: arguments.appBaseRequestData, apiManager: apiManager),
                    orderID: arguments.orderID,
                    blackboardItemBody: arguments.blackboardItemBody,
                    initialSelectedContents: arguments.initialSelectedContents,
                    isOfflineMode: arguments.isOfflineMode,
                    filteringByPhoto: arguments.filteringByPhoto,
                    searchQuery: arguments.searchQuery
                ),
                filterDoneHandler: arguments.filterDoneHandler
            )
        )
    }
    
    func modernBlackboardFilterSingleSelectViewController(_ arguments: BlackboardFilterSingleSingleArguments) -> BlackboardFilterSingleSelectViewController {
        return .init(
            with: .init(
                viewModel: .init(
                    blackboardFilterSingleSelectContents: BlackboardFilterSinglePhoto(),
                    currentContent: arguments.currentContent
                ),
                filterDoneHandler: arguments.filterDoneHandler
            )
        )
    }
    
    func modernBlackboardFilterConditionsHistoryViewController(_ arguments: BlackboardFilterConditionsHistoryViewArguments) -> BlackboardFilterConditionsHistoryViewController? {
        guard let viewModel = BlackboardFilterConditionsHistoryViewModel(
            orderID: arguments.orderID,
            advancedOptions: arguments.advancedOptions
        ) else { return nil }
        
        return .init(with: .init(viewModel: viewModel))
    }
}

// MARK: arguments (for view)
extension AppDependencies {
    public struct ModernEditBlackboardViewArguments {
        let orderID: Int
        let appBaseRequestData: AppBaseRequestData
        let snapshotData: SnapshotData
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
        let modernblackboardMaterial: ModernBlackboardMaterial
        let blackboardViewAppearance: ModernBlackboardAppearance
        let memoStyleArguments: ModernBlackboardMemoStyleArguments
        let editableScope: ModernEditBlackboardViewController.EditableScope
        let shouldResetBlackboardEditLoggingHandler: Bool
        let isOfflineMode: Bool
        
        public init(
            orderID: Int,
            appBaseRequestData: AppBaseRequestData,
            snapshotData: SnapshotData,
            advancedOptions: [ModernBlackboardConfiguration.AdvancedOption],
            modernblackboardMaterial: ModernBlackboardMaterial,
            blackboardViewAppearance: ModernBlackboardAppearance,
            memoStyleArguments: ModernBlackboardMemoStyleArguments,
            editableScope: ModernEditBlackboardViewController.EditableScope,
            shouldResetBlackboardEditLoggingHandler: Bool,
            isOfflineMode: Bool
        ) {
            self.orderID = orderID
            self.appBaseRequestData = appBaseRequestData
            self.snapshotData = snapshotData
            self.advancedOptions = advancedOptions
            self.modernblackboardMaterial = modernblackboardMaterial
            self.blackboardViewAppearance = blackboardViewAppearance
            self.memoStyleArguments = memoStyleArguments
            self.editableScope = editableScope
            self.shouldResetBlackboardEditLoggingHandler = shouldResetBlackboardEditLoggingHandler
            self.isOfflineMode = isOfflineMode
        }
    }
    
    struct BlackboardListViewArguments {
        let orderID: Int
        let appBaseRequestData: AppBaseRequestData
        let snapshotData: SnapshotData
        let selectedBlackboard: ModernBlackboardMaterial?
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
        let isOfflineMode: Bool
    }
    
    public struct CreateModernBlackboardViewArguments {
        let orderID: Int
        let appBaseRequestData: AppBaseRequestData
        let snapshotData: SnapshotData
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
        let blackboardViewAppearance: ModernBlackboardAppearance
        let shouldResetBlackboardEditLoggingHandler: Bool
        
        public init(
            orderID: Int,
            appBaseRequestData: AppBaseRequestData,
            snapshotData: SnapshotData,
            advancedOptions: [ModernBlackboardConfiguration.AdvancedOption],
            blackboardViewAppearance: ModernBlackboardAppearance,
            shouldResetBlackboardEditLoggingHandler: Bool
        ) {
            self.orderID = orderID
            self.appBaseRequestData = appBaseRequestData
            self.snapshotData = snapshotData
            self.advancedOptions = advancedOptions
            self.blackboardViewAppearance = blackboardViewAppearance
            self.shouldResetBlackboardEditLoggingHandler = shouldResetBlackboardEditLoggingHandler
        }
    }
    
    public struct ModernBlackboardFilterConditionsViewArguments {
        let orderID: Int
        let searchQuery: ModernBlackboardSearchQuery?
        let willDismissHandler: ((ModernBlackboardSearchQuery?) -> Void)
        let willDismissByCancelButtonHandler: (() -> Void)
        let willDismissByHistoryHandler: ((ModernBlackboardSearchQuery?) -> Void)
        let appBaseRequestData: AppBaseRequestData
        let snapshotData: SnapshotData
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
        let isOfflineMode: Bool
        
        public init(
            orderID: Int,
            searchQuery: ModernBlackboardSearchQuery?,
            willDismissHandler: @escaping ((ModernBlackboardSearchQuery?) -> Void),
            willDismissByCancelButtonHandler: @escaping (() -> Void),
            willDismissByHistoryHandler: @escaping ((ModernBlackboardSearchQuery?) -> Void),
            appBaseRequestData: AppBaseRequestData,
            snapshotData: SnapshotData,
            advancedOptions: [ModernBlackboardConfiguration.AdvancedOption],
            isOfflineMode: Bool
        ) {
            self.orderID = orderID
            self.searchQuery = searchQuery
            self.willDismissHandler = willDismissHandler
            self.willDismissByCancelButtonHandler = willDismissByCancelButtonHandler
            self.willDismissByHistoryHandler = willDismissByHistoryHandler
            self.appBaseRequestData = appBaseRequestData
            self.snapshotData = snapshotData
            self.advancedOptions = advancedOptions
            self.isOfflineMode = isOfflineMode
        }
    }
    
    struct BlackboardFilterMultiSelectArguments {
        let userID: Int
        let orderID: Int
        let blackboardItemBody: String
        let initialSelectedContents: [String]
        let appBaseRequestData: AppBaseRequestData
        let filterDoneHandler: ((String, [String]) -> Void)
        let isOfflineMode: Bool
        let filteringByPhoto: FilteringByPhotoType
        let searchQuery: ModernBlackboardSearchQuery?
    }
    
    struct BlackboardFilterSingleSingleArguments {
        let currentContent: String?
        let filterDoneHandler: ((String?) -> Void)
    }
    
    struct BlackboardFilterConditionsHistoryViewArguments {
        let orderID: Int
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
    }
}

private extension AppDependencies {
    func apiManager(isOfflineMode: Bool, userID: Int) -> ApiManager {
        if isOfflineMode {
            return ApiManager(client: OfflineStorageClient(userID: userID))
        } else {
            return ApiManager(client: AlamofireClient())
        }
    }
}

//
//  TakeCameraViewModel.swift
//  andpad-camera
//
//  Created by msano on 2022/06/09.
//

import AndpadCore
import RxCocoa
import RxSwift

/*
 TakeCameraViewModel = カメラ画面用のViewModel
 
 カメラ画面にはViewModelが無い（「BlackboardViewModel」というものはあるが、実質モデルパラメータのマッピングしか行っていないため、無い）状態が続いていたが、
 開発を進めていく中で取り回しがしづらい局面が往々にして発生したため、こちらに用意した
 
 - いきなり全機能を移す想定ではなく、追加機能から足していこうと考えている
 - また、当面は新黒板のみを対象としたVMとする
 
 [イニシャライズ方法について]
 カメラの各画面（特に新黒板の画面）はInstantiateによるDependancyを利用したイニシャライズ方法をとっていて、VMもその方法にのっとり生成されている、
 ただ、カメラ画面については、各利用側（施工や検査など）でイニシャライズを行なっている都合上、当面はドラスティックに変更しないようにしたい
 そのため、他画面とは異なるアプローチになる想定
 
 */

final class TakeCameraViewModel {
    // MARK: - define Inputs, Outputs
    enum Input {
        case update(ModernBlackboardAppearance)
        case didTapBlackboardImageButtonInBlackboardListView(ModernBlackboardMaterial)
        case didTapEditButtonInBlackboardListView(ModernBlackboardMaterial)
        case didTapTakePhotoButtonInBlackboardListView(ModernBlackboardMaterial)
        case updateBlackboardSettings(
            canEditBlackboardStyle: Bool,
            blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType,
            preferredPhotoFormat: ModernBlackboardCommonSetting.PhotoFormat
        )
    }

    enum Output {
        case presentEditViewController(AppDependencies.ModernEditBlackboardViewArguments)
        case returnToTakeCameraViewController(SelectionBlackboardListResult)
        case showErrorMessage
        case showLoadingView
        case hideLoadingView
        case resizeEnabled(enabled: Bool)
    }

    /// 選択用黒板一覧から撮影画面に戻るときに返すデータ
    struct SelectionBlackboardListResult {
        let blackboardMaterial: ModernBlackboardMaterial
        let blackboardAppearance: ModernBlackboardAppearance
        /// 黒板のスタイル変更可否
        let canEditBlackboardStyle: Bool
        /// APIから取得した黒板のサイズタイプ
        let blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType
        /// APIから取得した撮影画像形式
        let preferredPhotoFormat: ModernBlackboardCommonSetting.PhotoFormat
    }

    private struct StaticState {
        let orderID: Int
        let snapshotData: SnapshotData
        let appBaseRequestData: AppBaseRequestData
        let advancedOptions: [ModernBlackboardConfiguration.AdvancedOption]
    }
    
    let inputPort: PublishRelay<Input> = .init()
    let outputPort: ControlEvent<Output>

    private let networkService: ModernBlackboardNetworkServiceProtocol
    private let storage: (any ModernBlackboardCameraStorageProtocol)?
    private let staticState: StaticState
    private let disposeBag = DisposeBag()
    private let outputRelay: PublishRelay<Output>
    
    private let recieveModernBlackboardMaterialRelay = BehaviorRelay<ModernBlackboardMaterial?>(value: nil)
    /// 黒板のスタイル変更可否
    private let canEditBlackboardStyleRelay = BehaviorRelay<Bool>(value: false)
    /// 黒板のスタイル変更可否（読み取り専用）
    var canEditBlackboardStyle: Bool {
        return canEditBlackboardStyleRelay.value
    }

    /// APIから取得した黒板のサイズタイプ
    private let blackboardSizeTypeOnServerRelay = BehaviorRelay<ModernBlackboardAppearance.ModernBlackboardSizeType>(value: .free)
    /// APIから取得した黒板のサイズタイプ（読み取り専用）
    var blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType {
        return blackboardSizeTypeOnServerRelay.value
    }

    /// APIから取得した撮影画像形式
    let photoFormat = BehaviorRelay<ModernBlackboardCommonSetting.PhotoFormat>(value: .jpeg)

    private var appearance: ModernBlackboardAppearance
    private var tappedButtonType: ModernBlackboardListViewController.TappedButtonType?

    private(set) var remoteConfig: (any AndpadCameraDependenciesRemoteConfigProtocol)?

    init(
        networkService: ModernBlackboardNetworkServiceProtocol,
        storage: (any ModernBlackboardCameraStorageProtocol)?,
        orderID: Int,
        appearance: ModernBlackboardAppearance,
        snapshotData: SnapshotData,
        appBaseRequestData: AppBaseRequestData,
        advancedOptions: [ModernBlackboardConfiguration.AdvancedOption],
        isOfflineMode: Bool,
        canEditBlackboardStyle: Bool,
        blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType,
        photoFormat: ModernBlackboardCommonSetting.PhotoFormat,
        remoteConfig: (any AndpadCameraDependenciesRemoteConfigProtocol)? = AndpadCameraDependencies.shared.remoteConfigHandler
    ) {
        // MARK: - configure Outputs
        let relay = PublishRelay<Output>()
        self.outputPort = .init(events: relay)
        self.outputRelay = relay
        self.networkService = networkService
        self.storage = storage

        self.appearance = appearance
        
        self.staticState = .init(
            orderID: orderID,
            snapshotData: snapshotData,
            appBaseRequestData: appBaseRequestData,
            advancedOptions: advancedOptions
        )
        self.canEditBlackboardStyleRelay.accept(canEditBlackboardStyle)
        self.blackboardSizeTypeOnServerRelay.accept(blackboardSizeTypeOnServer)
        self.photoFormat.accept(photoFormat)
        self.remoteConfig = remoteConfig

        addBindings(isOfflineMode: isOfflineMode)
    }

    private func addBindings(isOfflineMode: Bool) {
        inputPort
            .bind(onNext: { [weak self] event in
                switch event {
                case .update(let appearance):
                    self?.updateEvent(appearance: appearance)
                case .didTapBlackboardImageButtonInBlackboardListView(let modernBlackboardMaterial):
                    self?.didTapBlackboardImageButtonEventInBlackboardListView(modernBlackboardMaterial: modernBlackboardMaterial)
                case .didTapEditButtonInBlackboardListView(let modernBlackboardMaterial):
                    self?.didTapEditButtonEventInBlackboardListView(modernBlackboardMaterial: modernBlackboardMaterial)
                case .didTapTakePhotoButtonInBlackboardListView(let modernBlackboardMaterial):
                    self?.didTapTakePhotoButtonEventInBlackboardListView(modernBlackboardMaterial: modernBlackboardMaterial)
                case .updateBlackboardSettings(canEditBlackboardStyle: let canEditBlackboardStyle, blackboardSizeTypeOnServer: let blackboardSizeTypeOnServer, let preferredPhotoFormat):
                    self?.canEditBlackboardStyleRelay.accept(canEditBlackboardStyle)
                    self?.blackboardSizeTypeOnServerRelay.accept(blackboardSizeTypeOnServer)
                }
            })
            .disposed(by: disposeBag)
        
        Observable
            .zip(
                networkService.getBlackboardCommonSettingObservable,
                recieveModernBlackboardMaterialRelay
                    .compactMap { $0 }
                    .asObservable()
            )
            .compactMap { [weak self] result, modernBlackboardMaterial -> Output? in
                guard let self,
                      let object = result.data.object else { return nil }

                canEditBlackboardStyleRelay.accept(object.canEditBlackboardStyle)
                blackboardSizeTypeOnServerRelay.accept(.init(sizeRate: object.blackboardDefaultSizeRate))

                let snapshotData = SnapshotData(
                    userID: staticState.snapshotData.userID,
                    orderName: staticState.snapshotData.orderName,
                    clientName: object.selectedConstructionPlayerName,
                    startDate: staticState.snapshotData.startDate
                )
                
                let theme = object.defaultTheme
                let memoStyleArguments = object.memoStyleArguments ?? .defaultSetting(with: theme)
                let blackboardTransparencyType = object.blackboardTransparencyType
                
                let blackboardViewAppearance = appearance
                    .updating(by: theme)
                    .updating(by: memoStyleArguments)
                    .updating(by: object.dateFormatType)
                    .updating(by: blackboardTransparencyType)
                    .updating(shouldBeReflectedNewLine: object.shouldBeReflectedNewLine)
                
                let updatedBlackboardMaterial = modernBlackboardMaterial
                    .updating(by: object.defaultTheme) // 黒板色の更新
                    .updating(by: snapshotData, shouldForceUpdateConstructionName: true) // 施工者名の更新
                    // 工事名のタイトル部分のテキストを更新
                    .updating(constructionNameTitle: object.constructionNameTitle)
                    .updating(constructionNameBody: object.constructionName)
                
                recieveModernBlackboardMaterialRelay.accept(nil)
                
                switch tappedButtonType {
                case .edit:
                    return .presentEditViewController(
                        .init(
                            orderID: staticState.orderID,
                            appBaseRequestData: staticState.appBaseRequestData,
                            snapshotData: snapshotData,
                            advancedOptions: staticState.advancedOptions,
                            modernblackboardMaterial: updatedBlackboardMaterial,
                            blackboardViewAppearance: blackboardViewAppearance,
                            memoStyleArguments: blackboardViewAppearance.memoStyleArguments,
                            editableScope: .all,
                            shouldResetBlackboardEditLoggingHandler: false,
                            isOfflineMode: isOfflineMode
                        )
                    )
                case .blackboardImage, .takePhoto:
                    return .returnToTakeCameraViewController(
                        .init(
                            blackboardMaterial: updatedBlackboardMaterial,
                            blackboardAppearance: blackboardViewAppearance,
                            canEditBlackboardStyle: canEditBlackboardStyleRelay.value,
                            blackboardSizeTypeOnServer: blackboardSizeTypeOnServerRelay.value,
                            preferredPhotoFormat: photoFormat.value
                        )
                    )
                case .none:
                    return nil
                }
            }
            .bind(to: outputRelay)
            .disposed(by: disposeBag)
        
        // receive error
        networkService.catchErrorDriver
            .drive(onNext: { [weak self] errorInformation in
                guard let self else { return }

                let output: Output?
                if errorInformation.requestType == ApiRouter.BlackboardCommonSettingRequest.self {
                    // NOTE: 特にエラーメッセージは出さず、無加工の黒板データを元に次画面へ遷移させていく
                    guard let modernBlackboardMaterial = recieveModernBlackboardMaterialRelay.value else { return }

                    switch tappedButtonType {
                    case .edit:
                        output = .presentEditViewController(
                            .init(
                                orderID: staticState.orderID,
                                appBaseRequestData: staticState.appBaseRequestData,
                                snapshotData: staticState.snapshotData,
                                advancedOptions: staticState.advancedOptions,
                                modernblackboardMaterial: modernBlackboardMaterial,
                                blackboardViewAppearance: appearance,
                                memoStyleArguments: appearance.memoStyleArguments,
                                editableScope: .all,
                                shouldResetBlackboardEditLoggingHandler: false,
                                isOfflineMode: isOfflineMode
                            )
                        )
                        recieveModernBlackboardMaterialRelay.accept(nil)
                    case .blackboardImage, .takePhoto:
                        output = .returnToTakeCameraViewController(
                            .init(
                                blackboardMaterial: modernBlackboardMaterial,
                                blackboardAppearance: appearance,
                                canEditBlackboardStyle: canEditBlackboardStyleRelay.value,
                                blackboardSizeTypeOnServer: blackboardSizeTypeOnServerRelay.value,
                                preferredPhotoFormat: photoFormat.value
                            )
                        )
                        recieveModernBlackboardMaterialRelay.accept(nil)
                    case .none:
                        output = nil
                    }
                } else {
                    output = .showErrorMessage
                }

                guard let output else { return }
                outputRelay.accept(output)
            })
            .disposed(by: disposeBag)

        // receive sidekicks
        networkService.showLoadingDriver
            .drive(onNext: { [weak self] _ in self?.outputRelay.accept(.showLoadingView) })
            .disposed(by: disposeBag)

        networkService.hideLoadingDriver
            .drive(onNext: { [weak self] _ in self?.outputRelay.accept(.hideLoadingView) })
            .disposed(by: disposeBag)

        Observable
            .combineLatest(canEditBlackboardStyleRelay, blackboardSizeTypeOnServerRelay) { canEdit, sizeType in
                // 黒板スタイルが変更可能、または管理者の設定した黒板サイズが「指定なし」の場合、サイズ変更が可能
                .resizeEnabled(enabled: canEdit || sizeType == .free)
            }
            .bind(to: outputRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - private (event)
extension TakeCameraViewModel {
    private func updateEvent(appearance: ModernBlackboardAppearance) {
        self.appearance = appearance
    }
    
    private func didTapBlackboardImageButtonEventInBlackboardListView(modernBlackboardMaterial: ModernBlackboardMaterial) {
        guard ModernBlackboardContentView.Pattern(by: modernBlackboardMaterial.layoutTypeID) != nil else {
            // カメラ画面で未定義黒板が表示されるのは想定外
            // （選択用黒板一覧からはボタン非活性で遷移できず、写真アップロードからはアラートを出して遷移できない仕様）
            AndpadCameraConfig.logger.nonFatalError(
                domain: "Unexpected",
                message: "カメラ画面に未定義黒板のデータが渡されたため処理終了（想定外エラー）"
            )
            return
        }
        
        tappedButtonType = .blackboardImage
        recieveModernBlackboardMaterialRelay.accept(modernBlackboardMaterial)
        getBlackboardCommonSetting()
    }
    
    private func didTapEditButtonEventInBlackboardListView(modernBlackboardMaterial: ModernBlackboardMaterial) {
        tappedButtonType = .edit
        recieveModernBlackboardMaterialRelay.accept(modernBlackboardMaterial)
        getBlackboardCommonSetting()
    }
    
    private func didTapTakePhotoButtonEventInBlackboardListView(modernBlackboardMaterial: ModernBlackboardMaterial) {
        tappedButtonType = .takePhoto
        recieveModernBlackboardMaterialRelay.accept(modernBlackboardMaterial)
        getBlackboardCommonSetting()
    }
}

// MARK: - private (fetch)
extension TakeCameraViewModel {
    private func getBlackboardCommonSetting() {
        networkService.getBlackboardCommonSetting(orderID: staticState.orderID)
    }
}

// MARK: - 黒板サイズ変更関連

extension TakeCameraViewModel {
    /// 黒板のサイズを強制的に更新する必要があれば、APIから取得した黒板サイズを返す
    ///
    /// ユーザーが黒板のサイズを変更する権限がない場合、
    /// システム側で黒板サイズを強制的に変更する必要がある
    ///
    /// - Returns: 黒板サイズ変更を行うためのサイズタイプ
    func getSizeTypeForForcedUpdate() -> ModernBlackboardAppearance.ModernBlackboardSizeType? {
        guard !isResizeEnabled() else {
            // 更新する必要がない
            return nil
        }
        return blackboardSizeTypeOnServerRelay.value
    }

    /// 黒板のサイズ変更が可能かどうか
    ///
    /// - Note: ユーザーによる黒板のサイズ変更が可能な条件は次の通り。黒板スタイルが変更可能、または管理者が設定した黒板サイズが「指定なし」。
    /// - Returns: true: 変更可能、false: 変更不可
    func isResizeEnabled() -> Bool {
        canEditBlackboardStyleRelay.value || blackboardSizeTypeOnServerRelay.value == .free
    }

    /// 新黒板付き撮影画面の黒板設定未読通知バッジを表示するかどうかを判定する
    /// - Parameter currentBlackboardSizeType: 現在ユーザーが選択している黒板サイズの種類
    /// - Returns: `true` : バッジ表示、 `false` : バッジ非表示
    ///
    /// - フローチャート:
    ///     - https://88-oct.atlassian.net/wiki/spaces/OCT/pages/3073933328/v5.71.0
    ///     - ＞[撮影画面の黒板設定に表示する赤マルの表示制御]＞[フローチャート]
    func shouldShowBadgeForModernBlackboardSettings(currentBlackboardSizeType: ModernBlackboardAppearance.ModernBlackboardSizeType) -> Bool {
        // 黒板のスタイル変更可否フラグの判別
        guard canEditBlackboardStyleRelay.value else {
            // 黒板のスタイルを変更可能にされた場合、バッジが復活するようにしたいので、
            // ストレージの黒板設定既読フラグをfalseに初期化する
            storage?.setBlackboardSettingsReadFlag(
                for: staticState.orderID,
                isRead: false
            )
            return false
        }

        // 黒板設定既読フラグの判別
        if let isRead = storage?.getBlackboardSettingsReadFlag(for: staticState.orderID), isRead {
            return false
        }

        // 黒板サイズレートの判別
        if blackboardSizeTypeOnServerRelay.value == .free {
            return false
        }

        // ユーザーの選択している黒板サイズの種類との比較
        if currentBlackboardSizeType == blackboardSizeTypeOnServerRelay.value {
            return false
        }
        return true
    }

    /// 新黒板付き撮影画面のストレージで、表示している案件の黒板設定既読フラグの値を既読に設定する
    func setBlackboardSettingsReadFlagAsTrue() {
        storage?.setBlackboardSettingsReadFlag(
            for: staticState.orderID,
            isRead: true
        )
    }
}

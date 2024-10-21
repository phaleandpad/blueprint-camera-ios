//
//  ModernBlackboardConfiguration.swift
//  andpad-camera
//
//  Created by msano on 2021/01/14.
//

public enum ModernBlackboardConfiguration {
    /// 黒板の短辺の長さの下限値
    static let minimumShortEdgeLength: CGFloat = 85.0
    /// 黒板の長辺の長さの下限値
    static let minimumLongEdgeLength: CGFloat = 106.0

    case enable(ConfigureArguments)
    case disable
    
    // MARK: arguments
    public struct ConfigureArguments {
        let orderID: Int
        private(set) var defaultModernBlackboardMaterial: ModernBlackboardMaterial
        let snapshotData: SnapshotData
        let appearance: ModernBlackboardAppearance
        private(set) var initialLocationData: InitialLocationData?
        let isHiddenBlackboardSwitchButton: Bool
        
        /// 詳細オプション。黒板関連の全てのViewおよび機能を使いたい場合、全ケースを配列に追加してください
        let advancedOptions: [AdvancedOption]
        /// 黒板のスタイル変更可否
        private(set) var canEditBlackboardStyle: Bool
        /// APIから取得した黒板のサイズタイプ
        private(set) var blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType
        /// APIから取得した撮影画像形式
        private(set) var preferredPhotoFormat: ModernBlackboardCommonSetting.PhotoFormat

        public init(
            orderID: Int,
            defaultModernBlackboardMaterial: ModernBlackboardMaterial,
            snapshotData: SnapshotData,
            appearance: ModernBlackboardAppearance,
            initialLocationData: InitialLocationData?,
            isHiddenBlackboardSwitchButton: Bool = false,
            advancedOptions: [AdvancedOption],
            canEditBlackboardStyle: Bool,
            blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType,
            preferredPhotoFormat: ModernBlackboardCommonSetting.PhotoFormat
        ) {
            self.orderID = orderID
            self.defaultModernBlackboardMaterial = defaultModernBlackboardMaterial
            self.snapshotData = snapshotData
            self.appearance = appearance
            self.initialLocationData = initialLocationData
            self.isHiddenBlackboardSwitchButton = isHiddenBlackboardSwitchButton
            self.advancedOptions = advancedOptions
            self.canEditBlackboardStyle = canEditBlackboardStyle
            self.blackboardSizeTypeOnServer = blackboardSizeTypeOnServer
            self.preferredPhotoFormat = preferredPhotoFormat
        }

        public func updating(with initialLocationData: InitialLocationData) -> Self {
            with {
                $0.initialLocationData = initialLocationData
            }
        }

        public func updating(with modernBlackboardMaterial: ModernBlackboardMaterial) -> Self {
            with {
                $0.defaultModernBlackboardMaterial = modernBlackboardMaterial
            }
        }

        public func updating(withCanEditBlackboardStyle canEditBlackboardStyle: Bool) -> Self {
            with {
                $0.canEditBlackboardStyle = canEditBlackboardStyle
            }
        }

        public func updating(withBlackboardSizeTypeOnServer blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType) -> Self {
            with {
                $0.blackboardSizeTypeOnServer = blackboardSizeTypeOnServer
            }
        }

        public func updating(withPreferredPhotoFormat preferredPhotoFormat: ModernBlackboardCommonSetting.PhotoFormat) -> Self {
            with {
                $0.preferredPhotoFormat = preferredPhotoFormat
            }
        }
    }

    // MARK: InitialLocationData
    public struct InitialLocationData: Codable, Equatable {
        public let centerPosition: CGPoint
        public let size: CGSize
        public let isLockedRotation: Bool

        /// （端末ではなく）黒板の傾きであるので注意
        public let orientation: UIDeviceOrientation?
        /// 黒板のサイズタイプ
        ///
        /// ユーザーの操作によって黒板設定モーダルから黒板のサイズタイプが指定されない限り、「指定なし」から変更されない。
        public let sizeType: ModernBlackboardAppearance.ModernBlackboardSizeType

        var frame: CGRect? {
            // NOTE: centerPositionを通常のposition（ = オブジェクトの左上の座標）に変換する
            let calcX = centerPosition.x - size.width / 2
            let calcY = centerPosition.y - size.height / 2
            let normalPosition = CGPoint(
                x: max(0, calcX),
                y: max(0, calcY)
            )

            return .init(
                origin: normalPosition,
                size: size
            )
        }

        public init(
            centerPosition: CGPoint,
            size: CGSize,
            isLockedRotation: Bool,
            orientation: UIDeviceOrientation?,
            sizeType: ModernBlackboardAppearance.ModernBlackboardSizeType
        ) {
            self.centerPosition = centerPosition
            self.size = size
            self.isLockedRotation = isLockedRotation
            self.orientation = orientation
            self.sizeType = sizeType
        }

        init(targetView: BlackboardBaseView, isLockedRotation: Bool, sizeType: ModernBlackboardAppearance.ModernBlackboardSizeType) {
            centerPosition = targetView.center
            size = targetView.bounds.size
            self.isLockedRotation = isLockedRotation
            orientation = targetView.orientation
            self.sizeType = sizeType
        }

        // MARK: - debug
        public func prettyDebug(with sceneDescription: String? = nil) {
            #if DEBUG
            print("\nInitialLocationData -----------------------------------")
            if let sceneDescription = sceneDescription {
                print("📖 scene [\(sceneDescription)]\n")
            }

            print("centerPosition: ", centerPosition.debugDescription)
            print("size: ", size.debugDescription)
            print("isLockedRotation: ", isLockedRotation)
            print("orientation: ", orientation.debugDescription)
            print("\n")

            print(" ------------------------------------------------------\n")
            #endif
        }

        // MARK: - Codable
        enum CodingKeys: String, CodingKey {
            case centerPosition
            case size
            case isLockedRotation
            case orientation
            case sizeType
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            centerPosition = try values.decode(CGPoint.self, forKey: .centerPosition)
            size = try values.decode(CGSize.self, forKey: .size)
            isLockedRotation = try values.decode(Bool.self, forKey: .isLockedRotation)
            // v5.70.0以前のバージョンではsizeTypeが存在しないため、Optionalでtryする
            if let sizeTypeRawValue = try? values.decode(Int.self, forKey: .sizeType) {
                sizeType = .init(rawValue: sizeTypeRawValue) ?? .free
            } else {
                // UserDefaultsのmodernBlackboardLocationData（端末単位）をデコードする場合はこの分岐に入る
                sizeType = .free
            }
            guard let orientationInt = try values.decode(Int?.self, forKey: .orientation) else {
                orientation = nil
                return
            }
            orientation = UIDeviceOrientation(rawValue: orientationInt)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(centerPosition, forKey: .centerPosition)
            try container.encode(size, forKey: .size)
            try container.encode(isLockedRotation, forKey: .isLockedRotation)
            let orientationInt = self.orientation?.rawValue
            try container.encode(orientationInt, forKey: .orientation)
            let sizeTypeRawValue = sizeType.rawValue
            try container.encode(sizeTypeRawValue, forKey: .sizeType)
        }
    }
    
    public var modernBlackboardLayoutTypeID: Int? {
        switch self {
        case .enable(let configureArguments):
            return configureArguments.defaultModernBlackboardMaterial.layoutTypeID
        case .disable:
            return nil
        }
    }
    
    var isModernBlackboard: Bool {
        switch self {
        case .enable:
            return true
        case .disable:
            return false
        }
    }
    
    var isOldBlackboard: Bool {
        !isModernBlackboard
    }

    var blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType? {
        switch self {
        case .enable(let configureArguments):
            return configureArguments.blackboardSizeTypeOnServer
        case .disable:
            return nil
        }
    }

    var canEditBlackboardStyle: Bool {
        switch self {
        case .enable(let configureArguments):
            return configureArguments.canEditBlackboardStyle
        case .disable:
            return false
        }
    }

    var preferredPhotoFormat: ModernBlackboardCommonSetting.PhotoFormat {
        switch self {
        case .enable(let configureArguments):
            return configureArguments.preferredPhotoFormat
        case .disable:
            // 旧黒板は jpeg 固定
            return .jpeg
        }
    }
}

// MARK: - Advanced Option
public extension ModernBlackboardConfiguration {
    typealias TappedMiniatureMapCellHandler = ((UIImage, UIViewController) -> Void)?
    
    enum AdvancedOption {
        /// 「黒板絞り込み履歴画面」を使用するために必要なオプション
        case useHistoryView(ModernBlackboardConfiguration.UseHistoryViewConfigureArguments)
        case useMiniatureMap(TappedMiniatureMapCellHandler)
        
        /// 豆図セルタップ時のハンドラー
        var tappedMiniatureMapCellHandler: TappedMiniatureMapCellHandler {
            guard case .useMiniatureMap(let handler) = self else { return nil }
            return handler
        }
    }
    
    // MARK: - UseHistoryViewConfigureArguments
    struct UseHistoryViewConfigureArguments {
        public let blackboardHistoryHandler: BlackboardHistoryHandlerProtocol
        
        public init(blackboardHistoryHandler: BlackboardHistoryHandlerProtocol) {
            self.blackboardHistoryHandler = blackboardHistoryHandler
        }
    }
}

private extension ModernBlackboardConfiguration.ConfigureArguments {
    /// この `ModernBlackboardConfiguration.ConfigureArguments` のインスタンスを変更するための便利メソッドです。
    /// このメソッドは、インスタンスのプロパティを変更するクロージャを受け取り、
    /// 変更された新しいインスタンスを返します。
    ///
    /// - 使用方法:
    ///
    /// ```
    /// let configuration = ModernBlackboardConfiguration.ConfigureArguments(...).with {
    ///   $0.initialLocationData = initialLocationData
    ///   $0.defaultModernBlackboardMaterial = modernBlackboardMaterial
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - block: `ModernBlackboardConfiguration.ConfigureArguments` のプロパティを変更するためのクロージャ。
    ///     `inout Self` を受け取り、変更を適用します。
    /// - Returns: 変更された `ModernBlackboardConfiguration.ConfigureArguments` の新しいインスタンス。
    func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
}

// MARK: - 黒板のサイズチェック

public extension ModernBlackboardConfiguration.InitialLocationData {
    /// 黒板のサイズが適切であるかどうかを判断する
    ///
    /// この関数は黒板のサイズが、下限値を下回っていないかどうかをチェックする。
    /// - Returns: 黒板のサイズが要件を満たしていれば `true` 、そうでなければ `false` を返す
    func isBlackboardSizeValid() -> Bool {
        let shorterSide = min(size.width, size.height)
        let longerSide = max(size.width, size.height)

        return shorterSide >= ModernBlackboardConfiguration.minimumShortEdgeLength
            && longerSide >= ModernBlackboardConfiguration.minimumLongEdgeLength
    }

    /// 黒板のサイズが不適切であることを示す非致命的エラーを Crashlytics に記録する
    ///
    /// この関数は、黒板のサイズが下限値を下回っている場合に使用される。
    func recordBlackboardSizeNonFatalError() {
        let message = "黒板のサイズが下限値を下回っています。短辺の下限値: \(ModernBlackboardConfiguration.minimumShortEdgeLength), 長辺の下限値: \(ModernBlackboardConfiguration.minimumLongEdgeLength), 実際のサイズ: \(size)"
        AndpadCameraConfig.logger.nonFatalError(domain: "BlackboardSizeInvalidError", message: message)
    }
}

// MARK: - OrderModernBlackboardLocationData

/// 案件ごとの黒板位置情報
public struct OrderModernBlackboardLocationData: Codable {
    /// 案件ID
    public let orderID: Int
    /// 黒板位置情報
    public let locationData: ModernBlackboardConfiguration.InitialLocationData

    /// 初期化
    /// - Parameters:
    ///   - orderID: 案件ID
    ///   - locationData: 黒板位置情報
    public init(orderID: Int, locationData: ModernBlackboardConfiguration.InitialLocationData) {
        self.orderID = orderID
        self.locationData = locationData
    }
}

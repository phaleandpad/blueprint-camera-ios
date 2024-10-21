//
//  ModernBlackboardMaterial.swift
//  andpad-camera
//
//  Created by msano on 2020/12/21.
//

public protocol ModernBlackboardData {}
public protocol BlackboardItemProtocol {}

public struct ModernBlackboardMaterial: Codable, Equatable, Sendable, ModernBlackboardData {
    public let id: Int
    public let blackboardTemplateID: Int
    public let layoutTypeID: Int
    public let photoCount: Int
    public let blackboardTheme: ModernBlackboardAppearance.Theme
    public let items: [Item]
    public let blackboardTrees: [TreeItem]
    
    // 豆図用
    public let miniatureMap: MiniatureMap?
    
    public let createdUser: User?
    public let updatedUser: User?
    public let createdAt: Date?
    public let updatedAt: Date?

    /// 黒板の表示順。
    ///
    /// - Note: /base_app/api/v1/my/orders/{order_id}/blackboards での仕様変更により追加。
    /// requiredなパラメータだが、ModernBlackboardMaterialは他のAPIのレスポンスとしても使用していることから、
    /// 他のAPIの受け取りに支障をきたさないよう、Optional定義とした。
    public let position: Int?

    /// 新規作成や編集した黒板を送信したときに、既存の黒板と重複したか否か。デフォルトはfalse
    public let isDuplicated: Bool
    /// コピー元黒板のID
    ///
    /// コピー元黒板のIDを指定した場合、新規黒板はコピー元黒板直下に作成される
    public let originalBlackboardID: Int?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case blackboardTemplateID = "blackboard_template_id"
        case layoutTypeID = "layout_type_id"
        case photoCount = "photos_count"
        case blackboardTheme = "blackboard_theme_code"
        case items = "contents"
        case blackboardTrees = "blackboard_trees"
        case miniatureMap = "miniature_map"
        case createdUser = "create_user"
        case updatedUser = "update_user"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isDuplicated = "is_duplicated"
        case position
        case originalBlackboardID = "original_blackboard_id"
    }

    // MARK: - Item
    public struct Item: Codable, BlackboardItemProtocol, Equatable, Sendable {
        public let itemName: String
        public let body: String
        public let position: Int

        private enum CodingKeys: String, CodingKey {
            case itemName = "item_name"
            case body
            case position
        }
        
        /// 工事名のアイテムか否か
        ///
        /// 黒板項目1行目に表示する仕様
        var isConstructionNameItem: Bool {
            self.position == 1
        }

        public init(
            itemName: String,
            body: String,
            position: Int
        ) {
            self.itemName = itemName
            self.body = body
            self.position = position
        }

        func updating(body: String) -> Self {
            return Item(itemName: self.itemName, body: body, position: self.position)
        }
        
        /// 工事名のタイトル部分のアイテムのテキストを更新する
        /// - Parameter constructionNameTitle: 工事名のタイトル
        /// - Returns: Self
        func updating(constructionNameTitle: String) -> Self {
            guard isConstructionNameItem else {
                return self
            }
            return Item(itemName: constructionNameTitle, body: self.body, position: self.position)
        }

        func updating(constructionNameBody: String) -> Self {
            guard isConstructionNameItem else {
                return self
            }
            return Item(itemName: self.itemName, body: constructionNameBody, position: self.position)
        }
    }

    // MARK: - TreeItem
    public struct TreeItem: Codable, Equatable, Sendable {
        public let id: Int
        public let body: String

        private enum CodingKeys: String, CodingKey {
            case id
            case body = "name" // NOTE: 名称はnameだが、実態は項目の値なのでbody
        }
        
        public init(id: Int, body: String) {
            self.id = id
            self.body = body
        }
    }
    
    // MARK: - User
    public struct User: Codable, Equatable, Sendable {
        public let id: Int
        public let name: String
        public let client: Client?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case client
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            id = try values.decode(Int.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            client = try? values.decode(Client.self, forKey: .client)
        }
        
        public struct Client: Codable, Equatable, Sendable {
            public let id: Int
            public let name: String
        }
    }
    
    public struct MiniatureMap: Codable, Equatable, Sendable {
        public let id: Int
        public let imageURL: URL?
        public let imageThumbnailURL: URL?

        private enum CodingKeys: String, CodingKey {
            case id
            case imageURL = "image_url"
            case imageThumbnailURL = "image_thumbnail_url"
        }
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            id = try values.decode(Int.self, forKey: .id)
            
            let imageURLString = try values.decode(String.self, forKey: .imageURL)
            if let imageURL = URL(string: imageURLString) {
                self.imageURL = imageURL
            } else {
                assertionFailure("豆図のURL文字列が不適当です")
                imageURL = nil
            }
            
            let imageThumbnailURLString = try values.decode(String.self, forKey: .imageThumbnailURL)
            if let imageThumbnailURL = URL(string: imageThumbnailURLString) {
                self.imageThumbnailURL = imageThumbnailURL
            } else {
                assertionFailure("豆図のサムネイルURL文字列が不適当です")
                imageThumbnailURL = nil
            }
        }
        
        public init(
            id: Int,
            imageURL: URL,
            imageThumbnailURL: URL
        ) {
            self.id = id
            self.imageURL = imageURL
            self.imageThumbnailURL = imageThumbnailURL
        }
    }

    // MARK: - init
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        blackboardTemplateID = try values.decode(Int.self, forKey: .blackboardTemplateID)
        layoutTypeID = try values.decode(Int.self, forKey: .layoutTypeID)
        photoCount = try values.decode(Int.self, forKey: .photoCount)
        blackboardTheme = .init(
            themeCode: try values.decode(Int.self, forKey: .blackboardTheme)
        )
        items = try values.decode([Item].self, forKey: .items)
            .sorted { $0.position < $1.position }
        blackboardTrees = try values.decode([TreeItem].self, forKey: .blackboardTrees)
        
        createdUser = try? values.decode(User.self, forKey: .createdUser)
        updatedUser = try? values.decode(User.self, forKey: .updatedUser)
        
        if let createdAtString = try? values.decode(String.self, forKey: .createdAt) {
            createdAt = createdAtString.asISOWithMillisecondDate()
        } else {
            createdAt = nil
        }
        if let updatedAtString = try? values.decode(String.self, forKey: .updatedAt) {
            updatedAt = updatedAtString.asISOWithMillisecondDate()
        } else {
            updatedAt = nil
        }
        
        if let isDuplicated = try? values.decode(Bool.self, forKey: .isDuplicated) {
            self.isDuplicated = isDuplicated
        } else {
            self.isDuplicated = false
        }

        miniatureMap = try? values.decode(MiniatureMap.self, forKey: .miniatureMap)

        if let position = try? values.decode(Int.self, forKey: .position) {
            self.position = position
        } else {
            position = nil
        }

        originalBlackboardID = try? values.decode(Int?.self, forKey: .originalBlackboardID)
    }

    public init(
        id: Int,
        blackboardTemplateID: Int,
        layoutTypeID: Int,
        photoCount: Int,
        blackboardTheme: ModernBlackboardAppearance.Theme,
        items: [Item],
        blackboardTrees: [TreeItem],
        miniatureMap: MiniatureMap?,
        originalBlackboardID: Int?
    ) {
        self.id = id
        self.blackboardTemplateID = blackboardTemplateID
        self.layoutTypeID = layoutTypeID
        self.photoCount = photoCount
        self.blackboardTheme = blackboardTheme
        self.items = items
        self.blackboardTrees = blackboardTrees
        
        self.createdUser = nil
        self.updatedUser = nil
        self.createdAt = nil
        self.updatedAt = nil
        self.isDuplicated = false
        self.miniatureMap = miniatureMap
        self.position = nil
        self.originalBlackboardID = originalBlackboardID
    }
    
    /// 案件内の黒板新規作成APIのリクエストパラメーター `item_name` に設定する定数
    private enum BlackboardCreationRequestItemName {
        static let memo = "備考"
        static let constructionDate = "施工日"
        static let constructionPlayer = "施工者"
    }

    /// 黒板レイアウトデータから生成
    public init(layout: ModernBlackboardLayout) {
        self.id = 0
        self.blackboardTemplateID = 0
        self.layoutTypeID = layout.layoutMaterial.id
        self.photoCount = 0
        self.blackboardTheme = layout.blackboardTheme
        
        guard let pattern = ModernBlackboardContentView.Pattern(by: layoutTypeID) else { fatalError() }
        
        self.items = layout.items
            .map {
                guard $0.itemName.isEmpty else {
                    return .init(itemName: $0.itemName, body: "", position: $0.position)
                }
                // NOTE: 特別な項目に対し、デフォルトの項目名を埋める
                // これらの項目名をローカライズすると、ユーザーが端末の言語を変えれば重複黒板でも登録が成功してしまうので、定数とする
                // （これがないと、黒板新規作成 / 編集POST時にバリデートエラーにひっかかる）
                let itemName = switch $0.position {
                case pattern.specifiedPosition(by: .memo):
                    BlackboardCreationRequestItemName.memo
                case pattern.specifiedPosition(by: .date):
                    BlackboardCreationRequestItemName.constructionDate
                case pattern.specifiedPosition(by: .constructionPlayer):
                    BlackboardCreationRequestItemName.constructionPlayer
                default:
                    // 上記以外の場合は元の空文字のまま
                    $0.itemName
                }
                return .init(itemName: itemName, body: "", position: $0.position)
            }
            .sorted { $0.position < $1.position }
        
        self.blackboardTrees = []

        self.miniatureMap = nil
        self.createdUser = nil
        self.updatedUser = nil
        self.createdAt = nil
        self.updatedAt = nil
        self.isDuplicated = false
        self.position = nil
        // 黒板レイアウトデータから生成する場合は、新規であり、コピー元黒板は存在しないので、nilを設定する
        originalBlackboardID = nil
    }

    public init(
        id: Int,
        blackboardTemplateID: Int,
        layoutTypeID: Int,
        photoCount: Int,
        blackboardTheme: ModernBlackboardAppearance.Theme,
        itemProtocols: [BlackboardItemProtocol],
        blackboardTrees: [TreeItem],
        miniatureMap: MiniatureMap?,
        snapshotData: SnapshotData? = nil,
        
        /// 強制的に施工者名を上書きするか否か
        shouldForceUpdateConstructionName: Bool = false,
        
        createdUser: User?,
        updatedUser: User?,
        createdAt: Date?,
        updatedAt: Date?,
        isDuplicated: Bool = false,
        position: Int? = nil,
        originalBlackboardID: Int?
    ) {
        /// （必要があれば）工事名をsnapshotDataの値に置換する
        func updateNewConstructionNameIfNeeded(
            items: [Item],
            pattern: ModernBlackboardContentView.Pattern,
            snapshotData: SnapshotData
        ) -> [Item] {
            var targetItems = items
            guard let constructionNamePosition = pattern.specifiedPosition(by: ModernBlackboardKeyItemName.constructionName) else { return targetItems }
            
            let constructionNameItem = targetItems
                .first { $0.position == constructionNamePosition }
                .map { $0.updating(body: snapshotData.orderName) }
            
            guard let newItem = constructionNameItem else { return targetItems }

            // 新しいアイテムと置換する
            targetItems = targetItems
                .filter { $0.position != constructionNamePosition }
            targetItems.append(newItem)
            return targetItems
        }
        
        /// （必要があれば）施工日をsnapshotDataの値に置換する
        func updateNewConstructionDateIfNeeded(
            items: [Item],
            pattern: ModernBlackboardContentView.Pattern,
            snapshotData: SnapshotData
        ) -> [Item] {
            var targetItems = items
            guard let constructionDatePosition = pattern.specifiedPosition(by: ModernBlackboardKeyItemName.date) else { return targetItems }

            let newConstructionDateItem = targetItems
                .first(where: { $0.position == constructionDatePosition })
                .map { $0.updating(body: snapshotData.startDate.asDateString()) }

            guard let newItem = newConstructionDateItem else { return targetItems }

            // 新しいアイテムと置換する
            targetItems = targetItems
                .filter { $0.position != constructionDatePosition }
            targetItems.append(newItem)
            return targetItems
        }

        /// （必要があれば）施工者をsnapshotDataの値に置換する
        func updateNewConstructionPlayerIfNeeded(
            items: [Item],
            pattern: ModernBlackboardContentView.Pattern,
            snapshotData: SnapshotData
        ) -> [Item] {
            var targetItems = items
            guard let constructionPlayerPosition = pattern.specifiedPosition(by: ModernBlackboardKeyItemName.constructionPlayer),
                  let constructionPlayerItem = targetItems
                     .first(where: { $0.position == constructionPlayerPosition }) else { return targetItems }

            // 施工者名を上書きすべきか判定（強制上書きフラグが無効の場合、元の値が空であれば上書きする）
            let shouldUpdateConstructionName = shouldForceUpdateConstructionName
                ? true
                : constructionPlayerItem.body.isEmpty
            guard shouldUpdateConstructionName else { return targetItems }

            // 新しいアイテムと置換する
            targetItems = targetItems
                .filter { $0.position != constructionPlayerPosition }
            targetItems.append(constructionPlayerItem.updating(body: snapshotData.clientName))
            return targetItems
        }
        
        self.id = id
        self.blackboardTemplateID = blackboardTemplateID
        self.layoutTypeID = layoutTypeID
        self.photoCount = photoCount
        self.blackboardTheme = blackboardTheme
        self.blackboardTrees = blackboardTrees
        self.miniatureMap = miniatureMap
        self.createdUser = createdUser
        self.updatedUser = updatedUser
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDuplicated = isDuplicated
        self.position = position
        self.originalBlackboardID = originalBlackboardID
        
        replaceNewItems: do {
            var newItems: [Item] = []

            if let items = itemProtocols as? [Item] {
                newItems = items
            }

            guard let snapshotData,
                  let pattern = ModernBlackboardContentView.Pattern(by: layoutTypeID) else {
                self.items = newItems.sorted { $0.position < $1.position }
                return
            }

            // 工事名の置換
            newItems = updateNewConstructionNameIfNeeded(
                items: newItems,
                pattern: pattern,
                snapshotData: snapshotData
            )
            // 施工日の置換
            newItems = updateNewConstructionDateIfNeeded(
                items: newItems,
                pattern: pattern,
                snapshotData: snapshotData
            )
            // 施工者の置換
            newItems = updateNewConstructionPlayerIfNeeded(
                items: newItems,
                pattern: pattern,
                snapshotData: snapshotData
            )

            //　NOTE: position順で並び替えた上でセットする
            self.items = newItems.sorted { $0.position < $1.position }
        }
    }
    
    /// 黒板の同等性チェックに必要な情報のみを含んだインスタンスを返します。
    ///
    /// - Warning: 一部ダミーの情報を含むため、同等性チェック以外の目的で使用しないでください。
    public static func forEquivalenceChecking(
        id: Int,
        layoutTypeID: Int,
        contents: [some ModernBlackBoardContent]
    ) -> Self {
        ModernBlackboardMaterial(
            id: id,
            blackboardTemplateID: 0,
            layoutTypeID: layoutTypeID,
            photoCount: 0,
            blackboardTheme: .black,
            itemProtocols: contents.map {
                Item(itemName: $0.itemName, body: $0.itemBody, position: $0.position)
            },
            blackboardTrees: [],
            miniatureMap: nil,
            createdUser: nil,
            updatedUser: nil,
            createdAt: nil,
            updatedAt: nil,
            originalBlackboardID: nil
        )
    }
}

extension ModernBlackboardMaterial {
    enum SearchKeyForItem {
        case position(Int)
    }
    
    /// 工事名のアイテム
    var constructionNameItem: Item? {
        items.first(where: { $0.isConstructionNameItem })
    }

    public func updating(by id: Int) -> ModernBlackboardMaterial {
        return .init(
            id: id,
            blackboardTemplateID: self.blackboardTemplateID,
            layoutTypeID: self.layoutTypeID,
            photoCount: self.photoCount,
            blackboardTheme: self.blackboardTheme,
            itemProtocols: self.items,
            blackboardTrees: self.blackboardTrees,
            miniatureMap: self.miniatureMap,
            createdUser: self.createdUser,
            updatedUser: self.updatedUser,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            isDuplicated: self.isDuplicated,
            position: self.position,
            originalBlackboardID: self.originalBlackboardID
        )
    }

    public func updating(by theme: ModernBlackboardAppearance.Theme) -> ModernBlackboardMaterial {
        return .init(
            id: self.id,
            blackboardTemplateID: self.blackboardTemplateID,
            layoutTypeID: self.layoutTypeID,
            photoCount: self.photoCount,
            blackboardTheme: theme,
            itemProtocols: self.items,
            blackboardTrees: self.blackboardTrees,
            miniatureMap: self.miniatureMap,
            createdUser: self.createdUser,
            updatedUser: self.updatedUser,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            isDuplicated: self.isDuplicated,
            position: self.position,
            originalBlackboardID: self.originalBlackboardID
        )
    }

    /// 対象モデルを更新し返却する
    /// - parameter snapshotData: 1つ目の引数。
    /// - parameter shouldForceUpdateConstructionName: trueの場合、施工者のvalueの有無に関わらず強制上書きする（falseの場合、施工者名が既に存在する場合上書きしない）
    /// - returns: 黒板データ
    public func updating(
        by snapshotData: SnapshotData,
        shouldForceUpdateConstructionName: Bool
    ) -> ModernBlackboardMaterial {
        return .init(
            id: self.id,
            blackboardTemplateID: self.blackboardTemplateID,
            layoutTypeID: self.layoutTypeID,
            photoCount: self.photoCount,
            blackboardTheme: self.blackboardTheme,
            itemProtocols: self.items,
            blackboardTrees: self.blackboardTrees,
            miniatureMap: self.miniatureMap,
            snapshotData: snapshotData,
            shouldForceUpdateConstructionName: shouldForceUpdateConstructionName,
            createdUser: self.createdUser,
            updatedUser: self.updatedUser,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            isDuplicated: self.isDuplicated,
            position: self.position,
            originalBlackboardID: self.originalBlackboardID
        )
    }

    /// 現在のインスタンスを基に、指定された新しい`items`を用いて新しいインスタンスを生成して返す
    ///
    /// - Parameter items: 新しい`items`の配列
    /// - Returns: `items`が更新された新しいインスタンス
    ///
    /// - Note: このメソッドは、他のプロパティは現在のインスタンスのものをそのまま用い、`items`だけを更新した新しいインスタンスを返す。
    public func updating(by items: [ModernBlackboardMaterial.Item]) -> ModernBlackboardMaterial {
        return .init(
            id: self.id,
            blackboardTemplateID: self.blackboardTemplateID,
            layoutTypeID: self.layoutTypeID,
            photoCount: self.photoCount,
            blackboardTheme: self.blackboardTheme,
            itemProtocols: items,
            blackboardTrees: self.blackboardTrees,
            miniatureMap: self.miniatureMap,
            createdUser: self.createdUser,
            updatedUser: self.updatedUser,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            isDuplicated: self.isDuplicated,
            position: self.position,
            originalBlackboardID: self.originalBlackboardID
        )
    }
    
    /// 写真枚数のみ更新する
    public func updating(photoCount: Int) -> ModernBlackboardMaterial {
        return .init(
            id: self.id,
            blackboardTemplateID: self.blackboardTemplateID,
            layoutTypeID: self.layoutTypeID,
            photoCount: photoCount,
            blackboardTheme: self.blackboardTheme,
            itemProtocols: self.items,
            blackboardTrees: self.blackboardTrees,
            miniatureMap: self.miniatureMap,
            createdUser: self.createdUser,
            updatedUser: self.updatedUser,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            isDuplicated: self.isDuplicated,
            position: self.position,
            originalBlackboardID: self.originalBlackboardID
        )
    }

    /// 工事名のタイトル部分のテキストを更新した新しいインスタンスを生成して返す
    ///
    /// - Parameter constructionNameTitle: 更新する工事名のタイトル部分のテキスト
    /// - Returns: 工事名のタイトル部分のテキストが更新された新しいインスタンス。対象項目が存在しない場合は、現在のインスタンスをそのまま返す。
    ///
    /// - Note: このメソッドは、他のプロパティは現在のインスタンスのものをそのまま用い、特定の`items`のプロパティだけを更新した新しいインスタンスを返す。
    public func updating(constructionNameTitle: String) -> Self {
        var updatedItems = items
        if let index = updatedItems.firstIndex(where: { $0.isConstructionNameItem }) {
            updatedItems[index] = items[index].updating(constructionNameTitle: constructionNameTitle)
        }
        return updating(by: updatedItems)
    }

    public func updating(constructionNameBody: String) -> Self {
        var updatedItems = items
        if let index = updatedItems.firstIndex(where: { $0.isConstructionNameItem }) {
            updatedItems[index] = items[index].updating(constructionNameBody: constructionNameBody)
        }
        return updating(by: updatedItems)
    }

    /// 重複フラグをリセット（「重複していない」状態にする）
    public func resetDuplicateFlag() -> ModernBlackboardMaterial {
        return .init(
            id: self.id,
            blackboardTemplateID: self.blackboardTemplateID,
            layoutTypeID: self.layoutTypeID,
            photoCount: self.photoCount,
            blackboardTheme: self.blackboardTheme,
            itemProtocols: self.items,
            blackboardTrees: self.blackboardTrees,
            miniatureMap: self.miniatureMap,
            createdUser: self.createdUser,
            updatedUser: self.updatedUser,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            isDuplicated: false, // NOTE: falseで「重複していない」状態とする
            position: self.position,
            originalBlackboardID: self.originalBlackboardID
        )
    }

    func item(key: SearchKeyForItem) -> Item? {
        switch key {
        case .position(let value):
            return items.first(where: { $0.position == value })
        }
    }

    // for node flow
    // NOTE: タップした黒板項目のノードリストを表示するためのparentIDを返却する
    func parentID(by selectedItemPosition: Int) -> Int? {
        /*
         【ユースケース】
         例えば、以下のような黒板があった場合に：

         - （工事名）
         - 工種
         - 工区
         - 備考
         - （施工日）
         - （施工者）

         「工区」セルをタップした場合、次画面の一覧では「工区」の一覧を出す必要がある
         -> そのためには、「工区」の親である「工種」のidをparentIDとして次画面に渡し、APIリクエストする必要がある
         */

        guard let targetItemIndex = items.firstIndex(where: { $0.position == selectedItemPosition - 1 }),
              targetItemIndex <= blackboardTrees.count else {
            assertionFailure()
            return nil
        }
        return blackboardTrees[targetItemIndex].id
    }
    
    public func toPostableBlackboardItemData() -> [PostableBlackboardItemData] {
        self.items.map {
            PostableBlackboardItemData(
                body: $0.body,
                itemName: $0.itemName,
                position: $0.position
            )
        }
    }
}

// MARK: - debug
extension ModernBlackboardMaterial {
    public func prettyDebug(with sceneDescription: String? = nil) {
        #if DEBUG
        print("\nModernBlackboardMaterial -----------------------------------")
        if let sceneDescription = sceneDescription {
            print("📖 scene [\(sceneDescription)]\n")
        }

        print("id: ", id)
        print("blackboardTemplateID: ", blackboardTemplateID)
        print("layoutTypeID: ", layoutTypeID)
        print("photoCount: ", photoCount)
        print("blackboardTheme: ", blackboardTheme)
        print("\n")

        items
            .enumerated()
            .forEach {
                print("items[\($0.offset)]  .............................................\n")
                print("  position: ", $0.element.position)
                print("  itemName: ", $0.element.itemName)
                print("  body: ", $0.element.body)
                print("\n")
            }

        print("\n = = = = = = = = = = = = = = = = = = = = = = \n")

        blackboardTrees
            .enumerated()
            .forEach {
                print("blackboardTrees[\($0.offset)]  .............................................\n")
                print("  id: ", $0.element.id)
                print("  name: ", $0.element.body)
                print("\n")
            }

        print("\n = = = = = = = = = = = = = = = = = = = = = = \n")
        
        print("createdUser: ", createdUser)
        print("createdAt: ", createdAt?.asDateString())
        print("updatedUser: ", updatedUser)
        print("updatedAt: ", updatedAt?.asDateString())

        print(" ------------------------------------------------------\n")
        #endif
    }
}

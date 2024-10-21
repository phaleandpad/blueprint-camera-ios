//
//  ModernBlackboardSearchQuery.swift
//  andpad-camera
//
//  Created by msano on 2021/04/20.
//

// NOTE: 黒板一覧の絞り込み検索用クエリ
public struct ModernBlackboardSearchQuery: Sendable {
    public let photoCondition: PhotoCondition
    public let conditionForBlackboardItems: [ConditionForBlackboardItem]
    public let freewords: String

    public struct ConditionForBlackboardItem: Codable, Equatable {
        public let targetItemName: String
        public let conditions: [String]

        private enum CodingKeys: String, CodingKey {
            case targetItemName = "blackboard_item_body"
            case conditions = "blackboard_content_body"
        }

        public init(
            targetItemName: String,
            conditions: [String]
        ) {
            self.targetItemName = targetItemName
            self.conditions = conditions
        }

        public var isEmpty: Bool {
            conditions.isEmpty
        }
    }

    public init(
        photoCondition: PhotoCondition = .all,
        conditionForBlackboardItems: [ConditionForBlackboardItem],
        freewords: String
    ) {
        self.photoCondition = photoCondition
        self.conditionForBlackboardItems = conditionForBlackboardItems
        self.freewords = freewords
    }
}

// MARK: - Codable
extension ModernBlackboardSearchQuery: Codable {
    private enum EncodeKeys: String, CodingKey {
        case photoCondition
        case conditionForBlackboardItems
        case freewords
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EncodeKeys.self)
        let photoConditionInt = try container.decode(Int.self, forKey: .photoCondition)
        photoCondition = PhotoCondition(rawValue: photoConditionInt) ?? .all
        conditionForBlackboardItems = try container.decode([ConditionForBlackboardItem].self, forKey: .conditionForBlackboardItems)
        freewords = try container.decode(String.self, forKey: .freewords)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodeKeys.self)
        try container.encode(photoCondition.rawValue, forKey: .photoCondition)
        try container.encode(conditionForBlackboardItems, forKey: .conditionForBlackboardItems)
        try container.encode(freewords, forKey: .freewords)
    }
}

// MARK: - PhotoCondition
public extension ModernBlackboardSearchQuery {
    enum PhotoCondition: Int, Equatable {
        case all = 0
        case hasPhoto
        case hasNoPhoto

        public var value: Bool? {
            switch self {
            case .all:
                return nil
            case .hasPhoto:
                return true
            case .hasNoPhoto:
                return false
            }
        }
    }
}

// MARK: - for json
public extension ModernBlackboardSearchQuery {
    // NOTE: リクエスト時はjson文字列化して使用する
    var jsonString: String? {
        let target = ShouldConvertJsonData(searchQuery: self)
        guard let jsonData = try? JSONEncoder().encode(target) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}

public extension ModernBlackboardSearchQuery {
    static func convertToConditionForBlackboardItems(
        blackboard: ModernBlackboardMaterial
    ) -> [ConditionForBlackboardItem] {
        // "工事名", "施工日", "施工者"は検索クエリから外す
        guard let pattern = ModernBlackboardContentView.Pattern(by: blackboard.layoutTypeID) else { return [] }
        let excludePositionList = [
                pattern.specifiedPosition(by: .constructionName),
                pattern.specifiedPosition(by: .date),
                pattern.specifiedPosition(by: .constructionPlayer)
            ]
            .compactMap { $0 }
        return blackboard.items
            .filter { !excludePositionList.contains($0.position) }
            .map { ConditionForBlackboardItem(targetItemName: $0.itemName, conditions: [$0.body]) }
    }
    
    /// 条件はデフォルトの状態か（実質検索クエリ自体がnilと同等となる）
    var isDefaultCondition: Bool {
        photoCondition == .all
            && conditionForBlackboardItems.isEmpty
            && freewords.isEmpty
    }
}

// MARK: - update
public extension ModernBlackboardSearchQuery {
    func updating(photoCondition: PhotoCondition) -> Self {
        .init(
            photoCondition: photoCondition,
            conditionForBlackboardItems: self.conditionForBlackboardItems,
            freewords: self.freewords
        )
    }
}

// MARK: - private
public extension ModernBlackboardSearchQuery {
    // NOTE: photoConditionはjson変換の対象外のため、除外したstructを用意する
    private struct ShouldConvertJsonData: Encodable {
        let conditionForBlackboardItems: [ConditionForBlackboardItem]
        let freewords: String

        private enum CodingKeys: String, CodingKey {
            case conditionForBlackboardItems = "blackboard"
            case freewords = "keyword"
        }

        init(searchQuery: ModernBlackboardSearchQuery) {
            self.conditionForBlackboardItems = searchQuery.conditionForBlackboardItems
            self.freewords = searchQuery.freewords
        }
    }
}

// MARK: - Equatable
extension ModernBlackboardSearchQuery: Equatable {
    public static func == (lhs: ModernBlackboardSearchQuery, rhs: ModernBlackboardSearchQuery) -> Bool {
        guard lhs.photoCondition == rhs.photoCondition,
              lhs.conditionForBlackboardItems == rhs.conditionForBlackboardItems,
              lhs.freewords == rhs.freewords else {
            return false
        }
        return true
    }
}

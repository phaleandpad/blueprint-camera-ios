//
//  PostBlackboardParams.swift
//  andpad-camera
//
//  Created by msano on 2022/02/09.
//

// MARK: - PostBlackboardParams (ApiParams)
/// 黒板新規作成用のApiParams
struct PostBlackboardParams: ApiParams {
    let blackboardData: [PostableBlackboardItemData]
    let layoutTypeID: Int
    let miniatureMapID: Int?
    let type: PostBlackboardType
    /// コピー元黒板のID
    ///
    /// コピー元黒板のIDを指定した場合、新規黒板はコピー元黒板直下に作成される
    let originalBlackboardID: Int?

    // NOTE:
    // SwiftyJSONで処理した際、ネストしたstruct配列（blackboardData）がうまくエンコードできなかった
    // -> そのため、 toDict() については明示的に使えなくさせている
    func toDict() -> [String: Any] {
        fatalError("[PostBlackboardParams] unimplemented.")
    }
}

// MARK: - PostBlackboardParams (Encodable)
extension PostBlackboardParams: Encodable {
    
    // NOTE: 実際にエンコードに利用している処理はこちら
    
    private enum EncodeKeys: String, CodingKey {
        case blackboardData = "blackboard_data"
        case layoutTypeID = "layout_type_id"
        case miniatureMapID = "miniature_map_id"
        case type
        case originalBlackboardID = "original_blackboard_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodeKeys.self)
        try container.encode(blackboardData, forKey: .blackboardData)
        try container.encode(layoutTypeID, forKey: .layoutTypeID)
        if let unwrappedMiniatureMapID = miniatureMapID {
            try container.encode(unwrappedMiniatureMapID, forKey: .miniatureMapID)
        }
        try container.encode(type.rawValue, forKey: .type)
        if let originalBlackboardID {
            try container.encode(originalBlackboardID, forKey: .originalBlackboardID)
        }
    }
    
    var jsonData: Data? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            print("[PostBlackboardParams] failed json encodeing.")
            return nil
        }
        return jsonData
    }
}

// MARK: - PostableBlackboardItemData
public struct PostableBlackboardItemData: Encodable {
    public let body: String
    public let itemName: String
    public let position: Int
    
    private enum EncodeKeys: String, CodingKey {
        case body
        case itemName = "item_name"
        case position
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodeKeys.self)

        // 空文字を送るとバックエンド側で正しく処理できないため、以下パラメータ2つは空文字をnilに置き換える
        // ref: https://88oct.slack.com/archives/C01CG2FGM6H/p1643964509882129?thread_ts=1643931144.167079&cid=C01CG2FGM6H
        try container.encode(body.isEmpty ? nil : body, forKey: .body)
        try container.encode(itemName.isEmpty ? nil : itemName, forKey: .itemName)

        try container.encode(position, forKey: .position)
    }
}

// MARK: - PostBlackboardType
public enum PostBlackboardType: String {
    /// 新規作成
    case new
    
    /// 編集時のコピー新規
    case copy
}

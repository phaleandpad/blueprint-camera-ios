//
//  PutBlackboardParams.swift
//  andpad-camera
//
//  Created by msano on 2022/05/26.
//

// NOTE: PostBlackboardParamsとほぼ同じ構造体（現状はtypeの有無がdiff）

struct PutBlackboardParams: ApiParams {
    let blackboardData: [PostableBlackboardItemData]
    let layoutTypeID: Int
    
    // NOTE:
    // SwiftyJSONで処理した際、ネストしたstruct配列（blackboardData）がうまくエンコードできなかった
    // -> そのため、 toDict() については明示的に使えなくさせている
    func toDict() -> [String: Any] {
        fatalError("[PutBlackboardParams] unimplemented.")
    }
}

// MARK: - Encodable
extension PutBlackboardParams: Encodable {
    
    // NOTE: 実際にエンコードに利用している処理はこちら
    
    private enum EncodeKeys: String, CodingKey {
        case blackboardData = "blackboard_data"
        case layoutTypeID = "layout_type_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodeKeys.self)
        try container.encode(blackboardData, forKey: .blackboardData)
        try container.encode(layoutTypeID, forKey: .layoutTypeID)
    }
    
    var jsonData: Data? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            print("[PostBlackboardParams] failed json encodeing.")
            return nil
        }
        return jsonData
    }
}

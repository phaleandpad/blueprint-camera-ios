//
//  BlackboardEditLoggingHandler.swift
//  andpad-camera
//
//  Created by msano on 2022/05/26.
//

/// カメラ起動からカメラキルまで、黒板に対するPOST / PUT操作の履歴を貯めるHandler
public struct BlackboardEditLoggingHandler {
    private static var _blackboardTypes: [BlackboardType] = []
    static var blackboardTypes: [BlackboardType] { _blackboardTypes }
}

// MARK: - static func
extension BlackboardEditLoggingHandler {
    static func add(type: BlackboardType) {
        var id: Int?
        switch type {
        case .posted(_, let blackboardID):
            id = blackboardID
        case .put(let blackboardMaterial):
            id = blackboardMaterial.id
        case .deleted(let blackboardID):
            id = blackboardID
        }
        guard let id else { fatalError() }
        
        // NOTE: id重複している場合は、後勝ちとして上書きする
        filterTypeBy(blackboardID: id, withoutPostedBlackboard: true, shouldAddDeletedType: false)
        _blackboardTypes.append(type)
    }
    
    /// 該当する黒板idのデータをリストから削除する
    ///
    /// - Parameter blackboardID: 黒板id
    /// - Parameter withoutPostedBlackboard: trueの場合、削除対象からpost型の黒板を除外する
    /// - Parameter shouldAddDeletedType: trueの場合、削除処理の後に、同じ黒版idで.deletedを追加する
    static func deleteTypeBy(
        blackboardID: Int,
        withoutPostedBlackboard: Bool,
        shouldAddDeletedType: Bool = true
    ) {
        filterTypeBy(
            blackboardID: blackboardID,
            withoutPostedBlackboard: withoutPostedBlackboard,
            shouldAddDeletedType: shouldAddDeletedType
        )
    }
    
    static func reset() {
        _blackboardTypes = []
    }
}

// MARK: - private (static func)
extension BlackboardEditLoggingHandler {
    private static func filterTypeBy(
        blackboardID: Int,
        withoutPostedBlackboard: Bool,
        shouldAddDeletedType: Bool
    ) {
        _blackboardTypes = _blackboardTypes.filter {
            switch $0 {
            case .posted(_, let id):
                let isDifferentIds = id != blackboardID

                // NOTE: 新規作成（posted）に限り、フラグによってはID重複していても除外しない
                guard shouldAddDeletedType else {
                    guard withoutPostedBlackboard else {
                        return isDifferentIds
                    }
                    return true
                }
                return isDifferentIds
            case .put(let blackboardMaterial):
                return blackboardMaterial.id != blackboardID
            case .deleted(let id):
                return id != blackboardID
            }
        }
        
        guard shouldAddDeletedType else { return }
        _blackboardTypes.append(.deleted(blackboardID: blackboardID)) // .deleted として追加する
    }
}

// MARK: - inner enum
extension BlackboardEditLoggingHandler {
    public enum BlackboardType {
        /// POST（新規作成 or コピー新規）された黒板情報
        case posted(PostBlackboardType, blackboardID: Int)
        
        /// PUT（上書き保存）された黒板情報
        case put(ModernBlackboardMaterial)
        
        /// 上書きマージ（ = 上書き保存の結果、編集元の黒板が既存の黒板に完全一致し、マージしたケース）された黒板情報
        case deleted(blackboardID: Int)
        // NOTE: わかりづらいが、DELETEリクエストをAPIに対して実行しているわけではないので注意
    }
}

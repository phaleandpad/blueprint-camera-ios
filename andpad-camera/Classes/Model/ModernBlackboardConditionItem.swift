//
//  ModernBlackboardConditionItem.swift
//  andpad-camera
//
//  Created by msano on 2022/01/13.
//

/// 案件内の黒板の黒板項目一覧
public struct ModernBlackboardConditionItem: Codable {
    /// 項目名
    public let body: String
    /// 優先表示フラグ
    let priorityDisplay: Bool

    private enum CodingKeys: String, CodingKey {
        case body
        case priorityDisplay = "priority_display"
    }
    
    public init(body: String, priorityDisplay: Bool) {
        self.body = body
        self.priorityDisplay = priorityDisplay
    }
}

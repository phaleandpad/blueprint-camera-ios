//
//  BlackboardFilterConditionsHistory.swift
//  andpad-camera
//
//  Created by msano on 2021/12/02.
//

public struct BlackboardFilterConditionsHistory: Codable {
    public let id: String
    public let orderID: Int
    public let updatedAt: Date
    public let query: ModernBlackboardSearchQuery
    
    public init(
        id: String = UUID().uuidString,
        orderID: Int,
        updatedAt: Date,
        query: ModernBlackboardSearchQuery
    ) {
        self.id = id
        self.orderID = orderID
        self.updatedAt = updatedAt
        self.query = query
    }
}

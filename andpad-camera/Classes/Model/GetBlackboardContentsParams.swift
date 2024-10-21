//
//  BlackboardConditionItemContentsParams.swift
//  andpad-camera
//
//  Created by msano on 2022/01/13.
//

import RxSwift

struct GetBlackboardPhotosParams: ApiParams {

    let offset: Int
    let limit: Int
    
    func toDict() -> [String: Any] {
        return [
            "offset": offset,
            "limit": limit
        ]
    }
}

public struct BlackboardConditionItemContentsParams: ApiParams {

    public enum ContentType {
        case search

        var queryString: String {
            switch self {
            case .search:
                return "search"
            }
        }
    }

    public let offset: Int
    public let limit: Int
    public let type: ContentType
    public let blackboardItemBody: String
    public let keyword: String?
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "offset": offset,
            "limit": limit,
            "type": type.queryString,
            "blackboard_item_body": blackboardItemBody
        ]
        if let keyword = keyword {
            dict["keyword"] = keyword
        }
        return dict
    }
}

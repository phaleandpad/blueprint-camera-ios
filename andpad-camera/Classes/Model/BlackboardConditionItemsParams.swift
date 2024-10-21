//
//  BlackboardConditionItemsParams.swift
//  andpad-camera
//
//  Created by msano on 2022/01/13.
//

public struct BlackboardConditionItemsParams: ApiParams {
    enum ContentType {
        case search

        var queryString: String {
            switch self {
            case .search:
                return "search"
            }
        }
    }
    
    enum PagingType {
        case enable(offset: Int, limit: Int)
        case disable
    }

    let contentType: ContentType
    let pagingType: PagingType
    
    func toDict() -> [String: Any] {

        switch pagingType {
        case .enable(let offset, let limit):
            return [
                "offset": offset,
                "limit": limit,
                "type": contentType.queryString
            ]
        case .disable:
            return [
                "type": contentType.queryString,
                "all": true
            ]
        }
    }
}

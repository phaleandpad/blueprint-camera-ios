//
//  BlackboardResultParams.swift
//  andpad-camera
//
//  Created by msano on 2021/01/06.
//

public struct BlackboardResultParams {
    public let offset: Int
    public let limit: Int
    let blackboardTreeID: Int?
    let photo: Bool?

    /**
     絞り込み用の検索クエリー
     - オフライン対応で施工側に検索条件を渡すため
     */
    public let searchQuery: ModernBlackboardSearchQuery?
    
    let searchQueryString: String? // jsonエンコードした検索クエリを格納
    public let sortTypeString: String
    
    init(
        offset: Int = 0,
        limit: Int = 20,
        blackboardTreeID: Int? = nil,
        photo: Bool? = nil,
        searchQuery: ModernBlackboardSearchQuery? = nil,
        sortTypeString: String
    ) {
        self.offset = offset
        self.limit = limit
        self.blackboardTreeID = blackboardTreeID
        self.photo = photo
        self.searchQuery = searchQuery
        self.searchQueryString = searchQuery?.jsonString
        self.sortTypeString = sortTypeString
    }
}

extension BlackboardResultParams: ApiParams {
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [String: AnyObject]()
        dict["limit"] = "\(limit)"
        if offset != 0 {
            dict["offset"] = "\(offset)"
        }
        if let blackboardTreeID = blackboardTreeID {
            dict["blackboard_tree_id"] = "\(blackboardTreeID)"
        }
        if let photo = photo {
            dict["photo"] = "\(photo)"
        }
        if let query = searchQueryString {
            dict["query"] = "\(query)"
        }
        dict["sort"] = "\(sortTypeString)"
        return dict
    }
}

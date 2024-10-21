//
//  BlackboardLayoutParams.swift
//  andpad-camera
//
//  Created by msano on 2021/01/06.
//

struct BlackboardLayoutParams: ApiParams {
    let offset: Int
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [String: AnyObject]()
        dict["offset"] = "\(offset)" as Any?
        return dict
    }
}

//
//  NetworkProtocols.swift
//  andpad-camera
//
//  Created by msano on 2020/11/02.
//

import UIKit

enum ApiParamsJSONSerializationError: Error {
    case invalidJSON
}

protocol ApiParams {
    func toDict() -> [String: Any]
    func toJSONData() throws -> Data
}

extension ApiParams {
    
    func toJSONData() throws -> Data {
        let jsonObject = toDict()
        guard JSONSerialization.isValidJSONObject(jsonObject) else {
            throw ApiParamsJSONSerializationError.invalidJSON
        }
        return try JSONSerialization.data(withJSONObject: jsonObject)
    }
}

protocol PhotoImageProtocol {
    var name: String { get set }

    var image: UIImage? { get set }

    var path: String? { get set }

    var originatedAt: Date? { get set }

    var isMovie: Bool { get set }
}

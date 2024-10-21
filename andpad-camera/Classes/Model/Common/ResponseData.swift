//
//  ResponseData.swift
//  andpad-camera
//
//  Created by msano on 2020/12/15.
//

// MARK: - ResponsePeelData
public struct ResponsePeelData<T: Codable>: Codable {
    public let object: T?
    public let objects: [T]?
    public let lastFlg: Bool?
    public let total: Int?
    //    let photos_state:String?
    public let permissions: [String]?

    private enum CodingKeys: String, CodingKey {
        case object
        case objects
        case lastFlg = "last_flg"
        case total
        case permissions
    }
}

// MARK: - ResponseData
public struct ResponseData<T: Codable>: Codable {
    public let data: ResponsePeelData<T>
    
    public init(data: ResponsePeelData<T>) {
        self.data = data
    }
}

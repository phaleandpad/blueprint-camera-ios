//
//  PhotoSizeType.swift
//  andpad-camera
//
//  Created by msano on 2020/11/05.
//

import UIKit

enum PhotoSizeType: String {
    case size2300
    case size1300

    static let values = [size2300, size1300]

    static func getIndex(_ name: String) -> Int {
        for (i, v) in PhotoSizeType.values.enumerated() where v.rawValue == name {
            return i
        }
        return -1
    }

    // TODO: 利用するか要検討
    //    static func getSizeSelectItems() -> [SelectItemViewController.SelectData]{
    //        var datas:[SelectItemViewController.SelectData] = []
    //        for (i,size) in PhotoSizeType.values.enumerated(){
    //            datas.append(SelectItemViewController.SelectData(index: i, name: size.name))
    //        }
    //        return datas
    //    }

    static func getType(name: String) -> PhotoSizeType {
        switch name {
        case "2300x2300":
            return .size2300
        case "1300x1300":
            return .size1300
        default:
            return .size1300
        }
    }

    var name: String {
        switch self {
        case .size2300:
            return "2300x2300"
        case .size1300:
            return "1300x1300"
        }
    }
}

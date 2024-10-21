//
//  ResolutionType.swift
//  andpad-camera
//
//  Created by msano on 2020/11/05.
//

enum ResolutionType: String {

    case reso100
    case reso080
    case reso060
    case reso040
    case reso020
    case reso010

    static let values = [reso100, reso080, reso060, reso040, reso020, reso010]

    static func getIndex(_ name: String) -> Int {
        for (i, v) in ResolutionType.values.enumerated() where v.rawValue == name {
            return i
        }
        return -1
    }

    //    static func getResolutionSelectItems() -> [SelectItemViewController.SelectData]{
    //        var datas:[SelectItemViewController.SelectData] = []
    //        for (i,reso) in ResolutionType.values.enumerated() {
    //            datas.append(SelectItemViewController.SelectData(index: i, name: reso.name))
    //        }
    //        return datas
    //    }

    static func getType(name: String) -> ResolutionType {
        switch name {
        case "100":
            return .reso100
        case "80":
            return .reso080
        case "60":
            return .reso060
        case "40":
            return .reso040
        case "20":
            return .reso020
        case "10":
            return .reso010
        default:
            return .reso010
        }
    }

    var resolution: CGFloat {
        switch self {
        case .reso100:
            return 1.0
        case .reso080:
            return 0.8
        case .reso060:
            return 0.6
        case .reso040:
            return 0.4
        case .reso020:
            return 0.2
        case .reso010:
            return 0.1
        }
    }
    
    var name: String {
        switch self {
        case .reso100:
            return "100"
        case .reso080:
            return "80"
        case .reso060:
            return "60"
        case .reso040:
            return "40"
        case .reso020:
            return "20"
        case .reso010:
            return "10"
        }
    }
}

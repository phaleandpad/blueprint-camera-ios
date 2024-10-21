//
//  OrderAndPermissions.swift
//  andpad-camera
//
//  Created by msano on 2022/05/24.
//

struct OrderAndPermissions: Codable {
    let order: Order?
    let permissions: Permissions
}

// MARK: - Permission
struct Permissions: Codable {
    let list: [String]

    enum CodingKeys: String, CodingKey {
        case list = "permissions"
    }
}

extension Permissions {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        list = try values.decode([String].self, forKey: .list)
    }
}

// MARK: - PermissionEnum
/// 権限ケース（施工本体より移植）
enum PermissionEnum: String {
    // 編集権限
    case blackboardEdit = "blackboard.edit"
    
    var string: String {
        rawValue
    }
}

// MARK: - Order
struct Order: Codable {
    private let teamRole: String
    
    enum CodingKeys: String, CodingKey {
        case teamRole = "team_role_type"
    }
}

extension Order {
    var teamRoleType: TeamRoleType? {
        .init(rawValue: teamRole)
    }
}

enum TeamRoleType: String {
    case ADMIN = "admin" // 1
    case BASIC = "basic" // 3
    case NONE = "none" // 2
}

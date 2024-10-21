//
//  ModernBlackboardLayout.swift
//  andpad-camera
//
//  Created by msano on 2020/12/15.
//

public struct ModernBlackboardLayout: Codable, ModernBlackboardData {
    let id: Int
    let layoutMaterial: LayoutMaterial
    let blackboardTreeID: Int
    public let blackboardTheme: ModernBlackboardAppearance.Theme
    let items: [Item]

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case layoutMaterial = "layout"
        case blackboardTreeID = "blackboard_tree_id"
        case blackboardTheme = "blackboard_theme_code"
        case items
    }

    struct LayoutMaterial: Codable {
        let id: Int
        let depth: Int

        private enum CodingKeys: String, CodingKey {
            case id
            case depth
        }
    }

    // NOTE: BlackboardItemへ変換可能にする必要があるかも
    struct Item: Codable {
        let id: Int
        let itemName: String
        let position: Int

        private enum CodingKeys: String, CodingKey {
            case id = "id"
            case itemName = "body"
            case position
        }
    }
}

// MARK: - decode
extension ModernBlackboardLayout {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        layoutMaterial = try values.decode(LayoutMaterial.self, forKey: .layoutMaterial)
        blackboardTreeID = try values.decode(Int.self, forKey: .blackboardTreeID)
        blackboardTheme = .init(
            themeCode: try values.decode(Int.self, forKey: .blackboardTheme)
        )
        items = try values.decode([Item].self, forKey: .items)
    }
    
    public init(
        pattern: ModernBlackboardContentView.Pattern,
        theme: ModernBlackboardAppearance.Theme
    ) {
        id = 0
        layoutMaterial = .init(id: pattern.rawValue, depth: 0)
        blackboardTreeID = 0
        blackboardTheme = theme
        
        var items: [Item] = []
        pattern.stackedInputsRowType.forEach {
            switch $0 {
            case .constructionName(let position):
                items.append(
                        .init(
                        id: 0,
                        itemName: L10n.Blackboard.AutoInputInformation.constructionNameTitle,
                        position: position
                    )
                )
            case .normal(let position):
                items.append(
                        .init(
                        id: 0,
                        itemName: "",
                        position: position
                    )
                )
            case .memo(let position):
                items.append(
                        .init(
                        id: 0,
                        itemName: "",
                        position: position
                    )
                )
            case .dateAndConstructionPlayer(let leftPosition, let rightPosition):
                items.append(
                        .init(
                        id: 0,
                        itemName: "",
                        position: leftPosition
                    )
                )
                items.append(
                        .init(
                        id: 0,
                        itemName: "",
                        position: rightPosition
                    )
                )
            case .constructionPlayer(position: let position):
                items.append(
                        .init(
                        id: 0,
                        itemName: "",
                        position: position
                    )
                )
            }
        }
        
        self.items = items
    }
}

// MARK: - debug
extension ModernBlackboardLayout {
    public func prettyDebug(with sceneDescription: String? = nil) {
        #if DEBUG
        print("\nBlackboardLayout -----------------------------------")
        if let sceneDescription = sceneDescription {
            print("📖 scene [\(sceneDescription)]\n")
        }

        print("id: ", id)
        print("layoutMaterial: ", layoutMaterial)
        print("blackboardTreeID: ", blackboardTreeID)
        print("\n")

        items
            .enumerated()
            .forEach {
                print("items[\($0.offset)]  .............................................\n")
                print("  id: ", $0.element.id)
                print("  position: ", $0.element.position)
                print("  itemName: ", $0.element.itemName)
                print("\n")
            }

        print(" ------------------------------------------------------\n")
        #endif
    }
}

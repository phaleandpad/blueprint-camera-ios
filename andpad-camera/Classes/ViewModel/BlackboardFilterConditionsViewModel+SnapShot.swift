//
//  BlackboardFilterConditionsViewModel+SnapShot.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/03/26.
//

extension BlackboardFilterConditionsViewModel {

    /// 「写真の有無」の選択状態。
    struct PhotoCondition: Equatable {
        let condition: SearchQuery.PhotoCondition

        var conditionModelType: ConditionModelType {
            .photo(condition.string)
        }
    }

    /// 優先表示ありの項目の選択状態。
    struct PinnedBlackboardItemCondition: Equatable {
        let itemName: String
        let selectedConditions: [String]
        let isActive: Bool

        var conditionModelType: ConditionModelType {
            .pinnedBlackboardItem(
                itemName: itemName,
                selectedConditions: selectedConditions,
                isActive: isActive
            )
        }
    }

    /// 優先表示なしの項目の選択状態。
    struct UnPinnedBlackboardItemCondition: Equatable {
        let itemName: String
        let selectedConditions: [String]
        let isVisible: Bool
        let isActive: Bool

        var conditionModelType: ConditionModelType {
            .unpinnedBlackboardItem(
                itemName: itemName,
                selectedConditions: selectedConditions,
                isVisible: isVisible,
                isActive: isActive
            )
        }
    }

    /// 「フリーワード」の選択状態。
    struct FreewordCondition: Equatable {
        let freeword: String

        var conditionModelType: ConditionModelType {
            .freeword(freeword)
        }
    }

    /// 項目の表示内容と選択状態のスナップショットを格納しておくためのクラス。
    struct ConditionsSnapShot: Equatable {
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.pinnedBlackboardItemConditions == rhs.pinnedBlackboardItemConditions
                && lhs.unpinnedBlackboardItemConditions == rhs.unpinnedBlackboardItemConditions
                && lhs.photoCondition == rhs.photoCondition
                && lhs.freewordCondition == rhs.freewordCondition
        }

        let photoCondition: PhotoCondition
        let pinnedBlackboardItemConditions: [PinnedBlackboardItemCondition]
        let unpinnedBlackboardItemConditions: [UnPinnedBlackboardItemCondition]
        let freewordCondition: FreewordCondition

        /// 「すべての項目を表示する」ボタンの表示条件
        private var showAllBlackboardItemsButtonCondition: ConditionModelType? {
            /// ピン留めされていない項目について、すべての項目が表示されているか否か
            let allAreVisible = unpinnedBlackboardItemConditions.allSatisfy { $0.isVisible }
            return allAreVisible ? nil : .showAllBlackboardItemsButton
        }

        /// 黒板の項目に関連するセルをまとめたもの
        ///
        /// 1つのセクションとして表示する
        private var blackboardItems: [ConditionModelType] {
            var items = pinnedBlackboardItemConditions.map { $0.conditionModelType }

            /// その他の項目のうち表示対象のもの
            let filteredUnpinnedBlackboardItemConditions = unpinnedBlackboardItemConditions.filter { $0.isVisible }
            if !pinnedBlackboardItemConditions.isEmpty, !filteredUnpinnedBlackboardItemConditions.isEmpty {
                // ピン留め項目もその他の項目（表示対象のもの）も両方存在するとき、区切り線を表示する
                items.append(.blackboardItemsSeparator)
            }
            // その他の項目のうち表示対象のものを追加する
            items.append(contentsOf: filteredUnpinnedBlackboardItemConditions.map { $0.conditionModelType })
            if let showAllBlackboardItemsButtonCondition {
                items.append(showAllBlackboardItemsButtonCondition)
            }

            return items
        }

        init(
            photoCondition: PhotoCondition = .init(condition: .all),
            pinnedBlackboardItemConditions: [PinnedBlackboardItemCondition] = [],
            unpinnedBlackboardItemConditions: [UnPinnedBlackboardItemCondition] = [],
            freewordCondition: FreewordCondition = .init(freeword: "")
        ) {
            self.photoCondition = photoCondition
            self.pinnedBlackboardItemConditions = pinnedBlackboardItemConditions
            self.unpinnedBlackboardItemConditions = unpinnedBlackboardItemConditions
            self.freewordCondition = freewordCondition
        }

        init(searchQuery: SearchQuery, initialSnapShot: ConditionsSnapShot) {
            self.photoCondition = initialSnapShot.photoCondition

            let updatedPinnedBlackboardItemConditions = initialSnapShot
                .pinnedBlackboardItemConditions
                .map { condition in
                    guard
                        let targetQueryCondition = searchQuery
                            .conditionForBlackboardItems
                            .first(where: { $0.targetItemName == condition.itemName }) else {
                        return condition
                    }
                    return .init(
                        itemName: condition.itemName,
                        selectedConditions: targetQueryCondition.conditions,
                        isActive: condition.isActive
                    )
                }
            self.pinnedBlackboardItemConditions = updatedPinnedBlackboardItemConditions

            self.unpinnedBlackboardItemConditions = initialSnapShot
                .unpinnedBlackboardItemConditions
                .map { condition in
                    guard
                        let targetQueryCondition = searchQuery
                            .conditionForBlackboardItems
                            .first(where: { $0.targetItemName == condition.itemName }) else {
                        return condition
                    }
                    return .init(
                        itemName: condition.itemName,
                        selectedConditions: targetQueryCondition.conditions,
                        // ピン留めされた項目が１つもない場合表示し、そうでない場合検索条件の有無によって判断する
                        isVisible: updatedPinnedBlackboardItemConditions.isEmpty || !targetQueryCondition.conditions.isEmpty,
                        isActive: condition.isActive
                    )
                }

            self.freewordCondition = .init(freeword: searchQuery.freewords)
        }

        var dataSourceItems: [DataSource.Section] {
            [
                .photo(items: [photoCondition.conditionModelType]),
                .blackboardItem(title: L10n.Blackboard.Filter.SectionTitle.blackboardItem, items: blackboardItems),
                .freeword(title: L10n.Blackboard.Filter.SectionTitle.freeword, items: [freewordCondition.conditionModelType])
            ]
        }

        /// ユーザーが指定した検索条件をクリアし、新しいインスタンスを返す
        ///
        /// このメソッドは、元のインスタンスに影響を与えず、新しいインスタンスを作成する。
        /// 写真条件、ピン留めされた黒板項目の条件、ピン留めされていない黒板項目の条件、フリーワード条件がクリアされる。
        ///
        /// - Returns: 条件がクリアされた新しいインスタンス
        func clearedSelectedConditions() -> Self {
            .init(
                photoCondition: .init(condition: .all),
                pinnedBlackboardItemConditions: pinnedBlackboardItemConditions.map { .init(itemName: $0.itemName, selectedConditions: [], isActive: true) },
                unpinnedBlackboardItemConditions: unpinnedBlackboardItemConditions.map { .init(itemName: $0.itemName, selectedConditions: [], isVisible: $0.isVisible, isActive: true) },
                freewordCondition: .init(freeword: "")
            )
        }

        func updating(photoCondition: PhotoCondition) -> Self {
            .init(
                photoCondition: photoCondition,
                pinnedBlackboardItemConditions: pinnedBlackboardItemConditions,
                unpinnedBlackboardItemConditions: unpinnedBlackboardItemConditions,
                freewordCondition: freewordCondition
            )
        }

        func updating(freewordCondition: FreewordCondition) -> Self {
            .init(
                photoCondition: photoCondition,
                pinnedBlackboardItemConditions: pinnedBlackboardItemConditions,
                unpinnedBlackboardItemConditions: unpinnedBlackboardItemConditions,
                freewordCondition: freewordCondition
            )
        }

        func updating(unpinnedBlackboardItemConditions: [UnPinnedBlackboardItemCondition]) -> Self {
            .init(
                photoCondition: photoCondition,
                pinnedBlackboardItemConditions: pinnedBlackboardItemConditions,
                unpinnedBlackboardItemConditions: unpinnedBlackboardItemConditions,
                freewordCondition: freewordCondition
            )
        }

        func updating(
            pinnedBlackboardItemConditions: [PinnedBlackboardItemCondition],
            unpinnedBlackboardItemConditions: [UnPinnedBlackboardItemCondition]
        ) -> Self {
            .init(
                photoCondition: photoCondition,
                pinnedBlackboardItemConditions: pinnedBlackboardItemConditions,
                unpinnedBlackboardItemConditions: unpinnedBlackboardItemConditions,
                freewordCondition: freewordCondition
            )
        }
    }
}

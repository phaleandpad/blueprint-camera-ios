//
//  ModernBlackboard.swift
//  andpad-camera
//
//  Created by 西悠作 on 2024/05/08.
//

// MARK: - ModernBlackBoardContent -

// TODO: typo修正 (BlackBoard => Blackboard)
public protocol ModernBlackBoardContent {
    var itemName: String { get }
    var itemBody: String { get }
    var position: Int { get }
}

extension ModernBlackBoardContent {
    
    /// 写真固有の情報かどうかを返します。
    public func isPhotoSpecific(in layout: ModernBlackboardContentView.Pattern) -> Bool {
        position == layout.specifiedPosition(by: .constructionName)
        || position == layout.specifiedPosition(by: .constructionPlayer)
        || position == layout.specifiedPosition(by: .date)
    }
}

extension ModernBlackboardMaterial.Item: ModernBlackBoardContent {
    public var itemBody: String { body }
}

// MARK: - AnyModernBlackBoardContent

/// `ModernBlackBoardContent`プロトコルの型消去。
///
/// `ModernBlackBoardContent`プロトコルに準拠した異なる型同士の比較に使用できます。
struct AnyModernBlackBoardContent: ModernBlackBoardContent, Hashable {
    let itemName: String
    let itemBody: String
    let position: Int
}

extension AnyModernBlackBoardContent {
    
    init(_ content: some ModernBlackBoardContent) {
        itemName = content.itemName
        itemBody = content.itemBody
        position = content.position
    }
}

// MARK: - ModernBlackBoardMiniatureMap -

public protocol ModernBlackBoardMiniatureMap {}

extension ModernBlackboardMaterial.MiniatureMap: ModernBlackBoardMiniatureMap {}

// MARK: - ModernBlackboard -

public protocol ModernBlackboard {
    associatedtype Content: ModernBlackBoardContent
    associatedtype MiniatureMap: ModernBlackBoardMiniatureMap
    
    var layoutTypeID: Int { get }
    var contents: [Content] { get }
    var miniatureMap: MiniatureMap? { get }
}

extension ModernBlackboardMaterial: ModernBlackboard {
    public var contents: [Item] { items }
}

// MARK: - Equivalence checking

public enum ModernBlackboardEquivalenceCheckingError: Error {
    case undefinedLayout(id: Int)
}

extension ModernBlackboard {
    
    public typealias Layout = ModernBlackboardContentView.Pattern
    public typealias EquivalenceCheckingError = ModernBlackboardEquivalenceCheckingError
    
    /// 自身と指定された黒板が同等の黒板かどうかを返します。
    ///
    /// 返り値は「中身が完全一致しているかどうか」ではなく「同じ黒板として扱われるかどうか」です。
    /// 例えば、写真固有の情報や豆図などは比較対象外です。
    ///
    /// - Parameter other: 比較対象の黒板。
    /// - Throws: レイアウトIDは一致するが未定義のレイアウトだった場合は
    ///           `EquivalenceCheckingError`を投げます。
    public func isEquivalent(to other: some ModernBlackboard) throws -> Bool {
        // レイアウトIDが一致しない場合は差分ありと判定
        guard layoutTypeID == other.layoutTypeID else {
            return false
        }
        
        // 未定義レイアウトの場合は例外を投げる
        guard let layout = Layout(rawValue: layoutTypeID) else {
            throw EquivalenceCheckingError.undefinedLayout(id: layoutTypeID)
        }
        
        // 比較対象外の項目（写真固有の情報）を除外して比較
        /*
         NOTE:
         contentsは順不同のためSetに変換してから比較している。
         仕様上positionが重複することはないため、contentsに重複項目が含まれることはない。
         */
        let commonContents = Set(
            contents
                .filter { !$0.isPhotoSpecific(in: layout) }
                .map(AnyModernBlackBoardContent.init)
        )
        let otherCommonContents = Set(
            other.contents
                .filter { !$0.isPhotoSpecific(in: layout) }
                .map(AnyModernBlackBoardContent.init)
        )
        assert(
            commonContents.count == otherCommonContents.count,
            "layoutTypeIDが一致していれば共通項目の個数も一致するはず"
        )
        return commonContents == otherCommonContents
    }
}

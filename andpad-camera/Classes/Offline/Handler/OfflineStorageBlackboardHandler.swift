//
//  OfflineStorageBlackboardHandler.swift
//  andpad-camera
//
//  Created by 江本 光晴 on 2023/12/21.
//

import Foundation

/**
 端末に保存された黒板に関する操作
 */
@MainActor public protocol OfflineStorageBlackboardHandlerProtocol {
    // NOTE: インタフェースは必要に応じて追加する
    
    func fetchBlackboard(with blackboardID: Int) throws -> ModernBlackboardMaterial?
    
    /// 黒板の同等性をチェックするのに十分な未アップロード写真黒板情報を取得する
    ///
    /// 写真固有の情報など同等性チェックに不要な情報は含んでいなくても良い
    ///
    /// - Warning: 一部ダミーの情報が含まれている可能性があるため、同等性チェック以外の目的で使用しないこと
    func fetchPhotoBlackboardForEquivalenceChecking(
        withID blackboardID: Int
    ) throws -> ModernBlackboardMaterial?
    
    func fetchBlackboardSetting(userID: Int, orderID: Int) throws -> ModernBlackboardCommonSetting?

    func fetchMiniatureMap(
        withID miniatureMapID: Int,
        imageType: MiniatureMapImageType
    ) -> UIImage?

    /// 重複する黒板が無いかどうかローカル黒板情報を検索する
    func duplicatedBlackboard(
        with blackboardMaterial: ModernBlackboardMaterial,
        userID: Int,
        orderID: Int
    ) throws -> ModernBlackboardMaterial?

    /// ローカルDBにコピー新規で黒板を保存する
    func createBlackboardCopy(
        userID: Int,
        orderID: Int,
        layoutTypeID: Int,
        contents: [ModernBlackboardMaterial.Item],
        miniatureMap: ModernBlackboardMaterial.MiniatureMap?,
        creationDateOnServer: Date,
        modificationDateOnServer: Date,
        originalBlackboardID: Int?
    ) throws -> ModernBlackboardMaterial?
    
    /// サーバーから取得した黒板情報をローカルに同期する。
    /// - Parameters:
    ///   - localBlackboardID: 更新対象のローカル黒板のID。
    ///   - remoteBlackboard: サーバーから取得した黒板情報。
    func synchronizeBlackboard(
        withID localBlackboardID: Int,
        with remoteBlackboard: ModernBlackboardMaterial
    ) throws
    
    /// ローカルに保存された黒板のIDを一時的なIDに付け替え、黒板リストの末尾に移動する。
    ///
    /// ローカルに保存された黒板とは以下を指す。
    /// - ダウンロードされた黒板
    /// - 未アップロード写真に紐づく黒板
    ///
    /// ダウンロード黒板はIDを付け替えダウンロード黒板リストの末尾に移動する。
    /// 未アップロード写真黒板はIDのみ付け替える。
    ///
    /// - Parameters:
    ///   - currentID: 変更前のID。
    /// - Returns: 変更後の一時ID。
    func assignTemporaryIDToLocalBlackboardAndMoveToLast(
        withCurrentID currentID: Int
    ) throws -> Int

    /**
     絞り込み条件の工種や符号などの項目を取得する
     */
    func fetchBlackboardConditionItems(userID: Int, orderID: Int, param: BlackboardConditionItemsParams) throws -> [ModernBlackboardConditionItem]
    
    /**
     絞り込み条件の項目に対応する条件を取得する
     */
    func fetchBlackboardConditionItemContents(userID: Int, orderID: Int, param: BlackboardConditionItemContentsParams) throws -> [ModernBlackboardConditionItemContent]
    
    /**
     絞り込み条件の項目に対応する条件を取得する
     */
    func fetchFilteredBlackboards(userID: Int, orderID: Int, param: BlackboardResultParams) throws -> [ModernBlackboardMaterial]
}

/**
 オフライン黒板情報の取得条件
 
 @note
 - 施工アプリ側の OfflineBlackboard.FetchCondition をここで参照できないので、コピーしています
 - 施工アプリ側でソート仕様が確定したら、それに合わせて変更する必要があります
 - OfflineUser.ID は Int に置き換えています
 */
/// オフライン黒板情報の取得条件。
public struct FetchCondition: Hashable, Sendable {
    public enum Sort: Hashable, Sendable {
        case byPosition(ascending: Bool)
        case byBlackboardID(ascending: Bool)
        case byCreationDateOnServer(ascending: Bool)
    }
    
    /// 全件取得条件。
    /// - Parameter userID: ユーザーID。`nil`を指定した場合は全ユーザーのデータを取得します。
    public static func all(userID: Int?) -> FetchCondition {
        .init(userID: userID)
    }
    
    /*
     NOTE:
     絞り込み中にユーザーIDを変更するユースケースは考えられず、ユーザーIDが誤って
     変更されるリスクの方が大きいためletにしている。
     */
    /// ユーザーID。
    ///
    /// 完全一致で取得します。`nil`を指定した場合は絞り込み対象になりません。
    public let userID: Int?
    
    /// 案件ID。
    ///
    /// 完全一致で取得します。`nil`を指定した場合は絞り込み対象になりません。
    public var orderID: Int?
    
    /// ソート条件。
    ///
    ///  - Note: 仕様上、第一ソート条件・第二ソート条件・第三ソート条件まで指定されます
    public var sortConditions: [Sort] = [
        .byPosition(ascending: true),
        .byBlackboardID(ascending: true),
        .byCreationDateOnServer(ascending: true)
    ]

    /// 取得件数。
    ///
    /// `nil` を指定した場合は全件取得します。
    public var limit: Int?

    /// 取得位置(オフセット)。
    ///
    /// `nil` を指定した場合は1件目から取得します。
    public var offset: Int?
}

/// - Note: fetchOrCreateBlackboard メソッドで発生したエラーを throw するために使用します。
public enum FetchOrCreateBlackboardError: Error {
    /// 黒板設定のしゅとくに失敗した場合
    case settingNotFound
}

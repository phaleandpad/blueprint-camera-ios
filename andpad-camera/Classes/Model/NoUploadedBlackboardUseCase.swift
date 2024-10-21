//
//  NoUploadedBlackboardUseCase.swift
//  andpad-camera
//
//  Created by 栗山徹 on 2024/01/13.
//

import Foundation
import RxSwift

/// オフラインモード時にローカルへ保存した黒板情報のサーバーへの登録やローカルデータの更新を行うために使用するクラスです。
///
/// - Note: DisposeBag を使用するためにクラス定義になっています。
public final class NoUploadedBlackboardUseCase {
    
    private enum FetchError: Error {
        case blackboardMaterialNotFound
    }

    private let disposeBag = DisposeBag()

    public init() {}
    
    /// ローカル黒板の同期によるID変更。
    public struct LocalBlackboardIDChange: Hashable, Sendable {
        public let oldID: Int
        public let newID: Int
    }
    
    /// ローカルに保存された黒板情報をサーバーと同期します。
    ///
    /// ローカルに保存された黒板情報とは以下を指します。
    /// - オフラインモード用にダウンロードされた黒板情報
    /// - 未アップロード写真に紐づいた黒板情報
    ///
    /// このメソッドで行う処理は主に以下の2つです。
    /// 1. サーバーに存在しない黒板であればサーバー側にも作成する
    /// 2. ローカルの黒板情報（ID、黒板一覧における位置、作成日など）をサーバー側と一致させる
    ///
    /// 2に伴い、ID重複を避けるため別の黒板のIDがマイナス値に変更される可能性があります。
    ///
    /// - Parameters:
    ///   - targetLocalBlackboard: ローカルに保存されている同期対象の黒板情報。
    ///   - orderID: 黒板が紐づく案件のID。
    ///   - appBaseRequestData: API呼び出しに必要な情報。
    ///   - offlineStorageHandler: ローカルDBの読み書き処理クラス。
    /// - Returns: 同期によるローカル黒板IDの変更内容のリスト。
    /// - Note: 返り値のリストを用いて同等のID変更を適用する場合、
    ///         必ずリストの順序に従って適用してください。
    @MainActor
    public func synchronizeBlackboardIfNeeded(
        _ targetLocalBlackboard: ModernBlackboardMaterial,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData,
        offlineStorageHandler: OfflineStorageHandler = .shared
    ) async throws -> [LocalBlackboardIDChange] {
        /*
         事後条件:
         - targetLocalBlackboardと同じ内容の黒板remoteBlackboardがサーバーに存在する
         - 対象のローカル黒板（targetLocalBlackboard自体ではなくDBデータ）の情報がremoteBlackboardと一致する
         */
        
        // 黒板作成APIに対象の黒板情報を送信し、同じ内容を持つ新規または既存の黒板情報を取得
        let remoteBlackboard = try await postBlackboard(
            blackboardMaterial: targetLocalBlackboard,
            orderID: orderID,
            appBaseRequestData: appBaseRequestData
        )
        assert(try! remoteBlackboard.isEquivalent(to: targetLocalBlackboard))
        
        let localBlackboardHandler = offlineStorageHandler.blackboard!
        var idChanges: [LocalBlackboardIDChange] = []
        
        /*
         対象のローカル黒板のIDをremoteBlackboard.idで上書きする前に、
         remoteBlackboardと同じIDの黒板がローカルに保存されていないか確認する。
         同じIDかつ異なる内容のローカル黒板が見つかった場合、ID重複を防ぐため事前にそのIDを振り直し、
         またダウンロード黒板リストの末尾に移動する。
         
         具体的なケース:
         1. 黒板（ID: 1, 内容: A）をダウンロード
         2. オフラインモードでローカル黒板Aを内容Bに編集
            -> 上書き編集ではなく新規ローカル黒板（ID: -t1, 内容: B）が作成される
         3. Web側で同じくサーバー黒板Aを内容Bに上書き編集
            -> IDそのままでサーバー黒板（ID: 1, 内容B）に変更される
         4. ローカル黒板（ID: -t1, 内容B）に紐づいた写真をアップロード
            i. ローカル黒板（ID: -t1, 内容B）を送信 -> サーバー黒板（ID: 1, 内容B）が返却される
            ii. ローカル黒板AのIDを1 -> -t2に変更し末尾に移動 // ここが該当処理
            iii. ローカル黒板BのIDを-t1 -> 1に変更し他情報も上書き
         
         NOTE:
         ダウンロード黒板と未アップロード写真黒板は互いに同じIDであれば必ず同じ内容であるため、
         一方のequivalenceだけチェックすればOK。一方しか存在しないケースもある。
         */
        var idDuplicatedLocalBlackboard = try? localBlackboardHandler
            .fetchPhotoBlackboardForEquivalenceChecking(withID: remoteBlackboard.id)
        if idDuplicatedLocalBlackboard == nil {
            idDuplicatedLocalBlackboard = try? localBlackboardHandler
                .fetchBlackboard(with: remoteBlackboard.id)
        }
        if let idDuplicatedLocalBlackboard,
           !(try idDuplicatedLocalBlackboard.isEquivalent(to: remoteBlackboard)) {
            let oldID = idDuplicatedLocalBlackboard.id
            let newID = try localBlackboardHandler
                .assignTemporaryIDToLocalBlackboardAndMoveToLast(withCurrentID: oldID)
            idChanges.append(.init(oldID: oldID, newID: newID))
        }
        
        // 対象のローカル黒板の情報をremoteBlackboardの情報で上書きする
        try localBlackboardHandler.synchronizeBlackboard(
            withID: targetLocalBlackboard.id,
            with: remoteBlackboard
        )
        idChanges.append(.init(oldID: targetLocalBlackboard.id, newID: remoteBlackboard.id))
        
        return idChanges
    }

    /// 既存の黒板登録 API をラップし、 async/await 方式で使えるようにする。
    ///
    /// - Parameters:
    ///  - blackboardMaterial: 送信する情報
    ///  - orderID: 案件ID
    ///  - appBaseRequestData: API呼び出しに必要な情報
    private func postBlackboard(
        blackboardMaterial: ModernBlackboardMaterial,
        orderID: Int,
        appBaseRequestData: AppBaseRequestData
    ) async throws -> ModernBlackboardMaterial {
        let apiManager = ApiManager(client: AlamofireClient())

        let itemData = blackboardMaterial.items.map { item in
            PostableBlackboardItemData(
                body: item.body,
                itemName: item.itemName,
                position: item.position
            )
        }

        // オフライン状態で黒板をコピー新規作成した状態でオンラインに復帰した場合、 type: 'copy' で登録する
        let params = PostBlackboardParams(
            blackboardData: itemData,
            layoutTypeID: blackboardMaterial.layoutTypeID,
            miniatureMapID: blackboardMaterial.miniatureMap?.id,
            type: .copy,
            originalBlackboardID: blackboardMaterial.originalBlackboardID
        )

        return try await withCheckedThrowingContinuation { continuation in
            apiManager.postBlackboard(params, orderID: orderID, appBaseRequestData: appBaseRequestData)
                .subscribe(
                    onSuccess: { result in
                        guard let blackboardMaterial = result.data.object else {
                            continuation.resume(throwing: FetchError.blackboardMaterialNotFound)
                            return
                        }
                        continuation.resume(returning: blackboardMaterial)
                    }, onFailure: { error in
                        continuation.resume(throwing: error)
                    }
                )
                .disposed(by: disposeBag)
        }
    }
}

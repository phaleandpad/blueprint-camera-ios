//
//  OfflineStorageHandler.swift
//  andpad-camera
//
//  Created by 江本 光晴 on 2023/12/21.
//

import Foundation

/**
 オフラインモード向けに、施工アプリ側からキャッシュ操作を注入する
 
 @example
 ```swift
 // 施工アプリにおいて
 let cacheBlackboardHandler = ...
 OfflineStorageHandler.shared.setUpHandler(blackboard: cacheBlackboardHandler)
 ```
 
 ```swift
 // カメラライブラリにおいて
 let result = OfflineStorageHandler.shared.blackboard.hogehoge()
 ```
 
 @description
 キャッシュされた黒板操作は blackboard として、目的ごとにプロパティを分けて、肥大化を防ぐ
 
 @description
 施工アプリから注入されるまで、カメラライブラリ側でこのクラスの機能は利用できない。
 起動直後に操作する場合は注意が必要です（nullableにするかは要検討）。
 
 @todo
 施工アプリからカメラライブラリへの注入はロガーなど複数あるので、
 まとめて注入する機能に修正する
 https://github.com/88labs/andpad-camera-ios/pull/667#discussion_r1434915713
 */
public final class OfflineStorageHandler {
    
    private(set) var blackboard: OfflineStorageBlackboardHandlerProtocol!
    
    public static let shared = OfflineStorageHandler()
    
    private init() {}
    
    public func setUpHandler(blackboard: OfflineStorageBlackboardHandlerProtocol) {
        self.blackboard = blackboard
    }
}

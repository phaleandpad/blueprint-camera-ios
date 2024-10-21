//
//  AndpadCameraDependencies.swift
//  ActiveLabel
//
//  Created by 江本 光晴 on 2024/06/03.
//

import Foundation

/**
 施工アプリ側から注入されるRemote Config
 */
public protocol AndpadCameraDependenciesRemoteConfigProtocol {
    func fetchUseBlackboardGeneratedWithSVG() -> Bool
}

/**
 施工アプリ側から注入する
 
 @description
 施工アプリから注入されるものをまとめた。
 
 @todo
 注入されるロガーやオフライン向けの関数もこのクラスで管理する
 
 @see
 - https://github.com/88labs/andpad-camera-ios/pull/667#discussion_r1434915713
 */
public final class AndpadCameraDependencies {
    public static let shared = AndpadCameraDependencies()
    private init() {}
    
    public private(set) var remoteConfigHandler: (any AndpadCameraDependenciesRemoteConfigProtocol)?

    public func setup(remoteConfigHandler: any AndpadCameraDependenciesRemoteConfigProtocol){
        self.remoteConfigHandler = remoteConfigHandler
    }
}

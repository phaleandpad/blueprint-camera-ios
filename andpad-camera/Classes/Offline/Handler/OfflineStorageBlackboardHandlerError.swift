//
//  OfflineStorageBlackboardHandlerError.swift
//  andpad-camera
//
//  Created by 江本 光晴 on 2024/01/10.
//

import Foundation

/**
 ローカルストレージに関するエラーです
 */
public enum OfflineStorageBlackboardHandlerError: Error {
    
    /**
     絞り込みで利用するフリーワードは5つ以下にしてください
     */
    case shouldBeNoMoreThanFiveFreeWords
}

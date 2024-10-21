//
//
//  AndpadCameraLogger.swift
//  Pods
//
//  Created by Yosuke Nakamura on 2022/04/11.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//
//

import Foundation

// MARK: - AndpadCameraLogger

/// ログ
public class AndpadCameraLogger {
    /// 非致命的なエラーが発生したときのアクション
    ///
    /// - Note: 本体アプリから依存性を注入します。
    public var nonFatalErrorAction: ((Error) -> Void)?

    public init() {}
}

// MARK: - 非致命的なエラーのロギング

extension AndpadCameraLogger {
    /// 非致命的なエラーが発生した場合に、設定されたアクションを呼び出す
    ///
    /// - Parameter error: 発生した非致命的なエラー
    func nonFatalError(_ error: Error) {
        nonFatalErrorAction?(error)
    }

    /// 非致命的なエラーが発生した場合に、設定されたアクションを呼び出す
    ///
    /// - Parameters:
    ///   - domain: エラードメイン
    ///   - additionalUserInfo: 追加のユーザー情報
    ///   - file: ソースファイル名
    ///   - function: 関数名
    ///   - line: 行番号
    ///
    /// - Usage:
    ///
    /// ```
    /// AndpadCameraConfig.logger.nonFatalError(
    ///     domain: "XXXError",
    ///     additionalUserInfo: [
    ///         NSLocalizedDescriptionKey: error.localizedDescription,
    ///         "Message": "エラーメッセージ"
    ///     ]
    /// )
    /// ```
    ///
    func nonFatalError(domain: String, additionalUserInfo: [String: Any], file: String = #file, function: String = #function, line: UInt = #line) {
        let error = makeNSError(domain: domain, additionalUserInfo: additionalUserInfo, file: file, function: function, line: line)
        nonFatalError(error)
    }

    /// 非致命的なエラーが発生した場合に、設定されたアクションを呼び出す
    ///
    /// - Parameters:
    ///   - domain: エラードメイン
    ///   - message: エラーメッセージ
    ///   - file: ソースファイル名
    ///   - function: 関数名
    ///   - line: 行番号
    ///
    /// - Usage:
    ///
    /// ```
    /// AndpadCameraConfig.logger.nonFatalError(
    ///     domain: "XXXError",
    ///     message: "エラーメッセージ"
    /// )
    /// ```
    ///
    func nonFatalError(domain: String, message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        let error = makeNSError(domain: domain, additionalUserInfo: ["Message": message], file: file, function: function, line: line)
        nonFatalError(error)
    }

    /// `NSError`オブジェクトを作成する
    ///
    /// - Parameters:
    ///   - domain: エラードメイン
    ///   - additionalUserInfo: 追加のユーザー情報
    ///   - file: ソースファイル名
    ///   - function: 関数名
    ///   - line: 行番号
    /// - Returns: 作成された`NSError`オブジェクト
    private func makeNSError(domain: String, additionalUserInfo: [String: Any], file: String, function: String, line: UInt) -> NSError {
        let fileName = (file.description as NSString).lastPathComponent
        let errorLocation = "\(fileName).\(function) L\(line)"
        var userInfo: [String: Any] = [
            "ErrorLocation": errorLocation
        ]

        return NSError(
            domain: domain,
            code: 0,
            // マージ時にキーが重複したら additionalUserInfo の値を優先する
            userInfo: userInfo.merging(additionalUserInfo, uniquingKeysWith: { $1 })
        )
    }
}

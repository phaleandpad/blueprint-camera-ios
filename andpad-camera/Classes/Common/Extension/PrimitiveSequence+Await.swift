//
//  PrimitiveSequence+Await.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/08/30.
//

import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {
    /// Swift Concurrency から RxSwift の Single に変換する
    /// - Parameter task: Swift Concurrencyによる処理
    /// - Returns: RxSwiftのSingle
    static func fromAwait(task: @escaping () async throws -> Element) -> Single<Element> {
        Single<Element>.create { observer in
            let task = Task {
                do {
                    let value = try await task()
                    observer(.success(value))
                } catch {
                    observer(.failure(error))
                }
            }

            return Disposables.create { task.cancel() }
        }
    }

    /// RxSwift から Swift Concurrency の処理に変換する（Throwing）
    /// - Returns: Swift Concurrency の処理
    func toAwaitThrowing() async throws -> Element {
        try await withCheckedThrowingContinuation { continuation in
            _ = self.subscribe(
                onSuccess: { continuation.resume(returning: $0) },
                onFailure: { continuation.resume(throwing: $0) }
            )
        }
    }

    /// RxSwift から Swift Concurrency の処理に変換する
    /// - Returns: Swift Concurrency の処理
    func toAwait() async -> Element {
        await withCheckedContinuation { continuation in
            _ = self.subscribe(
                onSuccess: { continuation.resume(returning: $0) }
            )
        }
    }
}

//
//  JavaScriptBridge.swift
//  andpad-camera
//
//  Created by Mitsuharu Emoto on 2024/06/26.
//

import Foundation
import JavaScriptCore

/**
 JavaScript ライブラリを Swift から実行するクラス

 @note
 SVG製の黒板を作成する際に渡すクエリーをAndroidと共有化するため、jsのライブラリ qs ( https://www.npmjs.com/package/qs ) のstringifyを実行させる
 
 @example
 ```swift
 let bridge = JavaScriptBridge()
 let result = try bridge.stringify(jsonString: jsonString)
 ```
 
 @note
 Module.bundle.js はこちらにアップロードしています
 https://88-oct.atlassian.net/browse/KOKUBAN-6118?focusedCommentId=144669
 
 JavaScript ライブラリを Swift から実行する方法はこちら（もしくは iOSDC Japan 2024 のパンフ記事を参照）
 https://speakerdeck.com/mitsuharu/2024-05-17-javascript-multiplatform
 */
public final class JavaScriptBridge {
    
    public enum BridgeError: Error {
        case bundleFound
        case evaluateScriptFailed(message: String)
        case functionFailed(message: String)
    }
    
    private let context = JSContext(virtualMachine: JSVirtualMachine())!
    private var bridge: JSValue?
    private let bundleFileName = "Module.bundle.js"
    private let moduleName = "Module"
    private let bundleName = "Bridge"
    
    init() {
        do {
            try setUp()
        } catch {
            assertionFailure("It failed to initialize JavaScriptBridge.")
        }
    }
    
    private func setUp() throws {
        // バンドルされた js ファイルを取得する
        guard
            let url = Bundle.andpadCamera.url(forResource: bundleFileName, withExtension: nil),
            let contents = try? String(contentsOf: url)
        else {
            throw BridgeError.bundleFound
        }
                
        // バンドルされた js ファイルの読み込み
        context.evaluateScript(contents)
        if let exception = context.exception {
            let message = exception.toString() ?? ""
            context.exception = nil
            throw BridgeError.evaluateScriptFailed(message: message)
        }
        
        // ブリッヂを取得する
        guard
            let module = context.objectForKeyedSubscript(moduleName),
            let bridge = module.objectForKeyedSubscript(bundleName)
        else {
            throw BridgeError.bundleFound
        }
        self.bridge = bridge
    }
    
    private func getFunction(name: String) -> JSValue? {
        guard
            let bridge,
            let function = bridge.objectForKeyedSubscript(name)
        else {
            return nil
        }
        return function
    }
    
    public func stringify(jsonString: String) throws -> String {
        let functionName = "stringify"
        guard let function = getFunction(name: functionName) else {
            throw BridgeError.functionFailed(message: "\(functionName) is not found")
        }
        
        let result = function.call(withArguments: [jsonString])
        if let exception = context.exception {
            let message = exception.toString() ?? ""
            context.exception = nil
            throw BridgeError.functionFailed(message: message)
        }
        
        guard let parameter = result?.toString() else {
            throw BridgeError.functionFailed(message: "result is failed")
        }
        return parameter
    }
}

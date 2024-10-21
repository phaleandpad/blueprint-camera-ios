//
//  JavaScriptBridgeTests.swift
//  andpad-camera_Tests
//
//  Created by 江本 光晴 on 2024/06/26.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import XCTest
@testable import andpad_camera

/**
 JavaScriptBridgeに関するテスト
 */
final class JavaScriptBridgeTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    /**
     jsのバンドルファイルが適切に追加さえているか
     */
    func testJsBundleFileExists() throws {
        let fileName = "Module.bundle.js"
        
        // リソース内にバンドルファイルがあるか
        guard let url = Bundle.andpadCamera.url(forResource: fileName, withExtension: nil) else {
            XCTFail("\(fileName) is not found.")
            return
        }
        
        // バンドルファイルが読み込めるか
        guard let _ = try? String(contentsOf: url) else {
            XCTFail("\(fileName) can be not loaded.")
            return
        }
    }
    
    /**
     stringify関数が適切に動作するか
     */
    func testJavaScriptBridgeStringify() throws {
        do {
            let patterns: [(json: String, expected: String)] = [
                (
                    json: "{\"a\": \"b\"}",
                    expected: "a=b"
                ),
                (
                    json: "{\"a\": { \"b\": \"c\" }}",
                    expected: "a%5Bb%5D=c"
                ),
                (
                    json: "{\"a\": \"b\", \"c\": [\"d\", \"e=f\"], \"f\": [[\"g\"], [\"h\"]]}",
                    expected: "a=b&c%5B0%5D=d&c%5B1%5D=e%3Df&f%5B0%5D%5B0%5D=g&f%5B1%5D%5B0%5D=h"
                ),
            ]
            let bridge = JavaScriptBridge()
            for (json, expected) in patterns {
                do {
                    let result = try bridge.stringify(jsonString: json)
                    XCTAssertEqual(result, expected)
                } catch {
                    XCTFail(error.localizedDescription)
                }
            }
        }
    }
    
    /**
     stringify関数がBlackboardPropsを対象に適切に動作するか
     */
    func testJavaScriptBridgeStringifyBlackboardProps() throws {
        do {
            // BlackboardProps向けの入力と評価の文字列が長すぎるので、別ファイルに書き出して検証してます
            guard
                let jsonString = readTextFile(named: "JavaScriptBridgeTests_JSON.txt"),
                let expected = readTextFile(named: "JavaScriptBridgeTests_Expected.txt")
            else {
                XCTFail()
                return
            }
            let bridge = JavaScriptBridge()
            let result = try bridge.stringify(jsonString: jsonString)
            XCTAssertEqual(result, expected)
        } catch {
            XCTFail()
        }
    }
}


private extension JavaScriptBridgeTests {
    
    func readTextFile(named fileName: String) -> String? {
        let bundle = Bundle(for: type(of: self))
        guard let fileURL = bundle.url(forResource: fileName, withExtension: nil) else {
            XCTFail("\(fileName) is not found.")
            return nil
        }
        do {
            // 不要な改行コードを削除する
            let contents = try String(contentsOf: fileURL, encoding: .utf8).trimmingCharacters(in: .newlines)
            return contents
        } catch {
            XCTFail("\(fileName) can be not loaded.")
            return nil
        }
    }
}

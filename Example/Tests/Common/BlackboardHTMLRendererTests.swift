//
//  BlackboardHTMLRendererTests.swift
//  andpad-camera_Tests
//
//  Created by 江本 光晴 on 2024/06/04.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import XCTest
@testable import andpad_camera

/**
 黒板をSVGで画像化するクラスのテスト
 
 @note
 exportImage のテストを行なっていましたが、index.html の構成が変わったためか、
 「クリーンビルドしてテストだと失敗、その後にテストをすると成功」とよく分からない状況になった。
 そのため、exportImage のテストはオミットした。
 */
final class BlackboardHTMLRendererTests: XCTestCase {
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testLoadIndexHtml() async throws {
        // 画像化に必要な index.html がバンドルされているか確認する
        guard let _ = Bundle.andpadCamera.url(forResource: "index.html", withExtension: nil) else {
            XCTFail()
            return
        }
    }
}

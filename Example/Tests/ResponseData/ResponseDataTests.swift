//
//  ResponseDataTests.swift
//  andpad-camera_Tests
//
//  Created by Yuka Kobayashi on 2021/04/22.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick

final class ResponseDataTests: QuickSpec {

    override class func spec() {

        describe("ResponseDataのパース") {
            context("dataの下にobjectが存在するjsonを読み込んだとき") {
                let jsonString = """
                {
                    "data": {
                        "object": { "id": 99, "name": "sample" }
                    }
                }
                """

                guard let subject = try? decode(jsonString) else {
                    XCTFail("Faild to decode json")
                    return
                }

                it("各propertyに正しい値が入っている") {
                    expect(subject.data.object?.number).to(equal(99))
                    expect(subject.data.object?.string).to(equal("sample"))
                    expect(subject.data.objects).to(beNil())
                    expect(subject.data.lastFlg).to(beNil())
                }
            }

            context("dataの下にobjectsが存在するjsonを読み込んだとき") {
                let jsonString = """
                {
                    "data": {
                        "objects": [
                            { "id": 55, "name": "sample1" },
                            { "id": 99, "name": "sample2" }
                        ]
                    }
                }
                """

                guard let subject = try? decode(jsonString) else {
                    XCTFail("Faild to decode json")
                    return
                }

                it("各propertyに正しい値が入っている") {
                    expect(subject.data.objects).to(haveCount(2))
                    expect(subject.data.objects?.first?.number).to(equal(55))
                    expect(subject.data.objects?.first?.string).to(equal("sample1"))
                    expect(subject.data.object).to(beNil())
                    expect(subject.data.lastFlg).to(beNil())
                }
            }

            context("dataの下にlast_flgが存在するjsonを読み込んだとき") {
                let jsonString = """
                {
                    "data": {
                        "last_flg": true
                    }
                }
                """

                guard let subject = try? decode(jsonString) else {
                    XCTFail("Faild to decode json")
                    return
                }

                it("各propertyに正しい値が入っている") {
                    expect(subject.data.lastFlg).to(beTrue())
                    expect(subject.data.object).to(beNil())
                    expect(subject.data.objects).to(beNil())
                }
            }

            context("dataの下にキーが存在しないjsonを読み込んだとき") {
                let jsonString = """
                {
                    "data": {}
                }
                """

                guard let subject = try? decode(jsonString) else {
                    XCTFail("Faild to decode json")
                    return
                }

                it("各propertyに正しい値が入っている") {
                    expect(subject.data.object).to(beNil())
                    expect(subject.data.objects).to(beNil())
                    expect(subject.data.lastFlg).to(beNil())
                }
            }

            context("dataが存在しないjsonを読み込んだとき") {
                let jsonString = "{}"

                it("decodeに失敗する") {
                    expect({ try decode(jsonString) }).to(throwError())
                }
            }
        }

        struct SomeResult: Codable {
            let number: Int
            let string: String
        }

        func decode(_ jsonString: String) throws -> ResponseData<SomeResult> {
            return try JSONDecoder().decode(
                ResponseData<SomeResult>.self,
                from: jsonString.data(using: .utf8)!
            )
        }
    }
}

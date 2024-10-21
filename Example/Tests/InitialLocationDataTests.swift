//
//  InitialLocationDataTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2021/09/29.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick

final class InitialLocationDataTests: QuickSpec {
    override class func spec() {
        describe("InitialLocationData") {
            context("位置 / サイズがセットされた状態でencode / decodeした場合") {
                it("元データと等価か") {
                    // arrange
                    let data = ModernBlackboardConfiguration.InitialLocationData(
                        centerPosition: .init(x: 10, y: 20),
                        size: .init(width: 300, height: 225),
                        isLockedRotation: false,
                        orientation: nil,
                        sizeType: .medium
                    )

                    // act
                    guard let encodedData = try? JSONEncoder().encode(data),
                          let decodedData = try? JSONDecoder().decode(ModernBlackboardConfiguration.InitialLocationData.self, from: encodedData) else {
                        fail("cannot encodeing or decoding.")
                        return
                    }

                    // assert
                    expect(decodedData.centerPosition).to(equal(CGPoint(x: 10, y: 20)))
                    expect(decodedData.size).to(equal(CGSize(width: 300, height: 225)))
                    expect(decodedData.orientation).to(beNil())
                    expect(decodedData.isLockedRotation).to(equal(false))
                    expect(decodedData.sizeType).to(equal(.medium))
                    expect(decodedData.frame).toNot(beNil())
                }
            }

            context("位置 / サイズ / 傾き / 傾きロックがセットされた状態でencode / decodeした場合") {
                it("元データと等価か") {
                    // arrange
                    let data = ModernBlackboardConfiguration.InitialLocationData(
                        centerPosition: .init(x: 10, y: 20),
                        size: .init(width: 300, height: 225),
                        isLockedRotation: true,
                        orientation: .landscapeLeft,
                        sizeType: .small
                    )

                    // act
                    guard let encodedData = try? JSONEncoder().encode(data),
                          let decodedData = try? JSONDecoder().decode(ModernBlackboardConfiguration.InitialLocationData.self, from: encodedData) else {
                        fail("cannot encodeing or decoding.")
                        return
                    }

                    // assert
                    expect(decodedData.centerPosition).to(equal(CGPoint(x: 10, y: 20)))
                    expect(decodedData.size).to(equal(CGSize(width: 300, height: 225)))
                    expect(decodedData.orientation).to(equal(.landscapeLeft))
                    expect(decodedData.isLockedRotation).to(equal(true))
                    expect(decodedData.sizeType).to(equal(.small))
                    expect(decodedData.frame).toNot(beNil())
                }
            }
        }
    }
}

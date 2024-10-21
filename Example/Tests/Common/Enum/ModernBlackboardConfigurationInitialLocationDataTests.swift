//
//  ModernBlackboardConfigurationInitialLocationDataTests.swift
//  andpad-camera_Tests
//
//  Created by 成瀬 未春 on 2023/12/01.
//  Copyright © 2023 ANDPAD Inc. All rights reserved.
//

import Nimble
import Quick
import XCTest

@testable import andpad_camera

final class ModernBlackboardConfigurationInitialLocationDataTests: QuickSpec {
    override class func spec() {
        describe("黒板のサイズが") {
            context("黒板の短辺が85で長辺が106の場合") {
                it("適切である") {
                    let locationData1 = dummyLocationData(size: CGSize(width: 106, height: 85))
                    expect(locationData1.isBlackboardSizeValid()).to(beTrue())

                    let locationData2 = dummyLocationData(size: CGSize(width: 85, height: 106))
                    expect(locationData2.isBlackboardSizeValid()).to(beTrue())
                }
            }
            context("黒板の短辺が86で長辺が106の場合") {
                it("適切である") {
                    let locationData1 = dummyLocationData(size: CGSize(width: 106, height: 86))
                    expect(locationData1.isBlackboardSizeValid()).to(beTrue())

                    let locationData2 = dummyLocationData(size: CGSize(width: 86, height: 106))
                    expect(locationData2.isBlackboardSizeValid()).to(beTrue())
                }
            }
            context("黒板の短辺が85で長辺が107の場合") {
                it("適切である") {
                    let locationData1 = dummyLocationData(size: CGSize(width: 107, height: 85))
                    expect(locationData1.isBlackboardSizeValid()).to(beTrue())

                    let locationData2 = dummyLocationData(size: CGSize(width: 85, height: 107))
                    expect(locationData2.isBlackboardSizeValid()).to(beTrue())
                }
            }
            context("黒板の短辺が84で長辺が106の場合") {
                it("不適切である") {
                    let locationData1 = dummyLocationData(size: CGSize(width: 106, height: 84))
                    expect(locationData1.isBlackboardSizeValid()).to(beFalse())

                    let locationData2 = dummyLocationData(size: CGSize(width: 84, height: 106))
                    expect(locationData2.isBlackboardSizeValid()).to(beFalse())
                }
            }
            context("黒板の短辺が85で長辺が105の場合") {
                it("不適切である") {
                    let locationData1 = dummyLocationData(size: CGSize(width: 105, height: 85))
                    expect(locationData1.isBlackboardSizeValid()).to(beFalse())

                    let locationData2 = dummyLocationData(size: CGSize(width: 85, height: 105))
                    expect(locationData2.isBlackboardSizeValid()).to(beFalse())
                }
            }
        }

        /// テスト用のダミーデータ
        /// - Parameter size: サイズ
        /// - Returns: テスト用のダミーデータ
        func dummyLocationData(size: CGSize) -> ModernBlackboardConfiguration.InitialLocationData {
            return ModernBlackboardConfiguration.InitialLocationData(
                centerPosition: .zero,
                size: size,
                isLockedRotation: false,
                orientation: .portrait,
                sizeType: .medium
            )
        }
    }
}

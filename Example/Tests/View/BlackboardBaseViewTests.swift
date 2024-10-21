//
//  BlackboardBaseViewTests.swift
//  andpad-camera_Tests
//
//  Created by 成瀬 未春 on 2024/05/17.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import Nimble
import Quick

@testable import andpad_camera

final class BlackboardBaseViewTests: QuickSpec {
    override class func spec() {
        let blackboardBaseView = BlackboardBaseView()

        describe("与えられたフレームをカメラのキャプチャエリアの境界内に収まるよう調整して、フレームを返す") {
            let aspectRatio = CGSize(width: 30, height: 23)
            let prohibitArea = CGRect(x: 10, y: 10, width: 300, height: 600)
            let targetSize = CGSize(width: 90, height: 69)

            context("左端にはみ出した場合") {
                // NOTE: サイズはアスペクト比が維持された状態で渡される
                let targetFrame = CGRect(
                    origin: .init(x: 9, y: 20),
                    size: targetSize
                )
                expect(targetFrame.origin.x).to(beLessThan(10))

                it("左上の角を掴んでいる場合") {
                    let actualFrame = blackboardBaseView.adjustedFrameToFitWithinProhibitArea(
                        targetFrame: targetFrame,
                        prohibitArea: prohibitArea,
                        grabbingCorner: .topLeft,
                        aspectRatio: aspectRatio
                    )

                    // 左端がprohibitAreaの左端と一致すること
                    expect(actualFrame.origin.x).to(equal(10))
                    // 掴んでいる角の対角の座標が変化していないこと
                    expect(CGPoint(x: actualFrame.maxX, y: actualFrame.maxY)).to(equal(CGPoint(x: targetFrame.maxX, y: targetFrame.maxY)))
                }

                it("左下の角を掴んでいる場合") {
                    let actualFrame = blackboardBaseView.adjustedFrameToFitWithinProhibitArea(
                        targetFrame: targetFrame,
                        prohibitArea: prohibitArea,
                        grabbingCorner: .bottomLeft,
                        aspectRatio: aspectRatio
                    )

                    // 左端がprohibitAreaの左端と一致すること
                    expect(actualFrame.origin.x).to(equal(10))
                    // 掴んでいる角の対角の座標が変化していないこと
                    expect(CGPoint(x: actualFrame.maxX, y: actualFrame.minY)).to(equal(CGPoint(x: targetFrame.maxX, y: targetFrame.minY)))
                }
            }

            context("下端にはみ出した場合") {
                // NOTE: サイズはアスペクト比が維持された状態で渡される
                let targetFrame = CGRect(
                    // y: prohibitAreaの下端 - targetSize.height + はみ出し分
                    origin: .init(x: 20, y: 610 - 69 + 1),
                    size: targetSize
                )
                expect(targetFrame.maxY).to(beGreaterThan(610))

                it("左下の角を掴んでいる場合") {
                    let actualFrame = blackboardBaseView.adjustedFrameToFitWithinProhibitArea(
                        targetFrame: targetFrame,
                        prohibitArea: prohibitArea,
                        grabbingCorner: .bottomLeft,
                        aspectRatio: aspectRatio
                    )

                    // 下端がprohibitAreaの下端と一致すること
                    expect(actualFrame.maxY).to(equal(610))
                    // 掴んでいる角の対角の座標が変化していないこと
                    expect(CGPoint(x: actualFrame.maxX, y: actualFrame.minY)).to(equal(CGPoint(x: targetFrame.maxX, y: targetFrame.minY)))
                }

                it("右下の角を掴んでいる場合") {
                    let actualFrame = blackboardBaseView.adjustedFrameToFitWithinProhibitArea(
                        targetFrame: targetFrame,
                        prohibitArea: prohibitArea,
                        grabbingCorner: .bottomRight,
                        aspectRatio: aspectRatio
                    )

                    // 下端がprohibitAreaの下端610と一致すること
                    expect(actualFrame.maxY).to(equal(610))
                    // 掴んでいる角の対角の座標が変化していないこと
                    expect(CGPoint(x: actualFrame.minX, y: actualFrame.minY)).to(equal(CGPoint(x: targetFrame.minX, y: targetFrame.minY)))
                }
            }

            context("右端にはみ出した場合") {
                // NOTE: サイズはアスペクト比が維持された状態で渡される
                let targetFrame = CGRect(
                    // x: prohibitAreaの右端 - targetSize.width + はみ出し分
                    origin: .init(x: 310 - 90 + 1, y: 20),
                    size: targetSize
                )
                expect(targetFrame.maxX).to(beGreaterThan(310))

                it("右下の角を掴んでいる場合") {
                    let actualFrame = blackboardBaseView.adjustedFrameToFitWithinProhibitArea(
                        targetFrame: targetFrame,
                        prohibitArea: prohibitArea,
                        grabbingCorner: .bottomRight,
                        aspectRatio: aspectRatio
                    )

                    // 右端がprohibitAreaの右端と一致すること
                    expect(actualFrame.maxX).to(equal(310))
                    // 掴んでいる角の対角の座標が変化していないこと
                    expect(CGPoint(x: actualFrame.minX, y: actualFrame.minY)).to(equal(CGPoint(x: targetFrame.minX, y: targetFrame.minY)))
                }

                it("右上の角を掴んでいる場合") {
                    let actualFrame = blackboardBaseView.adjustedFrameToFitWithinProhibitArea(
                        targetFrame: targetFrame,
                        prohibitArea: prohibitArea,
                        grabbingCorner: .topRight,
                        aspectRatio: aspectRatio
                    )

                    // 右端がprohibitAreaの右端と一致すること
                    expect(actualFrame.maxX).to(equal(310))
                    // 掴んでいる角の対角の座標が変化していないこと
                    expect(CGPoint(x: actualFrame.minX, y: actualFrame.maxY)).to(equal(CGPoint(x: targetFrame.minX, y: targetFrame.maxY)))
                }
            }

            context("上端にはみ出した場合") {
                // NOTE: サイズはアスペクト比が維持された状態で渡される
                let targetFrame = CGRect(
                    origin: .init(x: 20, y: 9),
                    size: targetSize
                )
                expect(targetFrame.origin.y).to(beLessThan(10))

                it("左上の角を掴んでいる場合") {
                    let actualFrame = blackboardBaseView.adjustedFrameToFitWithinProhibitArea(
                        targetFrame: targetFrame,
                        prohibitArea: prohibitArea,
                        grabbingCorner: .topLeft,
                        aspectRatio: aspectRatio
                    )

                    // 上端がprohibitAreaの上端と一致すること
                    expect(actualFrame.origin.y).to(equal(10))
                    // 掴んでいる角の対角の座標が変化していないこと
                    expect(CGPoint(x: actualFrame.maxX, y: actualFrame.maxY)).to(equal(CGPoint(x: targetFrame.maxX, y: targetFrame.maxY)))
                }

                it("右上の角を掴んでいる場合") {
                    let actualFrame = blackboardBaseView.adjustedFrameToFitWithinProhibitArea(
                        targetFrame: targetFrame,
                        prohibitArea: prohibitArea,
                        grabbingCorner: .topRight,
                        aspectRatio: aspectRatio
                    )

                    // 上端がprohibitAreaの上端と一致すること
                    expect(actualFrame.origin.y).to(equal(10))
                    // 掴んでいる角の対角の座標が変化していないこと
                    expect(CGPoint(x: actualFrame.minX, y: actualFrame.maxY)).to(equal(CGPoint(x: targetFrame.minX, y: targetFrame.maxY)))
                }
            }
        }
    }
}

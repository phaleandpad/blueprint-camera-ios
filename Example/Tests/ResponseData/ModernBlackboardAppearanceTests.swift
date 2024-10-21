//
//  ModernBlackboardAppearanceTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2022/07/14.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick

// MARK: - ModernBlackboardAppearanceTests

final class ModernBlackboardAppearanceTests: QuickSpec {
    override class func spec() {
        func someModernBlackboardAppearance(
            theme: ModernBlackboardAppearance.Theme = .black,
            alphaLevel: ModernBlackboardAppearance.AlphaLevel = .zero,
            dateFormatType: ModernBlackboardCommonSetting.DateFormatType = .withSlash,
            memoStyleArguments: ModernBlackboardMemoStyleArguments? = .init(
                textColor: ModernBlackboardAppearance.Theme.black.textColor,
                adjustableMaxFontSize: .small,
                verticalAlignment: .top,
                horizontalAlignment: .left
            ),
            shouldBeReflectedNewLine: Bool = false
        ) -> ModernBlackboardAppearance {
            return .init(
                theme: theme,
                alphaLevel: alphaLevel,
                dateFormatType: dateFormatType,
                memoStyleArguments: memoStyleArguments,
                shouldBeReflectedNewLine: shouldBeReflectedNewLine
            )
        }

        // MARK: .matchesAppearance(with:) のテスト

        describe("黒板アピアランスデータ同士の比較") {
            // MARK: - 一致

            context("完全一致するデータ同士を比較したとき") {
                it("一致の判定が返ること") {
                    let appearance01 = someModernBlackboardAppearance()
                    let appearance02 = someModernBlackboardAppearance()

                    expect(appearance01.matchesAppearance(with: appearance02)).to(beTrue())
                }
            }

            context("shouldBeReflectedNewLineが異なるデータ同士を比較したとき") {
                it("一致の判定が返ること") {
                    let appearance01 = someModernBlackboardAppearance(shouldBeReflectedNewLine: false)
                    let appearance02 = someModernBlackboardAppearance(shouldBeReflectedNewLine: true)

                    expect(appearance01.matchesAppearance(with: appearance02)).to(beTrue())
                }
            }

            // MARK: - 不一致

            context("themeが異なるデータ同士を比較したとき") {
                it("不一致の判定が返ること") {
                    let appearance01 = someModernBlackboardAppearance(theme: .black)
                    let appearance02 = someModernBlackboardAppearance(theme: .green)

                    expect(appearance01.matchesAppearance(with: appearance02)).to(beFalse())
                }
            }

            context("alphaLevelが異なるデータ同士を比較したとき") {
                it("不一致の判定が返ること") {
                    let appearance01 = someModernBlackboardAppearance(alphaLevel: .zero)
                    let appearance02 = someModernBlackboardAppearance(alphaLevel: .half)

                    expect(appearance01.matchesAppearance(with: appearance02)).to(beFalse())
                }
            }

            context("dateFormatTypeが異なるデータ同士を比較したとき") {
                it("不一致の判定が返ること") {
                    let appearance01 = someModernBlackboardAppearance(dateFormatType: .withSlash)
                    let appearance02 = someModernBlackboardAppearance(dateFormatType: .withChineseChar)

                    expect(appearance01.matchesAppearance(with: appearance02)).to(beFalse())
                }
            }

            context("memoStyleArgumentsが異なるデータ同士を比較したとき") {
                it("不一致の判定が返ること") {
                    let appearance01 = someModernBlackboardAppearance(
                        memoStyleArguments: .init(
                            textColor: ModernBlackboardAppearance.Theme.black.textColor,
                            adjustableMaxFontSize: .small,
                            verticalAlignment: .top,
                            horizontalAlignment: .left
                        )
                    )
                    let appearance02 = someModernBlackboardAppearance(
                        memoStyleArguments: .init(
                            textColor: ModernBlackboardAppearance.Theme.green.textColor,
                            adjustableMaxFontSize: .medium,
                            verticalAlignment: .bottom,
                            horizontalAlignment: .right
                        )
                    )

                    expect(appearance01.matchesAppearance(with: appearance02)).to(beFalse())
                }
            }
        }
    }
}

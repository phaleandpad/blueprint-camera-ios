//
//  StringExtensionSpec.swift
//  andpad-camera_Tests
//
//  Created by Toru Kuriyama on 2023/08/02.
//  Copyright © 2023 ANDPAD Inc. All rights reserved.
//

import XCTest

@testable import andpad_camera
import XCTest
import Quick
import Nimble

final class StringExtensionSpec: QuickSpec {
    override class func spec() {
        // MARK: numberOfNewLines
        describe("numberOfNewLines") {
            context("文字列に改行が1個含まれる") {
                let targetText = "改行\nあり"
                it("1を返すこと") {
                    expect(targetText.numberOfNewLines).to(equal(1))
                }
            }

            context("文字列に改行が2個含まれる(うち1つは末尾に改行がある)") {
                let targetText = "改行\nあり\n"
                it("2を返すこと") {
                    expect(targetText.numberOfNewLines).to(equal(2))
                }
            }

            context("文字列に改行が含まれない") {
                let targetText = "改行なし"
                it("0を返すこと") {
                    expect(targetText.numberOfNewLines).to(equal(0))
                }
            }

            context("空文字") {
                let targetText = ""
                it("0を返すこと") {
                    expect(targetText.numberOfNewLines).to(equal(0))
                }
            }

        }

        // MARK: numberOfLines
        describe("numberOfLines") {
            context("1行") {
                let targetText = "改行なし"
                it("1を返すこと") {
                    expect(targetText.numberOfLines).to(equal(1))
                }
            }

            context("3行") {
                let targetText = "この\nテキストは\n3行"
                it("3を返すこと") {
                    expect(targetText.numberOfLines).to(equal(3))
                }
            }

            context("空文字") {
                let targetText = ""
                it("0を返すこと") {
                    expect(targetText.numberOfLines).to(equal(0))
                }
            }
        }
    }
}

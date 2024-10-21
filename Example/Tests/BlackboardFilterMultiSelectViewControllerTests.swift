//
//  BlackboardFilterMultiSelectViewControllerTests.swift
//  andpad-camera_Tests
//
//  Created by msano on 2022/02/28.
//  Copyright © 2022 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import Nimble
import Quick
import XCTest
import RxSwift
import RxCocoa

final class BlackboardFilterMultiSelectViewControllerTests: QuickSpec {
    override class func spec() {
        let someAppBaseRequestData: AppBaseRequestData = .init(
            deviceUUID: nil,
            osType: "",
            version: "",
            accessToken: "",
            sharedBundleId: "",
            apiBaseURLString: "",
            authenticatedDeviceUUID: ""
        )

        describe("画面表示時（test life cycle）") {
            context("通常通り画面を生成した際に") {
                it("検索窓が表示され、またナビバーなどにかかる形で表示されないこと") {
                    let viewController = AppDependencies.shared.modernBlackboardFilterMultiSelectViewController(
                        .init(
                            userID: 88888,
                            orderID: 99999,
                            blackboardItemBody: "hoge",
                            initialSelectedContents: [],
                            appBaseRequestData: someAppBaseRequestData,
                            filterDoneHandler: { _, _ in },
                            isOfflineMode: false,
                            filteringByPhoto: .all,
                            searchQuery: nil
                        )
                    )

                    let subviews = viewController.view.recursiveSubviews
                    let searchBar = try XCTUnwrap(subviews.first(where: { $0 is UISearchBar }) as? UISearchBar)

                    expect(searchBar.isHidden).to(beFalse())
                    expect(searchBar.frame.origin.y >= 0).to(beTrue())
                    // heightが44以上か ref: https://dev.classmethod.jp/articles/difference-height-on-ios14-build-by-xcode12/
                    expect(searchBar.bounds.size.height >= 44.0).to(beTrue())
                }
            }
        }
    }
}

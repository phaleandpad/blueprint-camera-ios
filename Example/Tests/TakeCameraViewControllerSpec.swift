//
//  TakeCameraViewControllerSpec.swift
//  andpad-camera_Tests
//
//  Created by Yuka Kobayashi on 2021/06/30.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

@testable import andpad_camera
import AndpadCore
import Nimble
import Quick
import XCTest

final class TakeCameraViewControllerSpec: QuickSpec {
    override class func spec() {
        do {
            try checkCanDoingTests()
        } catch {
            print(error)
            return
        }

        let timeOutDuration: NimbleTimeInterval = .seconds(20)

        describe("[HTMLを使わない従来の画像化]複数撮影可能かつ新黒板ON") {
            var subject: TakeCameraViewController!
            var _result: [(urls: TakeCameraViewController.ImageURLs, exif: NSDictionary, isBlackboardAttached: Bool, modernBlackboardMaterial: ModernBlackboardMaterial?, legacyBlackboardType: BlackBoardType?, appliedPhotoQuality: PhotoQuality?)]?

            beforeEach {
                _result = nil

                // HTMLで表示する黒板ではない、従来の黒板の場合でテストする。
                AndpadCameraDependencies.shared.setup(remoteConfigHandler: RemoteConfigHandlerStub(useBlackboardGeneratedWithSVG: false))

                subject = makeSubject(
                    defaultBlackboardMaterial: makeBlackboardMaterial(id: 111, theme: .black),
                    defaultBlackboardAppearance: .init(theme: .black, alphaLevel: .full, dateFormatType: .defaultValue, shouldBeReflectedNewLine: false),
                    completionHandler: { _, result, _ in _result = result }
                )

                UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController = subject
                expect(subject.view.hasSubview(with: BlackboardBaseView.self)).toEventually(beTrue(), timeout: timeOutDuration)
            }

            context("一度も撮影せずに「次へ」ボタンをタップした場合") {
                it("completionは0件") {
                    tapNextButton(in: subject)
                    expect(_result).toNotEventually(beNil())
                    expect(_result).to(haveCount(0))
                }
            }

            context("撮影をしてから「次へ」ボタンをタップした場合") {
                xit("撮影した順番通りに画像と新黒板が返ってくる") {}
            }
        }

        describe("[HTMLを使った画像化]複数撮影可能かつ新黒板ON") {
            var subject: TakeCameraViewController!
            var _result: [(urls: TakeCameraViewController.ImageURLs, exif: NSDictionary, isBlackboardAttached: Bool, modernBlackboardMaterial: ModernBlackboardMaterial?, legacyBlackboardType: BlackBoardType?, appliedPhotoQuality: PhotoQuality?)]?

            beforeEach {
                _result = nil

                // HTMLで表示する黒板の場合でテストする。
                AndpadCameraDependencies.shared.setup(remoteConfigHandler: RemoteConfigHandlerStub(useBlackboardGeneratedWithSVG: true))

                subject = makeSubject(
                    defaultBlackboardMaterial: makeBlackboardMaterial(id: 111, theme: .black),
                    defaultBlackboardAppearance: .init(theme: .black, alphaLevel: .full, dateFormatType: .defaultValue, shouldBeReflectedNewLine: false),
                    completionHandler: { _, result, _ in _result = result }
                )

                UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController = subject
                expect(subject.view.hasSubview(with: BlackboardBaseView.self)).toEventually(beTrue(), timeout: timeOutDuration)
            }

            context("一度も撮影せずに「次へ」ボタンをタップした場合") {
                it("completionは0件") {
                    tapNextButton(in: subject)
                    expect(_result).toNotEventually(beNil())
                    expect(_result).to(haveCount(0))
                }
            }

            context("撮影をしてから「次へ」ボタンをタップした場合") {
                xit("撮影した順番通りに画像と新黒板が返ってくる") {}
            }
        }

        // NOTE: シュミレータ実行時のみテストコードの評価を許可する
        // 実機ビルドに限りテストに失敗する事象があったため暫定処理をしている
        // ref: https://github.com/88labs/andpad-camera-ios/pull/215#issuecomment-881181004
        func checkCanDoingTests() throws {
            var isSimulator: Bool {
                #if targetEnvironment(simulator)
                return true
                #else
                return false
                #endif
            }
            try XCTSkipUnless(isSimulator, "[skip tests] these tests are simulator only.")
        }

        func tapNextButton(in subject: TakeCameraViewController) {
            subject.view.findButton(with: L10n.Camera.Button.next).first?.sendActions(for: .touchUpInside)
        }

        func makeBlackboardMaterial(
            id: Int,
            theme: ModernBlackboardAppearance.Theme
        ) -> ModernBlackboardMaterial {
            let items: [ModernBlackboardMaterial.Item] = [
                .init(itemName: "name1", body: "body1", position: 1),
                .init(itemName: "name2", body: "body2", position: 2),
                .init(itemName: "name3", body: "body3", position: 3),
                .init(itemName: "name4", body: "body4", position: 4),
                .init(itemName: "name5", body: "body5", position: 5),
                .init(itemName: "name6", body: "body6", position: 6),
                .init(itemName: "name7", body: "body7", position: 7)
            ]

            return .forTesting(
                id: id,
                blackboardTemplateID: 222,
                layoutTypeID: 3,
                photoCount: 0,
                blackboardTheme: theme,
                itemProtocols: items,
                blackboardTrees: [],
                miniatureMap: nil,
                snapshotData: nil,
                createdUser: nil,
                updatedUser: nil,
                createdAt: nil,
                updatedAt: nil
            )
        }

        func makeSubject(
            defaultBlackboardMaterial: ModernBlackboardMaterial,
            defaultBlackboardAppearance: ModernBlackboardAppearance,
            completionHandler: @escaping TakeCameraViewController.URLCompletionHandler
        ) -> TakeCameraViewController {
            return TakeCameraViewController.make(
                isOfflineMode: false,
                data: nil,
                appBaseRequestData: .init(
                    deviceUUID: nil,
                    osType: "",
                    version: "",
                    accessToken: "",
                    sharedBundleId: "",
                    apiBaseURLString: "",
                    authenticatedDeviceUUID: ""
                ),
                isBlackboardEnabled: true,
                modernBlackboardConfiguration: .enable(
                    .init(
                        orderID: 999,
                        defaultModernBlackboardMaterial: defaultBlackboardMaterial,
                        snapshotData: .init(userID: 999999, orderName: "", clientName: "", startDate: .init()),
                        appearance: defaultBlackboardAppearance,
                        initialLocationData: nil,
                        advancedOptions: [],
                        canEditBlackboardStyle: true,
                        blackboardSizeTypeOnServer: .free,
                        preferredPhotoFormat: .jpeg
                    )
                ),
                inspectionTemplateEnabled: false,
                completionHandler: completionHandler,
                preferredResizeConfiguration: .init(size: "2300x2300", compressionQuality: 0.8),
                photoQualityOptions: [.defaultStandard, .defaultHigh],
                initialPhotoQuality: .defaultStandard,
                cancelHandler: { _, _ in },
                permissionNotAuthorizedHandler: { _, _ in },
                storage: nil
            )
        }
    }
}

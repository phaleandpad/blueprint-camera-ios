//
//  RemoteConfigHandlerStub.swift
//  andpad-camera_Tests
//
//  Created by 成瀬 未春 on 2024/08/28.
//  Copyright © 2024 ANDPAD Inc. All rights reserved.
//

import andpad_camera
import Foundation

struct RemoteConfigHandlerStub: AndpadCameraDependenciesRemoteConfigProtocol {
    private let useBlackboardGeneratedWithSVG: Bool

    init(useBlackboardGeneratedWithSVG: Bool) {
        self.useBlackboardGeneratedWithSVG = useBlackboardGeneratedWithSVG
    }

    func fetchUseBlackboardGeneratedWithSVG() -> Bool {
        useBlackboardGeneratedWithSVG
    }
}

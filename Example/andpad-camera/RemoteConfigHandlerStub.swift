//
//  RemoteConfigHandlerStub.swift
//  andpad-camera_Example
//
//  Created by 成瀬 未春 on 2024/09/01.
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

//
//
//  AVCaptureVideoOrientation+Extension.swift
//  Pods
//
//  Created by Yosuke Nakamura on 2021/05/27.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//
//

import AVFoundation

extension AVCaptureVideoOrientation {
    var uiDeviceOrientation: UIDeviceOrientation {
        switch self {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        }
    }

    var rotateAngle: Double {
        switch self {
        case .landscapeLeft:
            return Double.pi / 2
        case .landscapeRight:
            return Double.pi / 2 * -1
        case .portrait:
            return 0
        case .portraitUpsideDown:
            return Double.pi
        }
    }
}

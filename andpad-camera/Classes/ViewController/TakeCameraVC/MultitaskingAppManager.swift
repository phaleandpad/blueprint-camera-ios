//
//  MultitaskingAppManager.swift
//  andpad-camera
//
//  Created by 佐藤俊輔 on 2022/03/14.
//

import Foundation
import AVFoundation

/// マルチタスキング対応アプリ（「図面2.0」）にて必要なものを集約したクラス
///
/// マルチタスキング対応アプリでは「画面の向きを固定できない」ため各orientaionを許容する仕組みにしなくてはいけない
final class MultitaskingAppManager {
    
    var currentOrientation: UIInterfaceOrientation = .portrait {
        didSet {
            switch currentOrientation {
            case .portrait:
                self.captureVideoPreviewLayer?.connection?.videoOrientation = .portrait
            case .portraitUpsideDown:
                self.captureVideoPreviewLayer?.connection?.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                self.captureVideoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
            case .landscapeRight:
                self.captureVideoPreviewLayer?.connection?.videoOrientation = .landscapeRight
            default:
                break
            }
        }
    }
    
    init() {
        currentOrientation = MultitaskingAppManager.detectOrientation() ?? .portrait
    }
    
    static func detectOrientation() -> UIInterfaceOrientation? {
        // ref: https://stackoverflow.com/a/61749704
        UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }
    
    // MEMO:
    // これはTakeCameraViewControllerで管理してもよかったが、
    // マルチタスキング対応アプリのみインスタンスとして保持したかったのでここに定義してある
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // 以下、回転時に黒板の情報を特定するための変数群
    var previousOrientation: UIInterfaceOrientation?
    var isBlackboardOn = true
    var isLockOn = true
    var previousBlackboardOrientation: UIDeviceOrientation = .portrait
    
    func detectVideoAspectRatio(videoDimensions: CMVideoDimensions) -> CGFloat {
        if let orientation = MultitaskingAppManager.detectOrientation() {
            switch orientation {
            case .portrait, .portraitUpsideDown:
                return CGFloat(videoDimensions.width) / CGFloat(videoDimensions.height)
            case .landscapeLeft, .landscapeRight:
                return CGFloat(videoDimensions.height) / CGFloat(videoDimensions.width)
            default:
                break
            }
        }
        
        assertionFailure("ここは基本通らないはずなのでそれぽい値で返す")
        return CGFloat(videoDimensions.width) / CGFloat(videoDimensions.height)
    }
    
    // 画像の向きを調整する必要があるので調整する（調整後の画像を返す）
    func adjustImageRotation(
        image: UIImage,
        cameraPosition: AVCaptureDevice.Position
    ) -> UIImage {
        if let orientation = MultitaskingAppManager.detectOrientation() {
            if cameraPosition == .back {
                switch orientation {
                case .portrait:
                    return image // 何もしない、でOK
                case .portraitUpsideDown:
                    return UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
                case .landscapeLeft:
                    return UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
                case .landscapeRight:
                    return UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
                default:
                    break
                }
            } else if cameraPosition == .front {
                switch orientation {
                case .portrait:
                    return image // 何もしない、でOK
                case .portraitUpsideDown:
                    return UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
                case .landscapeLeft:
                    return UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
                case .landscapeRight:
                    return UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
                default:
                    break
                }
            }
        }
        
        assertionFailure("ここは基本通らないはずなのでそのまま返す")
        return image
    }
    
    func detectBlackboardOrientation() -> UIDeviceOrientation {
        
        guard let previousOrientation else {
            return .portrait
        }
        
        if isLockOn == false {
            return .portrait
        }
        
        // まず正面からみたときの黒板の向きを、元の画面の向きと黒板の向きから求める
        var blackboardOrientationForFront: UIDeviceOrientation
        switch (previousOrientation, previousBlackboardOrientation) {
        case (.portrait, .portrait),
            (.landscapeLeft, .landscapeLeft),
            (.portraitUpsideDown, .portraitUpsideDown),
            (.landscapeRight, .landscapeRight):
            blackboardOrientationForFront = .portrait
        case (.portrait, .landscapeLeft),
            (.landscapeLeft, .portraitUpsideDown),
            (.portraitUpsideDown, .landscapeRight),
            (.landscapeRight, .portrait):
            blackboardOrientationForFront = .landscapeLeft
        case (.portrait, .portraitUpsideDown),
            (.landscapeLeft, .landscapeRight),
            (.portraitUpsideDown, .portrait),
            (.landscapeRight, .landscapeLeft):
            blackboardOrientationForFront = .portraitUpsideDown
        case (.portrait, .landscapeRight),
            (.landscapeRight, .portraitUpsideDown),
            (.portraitUpsideDown, .landscapeLeft),
            (.landscapeLeft, .portrait):
            blackboardOrientationForFront = .landscapeRight
        default:
            return .portrait
        }
        
        // 最終的な黒板の向きを、端末の向きと正面からみたときの黒板の向きから求める
        switch (currentOrientation, blackboardOrientationForFront) {
        case (.portrait, .portrait),
            (.portraitUpsideDown, .portraitUpsideDown),
            (.landscapeLeft, .landscapeRight),
            (.landscapeRight, .landscapeLeft):
            return .portrait
        case (.portrait, .portraitUpsideDown),
            (.portraitUpsideDown, .portrait),
            (.landscapeLeft, .landscapeLeft),
            (.landscapeRight, .landscapeRight):
            return .portraitUpsideDown
        case (.portrait, .landscapeLeft),
            (.portraitUpsideDown, .landscapeRight),
            (.landscapeLeft, .portrait),
            (.landscapeRight, .portraitUpsideDown):
            return .landscapeLeft
        case (.portrait, .landscapeRight),
            (.portraitUpsideDown, .landscapeLeft),
            (.landscapeLeft, .portraitUpsideDown),
            (.landscapeRight, .portrait):
            return .landscapeRight
        default:
            return .portrait
        }
    }
    
    var currentAVCaptureVideoOrientation: AVCaptureVideoOrientation? {
        switch self.currentOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return nil
        }
    }
}

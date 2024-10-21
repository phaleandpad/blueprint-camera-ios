//
//  DummyCameraDriver.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2021/06/25.
//

import AVFoundation
import CoreGraphics
import Foundation
import RxCocoa
import RxSwift

#if DEBUG

final class DummyCameraDriver: CameraDriver {
    var device: AVCaptureDevice?

    enum CameraError: Error {
        case alreadyRunned
    }
    
    private(set) var position: AVCaptureDevice.Position = .back
    
    private let _didLockFocusAndExposure: PublishRelay<Void> = .init()
    var didLockFocusAndExposure: Signal<Void> {
        return _didLockFocusAndExposure.asSignal()
    }

    // NOTE:
    // ダミーなので、CameraDriverと同じ `AVCaptureSession` 型にする必要はないのだが、
    // 同じ方がCameraDriverとは比較しやすいかと思い、そのままとした
    private var captureSession: AVCaptureSession?
    
    func prepareCameraAndMakePreviewLayer(
        position: AVCaptureDevice.Position,
        orientationForMultitaskingApp: AVCaptureVideoOrientation? = nil,
        cameraType: CameraType = .single
    ) throws -> CameraDriverPrepareResult {

        guard captureSession == nil else {
            throw CameraError.alreadyRunned
        }

        let captureSession = AVCaptureSession()

        self.captureSession = captureSession

        self.position = position
        
        let layer = AVCaptureVideoPreviewLayer()
        let image = Asset.cameraPreview01.image
        layer.contents = image.cgImage
        
        return .init(
            isFlashAvailable: true,
            previewLayer: layer,
            videoDimentions: .init(
                width: Int32(image.size.width),
                height: Int32(image.size.height)
            )
        )
    }
    
    func destroyCamera() {
        captureSession = nil
    }
    func startRunning() {}
    func stopRunning() {}
    
    func capturePhoto(flashMode: AVCaptureDevice.FlashMode) -> Single<CaptureResult> {
        return .just((image: Asset.cameraPreview01.image, exif: .init()))
    }
    
    func updateScale(to newScale: CGFloat, with cameraType: CameraType) {}
    func updateFocusPoint(to newPoint: CGPoint) {}
    
    func lockFocusAndExposure(_ lock: Bool) {
        if lock {
            _didLockFocusAndExposure.accept(())
        }
    }
    
    func getISO() -> Float {
        return .zero
    }
    
    func updateISO(to newValue: Float, baseISO: Float) {}
    
    func blinkFlashlight() {}
    
    func turnOnFlashlight() {}
}

#endif

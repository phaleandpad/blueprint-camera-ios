//
//  CameraDriver.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2021/06/25.
//

import AVFoundation
import Foundation
import RxCocoa
import RxSwift

struct CameraDriverPrepareResult {
    let isFlashAvailable: Bool
    let previewLayer: AVCaptureVideoPreviewLayer
    let videoDimentions: CMVideoDimensions
}

enum CameraType {
    case single
    case dual
    case triple
    
    var deviceType: AVCaptureDevice.DeviceType {
        switch self {
        case .single:
            return .builtInWideAngleCamera
        case .dual:
            return .builtInDualWideCamera
        case .triple:
            return .builtInTripleCamera
        }
    }
    
    /// ズーム係数
    /// 広角カメラがある場合はvideoZoomFactorが1.0の時カメラ倍率が0.5倍のため
    var zoomCoefficient: Float {
        switch self {
        case .single:
            return 1.0
        case .dual, .triple:
            return 2.0
        }
    }
    
    /// ズーム幅
    /// 広角カメラがある場合は1倍~6.0倍
    /// 広角カメラがある場合は0.5倍~6.0倍
    var zoomRange: ClosedRange<Float> {
        switch self {
        case .single:
            return 1.0...6.0
        case .dual, .triple:
            return 0.5...6.0
        }
    }
    
    /// videoZoomFactorの値幅
    /// (ズーム幅 * ズーム係数)で値を求める
    ///
    /// MEMO: videoZoomFactorは乗数、かつこの値は1.0以上の値しか取らない
    /// 超広角カメラではこの値が1.0の時に倍率は0.5倍、2.0の時に倍率は1倍になる
    /// zoomCoefficientで倍率計算用に係数を定義して、然るべきところで計算している
    /// https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624611-videozoomfactor
    var zoomFactorRange: ClosedRange<Float> {
        return (zoomRange.lowerBound * zoomCoefficient)...(zoomRange.upperBound * zoomCoefficient)
    }
    
    static func preferred(for position: AVCaptureDevice.Position) -> Self {
        /// 対象のDeviceTypeがサポートされているかどうか
        func isSupported(deviceType: AVCaptureDevice.DeviceType) -> Bool {
            let supported = AVCaptureDevice.DiscoverySession(deviceTypes: [deviceType], mediaType: .video, position: .unspecified)
            return !supported.devices.isEmpty
        }
        
        /// 前面カメラの場合はシングルスケールのみサポート
        if position == .front {
            return .single
        } else if isSupported(deviceType: .builtInTripleCamera) {
            return .triple
        } else if isSupported(deviceType: .builtInDualWideCamera) {
            return .dual
        } else {
            return .single
        }
    }
}

protocol CameraDriver {
    typealias CaptureResult = (image: UIImage, exif: NSDictionary)

    var position: AVCaptureDevice.Position { get }
    var didLockFocusAndExposure: Signal<Void> { get }
    var device: AVCaptureDevice? { get }
    
    func prepareCameraAndMakePreviewLayer(
        position: AVCaptureDevice.Position,
        orientationForMultitaskingApp: AVCaptureVideoOrientation?,
        cameraType: CameraType
    ) throws -> CameraDriverPrepareResult
    func destroyCamera()

    func startRunning()
    func stopRunning()

    func capturePhoto(flashMode: AVCaptureDevice.FlashMode) -> Single<CaptureResult>

    func updateScale(to newScale: CGFloat, with cameraType: CameraType)

    func updateFocusPoint(to newPoint: CGPoint)
    func lockFocusAndExposure(_ lock: Bool)

    func getISO() -> Float
    func updateISO(to newValue: Float, baseISO: Float)
    
    func blinkFlashlight()
    func turnOnFlashlight()
}

final class SystemCameraDriver: NSObject, CameraDriver {
    enum CameraError: Error {
        case alreadyRunned
        case missingDevice
        case failToCapture
    }
    
    private(set) var position: AVCaptureDevice.Position = .back
    
    private let _didLockFocusAndExposure: PublishRelay<Void> = .init()
    var didLockFocusAndExposure: Signal<Void> {
        return _didLockFocusAndExposure.asSignal()
    }
    
    internal var device: AVCaptureDevice?
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    
    func prepareCameraAndMakePreviewLayer(
        position: AVCaptureDevice.Position,
        orientationForMultitaskingApp: AVCaptureVideoOrientation? = nil,
        cameraType: CameraType = .single
    ) throws -> CameraDriverPrepareResult {
        
        // マルチタスキング対応版ではcaptureSessionを生成しなおす
        if orientationForMultitaskingApp == nil {
            guard captureSession == nil else {
                throw CameraError.alreadyRunned
            }
        }
        
        guard let device = AVCaptureDevice.default(cameraType.deviceType, for: .video, position: position) else {
            throw CameraError.missingDevice
        }
        
        let captureSession = AVCaptureSession()
        
        self.captureSession = captureSession
        self.device = device
        self.position = position
        
        lockFocusAndExposure(false)
        
        let deviceInput = try AVCaptureDeviceInput(device: device)
        let photoOutput = AVCapturePhotoOutput()
        
        captureSession.sessionPreset = .photo
        
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            self.photoOutput = photoOutput
        }
        
        startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspect
        
        if let orientation = orientationForMultitaskingApp {
            previewLayer.connection?.videoOrientation = orientation
        }
        
        let videoDimensions = CMVideoFormatDescriptionGetDimensions(deviceInput.device.activeFormat.formatDescription)
        
        return .init(
            isFlashAvailable: device.isFlashAvailable,
            previewLayer: previewLayer,
            videoDimentions: videoDimensions
        )
    }
    
    func destroyCamera() {
        stopRunning()
        
        captureSession?.inputs.forEach {
            captureSession?.removeInput($0)
        }
        
        captureSession?.outputs.forEach {
            captureSession?.removeOutput($0)
        }
        
        captureSession = nil
        photoOutput = nil
    }
    
    func startRunning() {
        captureSession?.startRunning()
    }
    
    func stopRunning() {
        captureSession?.stopRunning()
    }
    
    private var _capturePhotoSubject: PublishSubject<CaptureResult>?

    func capturePhoto(flashMode: AVCaptureDevice.FlashMode) -> Single<CaptureResult> {
        
        let subject = PublishSubject<CaptureResult>()
        _capturePhotoSubject = subject
        
        return subject
            .do(onSubscribe: { [weak self] in
                guard let self else { return }
                
                let settings = AVCapturePhotoSettings()
                settings.flashMode = flashMode
                settings.isAutoStillImageStabilizationEnabled = true
                settings.isHighResolutionPhotoEnabled = false
                
                self.photoOutput?.capturePhoto(with: settings, delegate: self)
            }, onDispose: { [weak self] in
                self?._capturePhotoSubject = nil
            })
            .asSingle()
    }

    func updateScale(to newScale: CGFloat, with cameraType: CameraType) {
        let maxZoomFactor = CGFloat(cameraType.zoomFactorRange.upperBound)
        let minZoomFactor = CGFloat(cameraType.zoomFactorRange.lowerBound)
        let newZoomFactor = newScale * CGFloat(cameraType.zoomCoefficient)
        
        do {
            try device?.lockForConfiguration()
            
            // 最小値より小さく、最大値より大きくならないようにする
            device?.videoZoomFactor = max(min(newZoomFactor, maxZoomFactor), minZoomFactor)
            device?.unlockForConfiguration()
        } catch {
            // just ignore
        }
    }
    
    func lockFocusAndExposure(_ lock: Bool) {
        guard let device else { return }
        
        do {
            try device.lockForConfiguration()
            
            let focusMode: AVCaptureDevice.FocusMode = lock ? .locked : .continuousAutoFocus
            if device.isFocusModeSupported(focusMode) {
                device.focusMode = focusMode
            }
            
            let exposureMode: AVCaptureDevice.ExposureMode = lock ? .locked : .continuousAutoExposure
            if device.isExposureModeSupported(exposureMode) {
                device.exposureMode = exposureMode
            }
            
            device.unlockForConfiguration()
        } catch {
            // just ignore
        }
        
        if lock {
            _didLockFocusAndExposure.accept(())
        }
    }

    func updateFocusPoint(to newPoint: CGPoint) {
        guard let device else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = newPoint
            }
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = newPoint
            }
            
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            if !device.isExposureModeSupported(.custom) {
                device.setExposureTargetBias(0.0)
            }
            
            device.unlockForConfiguration()
        } catch {
            // just ignore
        }
    }
    
    func getISO() -> Float {
        return device?.iso ?? .zero
    }
    
    func updateISO(to newValue: Float, baseISO: Float) {
        guard let device else { return }
        
        do {
            try device.lockForConfiguration()
            // MEMO: シングルカメラはExposureMode.customがサポートされているのでISOを直接指定
            // それ以外はsetExposureTargetBiasでISOと露出時間を調整する
            if device.isExposureModeSupported(.custom),
               let iso = calculateISO(
                by: newValue,
                min: device.activeFormat.minISO,
                max: device.activeFormat.maxISO,
                baseISO: baseISO
               ) {
                
                device.exposureMode = .custom
                device.setExposureModeCustom(
                    duration: AVCaptureDevice.currentExposureDuration,
                    iso: iso,
                    completionHandler: nil
                )
            } else {
                let bias = exposureBias(
                    forSliderValue: newValue,
                    min: device.minExposureTargetBias,
                    max: device.maxExposureTargetBias
                )
                device.setExposureTargetBias(bias)
            }
            
            device.unlockForConfiguration()
        } catch {
            // just ignore
        }
    }
    
    private func calculateISO(
        by sliderValue: Float,
        min: Float,
        max: Float,
        baseISO: Float
    ) -> Float? {
        guard baseISO >= min,
              baseISO <= max else {
                  let message = "The passed ISO value \(baseISO) is outside the supported range"
                  AndpadCameraConfig.logger.nonFatalError(domain: "unsupportedISORangeError", additionalUserInfo: ["description": message])
                  assertionFailure(message)
                  return nil
              }
        let value = sliderValue * 100
        
        let median: Float = 50
        
        if value < median {
            let range = baseISO - min
            let deltaPerValue = range / median
            let delta = median - value
            let newValue = baseISO - (delta * deltaPerValue)
            return Float.maximum(newValue, min)
        } else {
            let range = max - baseISO
            let deltaPerValue = range / median
            let delta = value - median
            let newValue = baseISO + (delta * deltaPerValue)
            return Float.minimum(newValue, max)
        }
    }
    
    /// ExposureBiasを計算する
    /// sliderValueは0.0〜1.0のため、-1.0〜1.0のBiasに補正する
    private func exposureBias(
        forSliderValue sliderValue: Float,
        min: Float,
        max: Float
    ) -> Float {
        let bias = (sliderValue * 2) - 1.0
        if bias < min {
            return Float.maximum(bias, min)
        } else {
            return Float.minimum(bias, max)
        }
    }
}

extension SystemCameraDriver: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(
        _ captureOutput: AVCapturePhotoOutput,
        didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
        previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
        resolvedSettings: AVCaptureResolvedPhotoSettings,
        bracketSettings: AVCaptureBracketedStillImageSettings?,
        error: Error?
    ) {
        
        guard let photoSampleBuffer else {
            _capturePhotoSubject?.onError(CameraError.failToCapture)
            _capturePhotoSubject?.onCompleted()
            return
        }
        
        let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
            forJPEGSampleBuffer: photoSampleBuffer,
            previewPhotoSampleBuffer: previewPhotoSampleBuffer
        )
        
        guard let photoData,
              let image = UIImage(data: photoData),
              let exif = getEXIFFromImage(imageData: photoData) else {
            _capturePhotoSubject?.onError(CameraError.failToCapture)
            _capturePhotoSubject?.onCompleted()
            return
        }
        
        _capturePhotoSubject?.onNext((image: image, exif: exif))
        _capturePhotoSubject?.onCompleted()
    }
    
    private func getEXIFFromImage(imageData: Data) -> NSDictionary? {
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }
        
        return CGImageSourceCopyPropertiesAtIndex(
            imageSource,
            0,
            nil
        )
    }
    
    func blinkFlashlight() {
        guard let device, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = .on
            device.unlockForConfiguration()
            
            Task { @MainActor in
                try await Task.sleep(nanoseconds: UInt64(0.2 * Double(NSEC_PER_SEC)))
                
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
            }
        } catch {
            assertionFailure("Cannot enable Torch: \(error.localizedDescription)")
        }
    }
    
    func turnOnFlashlight() {
        guard let device, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = .on
            device.unlockForConfiguration()
        } catch {
            assertionFailure("Cannot enable Torch: \(error.localizedDescription)")
        }
    }
}

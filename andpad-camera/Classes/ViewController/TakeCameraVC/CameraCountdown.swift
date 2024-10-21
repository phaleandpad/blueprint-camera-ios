//
//  CameraCaptureCountdown.swift
//  andpad-camera
//
//  Created by Nguyen Ngoc Tam on 28/8/24.
//

import Foundation
import RxCocoa

enum CountdownPreset: CaseIterable, Identifiable {
    case none
    case threeSeconds
    case tenSeconds
    
    var id: Self {
        self
    }
    
    var duration: TimeInterval {
        switch self {
        case .none:
            0
        case .threeSeconds:
            3
        case .tenSeconds:
            10
        }
    }
}

final class CameraCountdown {
    enum State {
        case notRunning
        case running
        case completed
        case cancelled
    }
    
    /// The mode in which the flashlight operates.
    /// - `blink`: The flashlight will be turned on, then turned off after a brief period.
    /// - `continuous`: The flashlight will remain on continuously without turning off.
    enum FlashlightMode {
        case blink
        case continuous
    }
    
    let stateRelay = BehaviorRelay<State>(value: .notRunning)
    let flashlightModeRelay = PublishRelay<FlashlightMode>()
    let remainingDurationRelay = BehaviorRelay<TimeInterval>(value: 0)
    
    let preset: CountdownPreset
    let isFlashOn: Bool
    
    private var timer: Timer?
    private var flashlightSchedulerTask: Task<(), Error>?
    
    init(preset: CountdownPreset, isFlashOn: Bool) {
        self.preset = preset
        self.isFlashOn = isFlashOn
    }
    
    deinit {
        invalidateTimerAndCancelTasks()
    }
    
    func start() {
        guard stateRelay.value == .notRunning, preset != .none else { return }
        
        stateRelay.accept(.running)
        remainingDurationRelay.accept(preset.duration)
        turnOnFlashlight()
        
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true,
            block: { [weak self] _ in
                guard let self else { return }
                
                let remainingDuration = remainingDurationRelay.value - 1.0
                remainingDurationRelay.accept(remainingDuration)
                turnOnFlashlight()
                
                if remainingDuration == 0 {
                    completeCountdown()
                }
            }
        )
    }
    
    func cancel() {
        guard stateRelay.value != .cancelled else { return }
        
        invalidateTimerAndCancelTasks()
        stateRelay.accept(.cancelled)
    }
    
    private func completeCountdown() {
        invalidateTimerAndCancelTasks()
        stateRelay.accept(.completed)
    }
    
    private func invalidateTimerAndCancelTasks() {
        flashlightSchedulerTask?.cancel()
        flashlightSchedulerTask = nil
        timer?.invalidate()
        timer = nil
    }
    
    private func turnOnFlashlight() {
        let remainingTime = remainingDurationRelay.value
        guard remainingTime >= 1 else { return }
        
        if remainingTime == 1 {
            // Turn on the flashlight at the last second if the Flash option is on
            if isFlashOn {
                flashlightModeRelay.accept(.continuous)
            }
        } else {
            flashlightModeRelay.accept(.blink)
            
            // Blink the flashlight 2 times per second from the 3 ~ 1 second.
            if remainingTime <= 3 {
                flashlightSchedulerTask = Task { @MainActor in
                    try await Task.sleep(nanoseconds: 500_000_000) // Delay for 0.5 second
                    flashlightModeRelay.accept(.blink)
                }
            }
        }
    }
}

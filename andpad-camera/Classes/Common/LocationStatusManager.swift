//
//  LocationStatusManager.swift
//  andpad-camera
//
//  Created by 山本博 on 2024/06/26.
//

import Foundation
import CoreLocation

protocol LocationStatusManagerProtocol {
    func checkLocationPermission()
    func startUpdateLocation()
    func stopUpdateLocation()
}

public protocol LocationStatusManagerDelegate {
    func cameralocation(status: CLAuthorizationStatus)
    func cameralocation(coordinate: CLLocationCoordinate2D)
}

public class LocationStatusManager: NSObject {
        
    private let locationManager = CLLocationManager()
    private var latestCoodinate: CLLocationCoordinate2D?
    
    public var delegate: LocationStatusManagerDelegate?
    // [NOTE]
    // 基本的にはSingletonでの使用に制限をしていて、
    // このpermissionHandlerは使いたい時だけHandlerをセットして使用します。
    // ただ彼方此方で使用するとリソースの競合が発生します。
    // また、本クラス自体使用するケースは頻繁に起こるケースは考えにくいとは考えますが、
    // 使用方法に関しては注意が必要です。
    private var permissionHandler: ((CLAuthorizationStatus) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
}

extension LocationStatusManager: LocationStatusManagerProtocol {
    func checkLocationPermission() {
        let status = locationManager.authorizationStatus
        delegate?.cameralocation(status: status)
    }
    
    func startUpdateLocation() {
        if let latestCoodinate = latestCoodinate {
            delegate?.cameralocation(coordinate: latestCoodinate)
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationStatusManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latestCoodinate = locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first?.coordinate
        if let coordinate = latestCoodinate {
            delegate?.cameralocation(coordinate: coordinate)
            locationManager.stopUpdatingLocation()
        }
    }
}

//
//  NetworkReachabilityHandler.swift
//  andpad-camera
//
//  Created by msano on 2022/08/25.
//

import Alamofire

// MARK: - NetworkReachabilityHandler
final class NetworkReachabilityHandler {
    
    static let shared = NetworkReachabilityHandler()
    
    var status: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    var isOffline: Bool {
        switch status {
        case .unknown, .reachable:
            return false
        case .notReachable:
            return true
        }
    }
    
    init() {
        observe()
    }
    
    private let manager = NetworkReachabilityManager(host: "andpad.jp")
    
    private func observe() {
        guard let manager else { return }
        manager.stopListening()
        manager.startListening { [weak self] in self?.status = $0 }
    }
}

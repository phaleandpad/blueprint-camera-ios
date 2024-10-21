//
//  Movable.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/20.
//

import Foundation
protocol Movable {
    var moveEndPoint: CGPoint? { get set }
    var moveEnabled: Bool { get set }
    var updateDrawingItem: CGPoint? { get set }
    var moveCompletedHandler: ((Movable) -> Void)? { get set }
    
    func enableMove()
    func disableMove()
}

//
//  AppDelegate.swift
//  andpad-camera
//
//  Created by Toshihiro Taniguchi on 04/17/2018.
//  Copyright (c) 2018 ANDPAD Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()

        self.window = window

        return true
    }
}

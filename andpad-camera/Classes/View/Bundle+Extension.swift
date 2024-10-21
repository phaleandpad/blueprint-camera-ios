//
//  Bundle+Extension.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2020/11/24.
//

import UIKit

extension Bundle {
    static var andpadCamera: Bundle {
        let podBundle = Bundle(for: TakeCameraViewController.self)

        guard let bundleURL = podBundle.url(forResource: "andpad-camera", withExtension: "bundle"),
              let bundle = Bundle(url: bundleURL) else {
            fatalError("Missing bundle")
        }

        return bundle
    }

    func bundleIdentifier(appending label: String) -> String {
        let identifierPrefix: String = {

            if let bundleIdentifier = bundleIdentifier {
                return bundleIdentifier
            }

            assertionFailure()
            return ""
        }()

        return identifierPrefix + "." + label
    }
}

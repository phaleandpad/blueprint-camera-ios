//
//  ProcessInfo+Extension.swift
//  andpad-camera
//
//  Created by msano on 2020/11/05.
//

extension ProcessInfo {
    func isTest() -> Bool {
        return arguments.contains("test")
    }
}

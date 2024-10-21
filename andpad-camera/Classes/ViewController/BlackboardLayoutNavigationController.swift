//
//  ModernBlackboardNavigationController.swift
//  andpad-camera
//
//  Created by msano on 2020/12/10.
//

import UIKit

protocol  ModernBlackboardNavigationControllerProtocol {
    static var plainBackButton: UIBarButtonItem { get }
}

final class ModernBlackboardNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .lightTextColor
    }
}

// MARK: - ModernBlackboardNavigationControllerProtocol
extension ModernBlackboardNavigationController: ModernBlackboardNavigationControllerProtocol {
    static var plainBackButton = UIBarButtonItem(
        title: "",
        style: .plain,
        target: nil,
        action: nil
    )
}

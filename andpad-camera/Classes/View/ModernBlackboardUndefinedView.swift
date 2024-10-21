//
//  ModernBlackboardUndefinedView.swift
//  andpad-camera
//
//  Created by msano on 2022/10/11.
//

import Instantiate
import InstantiateStandard

final class ModernBlackboardUndefinedView: UIView {
    struct Dependency {}
}

// MARK: - NibType
extension ModernBlackboardUndefinedView: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernBlackboardUndefinedView: NibInstantiatable {
    func inject(_ dependency: Dependency) {}
}

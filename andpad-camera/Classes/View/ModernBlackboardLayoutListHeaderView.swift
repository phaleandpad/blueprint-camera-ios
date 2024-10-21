//
//  ModernBlackboardLayoutListHeaderView.swift
//  andpad-camera
//
//  Created by msano on 2022/09/09.
//

import Instantiate
import InstantiateStandard

final class ModernBlackboardLayoutListHeaderView: UICollectionReusableView {
    struct Dependency {}
    static let viewHeight: CGFloat = 79.0
}

// MARK: - NibType
extension ModernBlackboardLayoutListHeaderView: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension ModernBlackboardLayoutListHeaderView: Reusable {
    func inject(_ dependency: Dependency) {}
}

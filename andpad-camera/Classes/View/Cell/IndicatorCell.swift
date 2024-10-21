//
//  IndicatorCell.swift
//  andpad-camera
//
//  Created by msano on 2022/01/13.
//

import Instantiate
import InstantiateStandard

final class IndicatorCell: UITableViewCell {

    struct Dependency {}
    
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
}

// MARK: - NibType
extension IndicatorCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension IndicatorCell: Reusable {
    func inject(_ dependency: Dependency) {
        indicator.startAnimating()
    }
}

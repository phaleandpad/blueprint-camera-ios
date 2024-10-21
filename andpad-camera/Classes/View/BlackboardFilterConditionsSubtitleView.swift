//
//  BlackboardFilterConditionsSubtitleView.swift
//  andpad
//
//  Created by msano on 2021/11/16.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

final class BlackboardFilterConditionsSubtitleView: UIView {
    struct Dependency {}
    
    // IBOutlet
    @IBOutlet private weak var searchHistoryButton: UIButton!
}

// MARK: - subscribe対象
extension BlackboardFilterConditionsSubtitleView {
    var tappedSearchHistoryButton: Signal<Void> {
        searchHistoryButton.rx.tap.asSignal()
    }
}

// MARK: - NibType
extension BlackboardFilterConditionsSubtitleView: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension BlackboardFilterConditionsSubtitleView: NibInstantiatable {
    func inject(_ dependency: Dependency) {}
}

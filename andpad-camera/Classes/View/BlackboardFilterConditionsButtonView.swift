//
//  BlackboardFilterConditionsButtonView.swift
//  andpad
//
//  Created by msano on 2021/11/09.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

final class BlackboardFilterConditionsButtonView: UIView {
    struct Dependency {
        let viewType: ViewType
    }
    
    // IBOutlet
    @IBOutlet private weak var parentFilterLabelView: UIStackView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var counterUnitView: UIView!
    @IBOutlet private weak var counterUnitLabel: UILabel!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var childFilterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // In Japanese, we display a unit (the word ‘件’) next to the counter number. However, in some other languages like English and Vietnamese, there is no such unit. Therefore, we will check and hide this label if the unit text is not set or is empty to ensure the spacing is correct.
        counterUnitView.isHidden = counterUnitLabel.text?.isEmpty ?? true
    }
}

// MARK: - subscribe対象
extension BlackboardFilterConditionsButtonView {
    var tappedClearButton: Signal<Void> {
        clearButton.rx.tap.asSignal()
    }
    
    var tappedFilterButton: Signal<Void> {
        filterButton.rx.tap.asSignal()
    }
}

extension BlackboardFilterConditionsButtonView {
    func updateCounter(by count: Int) {
        counterLabel.text = count <= 9999 ? "\(count)" : "9999+"
    }
    
    func changeClearButtonState(isEnable: Bool) {
        clearButton.isEnabled = isEnable
        clearButton.buttonBorderColor = isEnable ? .gray222 : .grayBBB
    }
    
    enum ViewType {
        case parent
        case child
    }
}

// MARK: - private
extension BlackboardFilterConditionsButtonView {
    private func configure(with viewType: ViewType) {
        switch viewType {
        case .parent:
            parentFilterLabelView.isHidden = false
            childFilterLabel.isHidden = true
        case .child:
            parentFilterLabelView.isHidden = true
            childFilterLabel.isHidden = false
        }
    }
}

// MARK: - NibType
extension BlackboardFilterConditionsButtonView: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension BlackboardFilterConditionsButtonView: NibInstantiatable {
    func inject(_ dependency: Dependency) {
        configure(with: dependency.viewType)
    }
}

//
//  ColumnStackContainerView.swift
//  andpad-camera
//
//  Created by msano on 2022/02/21.
//

import RxSwift
import RxCocoa

extension ModernBlackboardItemInputsCell {
    
    // NOTE:
    // UIStackViewは背景色やボーダーが（iOS下位バージョンだと）表現できないため
    // ColumnStackViewを包むViewとして用意した
    //  -> heightやborder colorの更新はColumnStackView頼りで行っている
    
    final class ColumnStackContainerView: UIView {
        var columnStackView: ColumnStackView? {
            _columnStackView
        }
        
        private let disposeBag = DisposeBag()
        
        private var viewHeight: CGFloat = 0 {
            didSet {
                guard viewHeight > 0, viewHeight != oldValue else { return }
                layoutIfNeeded() // heightを更新させる
            }
        }
        
        private var _columnStackView: ColumnStackView? {
            didSet { addBinding() }
        }
        
        func configure(stackView: ColumnStackView) {
            layer.borderWidth = 1
            
            // set initial value (by column stack view)
            if let textViewBackgroundColor = stackView.textViewBackgroundColor {
                backgroundColor = textViewBackgroundColor
            }
            layer.borderColor = stackView.borderColor
            
            if !stackView.maskedCorners.isEmpty {
                cornerRadius = LayoutParams.normalInputCornerRadius
                layer.maskedCorners = stackView.maskedCorners
            }
            viewHeight = stackView.adjustedRowHeight.height
            
            addSubview(stackView)
            _columnStackView = stackView
            
            // set constraints
            snp.makeConstraints { make in
                make.edges.equalTo(stackView.snp.edges)
            }
        }
        
        // MARK: - private func
        private func addBinding() {
            guard let columnStackView = _columnStackView else { return }
            columnStackView.shouldAdjustHeightDriver
                .drive(onNext: { [weak self] in self?.viewHeight = $0.height })
                .disposed(by: disposeBag)
            
            columnStackView.changeBorderColorSignal
                .emit(onNext: { [weak self] in self?.layer.borderColor = $0 })
                .disposed(by: disposeBag)
        }
    }
}

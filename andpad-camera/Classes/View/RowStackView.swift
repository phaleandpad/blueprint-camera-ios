//
//  RowStackView.swift
//  andpad-camera
//
//  Created by msano on 2022/02/14.
//

import RxSwift
import RxCocoa

// MARK: - RowStackView
extension ModernBlackboardItemInputsCell {
    /// NOTE: 行単位（黒板項目名 / 黒板項目内容）でまとめたStackView
    final class RowStackView: UIStackView {
        
        enum RowDividingType {
            
            /// 項目名 + 項目値のペアとして区切られたrow
            case normal(parentStackViewWidth: CGFloat)
            
            /// 異なる2つの項目値のペア（施工日 / 施工者など）として区切られたrow
            case separateTwoItemValues(parentStackViewWidth: CGFloat)
            
            /// 1つの項目値のみ入力欄のある表示
            case onlyOneValue(parentStackViewWidth: CGFloat)
            
            var columnWidth: ColumnWidth {
                switch self {
                case .normal(let parentStackViewWidth):
                    return calcColumnWidth(
                        parentStackViewWidth,
                        leftRatio: LayoutParams.normalInputLeftWidthRatio,
                        leftMinWidth: LayoutParams.normalInputLeftMinWidth
                    )
                case .separateTwoItemValues(let parentStackViewWidth):
                    return calcColumnWidth(
                        parentStackViewWidth,
                        leftRatio: LayoutParams.dateInputWidthRatio,
                        leftMinWidth: LayoutParams.dateInputMinWidth
                    )
                case .onlyOneValue(let parentStackViewWidth):
                    return calcColumnWidth(
                        parentStackViewWidth,
                        leftRatio: 0, // 1項目だけのためratioは0
                        leftMinWidth: 0
                    )
                }
            }
            
            private func calcColumnWidth(
                _ parentStackViewWidth: CGFloat,
                leftRatio: CGFloat,
                leftMinWidth: CGFloat
            ) -> ColumnWidth {
                    let leftWidth = max(
                        parentStackViewWidth * leftRatio,
                        leftMinWidth
                    )
                    return .init(
                        left: leftWidth,
                        right: parentStackViewWidth - leftWidth
                    )
            }
        }
        
        struct ColumnWidth {
            let left: CGFloat
            let right: CGFloat
        }
        
        let scalableHeightRelay = BehaviorRelay<RowHeight>(value: .init(number: 0, height: LayoutParams.normalInputMinHeight))
        
        private let disposeBag = DisposeBag()
        private var rowNumber: Int = 0
        
        private var currentLeftColumnViewHeight: CGFloat = LayoutParams.normalInputMinHeight {
            didSet { adjustHeightIfNeeded() }
        }
        private var currentRightColumnViewHeight: CGFloat = LayoutParams.normalInputMinHeight {
            didSet { adjustHeightIfNeeded() }
        }

        func configure(
            rowNumber: Int,
            dividingType: RowDividingType,
            leftColumnView: ColumnStackContainerView,
            rightColumnView: ColumnStackContainerView
        ) {
            self.rowNumber = rowNumber
            
            // set content size heights
            scalableHeightRelay.accept(
                .init(
                    number: self.rowNumber,
                    height: max(
                        max(
                            leftColumnView.bounds.height,
                            rightColumnView.bounds.height
                        ),
                        LayoutParams.normalInputMinHeight
                    )
                )
            )

            axis = .horizontal
            
            addArrangedSubview(leftColumnView)
            addArrangedSubview(rightColumnView)
            
            snp.removeConstraints()
            snp.remakeConstraints { make in
                make.height.equalTo(scalableHeightRelay.value.height).priority(.high)
            }
            
            // （必要があれば）左右入力欄のwidthを更新
            switch dividingType {
            case .normal, .separateTwoItemValues, .onlyOneValue:
                leftColumnView.snp.makeConstraints { make in
                    make.width.equalTo(dividingType.columnWidth.left)
                }
            }
            
            addBinding(
                leftColumnView: leftColumnView,
                rightColumnView: rightColumnView
            )
        }
        
        private func addBinding(
            leftColumnView: ColumnStackContainerView,
            rightColumnView: ColumnStackContainerView
        ) {
            leftColumnView.columnStackView?.shouldAdjustHeightDriver
                .drive(onNext: { [weak self] in self?.currentLeftColumnViewHeight = $0.height })
                .disposed(by: disposeBag)
            
            rightColumnView.columnStackView?.shouldAdjustHeightDriver
                .drive(onNext: { [weak self] in self?.currentRightColumnViewHeight = $0.height })
                .disposed(by: disposeBag)
        }
        
        private func adjustHeightIfNeeded() {
            func adjust(_ newHeight: CGFloat) {
                scalableHeightRelay.accept(.init(number: rowNumber, height: newHeight))
                DispatchQueue.main.async { [weak self] in
                    self?.snp.updateConstraints { make in
                        make.height.equalTo(newHeight).priority(.high)
                    }
                }
            }

            let newHeight = currentLeftColumnViewHeight > currentRightColumnViewHeight
                ? currentLeftColumnViewHeight
                : currentRightColumnViewHeight
            guard scalableHeightRelay.value.height != newHeight else { return }
            adjust(newHeight)
        }
    }
}

//
//  ModernBlackboardListSortView.swift
//  andpad-camera
//
//  Created by msano on 2022/04/18.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

public final class ModernBlackboardListSortView: UIView {
    public struct Dependency {
        let sortState: SortState
        let total: Int
        
        public init(sortState: SortState, total: Int) {
            self.sortState = sortState
            self.total = total
        }
    }
    
    public static let viewHeight: CGFloat = 40
    
    private let disposeBag = DisposeBag()
    private let changedSortStateRelay = BehaviorRelay<SortState>(value: .idASC)
    
    private var total: Int = 0

    // IBOutlet
    @IBOutlet private weak var totalLabel: UILabel!
    
    public enum SortState {
        case idASC
        case idDESC
        
        var sortButtonIconImage: UIImage {
            switch self {
            case .idASC:
                return Asset.iconBottomDirectionalArrow.image
            case .idDESC:
                // NOTE:
                // もともと、矢印の方向の違うアイコンをそれぞれpdfで用意していたが、
                // なぜか片方しか表示されなかった（他のアイコンでだし分けした場合は問題なかった）
                // ファイルのリネームなど色々試したものの、原因がわからず、とりいそぎ180度回転でしのいでいる
                return Asset.iconBottomDirectionalArrow.image.imageRotatedByDegrees(deg: 180)
            }
        }
        
        var isSelected: Bool {
            switch self {
            case .idASC:
                return false
            case .idDESC:
                return true
            }
        }
        
        // NOTE: 現状caseが2つのみのためOKだが、増えるようならこちらは廃止することになりそう
        func toggle() -> Self {
            switch self {
            case .idASC:
                return .idDESC
            case .idDESC:
                return .idASC
            }
        }
    }
    
    // IBOutlet
    @IBOutlet private weak var sortButton: UIButton!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        sortButton.titleEdgeInsets = .init(
            top: 0,
            left: 0,
            bottom: 0,
            right: 6
        )
    }
}

// MARK: - subscribe対象
extension ModernBlackboardListSortView {
    // NOTE: タップされた後にソートのステータスを返す
    public var changedSortStateSignal: Signal<SortState> {
        changedSortStateRelay.asSignal(onErrorJustReturn: .idASC)
    }
}

extension ModernBlackboardListSortView {
    public func updateTotalLabel(_ total: Int) {
        self.total = total
        totalLabel.text = self.total > 0
            ? L10n.Blackboard.List.Sort.total(self.total)
            : L10n.Blackboard.List.Sort.totalZero
    }
    
    public func enableSortButton() {
        sortButton.isEnabled = true
    }
}

// MARK: - private
extension ModernBlackboardListSortView {
    private func configure(sortState: SortState, total: Int) {
        changedSortStateRelay.accept(sortState)
        updateTotalLabel(total)
    }
    
    private func changeButtonState(sortState: SortState) {
        sortButton.setImage(sortState.sortButtonIconImage, for: .normal)
    }
    
    private func addBinding() {
        sortButton.rx.tap
            .asSignal()
            .flatMapFirst { [weak self] in
                self?.sortButton.isEnabled = false
                return Signal.just(())
            }
            .emit(onNext: { [weak self] in
                guard let self else { return }
                self.changedSortStateRelay.accept(self.changedSortStateRelay.value.toggle())
            })
            .disposed(by: disposeBag)
        
        changedSortStateSignal
            .emit(onNext: { [weak self] in self?.changeButtonState(sortState: $0) })
            .disposed(by: disposeBag)
    }
}

// MARK: - NibType
extension ModernBlackboardListSortView: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernBlackboardListSortView: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        configure(sortState: dependency.sortState, total: total)
        addBinding()
    }
}

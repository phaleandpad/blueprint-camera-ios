//
//  ModernBlackboardAlphaCell.swift
//  andpad-camera
//
//  Created by msano on 2022/02/04.
//

import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa
import SnapKit

final class ModernBlackboardAlphaCell: UITableViewCell {
    typealias AlphaLevel = ModernBlackboardAppearance.AlphaLevel
    
    struct Dependency {
        let alphaLevel: AlphaLevel
        let canEditBlackboardStyle: Bool
    }
    
    @IBOutlet private weak var containerView: UIView!

    var disposeBag = DisposeBag()
    var canEditBlackboardStyle = true
    
    private let scaleLabelList = [
        L10n.Blackboard.Edit.noAlpha,
        L10n.Blackboard.Edit.harfAlpha,
        L10n.Blackboard.Edit.alpha
    ]
    
    var onValueChangedSignal: Signal<AlphaLevel> {
        onValueChangedRelay.asSignal()
    }
    
    private let onValueChangedRelay = PublishRelay<AlphaLevel>()
    
    private var slider: StickySlider?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slider = StickySlider(
            frame: containerView.bounds,
            scaleLabelList: scaleLabelList,
            style: .alpha,
            title: L10n.Blackboard.Edit.alphaForBlackboard,
            footnote: L10n.Blackboard.Edit.alphaForBlackboardFootnote
        )
        guard let slider else { return }
        
        containerView.addSubview(slider)
        slider.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        slider.setContentCompressionResistancePriority(.required, for: .vertical)
        addBinding()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        addBinding()
    }
    
    private func addBinding() {
        guard let slider else { return }
        slider.onValueChangedSignal
            .compactMap { AlphaLevel(rawValue: $0) }
            .emit(to: onValueChangedRelay)
            .disposed(by: disposeBag)
    }

    private func configure(alphaLevel: AlphaLevel) {
        slider?.setValue(Float(alphaLevel.rawValue), animated: false)
    }
}

// MARK: - NibType
extension ModernBlackboardAlphaCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension ModernBlackboardAlphaCell: Reusable {
    func inject(_ dependency: Dependency) {
        canEditBlackboardStyle = dependency.canEditBlackboardStyle
        configure(alphaLevel: dependency.alphaLevel)
    }
}

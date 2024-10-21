//
//  ModernMemoStyleCell.swift
//  andpad-camera
//
//  Created by msano on 2021/08/17.
//

import AndpadUIComponent
import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

final class ModernMemoStyleCell: UITableViewCell {
    
    struct Dependency {
        let initialSelectedValue: SelectedValue
        let canEditBlackboardStyle: Bool
    }
    
    struct SelectedValue: EditableBlackboardDataProtocol {
        let adjustableMaxFontSize: ModernMemoStyleType.AdjustableMaxFontSize
        let verticalAlignment: ModernMemoStyleType.VerticalAlignment
        let horizontalAlignment: NSTextAlignment
    }
    
    var disposeBag = DisposeBag()
    var canEditBlackboardStyle = true
    
    private var selectedValue: SelectedValue = .init(
        adjustableMaxFontSize: .small,
        verticalAlignment: .top,
        horizontalAlignment: .left
    ) {
        didSet { updateMemoStyleRelay.accept(selectedValue) }
    }

    // subscribe対象
    let updateMemoStyleSignal: Signal<SelectedValue>
    private let updateMemoStyleRelay = PublishRelay<SelectedValue>()
    
    private var fontSizeStyleItemView: ModernMemoStyleItemView?
    private var textVerticalAlignStyleItemView: ModernMemoStyleItemView?
    private var textHorizontalAlignStyleItemView: ModernMemoStyleItemView?

    // IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var styleItemsView: UIView!
    @IBOutlet private weak var styleItemsStackView: UIStackView!
    
    // initialize
    required init?(coder: NSCoder) {
        updateMemoStyleSignal = updateMemoStyleRelay.asSignal()
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .tsukuri.system.primaryTextOnSurface1
    }
    
    // life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        fontSizeStyleItemView = nil
        textVerticalAlignStyleItemView = nil
        textHorizontalAlignStyleItemView = nil
        styleItemsStackView.removeAllArrangedSubviews()
    }
}

// MARK: - private
extension ModernMemoStyleCell {
    private func configure(by defaultValue: SelectedValue) {
        styleItemsView.cornerRadius = 4
        styleItemsView.layer.borderWidth = 1
        styleItemsView.layer.borderColor = UIColor.grayDDD.cgColor
        
        createViews(by: defaultValue)
        addObservers()
    }
    
    private func createViews(by defaultValue: SelectedValue) {
        func setHeightAnchor(_ targetView: UIView, constant: CGFloat) {
            targetView.heightAnchor.constraint(equalToConstant: constant).isActive = true
        }

        func itemView(with dependency: ModernMemoStyleItemView.Dependency) -> ModernMemoStyleItemView {
            let view = ModernMemoStyleItemView(with: dependency)
            setHeightAnchor(view, constant: 40.0)
            return view
        }

        var dividerView: UIView {
            let view = UIView()
            view.backgroundColor = .grayDDD
            setHeightAnchor(view, constant: 1.0)
            return view
        }
        
        fontSizeStyleItemView = itemView(
            with: .init(
                type: .fontSize,
                level: .init(with: defaultValue.adjustableMaxFontSize)
            )
        )
        textVerticalAlignStyleItemView = itemView(
            with: .init(
                type: .textVerticalAlign,
                level: .init(with: defaultValue.verticalAlignment)
            )
        )
        textHorizontalAlignStyleItemView = itemView(
            with: .init(
                type: .textHorizontalAlign,
                level: .init(with: defaultValue.horizontalAlignment)
            )
        )

        // add into stackView
        styleItemsStackView.addArrangedSubview(fontSizeStyleItemView!)
        styleItemsStackView.addArrangedSubview(dividerView)
        styleItemsStackView.addArrangedSubview(textHorizontalAlignStyleItemView!)
        styleItemsStackView.addArrangedSubview(dividerView)
        styleItemsStackView.addArrangedSubview(textVerticalAlignStyleItemView!)
    }

    private func addObservers() {
        // subscribe item views
        fontSizeStyleItemView?.addObserver { [weak self] in self?.updateSelectedValue() }
        textVerticalAlignStyleItemView?.addObserver { [weak self] in self?.updateSelectedValue() }
        textHorizontalAlignStyleItemView?.addObserver { [weak self] in self?.updateSelectedValue() }
    }
    
    private func updateSelectedValue() {
        guard let fontSizeStyleItemView,
              let textVerticalAlignStyleItemView,
              let textHorizontalAlignStyleItemView else {
            return
        }
        selectedValue = .init(
            adjustableMaxFontSize: .init(with: fontSizeStyleItemView.selectLevel),
            verticalAlignment: .init(with: textVerticalAlignStyleItemView.selectLevel),
            horizontalAlignment: ModernMemoStyleType.horizontalAlignment(with: textHorizontalAlignStyleItemView.selectLevel)
        )
    }
}

// MARK: - NibType
extension ModernMemoStyleCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension ModernMemoStyleCell: Reusable {
    func inject(_ dependency: Dependency) {
        canEditBlackboardStyle = dependency.canEditBlackboardStyle
        configure(by: dependency.initialSelectedValue)
    }
}

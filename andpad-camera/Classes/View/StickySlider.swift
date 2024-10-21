//
//  StickySlider.swift
//  andpad-camera
//
//  Created by msano on 2022/01/19.
//

import AndpadUIComponent
import RxSwift
import RxCocoa

/// scaleLabelに対して吸着可能なスライダー
final class StickySlider: UISlider {
    
    // init
    convenience init(
        frame: CGRect,
        scaleLabelList: [String],
        style: StickySlider.Style,
        title: String?,
        footnote: String?
    ) {
        
        // 最低高があるため、満たさない場合は最低高にアジャストする
        let adjustedFrame = frame.height > LayoutParam.minFrameHeight
            ? frame
            : CGRect(
                origin: frame.origin,
                size: .init(
                    width: frame.width,
                    height: LayoutParam.minFrameHeight
                )
            )
        
        self.init(frame: adjustedFrame)
        
        self.scaleLabelList = scaleLabelList
        self.style = style
        setup(max: scaleLabelList.count - 1, title: title, footnote: footnote)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { // swiftlint:disable:this unavailable_function
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        frame.size
    }

    // subscribe対象
    var onValueChangedSignal: Signal<Int> {
        onValueChangedRelay.asSignal()
    }
    
    private let disposeBag = DisposeBag()
    private let onValueChangedRelay = PublishRelay<Int>()
    private var scaleLabelList: [String] = []
    private var style: StickySlider.Style = .alpha

    // MARK: - LayoutParam
    private enum LayoutParam {
        static let thumbEstimatedHeight: CGFloat = 28
        static let scaleLabelAreaHeight: CGFloat = 26
        static let scaleLabelAreaTopMargin: CGFloat = 32
        static let scaleLabelWidth: CGFloat = 80
        static let scalePointSize: CGSize = .init(width: 4, height: 8)
        static let titleLabelFontSize: CGFloat = 12
        static let titleLabelTopMargin: CGFloat = 6
        static let footnoteLabelFontSize: CGFloat = 11
        static let footnoteLabelBottomMargin: CGFloat = 6

        // StickySliderの最低高
        static let minFrameHeight = thumbEstimatedHeight + scaleLabelAreaTopMargin + scaleLabelAreaHeight + footnoteLabelFontSize + footnoteLabelBottomMargin
    }
}

// MARK: - override func (by UIResponder)
extension StickySlider {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        fixSliderPosition() // スライド終了後に位置を調整する
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true // つまみ部分以外でもスライド可能
    }
}

// MARK: - private
extension StickySlider {
    private func setup(max: Int, title: String?, footnote: String?) {
        minimumValue = 0
        maximumValue = Float(max)

        if let tintColor = style.tintColor {
            self.tintColor = tintColor
            minimumTrackTintColor = tintColor
            maximumTrackTintColor = tintColor
        }
        minimumValueImage = style.minimumValueImage
        maximumValueImage = style.maximumValueImage
        
        rx.controlEvent(.valueChanged)
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.onValueChange(round(self.value))
            })
            .disposed(by: disposeBag)
        
        configureScalePoints()
        configureScaleLabels()
        configureLabelIfNeeded(title: title, footnote: footnote)
    }
    
    private func configureScaleLabels() {
        let labelArea = UIStackView()
        labelArea.axis = .horizontal
        labelArea.distribution = .equalSpacing
        labelArea.alignment = .fill
        labelArea.isUserInteractionEnabled = true
        insertSubview(labelArea, at: 0)
        
        labelArea.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(LayoutParam.scaleLabelAreaTopMargin)
            make.centerX.equalToSuperview()
            make.height.equalTo(LayoutParam.scaleLabelAreaHeight)
            make.width.equalToSuperview().offset(self.thumbBounds.width / 2)
        }
        scaleLabelList.enumerated().forEach { [weak self] object in
            guard let self else { return }
            labelArea.addArrangedSubview(
                self.createScaleLabel(
                    text: object.element,
                    index: object.offset,
                    textAlignment: .center
                )
            )
        }
        bringSubviewToFront(labelArea)
    }
    
    private func configureScalePoints() {
        let pointArea = UIStackView()
        pointArea.axis = .horizontal
        pointArea.distribution = .equalSpacing
        pointArea.alignment = .fill
        pointArea.isUserInteractionEnabled = false
        insertSubview(pointArea, at: 0)
        
        pointArea.snp.makeConstraints { make in
            // heightが偶数なので少しだけアジャストする
            make.centerY.equalToSuperview().offset(1)
            make.centerX.equalToSuperview()
            make.height.equalTo(LayoutParam.scalePointSize.height)
            make.width.equalToSuperview().offset(-(self.thumbBounds.width * 2))
        }
        scaleLabelList.forEach { [weak self] _ in
            guard let self else { return }
            pointArea.addArrangedSubview(self.createScalePoint())
        }
    }
    
    private func configureLabelIfNeeded(title: String?, footnote: String?) {
        guard let title else { return }
        
        let label = UILabel()

        label.text = title
        label.font = .systemFont(ofSize: LayoutParam.titleLabelFontSize)
        label.textColor = .tsukuri.system.primaryTextOnSurface1
        label.textAlignment = .left
        insertSubview(label, at: 0)

        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(LayoutParam.titleLabelTopMargin)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        configureFootnoteLabelIfNeeded(footnote: footnote, titleLabel: label)
    }

    private func configureFootnoteLabelIfNeeded(footnote: String?, titleLabel: UILabel) {
        guard let footnote else { return }

        let label = UILabel()

        label.text = footnote
        label.font = .systemFont(ofSize: LayoutParam.footnoteLabelFontSize)
        label.textColor = .gray888
        label.textAlignment = .left
        insertSubview(label, at: 0)

        label.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    private func createScalePoint() -> UIView {
        let label = UIView()
        if let color = style.scalePointColor {
            label.backgroundColor = color
        }
        
        label.isUserInteractionEnabled = false

        label.snp.makeConstraints { make in
            make.width.equalTo(LayoutParam.scalePointSize.width)
            make.height.equalTo(LayoutParam.scalePointSize.height)
        }
        return label
    }
    
    private func createScaleLabel(text: String, index: Int, textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray222
        label.textAlignment = textAlignment
        label.isUserInteractionEnabled = true
        label.tag = index

        label.snp.makeConstraints { make in
            make.width.equalTo(LayoutParam.scaleLabelWidth)
        }

        let tapGestureRecognizer = StickySliderTapGesture(target: self, action: #selector(self.tapScaleLabel(_:)))
        tapGestureRecognizer.index = index
        label.addGestureRecognizer(tapGestureRecognizer)
        return label
    }
    
    private func fixSliderPosition() {
        let index = round(self.value)
        self.value = index
        onValueChange(index)
    }
    
    @objc func tapScaleLabel(_ sender: StickySliderTapGesture) {
        let value = Float(sender.index + Int(minimumValue))
        self.value = value
        onValueChange(value)
    }
    
    private func onValueChange(_ value: Float) {
        onValueChangedRelay.accept(Int(value))
    }
    
    final class StickySliderTapGesture: UITapGestureRecognizer {
        var index: Int = 0
    }
}

// MARK: - Style
extension StickySlider {
    enum Style {
        case alpha
        
        var minimumValueImage: UIImage {
            switch self {
            case .alpha:
                return Asset.iconBlackboardAlphaFill.image
            }
        }
        
        var maximumValueImage: UIImage {
            switch self {
            case .alpha:
                return Asset.iconBlackboardAlpha.image
            }
        }
        
        var tintColor: UIColor? {
            switch self {
            case .alpha:
                return .grayBBB
            }
        }
        
        var scalePointColor: UIColor? {
            tintColor
        }
    }
}

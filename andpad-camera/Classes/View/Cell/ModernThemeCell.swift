//
//  ModernThemeCell.swift
//  andpad-camera
//
//  Created by msano on 2021/06/04.
//

import AndpadUIComponent
import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

final class ModernThemeCell: UITableViewCell {
    typealias Theme = ModernBlackboardAppearance.Theme
    
    struct Dependency {
        let theme: Theme
        let canEditBlackboardStyle: Bool
    }
    
    var disposeBag = DisposeBag()
    
    // subscribe対象
    let updateThemeSignal: Signal<Theme>
    private let updateThemeRelay = PublishRelay<Theme>()
    
    var canEditBlackboardStyle = true
    
    // IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var theme1CircleView: UIView!
    @IBOutlet private weak var theme1selectingImageView: UIImageView!
    @IBOutlet private weak var theme2CircleView: UIView!
    @IBOutlet private weak var theme2selectingImageView: UIImageView!
    @IBOutlet private weak var theme3CircleView: UIView!
    @IBOutlet private weak var theme3selectingImageView: UIImageView!

    // IBAction
    @IBAction private func tappedTheme1Button(_ sender: UIButton) {
        selectedTheme = .black
    }

    @IBAction private func tappedTheme2Button(_ sender: UIButton) {
        selectedTheme = .white
    }

    @IBAction private func tappedTheme3Button(_ sender: UIButton) {
        selectedTheme = .green
    }

    private(set) var selectedTheme: Theme = .black {
        didSet {
            switch selectedTheme {
            case .black:
                theme1selectingImageView.isHidden = false
                theme2selectingImageView.isHidden = true
                theme3selectingImageView.isHidden = true
            case .white:
                theme1selectingImageView.isHidden = true
                theme2selectingImageView.isHidden = false
                theme3selectingImageView.isHidden = true
            case .green:
                theme1selectingImageView.isHidden = true
                theme2selectingImageView.isHidden = true
                theme3selectingImageView.isHidden = false
            }
            updateThemeRelay.accept(selectedTheme)
        }
    }
    
    // initialize
    required init?(coder: NSCoder) {
        updateThemeSignal = updateThemeRelay.asSignal()
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
    }
}

// MARK: - private
extension ModernThemeCell {
    private func configureBaseLayout() {
        // theme2のみ枠線を追加（ = 背景と同色のため）
        theme2CircleView.layer.borderColor = Theme.white.textColor.cgColor
        theme2CircleView.layer.borderWidth = 1.0

        // iOS12対策のため、コード上でtintColorをセット
        theme1selectingImageView.configureTintColor(Theme.black.textColor)
        theme2selectingImageView.configureTintColor(Theme.white.textColor)
        theme3selectingImageView.configureTintColor(Theme.green.textColor)
    }
    
    private func configure(theme: Theme) {
        selectedTheme = theme
    }
}

// MARK: - NibType
extension ModernThemeCell: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension ModernThemeCell: Reusable {
    func inject(_ dependency: Dependency) {
        canEditBlackboardStyle = dependency.canEditBlackboardStyle
        configureBaseLayout()
        configure(theme: dependency.theme)
    }
}

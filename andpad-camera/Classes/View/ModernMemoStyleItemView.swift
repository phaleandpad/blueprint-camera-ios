//
//  ModernMemoStyleItemView.swift
//  andpad-camera
//
//  Created by msano on 2021/08/18.
//

import Instantiate
import InstantiateStandard
import UIKit

final class ModernMemoStyleItemView: UIView {
    enum ItemType: CaseIterable {
        case fontSize
        case textHorizontalAlign
        case textVerticalAlign
        
        var title: String {
            switch self {
            case .fontSize:
                return L10n.Blackboard.Edit.fontSize
            case .textHorizontalAlign:
                return L10n.Blackboard.Edit.textHorizontalAlign
            case .textVerticalAlign:
                return L10n.Blackboard.Edit.textVerticalAlign
            }
        }
    }
    
    // IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var level1Button: UIButton!
    @IBOutlet private weak var level2Button: UIButton!
    @IBOutlet private weak var level3Button: UIButton!
    
    // IBAction
    @IBAction private func tappedlevel1Button(_ sender: Any) {
        changeButtonState(with: .level1)
        observer?()
    }
    @IBAction private func tappedlevel2Button(_ sender: Any) {
        changeButtonState(with: .level2)
        observer?()
    }
    @IBAction private func tappedlevel3Button(_ sender: Any) {
        changeButtonState(with: .level3)
        observer?()
    }

    private var dependency: Dependency?
    private var observer: (() -> Void)?
    
    var selectLevel: ModernMemoStyleType.SelectLevel = .level1
    
    struct Dependency {
        let type: ItemType
        let level: ModernMemoStyleType.SelectLevel
    }
    
    deinit {
        observer = nil
    }
}

extension ModernMemoStyleItemView {
    func addObserver(observer: @escaping () -> Void) {
        self.observer = observer
    }
}

// MARK: - private
extension ModernMemoStyleItemView {
    private func configureView() {
        guard let dependency else { return }
        titleLabel.text = dependency.type.title
        level1Button.setImage(buttonIcon(by: dependency.type, level: .level1), for: .normal)
        level2Button.setImage(buttonIcon(by: dependency.type, level: .level2), for: .normal)
        level3Button.setImage(buttonIcon(by: dependency.type, level: .level3), for: .normal)
        changeButtonState(with: dependency.level)
    }
    
    private func changeButtonState(with level: ModernMemoStyleType.SelectLevel) {
        self.selectLevel = level
        
        // Surface Critical Subdued/surface-state1 のシステムカラーに変更すること
        let selectedBackgroundColor = UIColor.tsukuri.reference.red10
        let normalBackgroundColor = UIColor.white
        let selectedTintColor = UIColor.tsukuri.system.primaryTextOnSurface1
        let normalTintColor = UIColor.tsukuri.system.secondaryTextOnSurface1
        
        level1Button.backgroundColor = normalBackgroundColor
        level2Button.backgroundColor = normalBackgroundColor
        level3Button.backgroundColor = normalBackgroundColor
        level1Button.tintColor = normalTintColor
        level2Button.tintColor = normalTintColor
        level3Button.tintColor = normalTintColor
        
        switch level {
        case .level1:
            level1Button.backgroundColor = selectedBackgroundColor
            level1Button.tintColor = selectedTintColor
        case .level2:
            level2Button.backgroundColor = selectedBackgroundColor
            level2Button.tintColor = selectedTintColor
        case .level3:
            level3Button.backgroundColor = selectedBackgroundColor
            level3Button.tintColor = selectedTintColor
        }
    }
    
    private func buttonIcon(by itemType: ItemType, level: ModernMemoStyleType.SelectLevel) -> UIImage {
        switch itemType {
        case .fontSize:
            switch level {
            case .level1:
                return Asset.iconFontWeightSmallInvert.image
            case .level2:
                return Asset.iconFontWeightMediumInvert.image
            case .level3:
                return Asset.iconFontWeightLargeInvert.image
            }
        case .textHorizontalAlign:
            switch level {
            case .level1:
                return Asset.iconAlignLeftInvert.image
            case .level2:
                return Asset.iconAlignCenterInvert.image
            case .level3:
                return Asset.iconAlignRightInvert.image
            }
        case .textVerticalAlign:
            switch level {
            case .level1:
                return Asset.iconAlignTopInvert.image
            case .level2:
                return Asset.iconAlignMiddleInvert.image
            case .level3:
                return Asset.iconAlignBottomInvert.image
            }
        }
    }
}

// MARK: - NibType
extension ModernMemoStyleItemView: NibType {
    static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernMemoStyleItemView: NibInstantiatable {
    func inject(_ dependency: Dependency) {
        self.dependency = dependency
        configureView()
    }
}

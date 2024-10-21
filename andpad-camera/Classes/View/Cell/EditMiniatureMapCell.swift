//
//  EditMiniatureMapCell.swift
//  andpad-camera-andpad-camera
//
//  Created by msano on 2022/08/26.
//

import AndpadUIComponent
import Instantiate
import InstantiateStandard
import RxSwift
import RxCocoa

public final class EditMiniatureMapCell: UITableViewCell {
    public struct Dependency {
        let state: MiniatureMapImageState
        let parentViewType: ParentViewType
        
        public init(
            state: MiniatureMapImageState,
            parentViewType: ParentViewType
        ) {
            self.state = state
            self.parentViewType = parentViewType
        }
    }

    private var miniatureMapImage: UIImage?
    
    public enum ParentViewType {
        case edit
        case detailInfo
        
        var titleFont: UIFont {
            switch self {
            case .edit:
                return .systemFont(ofSize: 12)
            case .detailInfo:
                return .systemFont(ofSize: 14)
            }
        }
        
        var titleTextColor: UIColor {
            switch self {
            case .edit:
                return .tsukuri.system.primaryTextOnSurface1
            case .detailInfo:
                return .gray888
            }
        }
        
        var isHiddenDescription: Bool {
            switch self {
            case .edit:
                return false
            case .detailInfo:
                return true
            }
        }

        var containerViewBottomMargin: CGFloat {
            switch self {
            case .edit:
                return 26
            case .detailInfo:
                return 8
            }
        }
    }
    
    // IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containerButton: UIButton!
    @IBOutlet private weak var miniatureMapImageView: UIImageView!
    @IBOutlet private weak var containerViewBottomMarginConstraint: NSLayoutConstraint!

    public var disposeBag = DisposeBag()
    
    public var tapButtonSignal: Signal<UIImage> {
        containerButton.rx.tap
            .asSignal()
            .compactMap { [weak self] in
                guard let self else { return nil }
                return self.miniatureMapImage
            }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .tsukuri.system.primaryTextOnSurface1
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.grayDDD.cgColor
        containerButton.setBackgroundImage(UIColor.whiteFAFA.createImage(), for: .normal)
        containerButton.setBackgroundImage(UIColor.white.createImage(), for: .highlighted)
        selectionStyle = .none
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

// MARK: - private
extension EditMiniatureMapCell {
    private func configure(
        appearance: MiniatureMapImageViewAppearance,
        parentViewType: ParentViewType
    ) {
        miniatureMapImageView.apply(appearance)
        containerButton.isUserInteractionEnabled = appearance.state.hasMiniatureMapImage
        
        switch appearance.state {
        case .beforeLoading, .loadFailed, .noURL:
            break
        case .loadSuccessful(let image):
            miniatureMapImage = image
        }
        
        titleLabel.font = parentViewType.titleFont
        titleLabel.textColor = parentViewType.titleTextColor
        descriptionLabel.isHidden = parentViewType.isHiddenDescription
        containerViewBottomMarginConstraint.constant = parentViewType.containerViewBottomMargin
    }
}

// MARK: - NibType
extension EditMiniatureMapCell: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - Reusable
extension EditMiniatureMapCell: Reusable {
    public func inject(_ dependency: Dependency) {
        configure(
            appearance: .init(
                state: dependency.state,
                isShowImageIntoBlackboard: false // 黒板内での描画ではないのでfalse
            ),
            parentViewType: dependency.parentViewType
        )
    }
}

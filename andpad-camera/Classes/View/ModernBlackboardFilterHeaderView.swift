//
//  ModernBlackboardFilterHeaderView.swift
//  andpad-camera
//
//  Created by msano on 2022/09/15.
//

import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift

public final class ModernBlackboardFilterHeaderView: UIView {
    public typealias SearchQuery = ModernBlackboardSearchQuery
    
    public struct Dependency {
        let searchQuery: SearchQuery?
        
        public init(searchQuery: SearchQuery?) {
            self.searchQuery = searchQuery
        }
    }
    
    public static let viewHeight: CGFloat = 48

    // @IBOutlet
    @IBOutlet private weak var photoConditionButton: UIButton!
    @IBOutlet private weak var filterButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    private let searchQueryRelay = BehaviorRelay<SearchQuery?>(value: nil)
    private let photoConditionButtonStateRelay = BehaviorRelay<PhotoConditionButtonStateData>(
        value: .init(state: .notSelected)
    )
    private let filterButtonStateRelay = BehaviorRelay<FilterButtonState>(value: .notSelected)
    
    public var updateSearchQuerySignal: Signal<SearchQuery?> {
        searchQueryRelay
            .observeOn(MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .asSignal(onErrorJustReturn: nil)
    }
    public var tapFilterButtonSignal: Signal<Void> {
        filterButton.rx.tap
            .asSignal()
    }
    
    private enum LayoutParam {
        static let buttonFontSize: CGFloat = 15
        static let buttonTitleEdgeInsetsLeft: CGFloat = 6
        static let buttonContentPadding: CGFloat = 10
        static let filterButtonCornerRadius: CGFloat = 4
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 15.0, *) {
            photoConditionButton.configuration = nil
            filterButton.configuration = nil
        }
        
        let defaultFont = UIFont.systemFont(ofSize: LayoutParam.buttonFontSize)
        photoConditionButton.titleLabel?.font = defaultFont
        photoConditionButton.imageView?.contentMode = .center
        photoConditionButton.titleEdgeInsets.left = LayoutParam.buttonTitleEdgeInsetsLeft

        filterButton.titleLabel?.font = defaultFont
        filterButton.imageView?.contentMode = .center
        filterButton.imageEdgeInsets = .init(
            top: 0,
            left: -LayoutParam.buttonTitleEdgeInsetsLeft,
            bottom: 0,
            right: LayoutParam.buttonTitleEdgeInsetsLeft
        )
        filterButton.cornerRadius = LayoutParam.filterButtonCornerRadius
        filterButton.setTitleColor(.redEF3, for: .normal)
        filterButton.setTitleColor(.redEF3, for: .selected)
    }
}

// MARK: - update
extension ModernBlackboardFilterHeaderView {
    public func update(searchQuery: SearchQuery?) {
        searchQueryRelay.accept(searchQuery)
        photoConditionButtonStateRelay.accept(
            .init(
                state: PhotoConditionButtonState(searchQuery: searchQuery),
                // NOTE: 外部からデータを渡された場合、写真条件ボタンのstateだけ更新（検索クエリは更新しない）
                shouldUpdateSearchQuery: false
            )
        )
    }
    
    public func enablePhotoConditionButton() {
        photoConditionButton.isEnabled = true
    }
}

// MARK: - private
extension ModernBlackboardFilterHeaderView {
    private func addBinding() {
        searchQueryRelay
            .asSignal(onErrorJustReturn: nil)
            .distinctUntilChanged()
            .emit(onNext: { [weak self] in
                guard let self else { return }
                let photoConditionButtonState = PhotoConditionButtonState(searchQuery: $0)
                let filterButtonState = FilterButtonState(searchQuery: $0)
                photoConditionButton.setImage(photoConditionButtonState.icon, for: .normal)
                filterButton.setImage(filterButtonState.icon, for: .normal)
                filterButton.backgroundColor = filterButtonState.backgroundColor
                filterButton.contentEdgeInsets = filterButtonState.contentEdgeInsets
                filterButton.titleLabel?.font = filterButtonState.font
            })
            .disposed(by: disposeBag)
        
        photoConditionButton.rx.tap
            .asSignal()
            .flatMapFirst { [weak self] in
                self?.photoConditionButton.isEnabled = false
                return Signal.just(())
            }
            .compactMap { [weak self] in
                guard let self else { return nil }
                return .init(state: self.photoConditionButtonStateRelay.value.state.toggle())
            }
            .emit(to: photoConditionButtonStateRelay)
            .disposed(by: disposeBag)
        
        photoConditionButtonStateRelay
            .asSignal(
                onErrorJustReturn: .init(
                    state: .notSelected,
                    shouldUpdateSearchQuery: false
                )
            )
            .distinctUntilChanged { $0.state == $1.state }
            .compactMap { [weak self] data in
                guard let self,
                      data.shouldUpdateSearchQuery else { return nil }
                guard let query = self.searchQueryRelay.value else {
                    return .init(
                        photoCondition: data.state.value,
                        conditionForBlackboardItems: [],
                        freewords: ""
                    )
                }
                return query.updating(photoCondition: data.state.value)
            }
            .emit(to: searchQueryRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - PhotoConditionButtonStateData
extension ModernBlackboardFilterHeaderView {
    private struct PhotoConditionButtonStateData {
        let state: PhotoConditionButtonState
        let shouldUpdateSearchQuery: Bool
        
        init(
            state: PhotoConditionButtonState,
            shouldUpdateSearchQuery: Bool = true
        ) {
            self.state = state
            self.shouldUpdateSearchQuery = shouldUpdateSearchQuery
        }
    }
}

// MARK: - State (PhotoConditionButton)
extension ModernBlackboardFilterHeaderView {
    private enum PhotoConditionButtonState {
        case selected
        case notSelected
        
        init(searchQuery: SearchQuery?) {
            switch searchQuery?.photoCondition {
            case .none, .all, .hasPhoto:
                self = .notSelected
            case .hasNoPhoto:
                self = .selected
            }
        }
        
        var value: SearchQuery.PhotoCondition {
            switch self {
            case .selected:
                return .hasNoPhoto
            case .notSelected:
                return .all
            }
        }
        
        var icon: UIImage {
            switch self {
            case .selected:
                return Asset.iconFilterSelectHeader.image
            case .notSelected:
                return Asset.iconFilterDeselectHeader.image
            }
        }
        
        func toggle() -> Self {
            switch self {
            case .selected:
                return .notSelected
            case .notSelected:
                return .selected
            }
        }
    }
}

// MARK: - State (FilterButton)
extension ModernBlackboardFilterHeaderView {
    private enum FilterButtonState {
        case selected
        case notSelected
        
        init(searchQuery: SearchQuery?) {
            guard let searchQuery else {
                self = .notSelected
                return
            }
            self = searchQuery.isDefaultCondition ? .notSelected : .selected
        }

        var icon: UIImage {
            switch self {
            case .selected:
                return Asset.iconFilterOnHeader.image
            case .notSelected:
                return Asset.iconFilterOffHeader.image
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .selected:
                return .hexStr("FFE8E9", alpha: 1.0)
            case .notSelected:
                return .clear
            }
        }
        
        var font: UIFont {
            switch self {
            case .selected:
                return .systemFont(
                    ofSize: LayoutParam.buttonFontSize,
                    weight: .bold
                )
            case .notSelected:
                return .systemFont(
                    ofSize: LayoutParam.buttonFontSize,
                    weight: .regular
                )
            }
        }
        
        var contentEdgeInsets: UIEdgeInsets {
            switch self {
            case .selected:
                return .init(
                    top: 0,
                    left: LayoutParam.buttonContentPadding + LayoutParam.buttonTitleEdgeInsetsLeft,
                    bottom: 0,
                    right: LayoutParam.buttonContentPadding
                )
            case .notSelected:
                return .init(top: 0, left: LayoutParam.buttonTitleEdgeInsetsLeft, bottom: 0, right: 0)
            }
        }
        
        func toggle() -> Self {
            switch self {
            case .selected:
                return .notSelected
            case .notSelected:
                return .selected
            }
        }
    }
}

// MARK: - NibType
extension ModernBlackboardFilterHeaderView: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernBlackboardFilterHeaderView: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
        addBinding()
        update(searchQuery: dependency.searchQuery)
    }
}

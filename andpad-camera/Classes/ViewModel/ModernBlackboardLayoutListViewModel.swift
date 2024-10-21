//
//  ModernBlackboardLayoutListViewModel.swift
//  andpad-camera
//
//  Created by msano on 2022/04/01.
//

import RxCocoa
import RxSwift

final class ModernBlackboardLayoutListViewModel {
    typealias DataSource = ModernBlackboardLayoutListDataSource
    
    enum Input {
        case viewDidLoad
        case didTapCell(DataSource.Section.Item)
        case didTapCancelButton
        case scrolledDown
    }

    enum Output {
        case dismiss
        case selectNewLayout(DataSource.Section.Item)
    }
    
    let inputPort: PublishRelay<Input> = .init()
    let outputPort: ControlEvent<Output>
    let dataSource = DataSource()
    let items = BehaviorRelay<[DataSource.Section]>(value: [])

    private let disposeBag = DisposeBag()
    private let outputRelay: PublishRelay<Output>

    private let itemBuilder: ItemBuilder

    init(useBlackboardGeneratedWithSVG: Bool) {
        // MARK: - configure Outputs
        let relay = PublishRelay<Output>()
        self.outputPort = .init(events: relay)
        self.outputRelay = relay

        self.itemBuilder = ItemBuilder(useBlackboardGeneratedWithSVG: useBlackboardGeneratedWithSVG)

        inputPort
            .bind(onNext: { [weak self] event in
                switch event {
                case .viewDidLoad:
                    self?.viewDidLoadEvent()
                case .didTapCancelButton:
                    self?.didTapCancelButtonEvent()
                case .scrolledDown:
                    break
                case .didTapCell(let item):
                    self?.didTapCellEvent(item: item)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: variable (included private static state)
extension ModernBlackboardLayoutListViewModel {
    var title: String {
        L10n.Blackboard.Layoutlist.title
    }
}

// MARK: - private
extension ModernBlackboardLayoutListViewModel {
    
    private func viewDidLoadEvent() {
        items.accept([.init(items: itemBuilder.build())])
    }
    
    private func didTapCancelButtonEvent() {
        outputRelay.accept(.dismiss)
    }
    
    private func didTapCellEvent(item: DataSource.Section.Item) {
        outputRelay.accept(.selectNewLayout(item))
    }
}

// MARK: - Item builder
extension ModernBlackboardLayoutListViewModel {

    /// Item 生成に使用するクラス。
    struct ItemBuilder {
        typealias Item = DataSource.Section.Item

        /// 表示統一対応版の黒板レイアウトを利用するかどうか。
        ///
        /// - Note: true の場合は表示統一対応版の黒板レイアウト、falseの場合は既存の黒板レイアウトが表示されます。
        /// - Note: 本フラグはレイアウト共通化に１本化された後は不要になります。
        private let useBlackboardGeneratedWithSVG: Bool

        init(useBlackboardGeneratedWithSVG: Bool) {
            self.useBlackboardGeneratedWithSVG = useBlackboardGeneratedWithSVG
        }

        /// 表示内容を生成する。
        func build() -> [Item] {
            // 黒板の全レイアウト（ただし豆図を持つレイアウトを除く）を表示する
            ModernBlackboardContentView.Pattern.allCasesWithoutMiniatureMapViewLayouts.compactMap { pattern in
                // レイアウト共通化有効の場合はSVGファイルを表示する
                let blackboardImageLoader: any ImageLazyLoading = if useBlackboardGeneratedWithSVG {
                    BlackboardSVGImageLoader(pattern: pattern)
                } else {
                    BlackboardImageLoaderUsingBlackboardView(pattern: pattern)
                }
                return (
                    layoutPattern: pattern,
                    layoutName: "\(pattern.layoutID)",
                    blackboardImageLoader: blackboardImageLoader
                )
            }
        }
    }
}

// MARK: - Image loader
extension ModernBlackboardLayoutListViewModel {

    /// 既存のModernBlackboardView を用いてレイアウト画像の読み込みを行うためのクラス。
    ///
    /// - Note: 本クラスはレイアウト共通化に１本化された後は不要になります。
    struct BlackboardImageLoaderUsingBlackboardView: ImageLazyLoading {
        private let appearance: ModernBlackboardAppearance
        private let layout: ModernBlackboardLayout

        init(pattern: ModernBlackboardContentView.Pattern) {
            self.appearance = ModernBlackboardAppearance(
                theme: .black,
                alphaLevel: .zero,
                dateFormatType: .defaultValue,
                shouldBeReflectedNewLine: false // "(案件名)" 固定表示なので改行の考慮不要(常にfalse)
            )
            self.layout = ModernBlackboardLayout(
                pattern: pattern,
                theme: appearance.theme
            )
        }

        func load() -> UIImage? {
            let blackboardView = ModernBlackboardView(
                layout,
                appearance: appearance,
                miniatureMapImageState: nil,    // 豆図表示は不要
                displayStyle: .withAutoInputInformation
            )
            return blackboardView?.image
        }
    }

    /// SVG画像の読み込みを行うためのクラス。
    ///
    /// - Note: 本クラスはアセットとして登録したSVGファイルを読み込むために使用します。ファイル名は「blackboard_layout_{レイアウト番号}」となっている必要があります。
    struct BlackboardSVGImageLoader: ImageLazyLoading {
        private let pattern: ModernBlackboardContentView.Pattern
        private let fileNamePrefix = "blackboard_layout_"

        init(pattern: ModernBlackboardContentView.Pattern) {
            self.pattern = pattern
        }

        func load() -> UIImage? {
            ImageAsset(name: fileNamePrefix + "\(pattern.layoutID)").image
        }
    }
}

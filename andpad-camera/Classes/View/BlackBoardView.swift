//  BlackBoardView.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/20.
//

import Foundation

protocol LegacyBlackBoardViewProtocol {
    func setViewModel(viewModel: BlackboardMappingModel)
    static func getView(type: BlackBoardType) -> BlackboardBaseView?
    static func getView(
        type: BlackBoardType,
        shouldIgnoreValueOfCombinedItem: Bool
    ) -> BlackboardBaseView?
    static func getActualView(type: BlackBoardType) -> BlackboardBaseView?
    func hideValues()
    func showValues()
}

protocol BlackBoardViewProtocol {}

final class BlackBoardView: BlackboardBaseView {
    private let scaleFactor: CGFloat = 0.2
    private let numberOfLines = 0
    private let textAlignment = NSTextAlignment.left

    @IBOutlet weak var constractionName: UILabel! {
        didSet { setLayoutCondition(to: constractionName) }
    }

    @IBOutlet weak var constractionPlace: UILabel! {
        didSet { setLayoutCondition(to: constractionPlace) }
    }

    @IBOutlet weak var constractionCategory: UILabel! {
        didSet { setLayoutCondition(to: constractionCategory) }
    }

    @IBOutlet weak var constractionPlayer: UILabel! {
        didSet { setLayoutCondition(to: constractionPlayer) }
    }

    @IBOutlet weak var constractionState: UILabel! {
        didSet { setLayoutCondition(to: constractionState) }
    }

    @IBOutlet weak var constractionPhotoClass: UILabel! {
        didSet { setLayoutCondition(to: constractionPhotoClass) }
    }

    @IBOutlet weak var photoTitle: UILabel! {
        didSet { setLayoutCondition(to: photoTitle) }
    }

    @IBOutlet weak var detail: UILabel! {
        didSet { setLayoutCondition(to: detail) }
    }

    @IBOutlet weak var inspectionReportTitle: UILabel! {
        didSet { setLayoutCondition(to: inspectionReportTitle) }
    }

    @IBOutlet weak var inspectionTitle: UILabel! {
        didSet { setLayoutCondition(to: inspectionTitle) }
    }

    @IBOutlet weak var inspectionItem: UILabel! {
        didSet { setLayoutCondition(to: inspectionItem) }
    }

    @IBOutlet weak var inspectionPoint: UILabel! {
        didSet { setLayoutCondition(to: inspectionPoint) }
    }

    @IBOutlet weak var inspector: UILabel! {
        didSet { setLayoutCondition(to: inspector) }
    }

    @IBOutlet weak var client: UILabel! {
        didSet { setLayoutCondition(to: client) }
    }

    @IBOutlet weak var memo: UILabel! {
        didSet { setLayoutCondition(to: memo) }
    }

    @IBOutlet weak var date: UILabel! {
        didSet {
            setLayoutCondition(
                to: date,
                fixTextAlignment: false
            )
        }
    }

    @IBOutlet weak var backGroundImageView: UIImageView!

    @IBOutlet weak var backgroundView: UIView!

    var viewModel: BlackboardMappingModel!

    private var type: BlackBoardType?

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - BlackBoardViewProtocol
extension BlackBoardView: BlackBoardViewProtocol {}

// MARK: - LegacyBlackBoardViewProtocol (元のプロトコル)
extension BlackBoardView: LegacyBlackBoardViewProtocol {
    func setViewModel(viewModel: BlackboardMappingModel) {
        self.viewModel = viewModel

        // templateのタイプによってアウトレットがnilになっているものがあるので全部nilチェックする
        constractionName?.text = viewModel.constractionName
        constractionPlace?.text = viewModel.constractionPlace
        constractionPlayer?.text = viewModel.constractionPlayer
        constractionState?.text = viewModel.constractionState
        constractionPhotoClass?.text = viewModel.constractionPhotoClass
        photoTitle?.text = viewModel.photoTitle
        detail?.text = viewModel.detail
        inspectionReportTitle?.text = viewModel.inspectionReportTitle
        inspectionTitle?.text = viewModel.inspectionTitle
        inspectionItem?.text = viewModel.inspectionItem
        inspectionPoint?.text = viewModel.inspectionPoint
        inspector?.text = viewModel.inspector
        client?.text = viewModel.client
        memo?.text = viewModel.memo
        constractionCategory?.text = viewModel.constractionCategory
        date?.text = viewModel.date?.asDateString()

        if let backGroundImageView = backGroundImageView {
            backGroundImageView.alpha = viewModel.alpha
        }

        if let backgroundView = backgroundView {
            backgroundView.alpha = viewModel.alpha
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    // 処理共通化
    static func getBaseView(_ type: BlackBoardType, isActual: Bool = false) -> BlackboardBaseView? {

        guard let nib = Bundle.andpadCamera.loadNibNamed(type.getNibName(), owner: self, options: nil),
              let baseView = nib.first as? BlackboardBaseView else {
            return nil
        }

        // 本来不要だが従来と挙動を揃えるために書いておく
        baseView.frame = isActual ? type.getActualFrame() : type.getFrame()

        return baseView
    }

    static func getView(type: BlackBoardType) -> BlackboardBaseView? {
        getView(type: type, shouldIgnoreValueOfCombinedItem: true)
    }

    static func getView(
        type: BlackBoardType,
        shouldIgnoreValueOfCombinedItem: Bool // 値のみ表示可能な項目エリアにおいて、true = なにも表示しない / false = 値を表示する
    ) -> BlackboardBaseView? {
        getBaseView(type)
    }

    static func getActualView(type: BlackBoardType) -> BlackboardBaseView? {
        return getBaseView(type, isActual: true)
    }

    func hideValues() {
        switchShowingValues(isHidden: true)
    }

    func showValues() {
        switchShowingValues(isHidden: false)
    }
}

// MARK: - private
extension BlackBoardView {
    private func setLayoutCondition(to label: UILabel, fixTextAlignment: Bool = true) {
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = scaleFactor
        label.numberOfLines = numberOfLines
        if fixTextAlignment {
            label.textAlignment = textAlignment
        }
    }

    private func switchShowingValues(isHidden: Bool) {
        guard let type, !type.isInspection else { return }

        constractionName?.isHidden = isHidden
        constractionPlace?.isHidden = isHidden
        constractionCategory?.isHidden = isHidden
        constractionPlayer?.isHidden = isHidden
        constractionState?.isHidden = isHidden
        constractionPhotoClass?.isHidden = isHidden
        photoTitle?.isHidden = isHidden
        detail?.isHidden = isHidden
        inspectionReportTitle?.isHidden = isHidden
        inspectionTitle?.isHidden = isHidden
        inspectionItem?.isHidden = isHidden
        inspectionPoint?.isHidden = isHidden
        inspector?.isHidden = isHidden
        client?.isHidden = isHidden
        memo?.isHidden = isHidden
        date?.isHidden = isHidden
    }
}

//
//  ModernEditBlackboardViewController.swift
//  andpad-camera-andpad-camera
//
//  Created by msano on 2022/01/25.
//

import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift
import SnapKit
import UIKit
import AndpadUIComponent

// NOTE:
// 新たに新黒板用に用意する編集画面
// （後ほどリネームする予定です）

public final class ModernEditBlackboardViewController: UIViewController {
    typealias ViewModel = ModernEditBlackboardViewModel
    
    public var modernCompletedHandler: ((CompletedHandlerData) -> Void)?
    
    public struct CompletedHandlerData {
        public let modernBlackboardMaterial: ModernBlackboardMaterial
        public let modernBlackboardAppearance: ModernBlackboardAppearance
        public let blackboardEditLogs: [BlackboardEditLoggingHandler.BlackboardType]
        /// 黒板のスタイル変更可否
        let canEditBlackboardStyle: Bool
        /// APIから取得した黒板のサイズタイプ
        let blackboardSizeTypeOnServer: ModernBlackboardAppearance.ModernBlackboardSizeType
        /// APIから取得した撮影画像形式
        let preferredPhotoFormat: ModernBlackboardCommonSetting.PhotoFormat
    }
    
    /// 黒板編集画面の遷移先の選択用黒板一覧でキャンセルボタンがタップされたときのハンドラー
    var selectableBlackboardListCancelResultHandler: ((ModernBlackboardListViewModel.CancelResult) -> Void)?

    public struct Dependency {
        let viewModel: ViewModel
    }
    
    private var viewModel: ViewModel!
    private let disposeBag = DisposeBag()
    
    private enum Const {
        static let sectionNum = 1
        static let sectionItems = 0
        static let scrollingThreshold: RxTimeInterval = .milliseconds(600)
        static let animatePreviewDuration: TimeInterval = 0.3
        static let animatePreviewCurve: UIView.AnimationCurve = .easeInOut
    }
    
    private enum LayoutParams {
        static let tableHeaderViewHeight: CGFloat = 24
        static let tableFooterViewHeight: CGFloat = 16
    }
    
    // IBOutlet
    
    @IBOutlet weak var tableView: TouchableTableView!
    @IBOutlet private weak var previewContainerView: UIView!
    @IBOutlet private weak var previewContainerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var offlineModeBar: OfflineModeBar!
    
    // MARK: - Subviews

    /// 従来方式の黒板レイアウト表示 (表示統一対応版に一本化したら本クラスは削除される想定)
    private var previewView: ModernBlackboardPreviewView?
    /// 表示統一対応用の黒板レイアウト(WKWebViewでSVG形式の黒板を表示する方式)
    private var previewWebView: ModernBlackboardPreviewWebView?
    private var isScrollingTableView = false
    private var isShowKeyboard = false
    
    private var modernBlackboardListViewController: ModernBlackboardListViewController?
    
    /// 拡大・縮小に使用するプレビュー View を取得する
    ///
    /// - Note: レイアウト自由化によって従来方式の黒板レイアウト表示が使われなくなるため、本プロパティは将来的に削除されます。
    private var expandablePreviewView: BlackboardPreviewExpandable? {
        if viewModel.useBlackboardGeneratedWithSVG {
            previewWebView
        } else {
            previewView
        }
    }

    /// 画面内で編集できる範囲
    public enum EditableScope: Equatable {
        /// 全て編集可能
        case all
        
        /// 黒板項目のみ編集可能
        case onlyBlackboardItems
        
        /// 黒板の上書き保存の権限があるか（こちらはあくまで内部ロジック上の権限で、サーバ側からも同権限の取得、比較が必要）
        var hasOverwriteBlackboardLocalPermission: Bool {
            switch self {
            case .all:
                return false
            case .onlyBlackboardItems:
                return true
            }
        }
    }
    
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isScrollingTableView else { return } // スクロール中は無視する

        let isInputView = touches.first {
            switch $0.view {
            case is UITextField, is UITextView:
                return true
            default:
                return false
            }
        }
        guard isInputView == nil else { return }

        if let event = event {
            switch event.type {
            case .touches:
                view.endEditing(true)
            default:
                break
            }
        }
    }
    
    // life cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addBinding()

        viewModel.inputPort.accept(.viewDidLoad)
    }
}

// MARK: - private (configuring)
extension ModernEditBlackboardViewController {
    private func configureView() {
        
        overrideUserInterfaceStyle = .light
        
        // configure navigationBar
        title = viewModel.title
        navigationItem.leftBarButtonItem = .init(
            image: Asset.iconCancel.image.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: nil
        )
        navigationItem.rightBarButtonItem = .init(
            title: L10n.Common.done,
            style: .done,
            target: self,
            action: nil
        )
        navigationController?.navigationBar.setModalBar()
        
        // configure previewContainerView
        setUpPreviewView()

        // configure tableView
        tableView.type = .edit(viewModel.editableScope)
        tableView.hasMiniatureMap = viewModel.hasMiniatureMapAtInit
        tableView.registerNib(type: ModernEditBlackboardErrorCell.self)
        tableView.registerNib(type: ModernBlackboardItemInputsCell.self)
        tableView.registerNib(type: EditMiniatureMapCell.self)
        tableView.registerNib(type: ModernMemoStyleCell.self)
        tableView.registerNib(type: ModernThemeCell.self)
        tableView.registerNib(type: ModernBlackboardAlphaCell.self)
        tableView.rx.setDelegate(viewModel.dataSource)
            .disposed(by: disposeBag)
        let tableHeaderView = UIView(
            frame: .init(
                x: .zero,
                y: .zero,
                width: view.frame.width,
                height: LayoutParams.tableHeaderViewHeight
            )
        )
        let tableFooterView = UIView(
            frame: .init(
                x: .zero,
                y: .zero,
                width: view.frame.width,
                height: LayoutParams.tableFooterViewHeight
            )
        )
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = tableFooterView
        
        // configure saveButton
        updateSaveButtonsState(isEnabled: true)
    }

    private func setUpPreviewView() {
        // Remote Configから取得した黒板の生成方法にもとづいて、処理を分岐する。
        if viewModel.useBlackboardGeneratedWithSVG {
            // HTMLで黒板を表示
            previewWebView = .init(with: .init(parentType: .editModernBlackboard(viewModel.editableScope)))
            guard let previewWebView else {
                return
            }
            previewContainerView.addSubview(previewWebView)
            previewWebView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            Task {
                viewModel.updatePreviewWebViewSize(previewWebView.previewWebViewSize)
                guard let query = await viewModel.makeInitialBlackboardWebViewQuery() else {
                    // クエリが取得できなかったら、黒板を更新しない
                    return
                }
                previewWebView.updateLayout(query: query)
            }
        } else {
            // HTMLを使わない従来の画像化で黒板を表示
            previewView = .init(with: .init(parentType: .editModernBlackboard(viewModel.editableScope)))
            guard let previewView else {
                return
            }
            previewContainerView.addSubview(previewView)
            previewView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            previewView.updateImage(
                by: viewModel.initialModernBlackboardMaterial,
                appearrance: viewModel.initialBlackboardViewAppearance,
                miniatureMapImageState: nil // 初期は空で表示
            )
        }

        view.sendSubviewToBack(previewContainerView)
    }

    private func addBinding() {
        // for navigationBarItem
        navigationItem.leftBarButtonItem?.rx.tap
            .asSignal()
            .map { ViewModel.Input.didTapCancelButton }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .asSignal()
            .map { ViewModel.Input.didTapSaveButton }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        // for keyboard
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .filter { [weak self] _ in
                guard let self else { return false }
                return !self.isShowKeyboard
            }
            .subscribe(onNext: { [weak self] in
                self?.shrinkPreview()
                self?.expandTableviewContentInset($0)
                self?.isShowKeyboard = true
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .filter { [weak self] _ in
                guard let self else { return false }
                return self.isShowKeyboard
            }
            .subscribe(onNext: { [weak self] _ in
                self?.expandPreview()
                self?.shrinkTableviewContentInset()
                self?.isShowKeyboard = false
            })
            .disposed(by: disposeBag)
        
        // for previewView（HTMLによる黒板）
        previewWebView?.tapArrowButton
            .map { ViewModel.Input.didTapArrowButton }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)

        previewWebView?.tapSelectBlackboardButton
            .map { ViewModel.Input.didTapSelectBlackboardButton }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)

        // for previewView（HTMLを使わない従来の画像化）
        previewView?.tapArrowButton
            .map { ViewModel.Input.didTapArrowButton }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
         previewView?.tapSelectBlackboardButton
            .map { ViewModel.Input.didTapSelectBlackboardButton }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        // for tableView
        viewModel.items
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map { _ in ViewModel.Input.didTapCell }
            .bind(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        tableView.tapSelectLayoutButtonRelay
            .map { ViewModel.Input.didTapSelectLayoutButton }
            .bind(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        tableView.rx.didScroll
            .asSignal()
            .do(onNext: { [weak self] in self?.isScrollingTableView = true })
            .debounce(Const.scrollingThreshold)
            .emit(onNext: { [weak self] in self?.isScrollingTableView = false })
            .disposed(by: disposeBag)

        tableView.rx.didEndDecelerating
            .asSignal()
            .debounce(Const.scrollingThreshold)
            .emit(onNext: { [weak self] in self?.isScrollingTableView = false })
            .disposed(by: disposeBag)
             
        tableView.updateErrorCellHeightSignal
                .emit(onNext: { [weak self] in self?.tableView.reloadData() })
                .disposed(by: disposeBag)
                
        tableView.updateBlackboardItemsSignal
            .map { ViewModel.Input.updateBlackboardItems($0) }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)
                
        tableView.updateMemoStyleSignal
            .map { ViewModel.Input.update($0) }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        tableView.updateThemeSignal
            .map { ViewModel.Input.update($0) }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)
        
        tableView.updateAlphaSignal
            .map { ViewModel.Input.update($0) }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)

        // NOTE: このアクションに限りVMは何もせず、外部から渡されたハンドラーを発火させるのみとする
        tableView.tapMiniatureMapButtonSignal
            .emit(onNext: { [weak self] image in
                guard let self,
                      let handler = self.viewModel.tappedMiniatureMapCellHandler else { return }
                handler(image, self)
            })
            .disposed(by: disposeBag)

        tableView.constructionNameDidTapSignal
            .emit(onNext: { [weak self] _ in
                let alertController = UIAlertController.editConstructionNameInBlackboardEditAlert { _ in
                    self?.viewModel.inputPort.accept(.didTapEditButtonInAlert)
                }
                self?.present(alertController, animated: true)
            })
                
        viewModel.outputPort
            .bind(onNext: { [weak self] event in
                guard let self else { return }
                switch event {
                case .updatePreview(let materialAndAppearance, let miniatureMapImageState):
                    self.previewView?.updateImage(
                        by: materialAndAppearance.blackboardMaterial,
                        appearrance: materialAndAppearance.appearance,
                        miniatureMapImageState: miniatureMapImageState
                    )
                case .updateWebPreview(let query):
                    previewWebView?.updateLayout(query: query)
                case .changeSaveButtonState:
                    break // 現状、なにもする必要がなくなったため、なにもしていない
                case .dismiss(let arguments):
                    if let arguments {
                        modernCompletedHandler?(arguments)
                    }

                    guard self.hasBlackboardListViewController else {
                        self.view.endEditing(true)
                        self.dismiss(animated: true)
                        return
                    }
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                case .endEditing:
                    self.view.endEditing(true)
                case .presentBlackboardListViewController(let arguments):
                    guard !self.hasBlackboardListViewController else {
                        // 既に黒板一覧をスタックしている場合、presentせず、自身をdismissする
                        self.view.endEditing(true)
                        self.dismiss(animated: true)
                        return
                    }
                    self.modernBlackboardListViewController = AppDependencies.shared.modernBlackboardListViewController(arguments)
                    guard let modernBlackboardListViewController = self.modernBlackboardListViewController else { return }
                    
                    modernBlackboardListViewController.didTapBlackboardImageButtonSignal
                        .map { ViewModel.Input.didTapBlackboardImageButtonInBlackboardListView($0) }
                        .emit(to: self.viewModel.inputPort)
                        .disposed(by: modernBlackboardListViewController.disposeBag)
                    
                    modernBlackboardListViewController.didTapEditButtonSignal
                        .map { ViewModel.Input.didTapEditButtonInBlackboardListView($0) }
                        .emit(to: self.viewModel.inputPort)
                        .disposed(by: modernBlackboardListViewController.disposeBag)
                    
                    modernBlackboardListViewController.didTapTakePhotoButtonSignal
                        .map { ViewModel.Input.didTapTakePhotoButtonInBlackboardListView($0) }
                        .emit(to: self.viewModel.inputPort)
                        .disposed(by: modernBlackboardListViewController.disposeBag)

                    modernBlackboardListViewController.cancelResultHandler = selectableBlackboardListCancelResultHandler

                    let navigationController = UINavigationController(rootViewController: modernBlackboardListViewController)
                    navigationController.modalPresentationStyle = .overFullScreen
                    navigationController.modalTransitionStyle = .crossDissolve
                    self.present(navigationController, animated: true)
                case .presentBlackboardLayoutListViewController:
                    let viewController = AppDependencies.shared.modernBlackboardLayoutListViewController()
                    
                    // 新しいレイアウトパターンを取得した時
                    viewController.selectNewLayoutPatternSignal
                        .map { ViewModel.Input.receiveNewLayoutPattern($0) }
                        .emit(to: self.viewModel.inputPort)
                        .disposed(by: self.disposeBag)
                    
                    let navigationController = UINavigationController(rootViewController: viewController)
                    navigationController.modalPresentationStyle = .overFullScreen
                    self.present(navigationController, animated: true)
                case .showErrorMessage(let error):
                    self.present(
                        UIAlertController.errorAlertWithOKButton(error: error),
                        animated: true
                    )
                case .showPostBlackboardErrorMessage:
                    self.present(
                        UIAlertController.postNewBlackboardNetworkErrorAlert(),
                        animated: true
                    )
                case .showLoadingView:
                    self.showLoading()
                case .hideLoadingView:
                    self.hideLoading()
                case .showValidateErrorAlert:
                    self.present(
                        UIAlertController.commonBlackboardValidateErrorAlert(
                            okHandler: { [weak self] _ in self?.tableView.scrollToTop() }
                        ),
                        animated: true
                    )
                case .showDestoryEditingBlackboardAlert(let okHandler):
                    self.present(
                        UIAlertController.destroyEditingBlackboardAlert(okHandler: okHandler),
                        animated: true
                    )
                case .showWillSelectNewLayoutAlert(let okHandler):
                    self.present(
                        UIAlertController.willSelectNewLayoutAlert(okHandler: okHandler),
                        animated: true
                    )
                case .showOverwriteOrCreateNewAlert(let overwriteHandler, let createNewHandler):
                    self.present(
                        UIAlertController.overwriteOrCreateNewAlert(
                            overwriteHandler: overwriteHandler,
                            createNewHandler: createNewHandler
                        ),
                        animated: true
                    )
                case .showUpdateBlackboardByAdminActionAlert(let okHandler, let cancelHandler):
                    self.present(
                        UIAlertController.updateBlackboardByAdminActionAlert(
                            okHandler: okHandler,
                            cancelHandler: cancelHandler
                        ),
                        animated: true
                    )
                case .returnToEditViewController(let blackboardMaterial, let appearance):
                    // （表示中の黒板一覧の裏に黒板編集がいる状態なので）黒板一覧を閉じる
                    self.modernBlackboardListViewController?.dismiss(animated: true)

                    // 新しい黒板データを編集画面に渡し、画面を更新
                    self.replace(
                        otherBlackboardMaterial: blackboardMaterial,
                        blackboardViewAppearance: appearance
                    )
                case .returnToTakeCameraViewController(let data):
                    self.returnTakeCameraByBlackboardList(completedHandlerData: data)
                case .updateSaveButtonState(let isEnabled):
                    self.updateSaveButtonsState(isEnabled: isEnabled)
                case .showDuplicateBlackboardAlert(let viewType, let confirmBlackboardHandler):
                    self.present(
                        UIAlertController.duplicateBlackboardAlert(
                            viewType: viewType,
                            confirmBlackboardHandler: confirmBlackboardHandler
                        ),
                        animated: true
                    )
                case .showAppStoreAlert:
                    self.present(
                        UIAlertController.moveAppStoreAlert(),
                        animated: true
                    )
                case .update(let hasMiniatureMap):
                    self.tableView.hasMiniatureMap = hasMiniatureMap
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isOfflineMode
            .subscribe(onNext: { [weak self] isOfflineMode in
                self?.offlineModeBar.isHidden = !isOfflineMode
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - private (for present / dismiss logic)
extension ModernEditBlackboardViewController {
    /// 黒板一覧画面が既にスタックされているか / 否か
    private var hasBlackboardListViewController: Bool {
        self.hasAlreadyStacked(
            vcType: ModernBlackboardListViewController.self,
            findType: .presenting
        )
    }
    
    // 黒板一覧起因のアクションで、カメラ画面まで戻る
    private func returnTakeCameraByBlackboardList(completedHandlerData data: CompletedHandlerData) {
        modernCompletedHandler?(data)

        // 編集画面から呼び出しているのは自明のため、そのままdismissする
        presentingViewController?.dismiss(animated: true)
    }
}

// MARK: - private (for preview)
extension ModernEditBlackboardViewController {
    /// 黒板プレビューを縮小させる
    private func shrinkPreview() {
        let shrinkPreviewAnimator = UIViewPropertyAnimator(
            duration: Const.animatePreviewDuration,
            curve: Const.animatePreviewCurve
        )
        shrinkPreviewAnimator.addAnimations { [weak self] in
            guard let self else { return }
            previewContainerTopMarginConstraint.constant = expandablePreviewView?.calculateNegativeTopMarginForShrinkMode(currentPreviewHeight: previewContainerView.frame.height) ?? 0
            view.layoutIfNeeded()
            expandablePreviewView?.shrink()
        }
        shrinkPreviewAnimator.startAnimation()
    }

    /// 黒板プレビューを拡大させる
    private func expandPreview() {
        let expandPreviewAnimator = UIViewPropertyAnimator(
            duration: Const.animatePreviewDuration,
            curve: Const.animatePreviewCurve
        )
        expandPreviewAnimator.addAnimations { [weak self] in
            guard let self else { return }
            previewContainerTopMarginConstraint.constant = 0
            view.layoutIfNeeded()
            expandablePreviewView?.expand()
        }
        expandPreviewAnimator.addCompletion { [weak self] _ in
            self?.expandablePreviewView?.doneExpand()
        }
        expandPreviewAnimator.startAnimation()
    }

    /// （黒板プレビューの縮小に合わせ）リスト末尾の余白を拡大する
    private func expandTableviewContentInset(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let newContentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        tableView.contentInset = newContentInset
        tableView.scrollIndicatorInsets = newContentInset
    }

    /// （黒板プレビューの拡大に合わせ）リスト末尾の余白を縮小する
    private func shrinkTableviewContentInset() {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
}

// MARK: - private (for save buttons)
extension ModernEditBlackboardViewController {
    private func updateSaveButtonsState(isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
}

extension ModernEditBlackboardViewController {
    /// カメラ画面に表示中の黒板とは異なる黒板を編集する場合、こちらをコールする
    func replace(
        otherBlackboardMaterial: ModernBlackboardMaterial,
        blackboardViewAppearance: ModernBlackboardAppearance
    ) {
        viewModel.inputPort.accept(
            .replaceOtherBlackboardMaterialAndAppearance(
                otherBlackboardMaterial,
                blackboardViewAppearance
            )
        )
    }
}

// MARK: - NibType
extension ModernEditBlackboardViewController: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension ModernEditBlackboardViewController: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
         viewModel = dependency.viewModel
    }
}

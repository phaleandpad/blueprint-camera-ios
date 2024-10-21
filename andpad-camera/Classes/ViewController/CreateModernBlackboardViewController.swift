//
//  CreateModernBlackboardViewController.swift
//  andpad-camera
//
//  Created by msano on 2022/04/06.
//
import Instantiate
import InstantiateStandard
import RxCocoa
import RxSwift
import SnapKit
import UIKit
import AndpadUIComponent

public final class CreateModernBlackboardViewController: UIViewController {
    typealias ViewModel = CreateModernBlackboardViewModel
    
    public var modernCompletedHandler: ((CompletedHandlerData) -> Void)?
    
    public struct CompletedHandlerData {
        public let modernBlackboardMaterial: ModernBlackboardMaterial
        public let modernBlackboardAppearance: ModernBlackboardAppearance
        public let blackboardEditLogs: [BlackboardEditLoggingHandler.BlackboardType]
        public let shouldShowToastView: Bool
    }
    
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
    
    // MARK: - Subviews

    /// 従来方式の黒板レイアウト表示 (表示統一対応版に一本化したら本クラスは削除される想定)
    private let previewView = ModernBlackboardPreviewView(with: .init(parentType: .createModernBlackboard))
    /// 表示統一対応用の黒板レイアウト(WKWebViewでSVG形式の黒板を表示する方式)
    private let previewWebView = ModernBlackboardPreviewWebView(with: .init(parentType: .createModernBlackboard))
    private var isScrollingTableView = false
    private var isShowKeyboard = false

    /// 拡大・縮小に使用するプレビュー View を取得する
    ///
    /// - Note: レイアウト自由化によって従来方式の黒板レイアウト表示が使われなくなるため、本プロパティは将来的に削除されます。
    private var expandablePreviewView: BlackboardPreviewExpandable {
        if viewModel.useBlackboardGeneratedWithSVG {
            previewWebView
        } else {
            previewView
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
extension CreateModernBlackboardViewController {
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
        if viewModel.useBlackboardGeneratedWithSVG {
            // ここではレイアウトの設定をするに留める (レイアウトへのデータのセットは別な場所で実施する)
            previewContainerView.addSubview(previewWebView)
            previewWebView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            // ViewModel にサイズ情報を格納するため、制約を即時で反映させる
            previewWebView.setNeedsLayout()
            Task {
                await MainActor.run {
                    previewWebView.layoutIfNeeded()
                }
                viewModel.setBlackboardLayoutSize(previewWebView.previewWebViewSize)
            }
        } else {
            previewContainerView.addSubview(previewView)
            previewView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            previewView.updateImage(
                by: viewModel.originalModernBlackboardMaterial,
                appearrance: viewModel.originalBlackboardViewAppearance,
                // 現状、新規作成時に豆図レイアウトを選択することはできないため、常にnilを渡す
                miniatureMapImageState: nil
            )
        }

        view.sendSubviewToBack(previewContainerView)
        
        // configure tableView
        tableView.registerNib(type: ModernEditBlackboardErrorCell.self)
        tableView.registerNib(type: ModernBlackboardItemInputsCell.self)
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
        
        // for previewView
        previewView.tapArrowButton
            .map { ViewModel.Input.didTapArrowButton }
            .emit(to: viewModel.inputPort)
            .disposed(by: disposeBag)

        previewWebView.tapArrowButton
            .map { ViewModel.Input.didTapArrowButton }
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
        
        viewModel.outputPort
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] event in
                guard let self else { return }
                switch event {
                case .updatePreview(let arguments):
                    self.previewView.updateImage(
                        by: arguments.blackboardMaterial,
                        appearrance: arguments.appearance,
                        // 現状、新規作成時に豆図レイアウトを選択することはできないため、常にnilを渡す
                        miniatureMapImageState: nil
                    )
                case .updateWebPreview(let query):
                    Task { @MainActor in
                        self.previewWebView.updateLayout(query: query)
                    }
                case .changeSaveButtonState:
                    break // 現状、なにもする必要がなくなったため、なにもしていない
                case .dismiss(let arguments):
                    if let arguments = arguments {
                        self.modernCompletedHandler?(arguments)
                    }
                    
                    guard self.hasBlackboardListViewController else {
                        self.view.endEditing(true)
                        self.dismiss(animated: true)
                        return
                    }
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                case .endEditing:
                    self.view.endEditing(true)
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
                case .showErrorMessage:
                    self.present(
                        UIAlertController.commonBlackboardNetworkErrorAlert(),
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
                case .showDestoryEditingBlackboardAlert(let fromCancelButton, let okHandler):
                    // 呼び出し元に応じて、微妙に表示文言を変えている（ただ、どちらも現データを破棄していいか問いかけるアラートではある）
                    self.present(
                        fromCancelButton
                            ? UIAlertController.destroyEditingBlackboardAlert(okHandler: okHandler)
                            : UIAlertController.willSelectNewLayoutAlert(okHandler: okHandler),
                        animated: true
                    )
                case .updateSaveButtonState(let isEnabled):
                    self.updateSaveButtonsState(isEnabled: isEnabled)
                case .showDuplicateBlackboardAlert(let confirmBlackboardHandler):
                    self.present(
                        UIAlertController.duplicateBlackboardAlert(
                            viewType: .createModernBlackboard,
                            confirmBlackboardHandler: confirmBlackboardHandler
                        ),
                        animated: true
                    )
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - private (for save buttons)
extension CreateModernBlackboardViewController {
    private func updateSaveButtonsState(isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
}

// MARK: - private (for present / dismiss logic)
extension CreateModernBlackboardViewController {
    /// 黒板一覧画面が既にスタックされているか / 否か
    private var hasBlackboardListViewController: Bool {
        self.hasAlreadyStacked(
            vcType: ModernBlackboardListViewController.self,
            findType: .presenting
        )
    }
    
    // 黒板一覧起因のアクションで、カメラ画面まで戻る
    private func returnTakeCameraByBlackboardList(blackboardMaterial: ModernBlackboardMaterial, appearance: ModernBlackboardAppearance) {
        modernCompletedHandler?(
            .init(
                modernBlackboardMaterial: blackboardMaterial,
                modernBlackboardAppearance: appearance,
                blackboardEditLogs: BlackboardEditLoggingHandler.blackboardTypes,
                shouldShowToastView: false
            )
        )
        // 編集画面から呼び出しているのは自明のため、そのままdismissする
        presentingViewController?.dismiss(animated: true)
    }
}

// MARK: - private (for preview)
extension CreateModernBlackboardViewController {
    /// 黒板プレビューを縮小させる
    private func shrinkPreview() {
        let shrinkPreviewAnimator = UIViewPropertyAnimator(
            duration: Const.animatePreviewDuration,
            curve: Const.animatePreviewCurve
        )
        shrinkPreviewAnimator.addAnimations { [weak self] in
            guard let self else { return }
            previewContainerTopMarginConstraint.constant = expandablePreviewView.calculateNegativeTopMarginForShrinkMode(currentPreviewHeight: previewContainerView.frame.height)
            view.layoutIfNeeded()
            expandablePreviewView.shrink()
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
            self?.previewContainerTopMarginConstraint.constant = 0
            self?.view.layoutIfNeeded()
            self?.expandablePreviewView.expand()
        }
        expandPreviewAnimator.addCompletion { [weak self] _ in self?.expandablePreviewView.doneExpand() }
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

// MARK: - NibType
extension CreateModernBlackboardViewController: NibType {
    public static var nibBundle: Bundle {
        .andpadCamera
    }
}

// MARK: - NibInstantiatable
extension CreateModernBlackboardViewController: NibInstantiatable {
    public func inject(_ dependency: Dependency) {
         viewModel = dependency.viewModel
    }
}

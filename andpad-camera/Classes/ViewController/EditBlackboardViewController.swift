//
//  EditBlackboardViewController.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/23.
//

import EasyPeasy
import UIKit

final class EditBlackboardViewController: UITableViewController {

    var completedHandler: ((UIViewController?, BlackboardMappingModel, BlackBoardType) -> Void)?
    var didTapCancelButtonHandler: (() -> Void)?

    private let SECTION_NUM = 2
    private let SECTION_TEMPLATE = 0
    private let SECTION_ITEMS = 1

    // MARK: - Subviews
    private let saveButton: UIButton = .init()
    // 工事名を編集するとクラッシュするが起きなくなる対処に使う用のTextField。表示はしない。
    private let amuletTextField: UITextField = .init()
    private var viewModel: BlackboardMappingModel!

    var selectedType: BlackBoardType?
    var items: [BlackboardItem] = []
    var values: [Any?] = []
    private var templateImage: UIImage?

    enum ReuseCellIdentifier: String, CaseIterable {
        case template = "BlackboardTemplateCell"
        case textField = "TextFieldCell"
        case textArea = "TextAreaCell"
        case alpha = "BlackboardAlphaCell"

        var string: String {
            rawValue
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        overrideUserInterfaceStyle = .light

        title = L10n.Common.Title.changeBlackboard

        navigationItem.rightBarButtonItem = .init(
            title: L10n.Common.done,
            style: .done,
            target: self,
            action: #selector(didTapSaveButton(_:))
        )

        let cancelImage = UIImage(
            named: "icon_cancel",
            in: .andpadCamera,
            compatibleWith: nil
        )

        navigationItem.leftBarButtonItem = .init(
            image: cancelImage?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(didTapCancelButton)
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()

        initView()

        saveButton: do {
            saveButton.translatesAutoresizingMaskIntoConstraints = false

            saveButton.setTitle(L10n.Common.done, for: .normal)
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.titleLabel?.font = .boldSystemFont(ofSize: 17.0)
            saveButton.backgroundColor = .andpadRed
            saveButton.layer.cornerRadius = 24.0

            view.addSubview(saveButton)

            saveButton.easy.layout(
                Width(96.0),
                Height(48.0)
            )

            saveButton.addTarget(
                self,
                action: #selector(didTapSaveButton(_:)),
                for: .touchUpInside
            )
        }

        setAccessibilityIdentifiers()
    }

    override func viewDidLayoutSubviews() {
        saveButton.frame.origin.x = self.tableView.contentSize.width - saveButton.frame.width - 16
        saveButton.frame.origin.y = self.tableView.contentSize.height - saveButton.frame.height - 16
        self.view.layoutIfNeeded()
    }

    func setViewModel(viewModel: BlackboardMappingModel) {
        self.viewModel = viewModel
    }

    private func updateView() {
        updateTemplateImage()
        tableView.reloadData()
    }

    private func initView() {

        tableView.allowsSelection = false

        let tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 100.0))
        tableView.tableFooterView = tableFooterView
        title = L10n.Common.Title.editCase

        let podBundle = Bundle(for: classForCoder.self)
        let bundleURL = podBundle.url(forResource: "andpad-camera", withExtension: "bundle")!
        let bundle = Bundle(url: bundleURL)

        ReuseCellIdentifier.allCases.forEach {
            tableView.register(
                UINib(nibName: $0.string, bundle: bundle),
                forCellReuseIdentifier: $0.string
            )
        }
        updateView()
        navigationController?.navigationBar.setModalBar()
    }

    private func updateTemplateImage() {
        if let type = selectedType {
            templateImage = type.getTemplateImage(
                view: view,
                isHiddenValues: true
            )
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    @objc func didTapCancelButton() {
        self.view.endEditing(true)
        didTapCancelButtonHandler?()
        self.dismiss(animated: true, completion: nil)
    }

    private func save() {
        self.view.endEditing(true)
        selectedType?.setViewModelParams(viewModel, items: items, values: values)
        completedHandler?(self, self.viewModel, selectedType ?? .case0)
        dismiss(animated: true, completion: nil)
    }

    func setSelectedType(type: BlackBoardType) {
        selectedType = type
        items = selectedType?.getItems() ?? []
        values = selectedType?.getValues(viewModel: viewModel) ?? []
    }

    @objc private func didTapSaveButton(_ sender: Any) {
        save()
    }

    private func setAccessibilityIdentifiers() {
        navigationController?.navigationBar.viewAccessibilityIdentifier = .editLegacyBlackboardViewNavigationBar
        navigationItem.leftBarButtonItem?.viewAccessibilityIdentifier = .editLegacyBlackboardViewCloseButton
        navigationItem.rightBarButtonItem?.viewAccessibilityIdentifier = .editLegacyBlackboardViewNavigationBarSaveButton
        saveButton.viewAccessibilityIdentifier = .editLegacyBlackboardSaveButton
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension EditBlackboardViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SECTION_NUM
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case SECTION_TEMPLATE:
            return 1
        case SECTION_ITEMS:
            return items.count
        default:
            fatalError()
        }
    }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let defaultHeight: CGFloat = 80.0

        switch indexPath.section {
        case SECTION_TEMPLATE:
            return 220.0
        case SECTION_ITEMS:
            let item = self.items[indexPath.row]
            return item.type?.height() ?? defaultHeight
        default:
            return defaultHeight
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SECTION_TEMPLATE:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReuseCellIdentifier.template.string, for: indexPath) as? BlackboardTemplateCell else {
                fatalError()
            }
            cell.configure(isHiddenButtonView: false)
            cell.templateImage.image = templateImage
            cell.addObserver { [weak self] in
                self?.goToTemplateList()
            }
            return cell
        case SECTION_ITEMS:
            let item = self.items[indexPath.row]
            let value = self.values[indexPath.row]

            switch item.type {
            case .textField, .date:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ReuseCellIdentifier.textField.string,
                    for: indexPath
                ) as? TextFieldCell else {
                    assertionFailure()
                    return UITableViewCell()
                }
                cell.textField.delegate = self
                cell.setItem(item: item, value: value)
                cell.addObserver { [weak self] value in
                    self?.values[indexPath.row] = value
                }
                return cell
            case .textArea:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ReuseCellIdentifier.textArea.string,
                    for: indexPath
                ) as? TextAreaCell else {
                    assertionFailure()
                    return UITableViewCell()
                }
                cell.label.text = item.name
                cell.setItem(item: item, value: value)
                cell.addObserver { [weak self] value in
                    self?.values[indexPath.row] = value
                }
                return cell
            case .alpha:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ReuseCellIdentifier.alpha.string,
                    for: indexPath
                ) as? BlackboardAlphaCell else {
                    assertionFailure()
                    return UITableViewCell()
                }
                cell.setItem(item: item, value: value)
                cell.addObserver { [weak self] value in
                    self?.values[indexPath.row] = value
                }
                return cell
            case  .theme, .memoStyle, .none:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // fix for https://github.com/88labs/andpad-camera-ios/issues/12
        amuletTextField.resignFirstResponder()
    }

    private func goToTemplateList() {
        let storyboard = UIStoryboard(name: "TemplateList", bundle: .andpadCamera)

        // Note:
        // 下のguard文の中でstoryboardの中から取り出すと何故かviewControllerが取得できないため
        // 一旦変数に取り出してからunwrapする
        let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController
        let viewController = navigationController?.viewControllers.first as? TemplateListViewController

        guard
            let nextNavigationController = navigationController,
            let templateListVC = viewController
        else {
            assertionFailure("Could not load correct view controller from storyboard.")
            return
        }

        templateListVC.completedHandler = { [weak self] bbtype in
            self?.setSelectedType(type: bbtype)
            self?.updateView()
        }

        present(nextNavigationController, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension EditBlackboardViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.setHighlightedBottomBorder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // iOS 17において、このタイミングでsetBottomBorderを呼ぶとアプリがクラッシュすることが判明した。
        // 現状、iOS 15以降においては、setHighlightedBottomBorderが機能していないため、このタイミングでsetBottomBorderを呼ぶ必要がなくなった。
        // 障害対応であることを考慮し、影響を最小限にするため、iOS 17以降でsetBottomBorderを呼び出さないよう修正した。
        if #unavailable(iOS 17) {
            textField.setBottomBorder()
        }
    }
}

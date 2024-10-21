//
//  TemplateListViewController.swift
//  andpad-camera
//
//  Created by Masaaki Kakimoto on 2018/08/21.
//

import UIKit

class TemplateListViewController: UIViewController, UICollectionViewDataSource,
                                  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var completedHandler: ((BlackBoardType) -> Void)?
    var selectedType: BlackBoardType?

    @IBAction private func tapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.setNeedsStatusBarAppearanceUpdate()
        initView()

        setAccessibilityIdentifiers()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    private func initView() {
        title = L10n.Common.Title.changeBlackboard
        navigationController?.navigationBar.setModalBar()

        navigationController?.navigationBar.tintColor = UIColor.gray
        let barItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = barItem
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let type = BlackBoardTypeManager.getType()[indexPath.row]
        let cell: UICollectionViewCell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "TemplateListCell",
                for: indexPath
            )
        if let tcell = cell as? TemplateListCell {
            tcell.setTemplate(type)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = BlackBoardTypeManager.getType()[indexPath.row]
        selectedType = type
        performSegue(withIdentifier: "SelectTemplateSegue", sender: nil)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return BlackBoardTypeManager.getType().count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalSpace: CGFloat = 2
        let cellSize: CGFloat = self.view.bounds.width / 2 - horizontalSpace
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "SelectTemplateSegue":
            if let viewController = segue.destination as? SelectTemplateViewController {
                viewController.selectedType = selectedType
                viewController.completedHandler = { [weak self] bbtype in
                    self?.completedHandler?(bbtype)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }

    private func setAccessibilityIdentifiers() {
        navigationController?.navigationBar.viewAccessibilityIdentifier = .templateListNavigationBar
        navigationItem.leftBarButtonItem?.viewAccessibilityIdentifier = .templateListCloseButton
        collectionView.viewAccessibilityIdentifier = .templateListCollectionView
    }
}

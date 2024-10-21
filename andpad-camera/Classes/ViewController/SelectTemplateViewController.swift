//
//  SelectTemplateViewController.swift
//  andpad-camera
//
//  Created by Masaaki Kakimoto on 2018/08/22.
//

import UIKit

class SelectTemplateViewController: UIViewController {
    @IBOutlet weak var templateImage: UIImageView!
    @IBOutlet weak var selectButton: UIButton!

    var selectedType: BlackBoardType?
    var completedHandler: ((BlackBoardType) -> Void)?

    @IBAction private func tapSelectButton(_ sender: Any) {
        guard let selectedType = selectedType else { return }
        completedHandler?(selectedType)
    }

    private func close() {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        templateImage.image = selectedType?.getTemplateImage(view: self.view, isHiddenValues: true)
        self.setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.setModalBar()

        setAccessibilityIdentifiers()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    private func setAccessibilityIdentifiers() {
        navigationController?.navigationBar.viewAccessibilityIdentifier = .selectTemplateViewNavigationBar
        selectButton.viewAccessibilityIdentifier = .selectTemplateViewSelectButton
        templateImage.viewAccessibilityIdentifier = .selectTemplateViewTemplateImage
    }
}

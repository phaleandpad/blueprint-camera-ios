//
//  UIViewController+Alert.swift
//  andpad-camera
//
//  Created by msano on 2022/01/17.
//

extension UIViewController {
    func showAlert(
        title: String?,
        message: String?,
        actionTitle: String = L10n.Common.ok,
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let okAction = UIAlertAction(title: actionTitle, style: .default, handler: handler)
            alert.addAction(okAction)

            self?.present(alert, animated: true, completion: nil)
        }
    }
}

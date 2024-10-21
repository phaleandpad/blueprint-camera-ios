//
//  UISearchBar+Extensions.swift
//  andpad-camera
//
//  Created by msano on 2022/01/13.
//

extension UISearchBar {

    // ref: https://stackoverflow.com/a/48204512
    var textField: UITextField? {
        searchTextField
    }

    func setMagnifyingGlassColorTo(color: UIColor) {
        let glassIconView = textField?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = color
    }
}

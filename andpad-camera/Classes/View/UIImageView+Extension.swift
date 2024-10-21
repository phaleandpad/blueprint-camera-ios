//
//  UIImageView+Extension.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2021/01/28.
//

import UIKit

extension UIImageView {

    func setNetworkImageUrl(_ url: URL) {

        let task = URLSession.shared.dataTask(
            with: url
        ) { [weak self] imageData, _, _ in
            guard let imageData else { return }

            DispatchQueue.main.async {
                self?.image = UIImage(data: imageData)
            }
        }

        task.resume()
    }

    // NOTE: iOS12対策用
    //
    // 本来template imageでtint colorをセットしていれば指定色が画像に反映される
    // （これはstoryboard / xib / コードいずれも反映可能）
    //
    // ただしiOS12の場合はコードで指定が必要（storyboard / xibだと正しく反映されない不具合あり）
    // ref: https://stackoverflow.com/questions/62801267/tint-color-for-ios12-system-image-button-doesnt-work
    // ※ こちらを利用する場合はstoryboard / xibのtintColorはdefaultにしておく必要がある
    func configureTintColor(_ color: UIColor) {
        image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
}

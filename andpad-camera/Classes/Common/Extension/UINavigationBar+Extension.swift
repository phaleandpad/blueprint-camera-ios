//
//  UINavigationBar+Extension.swift
//  andpad-camera
//
//  Created by 畠山友彰 on 2021/10/13.
//

import UIKit

extension UINavigationBar {
    /// 標準スタイルに近い`navigationBar`を使用します。タイトルの文字色などが標準とは異なります。
    ///
    /// iOS 14以前と同じく、中身のViewをトップまでスクロールしていても半透明の背景が表示され続けます。
    func useStandardLikeBar() {
        tintColor = .andpadRed
        setBackgroundImage(nil, for: .default)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textColor]
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
    }
    
    func setModalBar() {
        let image = UIColor.whiteFAFA.createImage()
        shadowImage = UIColor.grayBBB.createImage()
        setBackgroundImage(image, for: .default)
        tintColor = .andpadRed
        titleTextAttributes = [.foregroundColor: UIColor.textColor]
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
    }
}

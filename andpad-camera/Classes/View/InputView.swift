//
//  InputView.swift
//  smart-ec
//
//  Created by Daisuke Yamashita on 2016/09/11.
//  Copyright © 2016 ANDPAD Inc. All rights reserved.
//

import UIKit

class InputView: UIView {

    @IBOutlet var endBtn: UIButton! {
        didSet {
            endBtn.setTitle("完了", for: UIControl.State())
        }
    }

    var closeButtonTappedHandler: (() -> Void)?

    deinit {
        print("InputView deinit")
    }

    @IBAction private func end(_ sender: Any) {
        closeButtonTappedHandler?()
    }
}

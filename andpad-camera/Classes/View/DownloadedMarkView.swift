//
//  DownloadedMarkView.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2023/12/08.
//

import AndpadUIComponent
import SnapKit
import UIKit

/// ダウンロード済みマーク
///
/// 黒板一覧で使用される。
@IBDesignable
class DownloadedMarkView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
    }

    private func setUpViews() {
        let backgroundCircle = UIView()
        backgroundCircle.backgroundColor = .tsukuri.system.white.withAlphaComponent(0.85)
        let backgroundCircleLength: CGFloat = 32
        backgroundCircle.layer.cornerRadius = backgroundCircleLength / 2

        addSubview(backgroundCircle)
        backgroundCircle.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(backgroundCircleLength)
            make.height.equalTo(backgroundCircleLength)
        }

        let imageView = UIImageView(image: Asset.iconCloudCheck.image)
        imageView.tintColor = .tsukuri.reference.aqua80
        let imageLength: CGFloat = 24

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(imageLength)
            make.height.equalTo(imageLength)
        }

        // 初期設定は非表示
        isHidden = true
    }
}

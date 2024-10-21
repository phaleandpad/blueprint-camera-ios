//
//  ZoomSlider.swift
//  andpad-camera
//
//  Created by 吉田範之@andpad on 2023/05/10.
//

import Foundation
import UIKit
import AndpadUIComponent

/// カメラ画面の倍率スライダー
final class ZoomSlider: UISlider {
    // バーの高さ
    @IBInspectable var trackHeight: CGFloat = 2
    // つまみの直径
    @IBInspectable var thumbRadius: CGFloat = 12
    
    private var defaultScaleView: UIView = {
        let view = UIView()
        view.backgroundColor = .tsukuri.system.baseBorder
        view.layer.cornerRadius = 1.0
        view.isHidden = true
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // つまみの設定
        let thumb = thumbImage(diameter: thumbRadius)
        setThumbImage(thumb, for: .normal)
    }
    
    private func thumbImage(diameter: CGFloat) -> UIImage {
        let thumbView = UIView()
        // つまみのデザイン
        thumbView.layer.shadowOpacity = 1.0
        thumbView.layer.shadowRadius = 2
        thumbView.layer.backgroundColor = UIColor.tsukuri.system.andpadDarkRed.cgColor
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 1)
        thumbView.layer.shadowColor = UIColor.tsukuri.system.andpadDarkRed.withAlphaComponent(0.2).cgColor
        thumbView.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        thumbView.layer.cornerRadius = diameter / 2
        
        // つまみを描写（影が見切れないように、大きさ自体は直径の1.5倍にして、その分x,y座標をずらす）
        let renderer = UIGraphicsImageRenderer(
            bounds: CGRect(
                x: -(diameter * 0.5 / 2),
                y: -(diameter * 0.5 / 2),
                width: diameter * 1.5,
                height: diameter * 1.5
            )
        )
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
    
    func setUpScale() {
        // value = 1.0の時のX座標を取得するための処理
        let thumbRect = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: 1.0)
        let convertedThumbRect = convert(thumbRect, to: self)
        // つまみをずらした分の補正値
        let correctX = thumbRadius * 0.5 / 2 - 1.0
        
        defaultScaleView.isHidden = false
        insertSubview(defaultScaleView, at: 0)
        defaultScaleView.snp.remakeConstraints { make in
            make.width.equalTo(2.0)
            make.height.equalTo(20.0)
            make.centerY.equalToSuperview()
            make.centerX.equalTo(convertedThumbRect.midX - correctX)
        }
    }
    
    func hideScale() {
        defaultScaleView.isHidden = true
    }
}

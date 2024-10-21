//
//  GpsWarningView.swift
//  andpad-camera
//
//  Created by 山本博 on 2024/06/25.
//

import Foundation
import UIKit

final class GpsWarningView: UIView {
    
    var gpsWarningText = UILabel()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        let gpsWarningBackView = UIView(frame: .zero)
        gpsWarningBackView.backgroundColor = .tsukuri.system.criticalSurface()
        gpsWarningBackView.alpha = 0.7
        
        let icon = UIImage(asset: ImageAsset(name: "icon_map"))
        let gpsWarningIcon = UIImageView(image: icon)
        
        let closeButton = UIButton(type: .system)
        closeButton.tintColor = .tsukuri.system.white
        closeButton.setImage(UIImage(asset: ImageAsset(name: "icon_x")), for: .normal)
        closeButton.addAction(
            UIAction(title: L10n.todo("X（閉じる）ボタンを押下")) { [weak self] _ in
                guard let self else { return }
                self.hideMessage()
            },
            for: .touchUpInside
        )
        
        gpsWarningIcon.contentMode = .scaleAspectFit
        gpsWarningText.text = L10n.todo("")
        gpsWarningText.font = UIFont.boldSystemFont(ofSize: gpsWarningText.font.pointSize)
        gpsWarningText.textColor = .tsukuri.system.white
        
        let gpsWarningContents = UIStackView()
        gpsWarningContents.axis = .horizontal
        gpsWarningContents.spacing = 8
        gpsWarningContents.alignment = .center
        gpsWarningContents.addArrangedSubview(gpsWarningIcon)
        gpsWarningContents.addArrangedSubview(gpsWarningText)
        
        addSubview(gpsWarningBackView)
        addSubview(gpsWarningContents)
        addSubview(closeButton)
        
        gpsWarningBackView.translatesAutoresizingMaskIntoConstraints = false
        gpsWarningContents.translatesAutoresizingMaskIntoConstraints = false
        gpsWarningIcon.translatesAutoresizingMaskIntoConstraints = false
        gpsWarningText.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        isHidden = true
        
        // Auto Layoutを設定
        NSLayoutConstraint.activate([
            gpsWarningBackView.widthAnchor.constraint(equalTo: self.widthAnchor),
            gpsWarningBackView.heightAnchor.constraint(equalToConstant: 39),
            gpsWarningBackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            gpsWarningBackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            gpsWarningContents.heightAnchor.constraint(equalTo: gpsWarningBackView.heightAnchor, multiplier: 0.8),
            gpsWarningContents.centerXAnchor.constraint(equalTo: gpsWarningBackView.centerXAnchor),
            gpsWarningContents.centerYAnchor.constraint(equalTo: gpsWarningBackView.centerYAnchor),
            
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            closeButton.centerYAnchor.constraint(equalTo: gpsWarningBackView.centerYAnchor),
            closeButton.heightAnchor.constraint(equalTo: gpsWarningBackView.heightAnchor, multiplier: 0.8),
            closeButton.trailingAnchor.constraint(equalTo: gpsWarningBackView.trailingAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGPSDisabledMessage() {
        gpsWarningText.text = L10n.todo("位置情報がオフになっています")
        isHidden = false
    }
    func setGPSNotReceivedMessage() {
        gpsWarningText.text = L10n.todo("位置情報を取得できません")
        isHidden = false
    }
    
    func hideMessage() {
        isHidden = true
    }
}

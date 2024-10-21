//
//  OfflineModeBar.swift
//  andpad
//
//  Created by 吉田範之@andpad on 2023/11/15.
//  Copyright © 2023 ANDPAD Inc. All rights reserved.
//

import UIKit

public final class OfflineModeBar: UIView {
    
    private let iconView = {
        let icon = UIImageView(image: Asset.iconCloudOff.image)
        icon.tintColor = .tsukuri.system.white
        return icon
    }()
    
    private let offlineModeLabel = {
        let label = UILabel()
        label.textColor = .tsukuri.system.white
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.text = L10n.Offline.Bar.label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }
    
    private func setUpViews() {
        backgroundColor = .tsukuri.reference.aqua80
        
        let stackView = UIStackView(arrangedSubviews: [
            iconView,
            offlineModeLabel
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        
        iconView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.centerY.equalToSuperview()
        }
        offlineModeLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(4)
            make.verticalEdges.equalToSuperview().inset(7)
            make.centerY.equalToSuperview()
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

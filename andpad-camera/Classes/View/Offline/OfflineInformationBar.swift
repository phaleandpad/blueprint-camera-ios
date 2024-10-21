//
//  OfflineInformationBar.swift
//  andpad
//
//  Created by 吉田範之@andpad on 2023/11/30.
//  Copyright © 2023 ANDPAD Inc. All rights reserved.
//

import UIKit

public final class OfflineInformationBar: UIView {
    private let iconView = {
        let icon = UIImageView(image: Asset.fillIconInfoCircle.image)
        icon.tintColor = .tsukuri.reference.aqua80
        return icon
    }()
    
    private let informationLabel = {
        let label = UILabel()
        label.textColor = .tsukuri.system.primaryTextOnSurface1
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .headline)
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
        backgroundColor = .tsukuri.reference.aqua10
        
        addSubview(iconView)
        addSubview(informationLabel)
        
        iconView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        informationLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
        }
    }
    
    public func configure(information: String) {
        informationLabel.text = information
    }
}

//
//  NotUploadedPhotosInformationButton.swift
//  andpad
//
//  Created by 吉田範之@andpad on 2023/11/30.
//  Copyright © 2023 ANDPAD Inc. All rights reserved.
//

import UIKit

public final class NotUploadedPhotosInformationButton: UIButton {
    private let leadingIconView = {
        let icon = UIImageView(image: Asset.iconImage.image)
        icon.tintColor = .tsukuri.reference.aqua80
        return icon
    }()
    
    private let notUploadedPhotosLabel = {
        let label = UILabel()
        label.textColor = .tsukuri.system.regularTextOnSurface1
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let trailingIconView = {
        let icon = UIImageView(image: Asset.iconChevronRight.image)
        icon.tintColor = .tsukuri.reference.aqua80
        return icon
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
        
        addSubview(leadingIconView)
        addSubview(notUploadedPhotosLabel)
        addSubview(trailingIconView)
        
        leadingIconView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        trailingIconView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        notUploadedPhotosLabel.snp.makeConstraints { make in
            make.leading.equalTo(leadingIconView.snp.trailing).offset(8)
            make.trailing.equalTo(trailingIconView.snp.leading).offset(-8)
            make.verticalEdges.equalToSuperview().inset(16)
        }
    }
    
    public func configure(count: Int) {
        notUploadedPhotosLabel.text = L10n.Offline.unuploadedPhotos(count)
    }
}

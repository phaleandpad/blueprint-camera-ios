//
//  TemplateListCell.swift
//  andpad-camera
//
//  Created by Masaaki Kakimoto on 2018/08/22.
//

import Foundation
import UIKit

final class TemplateListCell: UICollectionViewCell {

    @IBOutlet weak var templateImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setTemplate(_ type: BlackBoardType) {
        templateImage.image = type.getTemplateImage(view: self, isHiddenValues: true)
    }

    deinit {
        print("TemplateList cell deinit")
    }
}

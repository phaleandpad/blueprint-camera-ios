//
//  CACornerMask+SyntaxSugar.swift
//  andpad-camera
//
//  Created by msano on 2022/01/26.
//

extension CACornerMask {
    static let rightTop: CACornerMask = .layerMaxXMinYCorner
    static let leftTop: CACornerMask = .layerMinXMinYCorner
    static let rightBottom: CACornerMask = .layerMaxXMaxYCorner
    static let leftBottom: CACornerMask = .layerMinXMaxYCorner
}

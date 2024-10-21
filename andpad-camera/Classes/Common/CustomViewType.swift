//
//  CustomViewType.swift
//  andpad-camera
//
//  Created by daisuke on 2018/04/20.
//

import Foundation
import UIKit

/** 写真の編集で定義されたカスタムViewの種別定義 */
public enum CustomViewType: String {
    case blackboard /** 黒板 */

    func getView(
        blackboardType: BlackBoardType?,
        shouldIgnoreValueOfCombinedItem: Bool = true
    ) -> UIView? {
        guard let blackboardType else { return nil }

        switch self {
        case .blackboard:
            return BlackBoardView.getView(
                type: blackboardType,
                shouldIgnoreValueOfCombinedItem: shouldIgnoreValueOfCombinedItem
            )
        }
    }

    public func getActualView(blackboardType: BlackBoardType = BlackBoardType.case0) -> UIView? {
        switch self {
        case .blackboard:
            return BlackBoardView.getActualView(type: blackboardType)
        }
    }
}

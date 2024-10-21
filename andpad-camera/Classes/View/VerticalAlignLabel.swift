//
//  VerticalAlignLabel.swift
//  andpad-camera
//
//  Created by msano on 2021/03/15.
//

final class VerticalAlignLabel: UILabel {
    var verticalTextAlignment: VerticalTextAlignmentType = .center {
        didSet {
            setNeedsDisplay()
        }
    }

    // life cycle
    override func drawText(in rect: CGRect) {
        let actualRect = textRect(
            forBounds: rect,
            limitedToNumberOfLines: numberOfLines
        )
        super.drawText(in: actualRect)
    }

    override func textRect(
        forBounds bounds: CGRect,
        limitedToNumberOfLines numberOfLines: Int
    ) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch verticalTextAlignment {
        case .top:
            textRect.origin.y = bounds.origin.y
        case .bottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) * 0.5
        }
        return textRect
    }
}

extension VerticalAlignLabel {
    enum VerticalTextAlignmentType {
        case top
        case center
        case bottom
    }
}

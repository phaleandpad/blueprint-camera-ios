//
//  WrapperCollectionViewCell.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2020/12/23.
//

import UIKit

protocol WrappableView: UIView {
    static func makeForWrapper() -> Self

    func prepareForReuse()
}

final class WrapperCollectionViewCell<WrappedView: WrappableView>: UICollectionViewCell {

    let view: WrappedView

    override init(frame: CGRect) {
        view = WrappedView.makeForWrapper()

        super.init(frame: frame)

        addSubview(view)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = bounds
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        view.prepareForReuse()
    }

    func update(_ handler: (WrappedView) -> Void) {
        handler(view)
    }
}

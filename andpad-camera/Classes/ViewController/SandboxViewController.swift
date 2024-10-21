//
//  SandboxViewController.swift
//  andpad-camera
//
//  Created by msano on 2020/11/17.
//

#if DEBUG

import SnapKit
import RxSwift

public final class SandboxViewController: UIViewController {
    private let stackView: UIStackView = .init()
    private let disposeBag = DisposeBag()
    
    var sliderLabel: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
}

// MARK: - private
extension SandboxViewController {
    private func configureView() {
        let initialValue: Float = 8.0
        let width = view.frame.width
        let height = view.frame.height

        let slider = StickySlider(
            frame: CGRect(
                x: width * 0.1,
                y: height * 0.2,
                width: width * 0.8,
                height: 10
            ),
            scaleLabelList: ["透過なし", "半透明", "透明"],
            style: .alpha,
            title: "黒板の透過度",
            footnote: "SVG形式で撮影する場合、黒板は透過されません"
        )
        
        slider.onValueChangedSignal
            .emit(onNext: { [weak self] in self?.sliderLabel.text = String($0) })
            .disposed(by: disposeBag)
        
        view.addSubview(slider)
        
        sliderLabel = UILabel()
        sliderLabel.frame = CGRect(x: width * 0.1, y: height * 0.4, width: width * 0.8, height: height * 0.1)
        sliderLabel.textAlignment = .center
        sliderLabel.text = String(initialValue)
        view.addSubview(sliderLabel)
        
        view.backgroundColor = .white
    }
}

#endif

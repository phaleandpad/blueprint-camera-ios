//
//  CountdownPresetSelectionViewController.swift
//  andpad-camera
//
//  Created by Nguyen Ngoc Tam on 3/9/24.
//

import UIKit
import SwiftUI

private enum Constant {
    static let buttonSize = CGSize(width: 64, height: 64)
}

final class CountdownPresetSelectionViewController: CameraDropdownHostingViewController<CountdownSelectionView> {
    let viewState: CountdownSelectionViewState
    
    init(
        selectedPreset: CountdownPreset = .none,
        selectAction: @escaping (_ selectedPresent: CountdownPreset) -> Void
    ) {
        viewState = CountdownSelectionViewState(
            availablePresets: CountdownPreset.allCases,
            selectedPreset: selectedPreset
        )
        
        super.init(
            rootView: CountdownSelectionView(
                state: viewState,
                selectAction: selectAction
            )
        )
        
        rootView.dismiss = { [weak self] in
            guard let self else { return }
            dismiss(animated: true)
        }
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        preferredContentSize = CGSize(
            width: Constant.buttonSize.width * CGFloat(viewState.availablePresets.count),
            height: Constant.buttonSize.height
        )
    }
    
    func rotateContent(angle: Double) {
        viewState.rotateAngle = angle
    }
}

@MainActor
final class CountdownSelectionViewState: ObservableObject {
    @Published private(set) var availablePresets: [CountdownPreset]
    @Published var selectedPreset: CountdownPreset = .none
    
    @Published var rotateAngle: Double = 0.0
    
    // MARK: - Initializers
    
    init(
        availablePresets: [CountdownPreset],
        selectedPreset: CountdownPreset
    ) {
        self.availablePresets = availablePresets
        self.selectedPreset = selectedPreset
    }
}

@MainActor
struct CountdownSelectionView: View {
    
    @ObservedObject private var state: CountdownSelectionViewState
    
    let selectAction: (_ selectedPresent: CountdownPreset) -> Void
    var dismiss: (() -> Void)?
    
    init(
        state: CountdownSelectionViewState,
        selectAction: @escaping (_ selectedPresent: CountdownPreset) -> Void
    ) {
        _state = .init(initialValue: state)
        self.selectAction = selectAction
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(state.availablePresets) { preset in
                IconTextButton(
                    iconImage: .init(asset: Asset.toolIconTimer),
                    text: preset.displayedText,
                    isSelected: state.selectedPreset == preset
                ) {
                    state.selectedPreset = preset
                    selectAction(preset)
                    dismiss?()
                }
                .rotationEffect(.radians(state.rotateAngle))
                .animation(.linear(duration: 0.2))
                
                if preset != state.availablePresets.last {
                    Divider()
                        .frame(width: 1)
                        .overlay(Color(.tsukuri.system.inverseBorder))
                }
            }
        }
        .background(Color(.tsukuri.system.inverseSurface(for: .state1)))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    Color(.tsukuri.system.inverseBorder),
                    lineWidth: 1
                )
        )
    }
}

private struct IconTextButton: View {
    let iconImage: Image
    let text: String
    let isSelected: Bool
    
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            VStack(spacing: 0) {
                iconImage
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(Color(.tsukuri.system.primaryTextOnInverseSurface))
            }
            .frame(width: Constant.buttonSize.width, height: Constant.buttonSize.height)
            .background(
                isSelected ? Color(.tsukuri.system.interactiveSurface(for: .primary)) : Color(.tsukuri.system.inverseSurface(for: .state1))
            )
        })
    }
}

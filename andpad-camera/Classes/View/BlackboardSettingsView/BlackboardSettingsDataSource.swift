//
//  BlackboardSettingsDataSource.swift
//  andpad-camera
//
//  Created by 正木 祥悠 on 2024/04/17.
//

import Foundation
import class UIKit.UIImage
import AndpadCore

struct BlackboardSettingsSectionConfiguration: Equatable {
    let id = UUID()
    let title: String
    fileprivate(set) var segments: [BlackboardSettingsSegmentConfiguration]
    fileprivate(set) var footer: BlackboardSettingsSectionFooterConfiguration?
}

struct BlackboardSettingsSegmentConfiguration: Equatable {
    let id = UUID()
    let title: String
    let iconType: BlackboardSettingsSegmentIconType
    let value: BlackboardSettingsSegmentValue
    let canEnabled: Bool
    var isEnabled: Bool
    var isSelected: Bool

    /// アクセシビリティ識別子
    var accessibilityIdentifier: String {
        switch value {
        case .blackboardVisibility(.show):
            ViewAccessibilityIdentifier.blackboardVisibilityShow.rawValue
        case .blackboardVisibility(.hide):
            ViewAccessibilityIdentifier.blackboardVisibilityHide.rawValue
        case .rotationLock(.lock):
            ViewAccessibilityIdentifier.rotationLock.rawValue
        case .rotationLock(.unlock):
            ViewAccessibilityIdentifier.rotationUnlock.rawValue
        case .sizeType(.small):
            ViewAccessibilityIdentifier.sizeTypeSmall.rawValue
        case .sizeType(.medium):
            ViewAccessibilityIdentifier.sizeTypeMedium.rawValue
        case .sizeType(.large):
            ViewAccessibilityIdentifier.sizeTypeLarge.rawValue
        case .sizeType(.free):
            ViewAccessibilityIdentifier.sizeTypeFree.rawValue
        case .photoQuality(let photoQuality):
            photoQuality.qualityType.rawValue
        case .photoFormat(let photoImageType):
            photoImageType.rawValue
        }
    }
}

enum BlackboardSettingsSegmentIconType: Equatable {
    case image(UIImage)
    case text(String)
}

enum BlackboardSettingsSegmentValue: Equatable {
    case blackboardVisibility(BlackboardVisibility)
    case rotationLock(RotationLock)
    case sizeType(ModernBlackboardAppearance.ModernBlackboardSizeType)
    case photoQuality(PhotoQuality)
    case photoFormat(ModernBlackboardCommonSetting.PhotoFormat)
}

extension BlackboardSettingsSegmentValue {
    enum BlackboardVisibility {
        case show
        case hide
    }
    enum RotationLock {
        case lock
        case unlock
    }
}

struct BlackboardSettingsSectionFooterConfiguration: Equatable {
    let id = UUID()
    let title: String
    var isHidden: Bool
}

private extension PhotoQuality {
    var title: String {
        switch qualityType {
        case .defaultStandard:
            L10n.Camera.BlackboardSettings.PhotoQuality.DefaultStandard.title
        case .defaultHigh:
            L10n.Camera.BlackboardSettings.PhotoQuality.DefaultHigh.title
        case .cals1M:
            L10n.Camera.BlackboardSettings.PhotoQuality.Cals1M.title
        case .cals2M:
            L10n.Camera.BlackboardSettings.PhotoQuality.Cals2M.title
        case .cals3M:
            L10n.Camera.BlackboardSettings.PhotoQuality.Cals3M.title
        }
    }

    var resolutionText: String {
        switch qualityType {
        case .defaultStandard:
            L10n.Camera.BlackboardSettings.PhotoQuality.DefaultStandard.description
        case .defaultHigh:
            L10n.Camera.BlackboardSettings.PhotoQuality.DefaultHigh.description
        case .cals1M:
            L10n.Camera.BlackboardSettings.PhotoQuality.Cals1M.description
        case .cals2M:
            L10n.Camera.BlackboardSettings.PhotoQuality.Cals2M.description
        case .cals3M:
            L10n.Camera.BlackboardSettings.PhotoQuality.Cals3M.description
        }
    }
}

private extension ModernBlackboardAppearance.ModernBlackboardSizeType {
    var sizeDescription: String {
        switch self {
        case .small:
            L10n.Camera.BlackboardSettings.Size.Small.description
        case .medium:
            L10n.Camera.BlackboardSettings.Size.Medium.description
        case .large:
            L10n.Camera.BlackboardSettings.Size.Large.description
        case .free:
            ""
        }
    }

    var calloutText: String {
        switch self {
        case .small, .medium, .large:
            L10n.Camera.BlackboardSettings.Footer.Size.Callout.title(title)
        case .free:
            ""
        }
    }
}

final class BlackboardSettingsDataSource {
    typealias SizeType = ModernBlackboardAppearance.ModernBlackboardSizeType

    private(set) var sections: [BlackboardSettingsSectionConfiguration] = []
    private let sizeTypeOnServer: SizeType?
    private let outputValueHandler: (BlackboardSettingsSegmentConfiguration) -> Void

    init(
        isBlackboardVisible: Bool,
        isRotationLocked: Bool,
        canSelectSize: Bool,
        selectedSizeType: SizeType?,
        sizeTypeOnServer: SizeType?,
        selectedPhotoQuality: PhotoQuality?,
        photoQualityOptions: [PhotoQuality],
        photoFormat: ModernBlackboardCommonSetting.PhotoFormat,
        isModernBlackboard: Bool,
        outputValueHandler: @escaping (BlackboardSettingsSegmentConfiguration) -> Void
    ) {
        self.sizeTypeOnServer = sizeTypeOnServer
        self.outputValueHandler = outputValueHandler
        setUpVisibilitySection(isBlackboardVisible: isBlackboardVisible)
        setUpOrientationSection(
            isBlackboardVisible: isBlackboardVisible,
            isRotationLocked: isRotationLocked
        )

        if isModernBlackboard {
            setUpSizeTypeSection(
                isBlackboardVisible: isBlackboardVisible,
                canSelectSize: canSelectSize,
                selectedSizeType: selectedSizeType
            )
        }

        setUpPhotoQualitySection(
            isBlackboardVisible: isBlackboardVisible,
            selectedPhotoQuality: selectedPhotoQuality,
            photoQualityOptions: photoQualityOptions
        )

        if isModernBlackboard {
            setUpPhotoFormatSection(
                isBlackboardVisible: isBlackboardVisible,
                photoFormat: photoFormat
            )
        }
    }

    func update(with configuration: BlackboardSettingsSegmentConfiguration) {
        sections = sectionsForVisibleChange(with: configuration)
        sections = sectionsForIsSelectedChange(with: configuration)
        sections = sectionsForIsSizeTypeSelectedChange(with: configuration)
    }
}
private extension BlackboardSettingsDataSource {
    func setUpVisibilitySection(isBlackboardVisible: Bool) {
        sections.append(
            contentsOf: [
                .init(
                    title: L10n.Camera.BlackboardSettings.Visibility.title,
                    segments: [
                        .init(
                            title: L10n.Camera.BlackboardSettings.Visibility.On.title,
                            iconType: .image(Asset.toolIconBlackboardOn.image),
                            value: .blackboardVisibility(.show),
                            canEnabled: true,
                            isEnabled: true,
                            isSelected: isBlackboardVisible
                        ),
                        .init(
                            title: L10n.Camera.BlackboardSettings.Visibility.Off.title,
                            iconType: .image(Asset.toolIconBlackboardOff.image),
                            value: .blackboardVisibility(.hide),
                            canEnabled: true,
                            isEnabled: true,
                            isSelected: !isBlackboardVisible
                        )
                    ]
                )
            ]
        )
    }

    func setUpOrientationSection(
        isBlackboardVisible: Bool,
        isRotationLocked: Bool
    ) {
        sections.append(
            contentsOf: [
                .init(
                    title: L10n.Camera.BlackboardSettings.Orientation.title,
                    segments: [
                        .init(
                            title: L10n.Camera.BlackboardSettings.Orientation.Unlock.title,
                            iconType: .image(Asset.toolIconRotationUnlock.image),
                            value: .rotationLock(.unlock),
                            canEnabled: true,
                            isEnabled: isBlackboardVisible,
                            isSelected: !isRotationLocked
                        ),
                        .init(
                            title: L10n.Camera.BlackboardSettings.Orientation.Lock.title,
                            iconType: .image(Asset.toolIconRotationLock.image),
                            value: .rotationLock(.lock),
                            canEnabled: true,
                            isEnabled: isBlackboardVisible,
                            isSelected: isRotationLocked
                        )
                    ]
                )
            ]
        )
    }

    func setUpSizeTypeSection(
        isBlackboardVisible: Bool,
        canSelectSize: Bool,
        selectedSizeType: SizeType?
    ) {
        guard let selectedSizeType else { return }
        func canEnabled(
            for sizeType: SizeType,
            selectedSizeType: SizeType,
            sizeTypeOnServer: SizeType?,
            canSelectSize: Bool
        ) -> Bool {
            switch sizeType {
            case .free:
                selectedSizeType == sizeType
            default:
                canSelectSize ? true : sizeTypeOnServer == .free || selectedSizeType == sizeType
            }
        }

        sections.append(
            contentsOf: [
                .init(
                    title: L10n.Camera.BlackboardSettings.Size.title,
                    segments: SizeType.allCases.map({
                        .init(
                            title: $0.sizeDescription,
                            iconType: .text($0.title),
                            value: .sizeType($0),
                            canEnabled: canEnabled(
                                for: $0,
                                selectedSizeType: selectedSizeType,
                                sizeTypeOnServer: sizeTypeOnServer,
                                canSelectSize: canSelectSize
                            ),
                            isEnabled: isBlackboardVisible,
                            isSelected: selectedSizeType == $0
                        )
                    }),
                    footer: .init(
                        title: sizeTypeOnServer?.calloutText ?? "",
                        isHidden: sizeTypeOnServer == .free || selectedSizeType == sizeTypeOnServer
                    )
                )
            ]
        )
    }

    func setUpPhotoQualitySection(
        isBlackboardVisible: Bool,
        selectedPhotoQuality: PhotoQuality?,
        photoQualityOptions: [PhotoQuality]
    ) {
        guard let selectedPhotoQuality, !photoQualityOptions.isEmpty else { return }
        sections.append(
            contentsOf: [
                .init(
                    title: L10n.Camera.BlackboardSettings.PhotoQuality.title,
                    segments: photoQualityOptions.map({
                        .init(
                            title: $0.resolutionText,
                            iconType: .text($0.title),
                            value: .photoQuality($0),
                            canEnabled: true,
                            isEnabled: isBlackboardVisible,
                            isSelected: $0 == selectedPhotoQuality
                        )
                    })
                )
            ]
        )
    }

    func setUpPhotoFormatSection(
        isBlackboardVisible: Bool,
        photoFormat: ModernBlackboardCommonSetting.PhotoFormat
    ) {
        sections.append(
            contentsOf: [
                .init(
                    title: L10n.Camera.BlackboardSettings.PhotoType.title,
                    segments: [
                        .init(
                            title: "",
                            iconType: .text(L10n.Camera.BlackboardSettings.PhotoType.jpeg),
                            value: .photoFormat(.jpeg),
                            canEnabled: true,
                            isEnabled: true,
                            isSelected: photoFormat == .jpeg
                        ),
                        .init(
                            title: "",
                            iconType: .text(L10n.Camera.BlackboardSettings.PhotoType.svg),
                            value: .photoFormat(.svg),
                            canEnabled: true,
                            isEnabled: isBlackboardVisible,
                            isSelected: photoFormat == .svg
                        )
                    ]
                )
            ]
        )
    }

    func sectionsForVisibleChange(with configuration: BlackboardSettingsSegmentConfiguration) -> [BlackboardSettingsSectionConfiguration] {
        guard let blackboardVisibility = configuration.blackboardVisibility else { return sections }
        sections.updateEach {
            $0.segments.updateEach {
                updatePhotoTypeSelection(&$0, with: blackboardVisibility)

                guard $0.canUpdateEnabledForVisibilityChange else { return }
                $0.isEnabled = configuration.isBlackboardVisible
            }
        }
        return sections
    }

    func updatePhotoTypeSelection(
        _ configuration: inout BlackboardSettingsSegmentConfiguration,
        with blackboardVisibility: BlackboardSettingsSegmentValue.BlackboardVisibility
    ) {
        // 黒板非表示時に jpeg 設定を選択状態にする
        guard blackboardVisibility == .hide else { return }

        switch configuration.photoFormat {
        case .jpeg:
            configuration.isSelected = true
            outputValueHandler(configuration)
        case .svg:
            configuration.isSelected = false
        default:
            break
        }
    }

    func sectionsForIsSelectedChange(with configuration: BlackboardSettingsSegmentConfiguration) -> [BlackboardSettingsSectionConfiguration] {
        sections.updateEach {
            guard $0.has(configuration) else { return }
            $0.segments.updateEach {
                $0.isSelected = $0.value == configuration.value
            }
        }
        return sections
    }

    func sectionsForIsSizeTypeSelectedChange(with configuration: BlackboardSettingsSegmentConfiguration) -> [BlackboardSettingsSectionConfiguration] {
        guard
            sizeTypeOnServer != .free,
            let selectedSizeType = configuration.sizeType
        else { return sections }
        sections.updateEach {
            $0.footer?.isHidden = selectedSizeType == sizeTypeOnServer
        }
        return sections
    }
}

private extension MutableCollection {
    mutating func updateEach(_ transform: (inout Element) -> Void) {
        for i in indices {
            transform(&self[i])
        }
    }
}

extension BlackboardSettingsSectionConfiguration {
    func has(_ configuration: BlackboardSettingsSegmentConfiguration) -> Bool {
        segments.contains(where: { $0.id == configuration.id })
    }

    func segmentConfiguration(for configurationID: UUID) -> BlackboardSettingsSegmentConfiguration? {
        segments.first { $0.id == configurationID }
    }
}

private extension BlackboardSettingsSegmentConfiguration {
    var isBlackboardVisible: Bool {
        switch value {
        case .blackboardVisibility(.show):
            true
        case .blackboardVisibility(.hide):
            false
        default:
            false
        }
    }

    var blackboardVisibility: BlackboardSettingsSegmentValue.BlackboardVisibility? {
        switch value {
        case .blackboardVisibility(let value):
            value
        default:
            nil
        }
    }

    var sizeType: ModernBlackboardAppearance.ModernBlackboardSizeType? {
        switch value {
        case .sizeType(let value):
            value
        default:
            nil
        }
    }

    var photoFormat: ModernBlackboardCommonSetting.PhotoFormat? {
        switch value {
        case .photoFormat(let value):
            value
        default:
            nil
        }
    }

    ///  黒板「非表示・表示」時に連動し非活性・活性に変化可能かを返す
    ///
    ///  連動して非活性にしない項目は以下であり、それ以外は連動する
    ///    - jpeg 設定 segment
    ///    - 表示・非表示 設定 segment
    var canUpdateEnabledForVisibilityChange: Bool {
        !(blackboardVisibility != nil || photoFormat == .jpeg)
    }
}

//
//  ViewAccessibilityIdentifier.swift
//  UITests
//
//  Created by msano on 2021/10/28.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import XCTest

// NOTE:
// 現状は本体側 / UITest側それぞれに ViewAccessibilityIdentifier が存在するので
// それぞれの内容に差分がないようにしてください
public enum ViewAccessibilityIdentifier: String {
    // MARK: - ViewController

    case launchCameraButton
    case enableModernBlackboardSwitch
    case enableLegacyBlackboardSwitch
    case enableInspectionLegacyBlackboardSwitch
    case enableShootingGuideImageSwitch
    case useBlackboardGeneratedWithSVGSwitch

    // MARK: 撮影画面

    case shutterButton
    case photoCountLabel
    case blackboardSettingsButton
    case takeCameraNextButton
    case takeCameraCancelButton
    case thumbnailImageButton
    case blackboardDragHandle
    case shootingGuideButton
    case shootingGuideImage
    case legacyBlackboardView

    // MARK: 黒板設定モーダル

    case blackboardSettingsView
    case blackboardSettingsSheetViewCloseButton
    case blackboardVisibilityShow
    case blackboardVisibilityHide
    case rotationLock
    case rotationUnlock
    case sizeTypeSmall
    case sizeTypeMedium
    case sizeTypeLarge
    case sizeTypeFree
    // `PhotoQuality.QualityType` と一致させる
    case photoQualityDefaultStandard = "defaultStandard"
    case photoQualityDefaultHigh = "defaultHigh"
    case photoQualityCals1M = "cals1M"
    case photoQualityCals2M = "cals2M"
    case photoQualityCals3M = "cals3M"

    // MARK: 写真プレビュー画面

    case photoPreviewNavigationBar
    case photoDeleteButton
    /// 写真削除確認アラートの削除ボタン
    case photoDeleteAlertDeleteButton
    case photoPreviewViewCloseButton
    case photoPreviewMainImageScrollView
    case photoPreviewThumbnailImageScrollView

    // MARK: 旧黒板の黒板編集画面

    case editLegacyBlackboardViewNavigationBar
    case editLegacyBlackboardViewCloseButton
    case editLegacyBlackboardViewTemplateListCell
    case editLegacyBlackboardViewTemplateListButton
    case editLegacyBlackboardViewTextFieldCell
    case editLegacyBlackboardViewDatePickerCell
    case editLegacyBlackboardViewDatePicker
    case editLegacyBlackboardAlphaSegmentedControl
    case editLegacyBlackboardSaveButton
    case editLegacyBlackboardViewNavigationBarSaveButton

    // MARK: 旧黒板の黒板テンプレート一覧画面

    case templateListNavigationBar
    case templateListCloseButton
    case templateListCollectionView

    // MARK: 選択した旧黒板テンプレートプレビュー画面

    case selectTemplateViewNavigationBar
    case selectTemplateViewSelectButton
    case selectTemplateViewTemplateImage
}

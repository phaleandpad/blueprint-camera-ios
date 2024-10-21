// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let buttonShoot = ImageAsset(name: "Button_Shoot")
  internal static let miniatureMapBeforeLoading = ImageAsset(name: "miniature_map_before_loading")
  internal static let miniatureMapBeforeLoadingForCell = ImageAsset(name: "miniature_map_before_loading_for_cell")
  internal static let miniatureMapLoadFailed = ImageAsset(name: "miniature_map_load_failed")
  internal static let miniatureMapLoadFailedForCell = ImageAsset(name: "miniature_map_load_failed_for_cell")
  internal static let miniatureMapNoUrl = ImageAsset(name: "miniature_map_no_url")
  internal static let toolIconBlackboardOff = ImageAsset(name: "tool_icon_blackboard_off")
  internal static let toolIconBlackboardOn = ImageAsset(name: "tool_icon_blackboard_on")
  internal static let toolIconBlackboardSettings = ImageAsset(name: "tool_icon_blackboard_settings")
  internal static let toolIconBlackboardSettingsNotifyBadge = ImageAsset(name: "tool_icon_blackboard_settings_notify_badge")
  internal static let toolIconFlashAuto = ImageAsset(name: "tool_icon_flash_auto")
  internal static let toolIconFlashOff = ImageAsset(name: "tool_icon_flash_off")
  internal static let toolIconFlashOn = ImageAsset(name: "tool_icon_flash_on")
  internal static let toolIconGuideOff = ImageAsset(name: "tool_icon_guide_off")
  internal static let toolIconGuideOn = ImageAsset(name: "tool_icon_guide_on")
  internal static let toolIconLocationOff = ImageAsset(name: "tool_icon_location_off")
  internal static let toolIconLocationOn = ImageAsset(name: "tool_icon_location_on")
  internal static let toolIconRotationLock = ImageAsset(name: "tool_icon_rotation_lock")
  internal static let toolIconRotationUnlock = ImageAsset(name: "tool_icon_rotation_unlock")
  internal static let toolIconSwitching = ImageAsset(name: "tool_icon_switching")
  internal static let toolIconTimer = ImageAsset(name: "tool_icon_timer")
  internal static let board01 = ImageAsset(name: "board01")
  internal static let cameraPreview01 = ImageAsset(name: "camera_preview01")
  internal static let arrow = ImageAsset(name: "arrow")
  internal static let arrowBottom = ImageAsset(name: "arrow_bottom")
  internal static let arrowThinBottom = ImageAsset(name: "arrow_thin_bottom")
  internal static let blackboardBg = ImageAsset(name: "blackboard_bg")
  internal static let blackboardLayout1 = ImageAsset(name: "blackboard_layout_1")
  internal static let blackboardLayout101 = ImageAsset(name: "blackboard_layout_101")
  internal static let blackboardLayout104 = ImageAsset(name: "blackboard_layout_104")
  internal static let blackboardLayout10 = ImageAsset(name: "blackboard_layout_10")
  internal static let blackboardLayout1001 = ImageAsset(name: "blackboard_layout_1001")
  internal static let blackboardLayout1003 = ImageAsset(name: "blackboard_layout_1003")
  internal static let blackboardLayout1004 = ImageAsset(name: "blackboard_layout_1004")
  internal static let blackboardLayout1103 = ImageAsset(name: "blackboard_layout_1103")
  internal static let blackboardLayout1105 = ImageAsset(name: "blackboard_layout_1105")
  internal static let blackboardLayout1202 = ImageAsset(name: "blackboard_layout_1202")
  internal static let blackboardLayout1203 = ImageAsset(name: "blackboard_layout_1203")
  internal static let blackboardLayout1303 = ImageAsset(name: "blackboard_layout_1303")
  internal static let blackboardLayout1403 = ImageAsset(name: "blackboard_layout_1403")
  internal static let blackboardLayout1502 = ImageAsset(name: "blackboard_layout_1502")
  internal static let blackboardLayout1503 = ImageAsset(name: "blackboard_layout_1503")
  internal static let blackboardLayout1505 = ImageAsset(name: "blackboard_layout_1505")
  internal static let blackboardLayout1602 = ImageAsset(name: "blackboard_layout_1602")
  internal static let blackboardLayout1603 = ImageAsset(name: "blackboard_layout_1603")
  internal static let blackboardLayout1802 = ImageAsset(name: "blackboard_layout_1802")
  internal static let blackboardLayout1803 = ImageAsset(name: "blackboard_layout_1803")
  internal static let blackboardLayout1805 = ImageAsset(name: "blackboard_layout_1805")
  internal static let blackboardLayout1902 = ImageAsset(name: "blackboard_layout_1902")
  internal static let blackboardLayout1903 = ImageAsset(name: "blackboard_layout_1903")
  internal static let blackboardLayout1905 = ImageAsset(name: "blackboard_layout_1905")
  internal static let blackboardLayout2 = ImageAsset(name: "blackboard_layout_2")
  internal static let blackboardLayout201 = ImageAsset(name: "blackboard_layout_201")
  internal static let blackboardLayout202 = ImageAsset(name: "blackboard_layout_202")
  internal static let blackboardLayout203 = ImageAsset(name: "blackboard_layout_203")
  internal static let blackboardLayout204 = ImageAsset(name: "blackboard_layout_204")
  internal static let blackboardLayout205 = ImageAsset(name: "blackboard_layout_205")
  internal static let blackboardLayout2202 = ImageAsset(name: "blackboard_layout_2202")
  internal static let blackboardLayout2203 = ImageAsset(name: "blackboard_layout_2203")
  internal static let blackboardLayout2205 = ImageAsset(name: "blackboard_layout_2205")
  internal static let blackboardLayout3 = ImageAsset(name: "blackboard_layout_3")
  internal static let blackboardLayout301 = ImageAsset(name: "blackboard_layout_301")
  internal static let blackboardLayout4 = ImageAsset(name: "blackboard_layout_4")
  internal static let blackboardLayout401 = ImageAsset(name: "blackboard_layout_401")
  internal static let blackboardLayout5 = ImageAsset(name: "blackboard_layout_5")
  internal static let blackboardLayout501 = ImageAsset(name: "blackboard_layout_501")
  internal static let blackboardLayout6 = ImageAsset(name: "blackboard_layout_6")
  internal static let blackboardLayout601 = ImageAsset(name: "blackboard_layout_601")
  internal static let blackboardLayout602 = ImageAsset(name: "blackboard_layout_602")
  internal static let blackboardLayout603 = ImageAsset(name: "blackboard_layout_603")
  internal static let blackboardLayout604 = ImageAsset(name: "blackboard_layout_604")
  internal static let blackboardLayout605 = ImageAsset(name: "blackboard_layout_605")
  internal static let blackboardLayout7 = ImageAsset(name: "blackboard_layout_7")
  internal static let blackboardLayout701 = ImageAsset(name: "blackboard_layout_701")
  internal static let blackboardLayout702 = ImageAsset(name: "blackboard_layout_702")
  internal static let blackboardLayout703 = ImageAsset(name: "blackboard_layout_703")
  internal static let blackboardLayout704 = ImageAsset(name: "blackboard_layout_704")
  internal static let blackboardLayout802 = ImageAsset(name: "blackboard_layout_802")
  internal static let blackboardLayout803 = ImageAsset(name: "blackboard_layout_803")
  internal static let blackboardLayout902 = ImageAsset(name: "blackboard_layout_902")
  internal static let blackboardLayout903 = ImageAsset(name: "blackboard_layout_903")
  internal static let fillIconInfoCircle = ImageAsset(name: "fill_icon_info_circle")
  internal static let iconAlignBottomInvert = ImageAsset(name: "icon_align_bottom_invert")
  internal static let iconAlignCenterInvert = ImageAsset(name: "icon_align_center_invert")
  internal static let iconAlignLeftInvert = ImageAsset(name: "icon_align_left_invert")
  internal static let iconAlignMiddleInvert = ImageAsset(name: "icon_align_middle_invert")
  internal static let iconAlignRightInvert = ImageAsset(name: "icon_align_right_invert")
  internal static let iconAlignTopInvert = ImageAsset(name: "icon_align_top_invert")
  internal static let iconBlackboardAlpha = ImageAsset(name: "icon_blackboard_alpha")
  internal static let iconBlackboardAlphaFill = ImageAsset(name: "icon_blackboard_alpha_fill")
  internal static let iconBlackboardSettingsClose = ImageAsset(name: "icon_blackboard_settings_close")
  internal static let iconBoard = ImageAsset(name: "icon_board")
  internal static let iconBoardInvert = ImageAsset(name: "icon_board_invert")
  internal static let iconBottomDirectionalArrow = ImageAsset(name: "icon_bottom_directional_arrow")
  internal static let iconCamera = ImageAsset(name: "icon_camera")
  internal static let iconCancel = ImageAsset(name: "icon_cancel")
  internal static let iconCancelButton = ImageAsset(name: "icon_cancel_button")
  internal static let iconCheckOld = ImageAsset(name: "icon_check_old")
  internal static let iconChevronRight = ImageAsset(name: "icon_chevron_right")
  internal static let iconCloudCheck = ImageAsset(name: "icon_cloud_check")
  internal static let iconCloudOff = ImageAsset(name: "icon_cloud_off")
  internal static let iconCommonGreyBoard = ImageAsset(name: "icon_common_grey_board")
  internal static let iconCommonGreyCamera = ImageAsset(name: "icon_common_grey_camera")
  internal static let iconCommonGreyCancel = ImageAsset(name: "icon_common_grey_cancel")
  internal static let iconCommonGreyDocument = ImageAsset(name: "icon_common_grey_document")
  internal static let iconCommonGreyNext = ImageAsset(name: "icon_common_grey_next")
  internal static let iconCommonGreyPhoto = ImageAsset(name: "icon_common_grey_photo")
  internal static let iconCommonGreySearchGlossy = ImageAsset(name: "icon_common_grey_search_glossy")
  internal static let iconDelete = ImageAsset(name: "icon_delete")
  internal static let iconEdit = ImageAsset(name: "icon_edit")
  internal static let iconFilterDeselectHeader = ImageAsset(name: "icon_filter_deselect_header")
  internal static let iconFilterDeselectMulti = ImageAsset(name: "icon_filter_deselect_multi")
  internal static let iconFilterOff = ImageAsset(name: "icon_filter_off")
  internal static let iconFilterOffHeader = ImageAsset(name: "icon_filter_off_header")
  internal static let iconFilterOn = ImageAsset(name: "icon_filter_on")
  internal static let iconFilterOnHeader = ImageAsset(name: "icon_filter_on_header")
  internal static let iconFilterSelectHeader = ImageAsset(name: "icon_filter_select_header")
  internal static let iconFilterSelectMulti = ImageAsset(name: "icon_filter_select_multi")
  internal static let iconFilterSelectSingle = ImageAsset(name: "icon_filter_select_single")
  internal static let iconFocus = ImageAsset(name: "icon_focus")
  internal static let iconFontWeightLargeInvert = ImageAsset(name: "icon_font_weight_large_invert")
  internal static let iconFontWeightMediumInvert = ImageAsset(name: "icon_font_weight_medium_invert")
  internal static let iconFontWeightSmallInvert = ImageAsset(name: "icon_font_weight_small_invert")
  internal static let iconHistory = ImageAsset(name: "icon_history")
  internal static let iconImage = ImageAsset(name: "icon_image")
  internal static let iconImageQuality = ImageAsset(name: "icon_image_quality")
  internal static let iconLabelInvertWhiteMinus = ImageAsset(name: "icon_label_invert_white_minus")
  internal static let iconLabelInvertWhitePlus = ImageAsset(name: "icon_label_invert_white_plus")
  internal static let iconList = ImageAsset(name: "icon_list")
  internal static let iconMap = ImageAsset(name: "icon_map")
  internal static let iconSelectBlackboard = ImageAsset(name: "icon_select_blackboard")
  internal static let iconSwitchView = ImageAsset(name: "icon_switch_view")
  internal static let iconSync = ImageAsset(name: "icon_sync")
  internal static let iconUndefined = ImageAsset(name: "icon_undefined")
  internal static let iconX = ImageAsset(name: "icon_x")
  internal static let sampleTate01 = ImageAsset(name: "sample_tate01")
  internal static let sampleYoko01 = ImageAsset(name: "sample_yoko01")
  internal static let sync = ImageAsset(name: "sync")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type

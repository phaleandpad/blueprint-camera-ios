// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum AppUpdateView {
    /// Please update the application as some blackboards are not available
    internal static let title = L10n.tr("Localizable", "appUpdateView.title", fallback: "Please update the application as some blackboards are not available")
    /// Update
    internal static let update = L10n.tr("Localizable", "appUpdateView.update", fallback: "Update")
  }
  internal enum Blackboard {
    internal enum Alert {
      internal enum Button {
        /// Clear filter
        internal static let clearCondition = L10n.tr("Localizable", "blackboard.alert.button.clearCondition", fallback: "Clear filter")
        /// 黒板選択を取りやめる
        internal static let destorySelectingBlackboard = L10n.tr("Localizable", "blackboard.alert.button.destorySelectingBlackboard", fallback: "黒板選択を取りやめる")
        internal enum BlackboardChangeOption {
          /// Edit
          internal static let editBlackboard = L10n.tr("Localizable", "blackboard.alert.button.blackboardChangeOption.editBlackboard", fallback: "Edit")
          /// Reload
          internal static let reloadBlackboard = L10n.tr("Localizable", "blackboard.alert.button.blackboardChangeOption.reloadBlackboard", fallback: "Reload")
          /// Select from blackboard list
          internal static let selectBlackboard = L10n.tr("Localizable", "blackboard.alert.button.blackboardChangeOption.selectBlackboard", fallback: "Select from blackboard list")
        }
      }
      internal enum CancelButton {
        /// Back to edit
        internal static let cannotSaveDuplicatedBlackboard = L10n.tr("Localizable", "blackboard.alert.cancelButton.cannotSaveDuplicatedBlackboard", fallback: "Back to edit")
      }
      internal enum ConfirmButton {
        /// Move to existing blackboard
        internal static let cannotSaveDuplicatedBlackboard = L10n.tr("Localizable", "blackboard.alert.confirmButton.cannotSaveDuplicatedBlackboard", fallback: "Move to existing blackboard")
      }
      internal enum CopyNewButton {
        /// Save as a new blackboard
        internal static let overwriteOrCopyNewBlackboard = L10n.tr("Localizable", "blackboard.alert.copyNewButton.overwriteOrCopyNewBlackboard", fallback: "Save as a new blackboard")
      }
      internal enum Desc {
        /// If you change the layout, the current contents (you entered) will be reset.
        internal static let doChangeLayout = L10n.tr("Localizable", "blackboard.alert.desc.doChangeLayout", fallback: "If you change the layout, the current contents (you entered) will be reset.")
        /// 編集した内容を破棄して、作成済みの黒板を選択しますか？
        internal static let hasEditedBlackboardItem = L10n.tr("Localizable", "blackboard.alert.desc.hasEditedBlackboardItem", fallback: "編集した内容を破棄して、作成済みの黒板を選択しますか？")
      }
      internal enum Description {
        /// Please check your input again.
        internal static let cannotSaveBlackboard = L10n.tr("Localizable", "blackboard.alert.description.cannotSaveBlackboard", fallback: "Please check your input again.")
        /// You will lose all the changes if you close this page
        internal static let destroyEditedBlackboard = L10n.tr("Localizable", "blackboard.alert.description.destroyEditedBlackboard", fallback: "You will lose all the changes if you close this page")
      }
      internal enum EditButton {
        /// Edit
        internal static let editConstructionNameInBlackboardEdit = L10n.tr("Localizable", "blackboard.alert.editButton.editConstructionNameInBlackboardEdit", fallback: "Edit")
      }
      internal enum Message {
        /// Cannot edit the text while keep the line break positions setting
        internal static let editConstructionNameInBlackboardEdit = L10n.tr("Localizable", "blackboard.alert.message.editConstructionNameInBlackboardEdit", fallback: "Cannot edit the text while keep the line break positions setting")
        /// If you overwrite and save, the original blackboard content will be lost.
        internal static let overwriteOrCopyNewBlackboard = L10n.tr("Localizable", "blackboard.alert.message.overwriteOrCopyNewBlackboard", fallback: "If you overwrite and save, the original blackboard content will be lost.")
        /// 管理者が設定を変更しました
        internal static let updateBlackboardByAdminAction = L10n.tr("Localizable", "blackboard.alert.message.updateBlackboardByAdminAction", fallback: "管理者が設定を変更しました")
      }
      internal enum OkButton {
        /// 反映する
        internal static let updateBlackboardByAdminAction = L10n.tr("Localizable", "blackboard.alert.okButton.updateBlackboardByAdminAction", fallback: "反映する")
      }
      internal enum OverwriteButton {
        /// Overwrite and save
        internal static let overwriteOrCopyNewBlackboard = L10n.tr("Localizable", "blackboard.alert.overwriteButton.overwriteOrCopyNewBlackboard", fallback: "Overwrite and save")
      }
      internal enum TakeCameraButton {
        /// Capture with existing blackboard
        internal static let cannotSaveDuplicatedBlackboard = L10n.tr("Localizable", "blackboard.alert.takeCameraButton.cannotSaveDuplicatedBlackboard", fallback: "Capture with existing blackboard")
      }
      internal enum Title {
        /// Edit this blackboard?
        internal static let blackboardChangeOptions = L10n.tr("Localizable", "blackboard.alert.title.blackboardChangeOptions", fallback: "Edit this blackboard?")
        /// Unable to save changes
        internal static let cannotSaveBlackboard = L10n.tr("Localizable", "blackboard.alert.title.cannotSaveBlackboard", fallback: "Unable to save changes")
        /// There is an existing blackboard with the same content, your changes couldn't be saved
        internal static let cannotSaveDuplicatedBlackboard = L10n.tr("Localizable", "blackboard.alert.title.cannotSaveDuplicatedBlackboard", fallback: "There is an existing blackboard with the same content, your changes couldn't be saved")
        /// Discard the changes?
        internal static let destroyEditedBlackboard = L10n.tr("Localizable", "blackboard.alert.title.destroyEditedBlackboard", fallback: "Discard the changes?")
        /// Change layout?
        internal static let doChangeLayout = L10n.tr("Localizable", "blackboard.alert.title.doChangeLayout", fallback: "Change layout?")
        /// Disable the line break position setting and edit Construction name?
        internal static let editConstructionNameInBlackboardEdit = L10n.tr("Localizable", "blackboard.alert.title.editConstructionNameInBlackboardEdit", fallback: "Disable the line break position setting and edit Construction name?")
        /// No blackboards match the filter
        internal static let emptyBlackboard = L10n.tr("Localizable", "blackboard.alert.title.emptyBlackboard", fallback: "No blackboards match the filter")
        /// 編集した内容があります
        internal static let hasEditedBlackboardItem = L10n.tr("Localizable", "blackboard.alert.title.hasEditedBlackboardItem", fallback: "編集した内容があります")
        /// This blackboard can be overwritten and saved.
        internal static let overwriteOrCopyNewBlackboard = L10n.tr("Localizable", "blackboard.alert.title.overwriteOrCopyNewBlackboard", fallback: "This blackboard can be overwritten and saved.")
      }
    }
    internal enum AutoInputInformation {
      /// (Project name)
      internal static let constructionName = L10n.tr("Localizable", "blackboard.autoInputInformation.constructionName", fallback: "(Project name)")
      /// (Construction name)
      internal static let constructionNameTitle = L10n.tr("Localizable", "blackboard.autoInputInformation.constructionNameTitle", fallback: "(Construction name)")
      /// (Configured Company Name)
      internal static let constructionPlayerName = L10n.tr("Localizable", "blackboard.autoInputInformation.constructionPlayerName", fallback: "(Configured Company Name)")
      /// (Captured date)
      internal static let date = L10n.tr("Localizable", "blackboard.autoInputInformation.date", fallback: "(Captured date)")
    }
    internal enum Create {
      /// Contents
      internal static let descriptionForInputs = L10n.tr("Localizable", "blackboard.create.descriptionForInputs", fallback: "Contents")
      /// Create a New Blackboard
      internal static let title = L10n.tr("Localizable", "blackboard.create.title", fallback: "Create a New Blackboard")
    }
    internal enum DefaultName {
      /// 透過度
      internal static let alpha = L10n.tr("Localizable", "blackboard.defaultName.alpha", fallback: "透過度")
      /// 施主名
      internal static let client = L10n.tr("Localizable", "blackboard.defaultName.client", fallback: "施主名")
      /// 工種
      internal static let constractionCategory = L10n.tr("Localizable", "blackboard.defaultName.constractionCategory", fallback: "工種")
      /// Construction name
      internal static let constractionName = L10n.tr("Localizable", "blackboard.defaultName.constractionName", fallback: "Construction name")
      /// 工事場所
      internal static let constractionPlace = L10n.tr("Localizable", "blackboard.defaultName.constractionPlace", fallback: "工事場所")
      /// 施工者
      internal static let constractionPlayer = L10n.tr("Localizable", "blackboard.defaultName.constractionPlayer", fallback: "施工者")
      /// 写真区分
      internal static let constructionPhotoClass = L10n.tr("Localizable", "blackboard.defaultName.constructionPhotoClass", fallback: "写真区分")
      /// 施工状況
      internal static let constructionState = L10n.tr("Localizable", "blackboard.defaultName.constructionState", fallback: "施工状況")
      /// 施工日
      internal static let date = L10n.tr("Localizable", "blackboard.defaultName.date", fallback: "施工日")
      /// 詳細
      internal static let detail = L10n.tr("Localizable", "blackboard.defaultName.detail", fallback: "詳細")
      /// 検査項目
      internal static let inspectionItem = L10n.tr("Localizable", "blackboard.defaultName.inspectionItem", fallback: "検査項目")
      /// 検査箇所
      internal static let inspectionPoint = L10n.tr("Localizable", "blackboard.defaultName.inspectionPoint", fallback: "検査箇所")
      /// 検査報告書
      internal static let inspectionReportTitle = L10n.tr("Localizable", "blackboard.defaultName.inspectionReportTitle", fallback: "検査報告書")
      /// 検査名
      internal static let inspectionTitle = L10n.tr("Localizable", "blackboard.defaultName.inspectionTitle", fallback: "検査名")
      /// 検査担当会社
      internal static let inspector = L10n.tr("Localizable", "blackboard.defaultName.inspector", fallback: "検査担当会社")
      /// Notes
      internal static let memo = L10n.tr("Localizable", "blackboard.defaultName.memo", fallback: "Notes")
      /// 写真タイトル
      internal static let photoTitle = L10n.tr("Localizable", "blackboard.defaultName.photoTitle", fallback: "写真タイトル")
    }
    internal enum Edit {
      /// 100%%
      internal static let alpha = L10n.tr("Localizable", "blackboard.edit.Alpha", fallback: "100%%")
      /// Blackboard transparency
      internal static let alphaForBlackboard = L10n.tr("Localizable", "blackboard.edit.alphaForBlackboard", fallback: "Blackboard transparency")
      /// SVG形式で撮影する場合、黒板は透過されません
      internal static let alphaForBlackboardFootnote = L10n.tr("Localizable", "blackboard.edit.alphaForBlackboardFootnote", fallback: "SVG形式で撮影する場合、黒板は透過されません")
      /// Contents
      internal static let descriptionForInputs = L10n.tr("Localizable", "blackboard.edit.descriptionForInputs", fallback: "Contents")
      /// Font size
      internal static let fontSize = L10n.tr("Localizable", "blackboard.edit.fontSize", fallback: "Font size")
      /// 50%%
      internal static let harfAlpha = L10n.tr("Localizable", "blackboard.edit.harfAlpha", fallback: "50%%")
      /// 0%%
      internal static let noAlpha = L10n.tr("Localizable", "blackboard.edit.noAlpha", fallback: "0%%")
      /// Horizontal align
      internal static let textHorizontalAlign = L10n.tr("Localizable", "blackboard.edit.textHorizontalAlign", fallback: "Horizontal align")
      /// Vertical align
      internal static let textVerticalAlign = L10n.tr("Localizable", "blackboard.edit.textVerticalAlign", fallback: "Vertical align")
      /// Edit blackboard
      internal static let title = L10n.tr("Localizable", "blackboard.edit.title", fallback: "Edit blackboard")
      internal enum Preview {
        internal enum SelectBlackboardButton {
          /// Blackboard list
          internal static let title = L10n.tr("Localizable", "blackboard.edit.preview.selectBlackboardButton.title", fallback: "Blackboard list")
        }
      }
      internal enum Validate {
        /// Less than %d characters
        internal static func lessThanCharacters(_ p1: Int) -> String {
          return L10n.tr("Localizable", "blackboard.edit.validate.lessThanCharacters", p1, fallback: "Less than %d characters")
        }
        /// Please fill in all fields
        internal static let shouldinputAllBlackboardItemName = L10n.tr("Localizable", "blackboard.edit.validate.shouldinputAllBlackboardItemName", fallback: "Please fill in all fields")
        /// Item name must be less than 10 characters
        internal static let shouldinputWithin10charsInBlackboardItemName = L10n.tr("Localizable", "blackboard.edit.validate.shouldinputWithin10charsInBlackboardItemName", fallback: "Item name must be less than 10 characters")
        /// Notes must be less than 200 characters
        internal static let shouldinputWithin200charsInMemo = L10n.tr("Localizable", "blackboard.edit.validate.shouldinputWithin200charsInMemo", fallback: "Notes must be less than 200 characters")
        /// Construction name must be less than 254 characters
        internal static let shouldinputWithin254charsInConstructionName = L10n.tr("Localizable", "blackboard.edit.validate.shouldinputWithin254charsInConstructionName", fallback: "Construction name must be less than 254 characters")
        /// Content of item must be less than 30 characters
        internal static let shouldinputWithin30charsInBlackboardItemValue = L10n.tr("Localizable", "blackboard.edit.validate.shouldinputWithin30charsInBlackboardItemValue", fallback: "Content of item must be less than 30 characters")
        /// Company name must be less than 30 characters
        internal static let shouldinputWithin30charsInConstructionPlayerName = L10n.tr("Localizable", "blackboard.edit.validate.shouldinputWithin30charsInConstructionPlayerName", fallback: "Company name must be less than 30 characters")
      }
    }
    internal enum Error {
      /// エラーが発生しました
      internal static let commonText = L10n.tr("Localizable", "blackboard.error.commonText", fallback: "エラーが発生しました")
      /// データが0件のため、表示できません
      internal static let emptyItem = L10n.tr("Localizable", "blackboard.error.emptyItem", fallback: "データが0件のため、表示できません")
      /// 履歴データの操作に失敗しました
      internal static let failToHandleHistories = L10n.tr("Localizable", "blackboard.error.failToHandleHistories", fallback: "履歴データの操作に失敗しました")
      /// Connection failure
      internal static let noConnection = L10n.tr("Localizable", "blackboard.error.noConnection", fallback: "Connection failure")
      /// Try again
      internal static let retry = L10n.tr("Localizable", "blackboard.error.retry", fallback: "Try again")
      internal enum CannotGetHistories {
        /// しばらくしてからもう一度お試しください
        internal static let alertDescription = L10n.tr("Localizable", "blackboard.error.cannotGetHistories.alertDescription", fallback: "しばらくしてからもう一度お試しください")
        /// 検索履歴が取得できません
        internal static let alertTitle = L10n.tr("Localizable", "blackboard.error.cannotGetHistories.alertTitle", fallback: "検索履歴が取得できません")
      }
      internal enum CannotUseHistoryFunction {
        /// ただいま履歴機能は使用できません。
        internal static let alertDescription = L10n.tr("Localizable", "blackboard.error.cannotUseHistoryFunction.alertDescription", fallback: "ただいま履歴機能は使用できません。")
      }
      internal enum FailToCreateBlackboard {
        /// Please try again at a good connection
        internal static let alertDescription = L10n.tr("Localizable", "blackboard.error.failToCreateBlackboard.alertDescription", fallback: "Please try again at a good connection")
        /// Failed to create or edit blackboard
        internal static let alertTitle = L10n.tr("Localizable", "blackboard.error.failToCreateBlackboard.alertTitle", fallback: "Failed to create or edit blackboard")
      }
    }
    internal enum Filter {
      /// With/Without Photo
      internal static let existPhoto = L10n.tr("Localizable", "blackboard.filter.existPhoto", fallback: "With/Without Photo")
      /// Free keyword
      internal static let freeword = L10n.tr("Localizable", "blackboard.filter.freeword", fallback: "Free keyword")
      /// The contents that were not included in filtered blackboards are hidden
      internal static let hideContentNotice = L10n.tr("Localizable", "blackboard.filter.hideContentNotice", fallback: "The contents that were not included in filtered blackboards are hidden")
      /// Items
      internal static let item = L10n.tr("Localizable", "blackboard.filter.item", fallback: "Items")
      /// Notes
      internal static let memo = L10n.tr("Localizable", "blackboard.filter.memo", fallback: "Notes")
      /// %d件の絞り込み条件
      internal static func multiSelectText(_ p1: Int) -> String {
        return L10n.tr("Localizable", "blackboard.filter.multiSelectText", p1, fallback: "%d件の絞り込み条件")
      }
      /// 検索に一致する項目がありませんでした。
      internal static let noMatchMessage = L10n.tr("Localizable", "blackboard.filter.noMatchMessage", fallback: "検索に一致する項目がありませんでした。")
      /// Not available
      internal static let notApplicable = L10n.tr("Localizable", "blackboard.filter.notApplicable", fallback: "Not available")
      /// 再検索
      internal static let reSearch = L10n.tr("Localizable", "blackboard.filter.reSearch", fallback: "再検索")
      /// Select
      internal static let select = L10n.tr("Localizable", "blackboard.filter.select", fallback: "Select")
      /// No %@
      internal static func selectEmptyItem(_ p1: Any) -> String {
        return L10n.tr("Localizable", "blackboard.filter.selectEmptyItem", String(describing: p1), fallback: "No %@")
      }
      /// Display all items
      internal static let showAllBlackboardItemsButtonText = L10n.tr("Localizable", "blackboard.filter.showAllBlackboardItemsButtonText", fallback: "Display all items")
      /// Blackboard filter
      internal static let title = L10n.tr("Localizable", "blackboard.filter.title", fallback: "Blackboard filter")
      /// Not selected
      internal static let unspecified = L10n.tr("Localizable", "blackboard.filter.unspecified", fallback: "Not selected")
      internal enum Clear {
        /// Clear
        internal static let clearText = L10n.tr("Localizable", "blackboard.filter.clear.clearText", fallback: "Clear")
        /// Clear the filter items?
        internal static let clearTextConfirmMessage = L10n.tr("Localizable", "blackboard.filter.clear.clearTextConfirmMessage", fallback: "Clear the filter items?")
        /// 条件を削除
        internal static let deleteText = L10n.tr("Localizable", "blackboard.filter.clear.deleteText", fallback: "条件を削除")
        /// 条件をクリアする
        internal static let searchClearText = L10n.tr("Localizable", "blackboard.filter.clear.searchClearText", fallback: "条件をクリアする")
      }
      internal enum EditAlert {
        /// Discard
        internal static let destruction = L10n.tr("Localizable", "blackboard.filter.editAlert.destruction", fallback: "Discard")
        /// Discard the changed contents?
        internal static let message = L10n.tr("Localizable", "blackboard.filter.editAlert.message", fallback: "Discard the changed contents?")
        /// Discard change
        internal static let title = L10n.tr("Localizable", "blackboard.filter.editAlert.title", fallback: "Discard change")
      }
      internal enum Photo {
        /// All
        internal static let all = L10n.tr("Localizable", "blackboard.filter.photo.all", fallback: "All")
        /// Without photo
        internal static let onlyWithoutPhotos = L10n.tr("Localizable", "blackboard.filter.photo.onlyWithoutPhotos", fallback: "Without photo")
        /// With photo
        internal static let onlyWithPhotos = L10n.tr("Localizable", "blackboard.filter.photo.onlyWithPhotos", fallback: "With photo")
      }
      internal enum SectionTitle {
        /// Items
        internal static let blackboardItem = L10n.tr("Localizable", "blackboard.filter.sectionTitle.blackboardItem", fallback: "Items")
        /// Free keyword (Up to 5 words)
        internal static let freeword = L10n.tr("Localizable", "blackboard.filter.sectionTitle.freeword", fallback: "Free keyword (Up to 5 words)")
      }
      internal enum Title {
        /// Search for items
        internal static let searchForBlackboardItem = L10n.tr("Localizable", "blackboard.filter.title.searchForBlackboardItem", fallback: "Search for items")
      }
    }
    internal enum Filtered {
      /// %d件
      internal static func count(_ p1: Int) -> String {
        return L10n.tr("Localizable", "blackboard.filtered.count", p1, fallback: "%d件")
      }
      /// -件
      internal static let emptyCount = L10n.tr("Localizable", "blackboard.filtered.emptyCount", fallback: "-件")
    }
    internal enum History {
      /// Search history
      internal static let title = L10n.tr("Localizable", "blackboard.history.title", fallback: "Search history")
    }
    internal enum Layoutlist {
      /// Select a blackboard layout
      internal static let title = L10n.tr("Localizable", "blackboard.layoutlist.title", fallback: "Select a blackboard layout")
      internal enum HeaderDescription {
        /// Please select a layout to create a new blackboard
        internal static let selectBlackboardLayout = L10n.tr("Localizable", "blackboard.layoutlist.headerDescription.selectBlackboardLayout", fallback: "Please select a layout to create a new blackboard")
      }
    }
    internal enum List {
      /// Filter
      internal static let filter = L10n.tr("Localizable", "blackboard.list.filter", fallback: "Filter")
      /// No blackboard
      internal static let noBlackboardMessage = L10n.tr("Localizable", "blackboard.list.noBlackboardMessage", fallback: "No blackboard")
      /// No matched blackboards were found.
      internal static let noMatchMessage = L10n.tr("Localizable", "blackboard.list.noMatchMessage", fallback: "No matched blackboards were found.")
      /// Blackboards
      internal static let title = L10n.tr("Localizable", "blackboard.list.title", fallback: "Blackboards")
      internal enum Photo {
        /// %d photo(s)
        internal static func count(_ p1: Int) -> String {
          return L10n.tr("Localizable", "blackboard.list.photo.count", p1, fallback: "%d photo(s)")
        }
      }
      internal enum Sort {
        /// Total %d item(s)
        internal static func total(_ p1: Int) -> String {
          return L10n.tr("Localizable", "blackboard.list.sort.total", p1, fallback: "Total %d item(s)")
        }
        /// Total - item(s)
        internal static let totalZero = L10n.tr("Localizable", "blackboard.list.sort.totalZero", fallback: "Total - item(s)")
      }
    }
    internal enum MiniatureMap {
      internal enum Alert {
        internal enum CancelButton {
          /// 撮影を中断
          internal static let failedToLoadMiniatureMap = L10n.tr("Localizable", "blackboard.miniatureMap.alert.cancelButton.failedToLoadMiniatureMap", fallback: "撮影を中断")
        }
        internal enum Description {
          /// 通信環境の良いところで再度お試しください
          internal static let failedToLoadMiniatureMap = L10n.tr("Localizable", "blackboard.miniatureMap.alert.description.failedToLoadMiniatureMap", fallback: "通信環境の良いところで再度お試しください")
        }
        internal enum Title {
          /// 黒板内の豆図ファイルの読み込みに失敗しました
          internal static let failedToLoadMiniatureMap = L10n.tr("Localizable", "blackboard.miniatureMap.alert.title.failedToLoadMiniatureMap", fallback: "黒板内の豆図ファイルの読み込みに失敗しました")
        }
      }
    }
    internal enum Variable {
      /// No %@
      internal static func emptyBlackboardItem(_ p1: Any) -> String {
        return L10n.tr("Localizable", "blackboard.variable.emptyBlackboardItem", String(describing: p1), fallback: "No %@")
      }
      /// %@を選択
      internal static func selectBlackboardItem(_ p1: Any) -> String {
        return L10n.tr("Localizable", "blackboard.variable.selectBlackboardItem", String(describing: p1), fallback: "%@を選択")
      }
      internal enum Input {
        /// Item %d
        internal static func blackboardItemName(_ p1: Int) -> String {
          return L10n.tr("Localizable", "blackboard.variable.input.blackboardItemName", p1, fallback: "Item %d")
        }
        /// Content %d
        internal static func blackboardItemValue(_ p1: Int) -> String {
          return L10n.tr("Localizable", "blackboard.variable.input.blackboardItemValue", p1, fallback: "Content %d")
        }
      }
    }
  }
  internal enum Camera {
    /// 撮影枚数が上限に達したため写真書き込みはできません
    internal static let drawDisabled = L10n.tr("Localizable", "camera.drawDisabled", fallback: "撮影枚数が上限に達したため写真書き込みはできません")
    /// Auto
    internal static let iconTitleAuto = L10n.tr("Localizable", "camera.iconTitleAuto", fallback: "Auto")
    /// Config
    internal static let iconTitleBlackboardSettings = L10n.tr("Localizable", "camera.iconTitleBlackboardSettings", fallback: "Config")
    /// Lock
    internal static let iconTitleLock = L10n.tr("Localizable", "camera.iconTitleLock", fallback: "Lock")
    /// Off
    internal static let iconTitleOff = L10n.tr("Localizable", "camera.iconTitleOff", fallback: "Off")
    /// On
    internal static let iconTitleOn = L10n.tr("Localizable", "camera.iconTitleOn", fallback: "On")
    /// Back
    internal static let iconTitleSwitchBack = L10n.tr("Localizable", "camera.iconTitleSwitchBack", fallback: "Back")
    /// Front
    internal static let iconTitleSwitchFront = L10n.tr("Localizable", "camera.iconTitleSwitchFront", fallback: "Front")
    /// Rotate
    internal static let iconTitleUnlock = L10n.tr("Localizable", "camera.iconTitleUnlock", fallback: "Rotate")
    /// Maximum number of photos reached
    internal static let reachedPhotoLimit = L10n.tr("Localizable", "camera.reachedPhotoLimit", fallback: "Maximum number of photos reached")
    internal enum Alert {
      internal enum CancelButton {
        /// Back to camera
        internal static let destroyPhotos = L10n.tr("Localizable", "camera.alert.cancelButton.destroyPhotos", fallback: "Back to camera")
      }
      internal enum Description {
        /// The captured photos will not be saved if you close the camera without saving the photos
        internal static let destroyPhotos = L10n.tr("Localizable", "camera.alert.description.destroyPhotos", fallback: "The captured photos will not be saved if you close the camera without saving the photos")
      }
      internal enum Title {
        /// Discard captured image?
        internal static let destroyPhotos = L10n.tr("Localizable", "camera.alert.title.destroyPhotos", fallback: "Discard captured image?")
      }
      internal enum UploadButton {
        /// To upload
        internal static let destroyPhotos = L10n.tr("Localizable", "camera.alert.uploadButton.destroyPhotos", fallback: "To upload")
      }
    }
    internal enum BlackboardSettings {
      /// Blackboard settings
      internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.title", fallback: "Blackboard settings")
      internal enum Footer {
        internal enum Size {
          internal enum Callout {
            /// ※The default value is "%@"
            internal static func title(_ p1: Any) -> String {
              return L10n.tr("Localizable", "camera.blackboardSettings.footer.size.callout.title", String(describing: p1), fallback: "※The default value is \"%@\"")
            }
          }
        }
      }
      internal enum Orientation {
        /// Direction
        internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.orientation.title", fallback: "Direction")
        internal enum Lock {
          /// Lock
          internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.orientation.lock.title", fallback: "Lock")
        }
        internal enum Unlock {
          /// Rotate
          internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.orientation.unlock.title", fallback: "Rotate")
        }
      }
      internal enum PhotoQuality {
        /// Quality
        internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.title", fallback: "Quality")
        internal enum Cals1M {
          /// (1M)
          internal static let description = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.cals1M.description", fallback: "(1M)")
          /// CALS Low
          internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.cals1M.title", fallback: "CALS Low")
        }
        internal enum Cals2M {
          /// (2M)
          internal static let description = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.cals2M.description", fallback: "(2M)")
          /// CALS Med
          internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.cals2M.title", fallback: "CALS Med")
        }
        internal enum Cals3M {
          /// (3M)
          internal static let description = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.cals3M.description", fallback: "(3M)")
          /// CALS Lrg
          internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.cals3M.title", fallback: "CALS Lrg")
        }
        internal enum DefaultHigh {
          /// (1725×
          /// 2300)
          internal static let description = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.defaultHigh.description", fallback: "(1725×\n2300)")
          /// High
          internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.defaultHigh.title", fallback: "High")
        }
        internal enum DefaultStandard {
          /// (975×
          /// 1300)
          internal static let description = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.defaultStandard.description", fallback: "(975×\n1300)")
          /// Standard
          internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.photoQuality.defaultStandard.title", fallback: "Standard")
        }
      }
      internal enum PhotoType {
        /// JPG
        internal static let jpeg = L10n.tr("Localizable", "camera.blackboardSettings.photoType.jpeg", fallback: "JPG")
        /// SVG
        internal static let svg = L10n.tr("Localizable", "camera.blackboardSettings.photoType.svg", fallback: "SVG")
        /// Format
        internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.photoType.title", fallback: "Format")
      }
      internal enum Size {
        /// Free value
        internal static let free = L10n.tr("Localizable", "camera.blackboardSettings.size.free", fallback: "Free value")
        /// L
        internal static let large = L10n.tr("Localizable", "camera.blackboardSettings.size.large", fallback: "L")
        /// M
        internal static let medium = L10n.tr("Localizable", "camera.blackboardSettings.size.medium", fallback: "M")
        /// S
        internal static let small = L10n.tr("Localizable", "camera.blackboardSettings.size.small", fallback: "S")
        /// Size
        internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.size.title", fallback: "Size")
        internal enum Large {
          /// (150%%)
          internal static let description = L10n.tr("Localizable", "camera.blackboardSettings.size.large.description", fallback: "(150%%)")
        }
        internal enum Medium {
          /// (100%%)
          internal static let description = L10n.tr("Localizable", "camera.blackboardSettings.size.medium.description", fallback: "(100%%)")
        }
        internal enum Small {
          /// (75%%)
          internal static let description = L10n.tr("Localizable", "camera.blackboardSettings.size.small.description", fallback: "(75%%)")
        }
      }
      internal enum Visibility {
        /// Display
        internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.visibility.title", fallback: "Display")
        internal enum Off {
          /// Off
          internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.visibility.off.title", fallback: "Off")
        }
        internal enum On {
          /// On
          internal static let title = L10n.tr("Localizable", "camera.blackboardSettings.visibility.on.title", fallback: "On")
        }
      }
    }
    internal enum Button {
      /// Next
      internal static let next = L10n.tr("Localizable", "camera.button.next", fallback: "Next")
    }
    internal enum Timer {
      /// %d秒
      internal static func seconds(_ p1: Int) -> String {
        return L10n.tr("Localizable", "camera.timer.seconds", p1, fallback: "%d秒")
      }
    }
    internal enum Variables {
      /// Please take up to %d photos only
      internal static func countPhotoLimit(_ p1: Int) -> String {
        return L10n.tr("Localizable", "camera.variables.countPhotoLimit", p1, fallback: "Please take up to %d photos only")
      }
      /// 撮影枚数: %d枚
      internal static func countTakePhotos(_ p1: Int) -> String {
        return L10n.tr("Localizable", "camera.variables.countTakePhotos", p1, fallback: "撮影枚数: %d枚")
      }
    }
  }
  internal enum Common {
    /// Back
    internal static let back = L10n.tr("Localizable", "common.back", fallback: "Back")
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// データが0件のため、表示できません
    internal static let cannotShowZeroData = L10n.tr("Localizable", "common.cannotShowZeroData", fallback: "データが0件のため、表示できません")
    /// Change
    internal static let change = L10n.tr("Localizable", "common.change", fallback: "Change")
    /// Close
    internal static let close = L10n.tr("Localizable", "common.close", fallback: "Close")
    /// 、
    internal static let comma = L10n.tr("Localizable", "common.comma", fallback: "、")
    /// Delete
    internal static let delete = L10n.tr("Localizable", "common.delete", fallback: "Delete")
    /// Discard
    internal static let destroy = L10n.tr("Localizable", "common.destroy", fallback: "Discard")
    /// Done
    internal static let done = L10n.tr("Localizable", "common.done", fallback: "Done")
    /// Write-on
    internal static let draw = L10n.tr("Localizable", "common.draw", fallback: "Write-on")
    /// Error
    internal static let error = L10n.tr("Localizable", "common.error", fallback: "Error")
    /// OK
    internal static let ok = L10n.tr("Localizable", "common.ok", fallback: "OK")
    /// Try again
    internal static let retry = L10n.tr("Localizable", "common.retry", fallback: "Try again")
    /// Save
    internal static let save = L10n.tr("Localizable", "common.save", fallback: "Save")
    /// このまま選択
    internal static let selectAsItIs = L10n.tr("Localizable", "common.selectAsItIs", fallback: "このまま選択")
    internal enum Alert {
      internal enum Description {
        /// Please update your application in order to use these blackboard
        internal static let appUpdate = L10n.tr("Localizable", "common.alert.description.appUpdate", fallback: "Please update your application in order to use these blackboard")
      }
      internal enum Title {
        /// Update the application?
        internal static let appUpdate = L10n.tr("Localizable", "common.alert.title.appUpdate", fallback: "Update the application?")
      }
      internal enum UpdateButton {
        /// Update
        internal static let appUpdate = L10n.tr("Localizable", "common.alert.updateButton.appUpdate", fallback: "Update")
      }
    }
    internal enum Error {
      /// Connection failure
      internal static let failToConnectNetwork = L10n.tr("Localizable", "common.error.failToConnectNetwork", fallback: "Connection failure")
      /// 処理を完了できませんでした
      internal static let operationCouldNotBeCompleted = L10n.tr("Localizable", "common.error.operationCouldNotBeCompleted", fallback: "処理を完了できませんでした")
      /// 不明なエラーが発生しました。
      internal static let unknown = L10n.tr("Localizable", "common.error.unknown", fallback: "不明なエラーが発生しました。")
    }
    internal enum Title {
      /// 黒板を変更
      internal static let changeBlackboard = L10n.tr("Localizable", "common.title.changeBlackboard", fallback: "黒板を変更")
      /// 黒板を編集
      internal static let editBlackboard = L10n.tr("Localizable", "common.title.editBlackboard", fallback: "黒板を編集")
      /// 項目を編集
      internal static let editCase = L10n.tr("Localizable", "common.title.editCase", fallback: "項目を編集")
      /// レイアウトを選択
      internal static let selectLayout = L10n.tr("Localizable", "common.title.selectLayout", fallback: "レイアウトを選択")
    }
    internal enum Variables {
      internal enum Validate {
        /// %@は%d文字以内にしてください
        internal static func textMaxLength(_ p1: Any, _ p2: Int) -> String {
          return L10n.tr("Localizable", "common.variables.validate.textMaxLength", String(describing: p1), p2, fallback: "%@は%d文字以内にしてください")
        }
      }
    }
  }
  internal enum Memo {
    internal enum Input {
      /// Notes
      internal static let placeholder = L10n.tr("Localizable", "memo.input.placeholder", fallback: "Notes")
    }
  }
  internal enum Offline {
    /// Unuploaded photos（%d）
    internal static func unuploadedPhotos(_ p1: Int) -> String {
      return L10n.tr("Localizable", "offline.unuploadedPhotos", p1, fallback: "Unuploaded photos（%d）")
    }
    internal enum Bar {
      /// ANDPAD is currently set to offline
      internal static let label = L10n.tr("Localizable", "offline.bar.label", fallback: "ANDPAD is currently set to offline")
    }
  }
  internal enum Photo {
    /// Delete this photo?
    internal static let isDeletePhoto = L10n.tr("Localizable", "photo.isDeletePhoto", fallback: "Delete this photo?")
    /// AE/AF lock
    internal static let lockAEAF = L10n.tr("Localizable", "photo.lockAEAF", fallback: "AE/AF lock")
    /// Save
    internal static let save = L10n.tr("Localizable", "photo.save", fallback: "Save")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.andpadCamera.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

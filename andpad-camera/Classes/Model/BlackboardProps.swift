//
//  BlackboardProps.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/08/28.
//

// swiftlint:disable switch_case_alignment

import CryptoKit
import Foundation

// MARK: - BlackboardProps

/**
 JSの型BlackboardPropsを再現しています
 @see: https://github.com/88labs/andpad-blackboard-web-components
 */
public struct BlackboardProps: Encodable, Sendable {
    enum BlackboardPropsError: LocalizedError {
        case failedToEncodeJSON

        var errorDescription: String? {
            switch self {
            case .failedToEncodeJSON:
                return "BlackboardPropsをJSONにエンコードするのに失敗しました。"
            }
        }
    }

    enum Color: String, Encodable {
        case black
        case white
        case green

        init(theme: ModernBlackboardAppearance.Theme) {
            self = switch theme {
            case .black: BlackboardProps.Color.black
            case .white: BlackboardProps.Color.white
            case .green: BlackboardProps.Color.green
            }
        }
    }

    enum RemarkHorizontalAlign: String, Encodable {
        case left
        case center
        case right

        init(memoStyle: ModernBlackboardMemoStyleArguments) {
            self = switch memoStyle.horizontalAlignment {
            case .center: RemarkHorizontalAlign.center
            case .right: RemarkHorizontalAlign.right
            case .left: RemarkHorizontalAlign.left
            default: RemarkHorizontalAlign.left
            }
        }
    }

    enum RemarkTextSize: String, Encodable {
        case small
        case medium
        case large

        init(memoStyle: ModernBlackboardMemoStyleArguments) {
            self = switch memoStyle.adjustableMaxFontSize {
            case .small: RemarkTextSize.small
            case .medium: RemarkTextSize.medium
            case .large: RemarkTextSize.large
            }
        }
    }

    enum RemarkVerticalAlign: String, Encodable {
        case top
        case middle
        case bottom

        init(memoStyle: ModernBlackboardMemoStyleArguments) {
            self = switch memoStyle.verticalAlignment {
            case .top: RemarkVerticalAlign.top
            case .middle: RemarkVerticalAlign.middle
            case .bottom: RemarkVerticalAlign.bottom
            }
        }
    }

    enum FirstRowBlackboardItemBodyType: String, Encodable {
        case initialValue = "initial_value"
        case custom
    }

    enum Opacity: Float, Encodable {
        case zero = 0 // 透明
        case half = 0.5
        case full = 1 // 透過なし

        init(alphaLevel: ModernBlackboardAppearance.AlphaLevel) {
            // Opacity と alphaLevel で値の効果が反対なのを注意すること
            self = switch alphaLevel {
            case .zero: Opacity.full
            case .half: Opacity.half
            case .full: Opacity.zero
            }
        }
    }

    struct Order: Encodable {
        /// 案件名の型
        ///
        /// もとのjsが `name: string | string[];` と union型で文字列もしくは文字列配列を許容する型だが、swiftではそれに対応する型がないので、文字列と文字列配列それぞれの変数を定義した。jsonへの変換時は、encode関数でnameを調整している。
        enum NameType: Encodable {
            /// 案件名の改行反映なしの場合
            case single(String)
            /// 案件名の改行反映ありの場合
            case multiple([String])

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .single(let name):
                    try container.encode(name)
                case .multiple(let names):
                    try container.encode(names)
                }
            }
        }

        let id: Int
        let name: NameType

        init(id: Int, name: NameType) {
            self.id = id
            self.name = name
        }

        init(
            blackboardDataObject: ModernBlackboardContent.ModernBlackboardDataObject,
            displayStyle: ModernBlackboardCaseViewDisplayStyle,
            shouldBeReflectedNewLine: Bool
        ) {
            switch blackboardDataObject {
            case .material(item: let item):
                // 案件名
                // 「自動入力値についての情報」を表記する場合を考慮
                let name = displayStyle.autoInputInformationText(keyItem: .constructionName) ?? item.items.first { $0.isConstructionNameItem }?.body ?? ""
                // Note: 配列の中身が1件だとしても、改行反映ありの場合は配列で返す必要がある
                if shouldBeReflectedNewLine {
                    self.init(
                        id: item.id,
                        name: .multiple(name.components(separatedBy: .newlines))
                    )
                } else {
                    self.init(
                        id: item.id,
                        name: .single(name)
                    )
                }
            case .layout(item: let item):
                // FIXME: レイアウト共通化 今回の開発範囲では対象外なため、確認は不十分です
                self.init(
                    id: item.id,
                    name: .single(L10n.Blackboard.DefaultName.constractionName)
                )
            }
        }
    }

    struct Blackboard: Encodable {
        let id: Int
        let blackboardTemplateId: Int

        // 元々はUnion型で定義されている。enumで定義すべきだが、数が多い＆可変になるのでIntで定義する
        let layoutTypeId: Int

        let contents: [Content]
        let photosCount: Int
        let miniatureMapUrl: String?

        // swiftlint:disable discouraged_optional_boolean
        // Swiftでは好ましくない型定義だが、JS側の実装に従う
        let isMiniatureMapProcessing: Bool?
        let isEdged: Bool?
        // swiftlint:enable discouraged_optional_boolean

        /// 初期化
        /// - Parameters:
        ///   - blackboardContent: 黒板WebViewに表示する内容 ModernBlackboardContent
        ///   - miniatureMapImageType: 豆図画像の種類
        ///   - shouldShowMiniatureMapFromLocal: ローカルに保存した豆図画像を読み込むかどうか。オフライン対応でローカルから豆図画像を読み込むかどうか判別するために使用する。
        ///   - shouldShowPlaceholder: プレースホルダーを表示するかどうか
        init(
            blackboardContent: ModernBlackboardContent,
            miniatureMapImageType: MiniatureMapImageType,
            shouldShowMiniatureMapFromLocal: Bool,
            shouldShowPlaceholder: Bool
        ) async {
            self.contents = Content.makeContents(
                blackboardContent: blackboardContent,
                shouldShowPlaceholder: shouldShowPlaceholder
            )
            switch blackboardContent.modernBlackboardDataObject {
            case .material(item: let item):
                // 撮影画面などではこちらが呼ばれる（初期フェーズで対応する箇所）
                self.id = item.id
                self.blackboardTemplateId = item.blackboardTemplateID
                self.layoutTypeId = item.layoutTypeID
                self.photosCount = item.photoCount
                self.miniatureMapUrl = await item.miniatureMap?.getImageURLString(
                    imageType: miniatureMapImageType,
                    shouldShowMiniatureMapFromLocal: shouldShowMiniatureMapFromLocal
                )
                self.isMiniatureMapProcessing = nil
                self.isEdged = nil
            case .layout(item: let item):
                // FIXME: レイアウト共通化 今回の開発範囲では対象外なため、確認は不十分です
                self.id = item.id
                self.blackboardTemplateId = blackboardContent.pattern.layoutID
                self.layoutTypeId = item.layoutMaterial.id
                self.photosCount = 0
                self.miniatureMapUrl = nil
                self.isMiniatureMapProcessing = nil
                self.isEdged = nil
            }
        }

        struct Content: Encodable {
            let position: Int
            let body: String
            let itemName: String
            let displayFlg: Bool // jsの元々の実装を尊重する
            let placeholder: Placeholder?

            static func makeContents(blackboardContent: ModernBlackboardContent, shouldShowPlaceholder: Bool) -> [Content] {
                switch blackboardContent.modernBlackboardDataObject {
                case .material(item: let item):
                    let contents = item.items.enumerated().map {
                        let index = $0.offset
                        let object = $0.element

                        // これはアプリ側でlayoutの構成を知っておく必要がある。
                        // レイアウト共通化を完全対応（自由化）する場合は、
                        // たとえば item 自体に種類プロパティなどが必要になりそう
                        let tempBody = blackboardContent.values?[safe: index] ?? object.body
                        let body = switch object.position {
                        case blackboardContent.pattern.specifiedPosition(by: .constructionName):
                            blackboardContent.displayStyle.autoInputInformationText(keyItem: .constructionName) ?? tempBody
                        case blackboardContent.pattern.specifiedPosition(by: .memo):
                            blackboardContent.displayStyle.autoInputInformationText(keyItem: .memo) ?? tempBody
                        case blackboardContent.pattern.specifiedPosition(by: .date):
                            blackboardContent.displayStyle.autoInputInformationText(keyItem: .date) ?? tempBody
                        case blackboardContent.pattern.specifiedPosition(by: .constructionPlayer):
                            blackboardContent.displayStyle.autoInputInformationText(keyItem: .constructionPlayer) ?? tempBody
                        default:
                            tempBody
                        }

                        // プレースホルダ (備考・項目名・項目内容のみセットする)
                        let placeholder: Placeholder?
                        if shouldShowPlaceholder {
                            switch object.position {
                            case blackboardContent.pattern.specifiedPosition(by: .constructionName):
                                placeholder = nil
                            case blackboardContent.pattern.specifiedPosition(by: .memo):
                                // 備考欄は項目内容にあたる。また、プレースホルダにはAPIから取得した項目名を表示する。
                                placeholder = .init(
                                    itemName: nil,
                                    body: object.itemName
                                )
                            case blackboardContent.pattern.specifiedPosition(by: .date):
                                placeholder = nil
                            case blackboardContent.pattern.specifiedPosition(by: .constructionPlayer):
                                placeholder = nil
                            default:
                                placeholder = .init(
                                    itemName: L10n.Blackboard.Variable.Input.blackboardItemName(index),
                                    body: L10n.Blackboard.Variable.Input.blackboardItemValue(index)
                                )
                            }
                        } else {
                            placeholder = nil
                        }

                        return Content(
                            position: object.position,
                            body: body,
                            itemName: object.itemName,
                            displayFlg: true,
                            placeholder: placeholder
                        )
                    }
                    return contents
                case .layout(item: let item):
                    // FIXME: レイアウト共通化 今回の開発範囲では対象外なため、確認は不十分です
                    let contents = item.items.map {
                        Content(
                            position: $0.position,
                            body: "",
                            itemName: $0.itemName,
                            displayFlg: true,
                            placeholder: nil
                        )
                    }
                    return contents
                }
            }
        }

        struct Placeholder: Encodable {
            let itemName: String?
            let body: String?
        }
    }

    let order: Order
    let blackboard: Blackboard
    let color: Color
    let scale: Float

    /**
     characterWidthRatioにnilを設定すると、SVG作成時にデフォルト値の0.6が利用される
     ここで小数を設定すると、処理の過程で2進数の誤差が生じるので注意すること
     */
    let characterWidthRatio: Float?
    let isShowEmptyMiniatureMap: Bool
    let isHiddenNoneAndEmptyMiniatureMap: Bool
    let remarkHorizontalAlign: RemarkHorizontalAlign
    let remarkTextSize: RemarkTextSize
    let remarkVerticalAlign: RemarkVerticalAlign
    let firstRowBlackboardItemBodyType: FirstRowBlackboardItemBodyType
    let firstRowBlackboardItemBody: String
    let opacity: Opacity
    let isEdged: Bool

    /// ModernBlackboardContentからJSの型BlackboardPropsを生成する
    /// - Parameters:
    ///   - blackboardContent: 黒板WebViewに表示する内容 ModernBlackboardContent
    ///   - size: 黒板WebViewのサイズ。HTMLのスケールの計算に使用する。
    ///   - miniatureMapImageType: 豆図画像の種類
    ///   - shouldShowMiniatureMapFromLocal: ローカルに保存した豆図画像を読み込むかどうか。オフライン対応でローカルから豆図画像を読み込むかどうか判別するために使用します。使用しない場合はfalseを指定してください。
    ///   - isShowEmptyMiniatureMap: 豆図の部分に、豆図画像ロード前の画像を表示するか、豆図登録なしの画像を表示するか。 `true` : 豆図画像ロード前の画像を表示する。 `false` : 豆図登録なしの画像を表示する。なお、サーバー側では `false` がデフォルト値になっている。
    ///   - isHiddenNoneAndEmptyMiniatureMap: 豆図の部分が、豆図画像ロード前の画像か豆図登録なしの画像の場合、非表示にするか。 `true` : 非表示にする。 `false` : 表示する。なお、サーバー側では `false` がデフォルト値になっている。
    ///   - shouldShowPlaceholder: プレースホルダーを表示するかどうか。 `true` : プレースホルダーを表示する。 `false` : 表示しない。
    public init(
        blackboardContent: ModernBlackboardContent,
        size: CGSize,
        miniatureMapImageType: MiniatureMapImageType,
        shouldShowMiniatureMapFromLocal: Bool,
        isShowEmptyMiniatureMap: Bool,
        isHiddenNoneAndEmptyMiniatureMap: Bool,
        shouldShowPlaceholder: Bool
    ) async {
        self.order = .init(
            blackboardDataObject: blackboardContent.modernBlackboardDataObject,
            displayStyle: blackboardContent.displayStyle,
            shouldBeReflectedNewLine: blackboardContent.shouldBeReflectedNewLine
        )
        self.blackboard = await Blackboard(
            blackboardContent: blackboardContent,
            miniatureMapImageType: miniatureMapImageType,
            shouldShowMiniatureMapFromLocal: shouldShowMiniatureMapFromLocal,
            shouldShowPlaceholder: shouldShowPlaceholder
        )
        self.color = BlackboardProps.Color(theme: blackboardContent.theme)
        // アプリの黒板サイズを、index.htmlのsvgが180x138であることを元に、scaleで調整する
        self.scale = Float(max(size.width, size.height) / 180)
        self.characterWidthRatio = nil
        self.remarkHorizontalAlign = RemarkHorizontalAlign(memoStyle: blackboardContent.memoStyleArguments)
        self.remarkTextSize = RemarkTextSize(memoStyle: blackboardContent.memoStyleArguments)
        self.remarkVerticalAlign = RemarkVerticalAlign(memoStyle: blackboardContent.memoStyleArguments)
        // ここでは表示するテキストしかないので、表示素材から取得する
        self.firstRowBlackboardItemBody = {
            switch blackboardContent.modernBlackboardDataObject {
            case .material(item: let item):
                return item.items.first { $0.isConstructionNameItem }?.itemName ?? ""
            case .layout(item: let item):
                return item.items.first { $0.position == 1 }?.itemName ?? ""
            }
        }()
        // この時点では、初期値なのかカスタムなのか分からないので、firstRowBlackboardItemBodyから判定する
        self.firstRowBlackboardItemBodyType = self.firstRowBlackboardItemBody.isEmpty ? .initialValue : .custom
        self.opacity = Opacity(alphaLevel: blackboardContent.alphaLevel)
        self.isEdged = !(blackboardContent.displayStyle.shouldSetCornerRounder)

        self.isShowEmptyMiniatureMap = isShowEmptyMiniatureMap
        self.isHiddenNoneAndEmptyMiniatureMap = isHiddenNoneAndEmptyMiniatureMap
    }

    func encodeToJSON() throws -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(self)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw BlackboardPropsError.failedToEncodeJSON
        }
        return jsonString
    }

    /// 黒板を生成するためのクエリーパラメーターを作成する
    /// - Returns: クエリーパラメーター
    public func makeQueryParameter() throws -> String {
        let json = try encodeToJSON()
        let parameter = try JavaScriptBridge().stringify(jsonString: json)
        return parameter
    }
}

private extension Collection {
    /**
     配列の範囲外のindexを指定するとnilを返す
     */
    subscript(safe index: Index) -> Element? {
        if startIndex <= index, index < endIndex {
            return self[index]
        }
        return nil
    }
}

private extension ModernBlackboardMaterial.MiniatureMap {
    /// 指定されたサイズの豆図画像のURL文字列を取得する。
    /// オンラインモードの場合は、Web URLを返す。
    /// オフラインモードの場合は、ローカルに保存された豆図画像をHTMLで扱えるファイルパスに保存し直してから、そのファイルパスを返す。
    ///
    /// - Parameters:
    ///   - imageType: 豆図画像の種類
    ///   - shouldShowMiniatureMapFromLocal: ローカルに保存した豆図画像を読み込むかどうか。オフライン対応でローカルから豆図画像を読み込むかどうか判別するために使用する。
    /// - Returns: 豆図画像のURL文字列。URLが見つからない場合は `nil` を返す。
    @MainActor
    func getImageURLString(
        imageType: MiniatureMapImageType,
        shouldShowMiniatureMapFromLocal: Bool
    ) -> String? {
        if shouldShowMiniatureMapFromLocal {
            // オフラインモードの場合
            // ローカルに保存された豆図画像を取得する。
            guard let image = OfflineStorageHandler.shared.blackboard.fetchMiniatureMap(withID: id, imageType: imageType) else {
                return nil
            }
            do {
                // HTMLで扱えるファイルパスに保存し直す。
                return try fetchOrCreateLocalPath(from: image)
            } catch {
                assertionFailure(error.localizedDescription)
                return nil
            }
        } else {
            // オンラインモードの場合
            let imageURL = switch imageType {
            case .rawImage:
                imageURL
            case .thumbnail:
                imageThumbnailURL
            }
            return imageURL?.absoluteString
        }
    }

    /**
     豆図画像のローカルパスを取得する

     @description
     SVGでは画像をパスで渡す必要があるため、
     画像データをtempディレクトリに保存して、そのローカルパスを返す。
     */
    func fetchOrCreateLocalPath(from image: UIImage) throws -> String? {
        // 保存するtempディレクトリ
        // なお、tempディレクトリに保存するので、アプリ内では削除機能は実装しない
        let dirName = AppInfoUtil.svgBlackboardMiniatureMapImageDirectoryName
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(dirName)

        // ディレクトリが存在しない場合は作成する
        if !fileManager.fileExists(atPath: tempDirectory.path) {
            try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        // 保存するファイル名は画像データから作成する
        let fileName = image.uniqueName()
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        // すでに保存済みならば、ダウンロードせずにローカルパスを返す
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL.path
        }

        do {
            if let data = image.data() {
                try data.write(to: fileURL)
                return fileURL.path
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

private extension UIImage {
    func data() -> Data? {
        return self.jpegData(compressionQuality: 1.0)
    }

    /**
     画像自体からユニークな画像名（.jpg拡張子あり）を作成する
     */
    func uniqueName() -> String {
        let fileExtension = ".jpg"
        if let data = self.data() {
            let hash = SHA512.hash(data: data)
            return hash.map { String(format: "%02x", $0) }.joined() + fileExtension
        } else {
            // おそらく起こらない状態だが、その場合は UUID を設定する
            return UUID().uuidString + fileExtension
        }
    }
}

// swiftlint:enable switch_case_alignment

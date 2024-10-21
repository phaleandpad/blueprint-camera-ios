//
//  BlackboardWebViewConfigurable.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/07/27.
//

import WebKit

// MARK: - BlackboardWebViewConfigurable

public protocol BlackboardWebViewConfigurable {
    func createAndConfigureBlackboardWebView(delegate: WKNavigationDelegate?, scriptMessageHandler: WKScriptMessageHandler?, size: CGSize?) -> WKWebView
    func blackboardWebView(_ webView: WKWebView, loadHTMLFromLocalURL url: URL)
    func blackboardWebView(_ webView: WKWebView, loadHTMLWithQuery query: String)
    func blackboardWebView(_ webView: WKWebView, captureScreenshot completion: @escaping (UIImage?) -> Void)
    func isBlackboardWebViewEventHandler(for message: WKScriptMessage) -> Bool
}

// MARK: - Public Extensions

public extension BlackboardWebViewConfigurable {
    /// `WKWebView`インスタンスを作成し、ナビゲーションデリゲート、スクリプトメッセージハンドラー、
    /// サイズのオプションパラメータを使用して設定します。
    ///
    /// - Parameters:
    ///   - delegate: ナビゲーションイベントを処理するためのオプションの`WKNavigationDelegate`。
    ///     指定しない場合、ナビゲーションイベントは処理されません。
    ///   - scriptMessageHandler: Webコンテンツから送信されたJavaScriptメッセージを処理するためのオプションの`WKScriptMessageHandler`。
    ///     指定しない場合、JavaScriptメッセージは処理されません。
    ///   - size: WebViewの初期サイズを指定するオプションの`CGSize`。指定しない場合、WebViewはゼロフレームで初期化されます。
    ///
    /// - Returns: 指定されたパラメータと設定で構成された`WKWebView`インスタンス。
    ///
    /// - Note: このメソッドは、カスタムフォントスクリプトや`makeJavaScriptCode`で提供される追加のJavaScriptコードを
    ///   自動的にインジェクトします。WebViewの背景とスクロールビューはデフォルトで透過に設定されています。
    func createAndConfigureBlackboardWebView(
        delegate: WKNavigationDelegate? = nil,
        scriptMessageHandler: WKScriptMessageHandler? = nil,
        size: CGSize? = nil
    ) -> WKWebView {
        let configuration = configureBlackboardWebView(scriptMessageHandler: scriptMessageHandler)
        let webView = createBlackboardWebView(
            size: size,
            configuration: configuration
        )
        webView.navigationDelegate = delegate

        return webView
    }

    func blackboardWebView(_ webView: WKWebView, loadHTMLFromLocalURL url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func blackboardWebView(_ webView: WKWebView, loadHTMLWithQuery query: String) {
        // index.html と汎用性高い名前だが、今は他にリソースに同名ファイルがないので、そのまま利用しています
        guard let url = Bundle.andpadCamera.url(forResource: "index", withExtension: "html") else {
            assertionFailure("Local HTML file not found")
            return
        }

        let urlString = "\(url.absoluteString)?\(query)"
        guard let finalURL = URL(string: urlString) else {
            assertionFailure("Invalid URL with query")
            return
        }

        let request = URLRequest(url: finalURL)
        webView.load(request)
    }

    func blackboardWebView(_ webView: WKWebView, captureScreenshot completion: @escaping (UIImage?) -> Void) {
        let configuration = WKSnapshotConfiguration()
        configuration.afterScreenUpdates = true
        webView.takeSnapshot(with: configuration) { image, error in
            guard error == nil else {
                assertionFailure("Error capturing web view: \(String(describing: error?.localizedDescription))")
                completion(nil)
                return
            }
            completion(image)
        }
    }

    func isBlackboardWebViewEventHandler(for message: WKScriptMessage) -> Bool {
        message.name == eventHandlerName
    }
}

// MARK: - Private Extensions

private extension BlackboardWebViewConfigurable {
    var eventHandlerName: String {
        return "eventHandler"
    }

    var miniatureMapChangeEventName: String {
        return "miniature-map-change"
    }

    /// `WKWebView`インスタンスを作成します。
    /// - Parameters:
    ///   - size: オプションの`CGSize`。指定しない場合、WebViewはゼロフレームで初期化されます。
    ///   - configuration: オプションの`WKWebViewConfiguration`。
    /// - Returns: 指定されたサイズで構成された`WKWebView`インスタンス。
    func createBlackboardWebView(
        size: CGSize? = nil,
        configuration: WKWebViewConfiguration
    ) -> WKWebView {
        let webView = WKWebView(
            frame: size.map { .init(origin: .zero, size: $0) } ?? .zero,
            configuration: configuration
        )
        // 画像を透過するため、webView自体の背景を透過させる
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    /// `WKWebViewConfiguration`を構成します。
    /// - Parameter scriptMessageHandler: Webコンテンツから送信されたJavaScriptメッセージを処理するためのオプションの`WKScriptMessageHandler`。
    ///   指定しない場合、JavaScriptメッセージは処理されません。
    /// - Returns: 指定された設定で構成された`WKWebViewConfiguration`インスタンス。
    func configureBlackboardWebView(
        scriptMessageHandler: WKScriptMessageHandler? = nil
    ) -> WKWebViewConfiguration {
        let userContentController = WKUserContentController()

        // JavaScriptからネイティブコードへメッセージを送信する際の受け手を設定する
        if let scriptMessageHandler {
            userContentController.add(scriptMessageHandler, name: eventHandlerName)
        }

        // WebページにインジェクトするJavaScriptコードを追加する
        let userScript = createUserScript(
            eventHandlerName: eventHandlerName,
            miniatureMapChangeEventType: miniatureMapChangeEventName
        )
        userContentController.addUserScript(userScript)

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        return configuration
    }

    /// 指定されたイベントハンドラ名とミニチュアマップ変更イベントタイプに基づいて、`WKUserScript` を作成します。
    ///
    /// - Parameters:
    ///   - eventHandlerName: JavaScriptからのメッセージを受信するためのイベントハンドラ名。
    ///   - miniatureMapChangeEventType: ミニチュアマップの変更を監視するためのイベントタイプ。
    ///
    /// - Returns: インジェクトするために構成された `WKUserScript` インスタンス。
    ///
    /// - Note: このメソッドは、指定されたイベントをリッスンするためのJavaScriptコードと、
    ///   必要に応じてフォントスクリプトを組み合わせた `WKUserScript` を生成します。
    ///   生成されたスクリプトは、Webページのメインフレームの読み込みが完了した後に実行されます。
    func createUserScript(eventHandlerName: String, miniatureMapChangeEventType: String) -> WKUserScript {
        let javaScriptCode = generateJavaScriptCode(eventHandlerName: eventHandlerName, miniatureMapChangeEventType: miniatureMapChangeEventType)
        let fontScript = generateFontScript()

        let combinedScript = [fontScript, javaScriptCode].compactMap { $0 }.joined(separator: "\n")
        return WKUserScript(source: combinedScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    /**
     index.html に渡す JavaScript 関数（可能な限り、type-safeにしたい）
     */
    func generateJavaScriptCode(eventHandlerName: String, miniatureMapChangeEventType: String) -> String {
        """
        window.addEventListener('load', (event) => {
            const message = {type: 'onSuccess', message: event.message};
            const jsonString = JSON.stringify(message);
            window.webkit.messageHandlers.\(eventHandlerName).postMessage(jsonString);
        });
        window.addEventListener('error', (event) => {
            const message = {type: 'onError', message: event.error?.message ?? event.message};
            const jsonString = JSON.stringify(message);
            window.webkit.messageHandlers.\(eventHandlerName).postMessage(jsonString);
        });
        window.addEventListener('unhandledrejection', (event) => {
            const message = {type: 'onException', message: `${event.reason}`};
            const jsonString = JSON.stringify(message);
            window.webkit.messageHandlers.\(eventHandlerName).postMessage(jsonString);
        });
        window.addEventListener('mounted', (event) => {
            const message = {type: 'onMounted', message: 'It is mounted'};
            const jsonString = JSON.stringify(message);
            window.webkit.messageHandlers.\(eventHandlerName).postMessage(jsonString);
        });
        window.addEventListener('\(miniatureMapChangeEventType)', (event) => {
            const message = {type: 'onMiniatureMapChange', message: event.detail};
            const jsonString = JSON.stringify(message);
            window.webkit.messageHandlers.\(eventHandlerName).postMessage(jsonString);
        });
        """
    }

    /**
     index.htmlで利用するフォントをリソース内のフォントデータのパスに書き換えるスクリプト
     - フォントをリソース内のフォントデータのパスに書き換える
     - フォントサイズの自動調整を無効にする

     @note
     index.htmlのスタイルで指定するfont-faceを知っている前提なので、
     index.html側でフォントに関する修正がある場合は、その修正に追従する必要がある
     */
    func generateFontScript() -> String? {
        let robotoMono = "RobotoMono-Regular.ttf"
        let notoSansJP = "NotoSansJP-Regular.ttf"
        guard
            let robotoMonoURL = Bundle.andpadCamera.url(forResource: robotoMono, withExtension: nil),
            let notoSansJPURL = Bundle.andpadCamera.url(forResource: notoSansJP, withExtension: nil) else {
            // 通常では発生しないパターンです。
            // このパターンが発生したら、CocoaPodsでバンドルされるフォントデータの設定に誤りがあります
            assertionFailure("\(robotoMono)もしくは\(notoSansJP)のフォントがリソースにありません")
            return nil
        }

        return """
        var style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = `
            @font-face {
                font-family: 'Roboto Mono';
                src: url('\(robotoMonoURL.absoluteString)') format('truetype');
                font-weight: 400;
                font-style: normal;
            }
            @font-face {
                font-family: 'Noto Sans JP';
                src: url('\(notoSansJPURL.absoluteString)') format('truetype');
                font-weight: 400;
                font-style: normal;
            }
            body {
                font-family: 'Roboto Mono', 'Noto Sans JP', monospace;
                text-size-adjust: 100%;
                -webkit-text-size-adjust: 100%;
            }
        `;
        document.head.appendChild(style);
        """
    }
}

// MARK: - JavaScriptEvent

/**
 index.html から発行されたイベントを iOS で使いやすい形にする
 */
enum JavaScriptEvent {
    case onSuccess                      // js本来のイベント
    case onError(message: String)       // js本来のイベント
    case onException(message: String)   // js本来のイベント
    case onMounted                      // コンポーネント自体のマウント完了カスタムイベント
    case onMiniatureMapChange(message: MiniatureMapChangeMessage)   // 豆図状態変更カスタムイベント

    /**
     messageBody `{type: 'onSuccess', message: 'this is message'}` のような JSON から enum を生成する
     */
    init(messageBody: Any) {
        guard
            let string = messageBody as? String,
            let data = string.data(using: .utf8),
            let dict = try? JSONDecoder().decode([String: String].self, from: data),
            let type = dict["type"]
        else {
            // index.htmlは組み込まれたファイルなので、これは発生しない想定。
            // 開発中の確認漏れなどのチェック目的です。
            assertionFailure("黒板を生成するindex.htmlから想定しないイベントが送られました")
            self = .onException(message: "")
            return
        }

        let message = dict["message"] ?? ""
        switch type {
        case "onSuccess":
            self = .onSuccess
        case "onError":
            self = .onError(message: message)
        case "onException":
            self = .onException(message: message)
        case "onMounted":
            self = .onMounted
        case "onMiniatureMapChange":
            guard let miniatureMapChangeMessage = MiniatureMapChangeMessage(rawValue: message) else {
                // index.htmlは組み込まれたファイルなので、これは発生しない想定。
                // 開発中の確認漏れなどのチェック目的です。
                assertionFailure("黒板を生成するindex.htmlから想定しないイベントが送られました")
                self = .onException(message: "")
                return
            }
            self = .onMiniatureMapChange(message: miniatureMapChangeMessage)
        default:
            // index.htmlは組み込まれたファイルなので、これは発生しない想定。
            // 開発中の確認漏れなどのチェック目的です。
            assertionFailure("黒板を生成するindex.htmlから想定しないイベントが送られました")
            self = .onException(message: "")
        }
    }

    /**
     onMiniatureMapChange 向けの message
     */
    enum MiniatureMapChangeMessage: String {
        case unsupported    // 豆図付きレイアウトでない
        case processing     // 豆図登録中
        case loading        // 豆図表示中
        case loaded         // 豆図表示完了
        case errored        // 豆図読み込み失敗
        case none           // 豆図レイアウトだけど表示無し
        case empty          // 豆図が空
        case hidden         // isHiddenNoneAndEmptyMiniatureMap == true の場合に発火される
    }
}

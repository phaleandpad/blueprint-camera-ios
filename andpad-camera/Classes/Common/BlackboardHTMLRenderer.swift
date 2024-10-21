//
//  BlackboardHTMLRenderer.swift
//  andpad-camera
//
//  Created by 江本 光晴 on 2024/06/04.
//

import Foundation
import WebKit

/**
 HTML（SVG）製の黒板を画像化するクラス
 */
final class BlackboardHTMLRenderer: NSObject, BlackboardWebViewConfigurable {

    private var webView: WKWebView?
    private var completionHandler: ((UIImage?) -> Void)?
    private var hasHandler: Bool {
        completionHandler != nil
    }
    
    deinit {
        completionHandler = nil
    }
    
    /**
     黒板 html(svg) を画像化する
     
     @param URL SVG画像のURL
     @param size 画像化する対象のCGSize
     
     @example
     ```swift
     let URL = URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)
     let size = CGSize(width: 360, height: 276)
     let renderer = BlackboardHTMLRenderer()
     let image = await renderer.exportImage(URL: URL, size: size)
     ```
     */
    @MainActor
    func exportImage(URL: URL, size: CGSize) async -> UIImage? {
        webView = createAndConfigureBlackboardWebView(delegate: self, scriptMessageHandler: self, size: size)
        blackboardWebView(webView!, loadHTMLFromLocalURL: URL)

        return await withCheckedContinuation { continuation in
            self.completionHandler = { image in
                continuation.resume(returning: image)
            }
        }
    }
}

extension BlackboardHTMLRenderer: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard isBlackboardWebViewEventHandler(for: message) else {
            // 監視対象でないので早期で抜ける（監視対象外はこのデリゲートは呼ばれないが念の為）
            return
        }
        
        // WebViewの画像化とその結果を返す関数
        // 受け取ったイベントのパターンによって、多少分岐するが原則同様なので共通化している
        // イベントを受け取ったタイミングでも描画完了前に画像化される場合があり、遅延を追加している
        let completion = { (delay: Double) in
            DispatchQueue.main.asyncAfter(deadline: (.now() + delay)) { [weak self] in
                guard let self, let webView else { return }
                blackboardWebView(webView) { [weak self] image in
                    self?.completionHandler?(image)
                    self?.completionHandler = nil
                }
            }
        }
        
        let event = JavaScriptEvent(messageBody: message.body)
        switch event {
        case .onSuccess, .onError:
            // ここでの処理は不要。描画確認は onMiniatureMapChange で行う
            break
        
        case .onException(let message):
            assertionFailure(message)
            completion(0)
            
        case .onMounted:
            // コンポーネント自体のマウント完了カスタムイベント（いまのところ処理不要）
            break
    
        case .onMiniatureMapChange(let message):
            switch message {
            case .loaded, .none, .unsupported, .hidden, .empty:
                // 完了形のイベントなので処理を完遂する
                completion(0.5)
            case .errored:
                // 異常系であるが、黒板作成前に豆図ダウンロード確認が行われるので、この状態は発生しない
                // ここでは異常系の実装がないので、仮に完了系と同等に扱う
                // 黒板作成自体で異常系を取り扱うようになったら、対応する必要がある
                assertionFailure("onMiniatureMapChange で errored を受け取りました")
                completion(0.5)
            default:
                // processingやloadingは完了系イベントが次に来るので何もしない
                break
            }
        }
    }
}

extension BlackboardHTMLRenderer: WKNavigationDelegate {
        
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 注入したjsのコードで完了イベントを検知している
        // 何かの原因で検知失敗したときのフェイルセーフとして、タイムアウトを設定する
        // その場合に表示誤りが起こった場合は、ユーザー自身で再読み込みを実行する
        let timeout: Double = 10.0
        DispatchQueue.main.asyncAfter(deadline: (.now() + timeout)) { [weak self] in
            guard let self, hasHandler else { return }
            blackboardWebView(webView) { [weak self] image in
                self?.completionHandler?(image)
                self?.completionHandler = nil
            }
        }
    }
}

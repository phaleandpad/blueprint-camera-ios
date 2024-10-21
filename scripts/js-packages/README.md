# JavaScript ライブラリからバンドルファイルを作成する

- 黒板SVGを作成する過程で qs という JavaScript (以降、JS) ライブラリを使用しています
- このライブラリは JSON からクエリーパラメータを作成します
- Android との差分をなくすため導入しました

## バンドルファイルの生成

前提

- iOS は 生の JS を実行できますが、ライブラリなので依存関係やファイル構造の問題で、ライブラリそのままの実行は難しいです
- webpack でバンドルファイルを作成して、iOS プロジェクトに導入します


準備

- Node.js の 20 系を用意してください
-  yarn v1 を用意してください（例：`brew install yarn`）
- コードを修正する際は `src/index.ts` を修正してください

バンドルファイルの生成コマンド

- `js-package/dict` に `Module.bundle.js` が生成されます

```shell
yarn
yarn build
```

テスト

```shell
yarn test
```

## iOS でバンドルファイルを使う

ファイルの読み込み

```swift
import JavaScriptCore

let context = JSContext(virtualMachine: JSVirtualMachine())!
let bundleFileName = "Module.bundle.js"

guard
	let url = Bundle.andpadCamera.url(forResource: bundleFileName, withExtension: nil),
	let contents = try? String(contentsOf: url)
else {
 	return
}
 
 // バンドルされた js ファイルの読み込み
context.evaluateScript(contents)
```

関数のインスタンス取得および実行

```swift
let moduleName = "Module"
let bundleName = "Bridge"
let functionName = "バンドルファイルで定義した関数名"

guard
	let module = context.objectForKeyedSubscript(moduleName),
	let bridge = module.objectForKeyedSubscript(bundleName),
	let function = bridge.objectForKeyedSubscript(name)
else {
	return
}

let arg = "引数"
let result = function.call(withArguments: [arg])
let output = result?.toString()
```

エラーハンドリング

- エラーが起こったら、一律に処理される
- 例外を投げたい場合に困る

```swift
context.exceptionHandler = { context, error in
	guard let error = error, let message = error.toString() else {
		return
	}
	print("JSContext#exceptionHandler Error: \(message)")
}
```

OR

- contextの操作を行なったたびにエラーを調べる
- 都度確認で面倒だが、例外などエラー処理を行いやすい


```swift
let result = function.call(withArguments: [arg])
if let exception = context.exception {
	let message = exception.toString() ?? ""
	context.exception = nil
      throw BridgeError.functionFailed(message: message)
}
```

その他、詳しくは andpad-camera-ios 内の `JavaScriptBridge.swift` を参照してください。

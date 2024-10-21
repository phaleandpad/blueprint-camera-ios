# andpad-camera
カメラライブラリ

# ユーザー向けガイド

## インストール手順

### [CocoaPods](http://cocoapods.org) を使う

Podfileに以下の行を記述してください。

```
pod 'andpad-camera', :git => "git@github.com:88labs/andpad-camera-ios.git", :tag => 'vX.Y.Z'
```

その後 `pod install` を実行してください。

# 開発者向けガイド

## 環境構築

### 依存ツール

- Xcode
	- CIと同じバージョンを使用すること
    - [bitrise.yml](bitrise.yml)の `stack` を参照

## 手順

1. 依存ツールをすべてインストール
1. リポジトリをクローンして、Exampleアプリのルート階層に移動する

	```bash
	$ git clone git@github.com:88labs/andpad-camera-ios.git
	$ cd andpad-camera-ios
	$ cd Example
	```

1. ツールやライブラリをインストールする

	```bash
	$ make
	```

	すべてのコマンドが成功するとXcodeプロジェクトが開かれます。初回は依存ライブラリ等のダウンロードが走るため時間がかかります。 

### 環境をリセット

キャッシュやDerivedDataを削除します。

```bash
$ make clean
```

環境構築に失敗したときは、一度 `$ make clean` をしてから `$ make` をすると、うまくいくことがあります。

### 補足

#### サンプルアプリのセットアップ

- 一部画面では、**画面表示のためにAPIレスポンスの取得が必要**です。そのために以下を用意してください
	- VPN接続を行うこと
	- アカウント認証に通るよう、リクエストパラメータを調整すること
		- 1: 新黒板の権限がある案件である
			- feature2に存在するデータであることが前提です
			- orderIDが上記のものである必要があります
				- Example用のデータは `DummyData` 内を確認してください
		- 2: 1に実在する新黒板のデータであること
			- feature2に存在するデータであることが前提です
			- :bulb: 現在 `ModernBlackboardMaterialStub` のlayout2であれば、feature2に実在するため利用可能です
				- Example用のデータは `DummyData` 内を確認してください
		- 3: 1の案件に認証ユーザーが属していること
			- feature2に存在するデータであることが前提です
			- 認証ユーザーの情報は `AppBaseRequestData` に定義しているので、そちらを見直す必要があります
		   	- Example用のデータは `DummyData` 内を確認してください

（1, 3についてはfeature2のデータをデフォルト適用しているため、2を変更するのみでおそらく対応可能です、うまく行かない場合はサーバデータを確認の上、適宜1, 2, 3を調整してみてください）

## CI/CD

- Bitrise
	- [Bitrise CI > andpad-camera-ios](https://app.bitrise.io/app/35479243ba0b60bf)
- GitHub Actions

## デプロイ方法

機能の実装や不具合の修正などをして新しいバージョンとしてデプロイしたいときの手順は以下

- 1. 手動テストを行う
  - テスト結果を記入の上、デプロイプロセスに進んでください
    - https://docs.google.com/spreadsheets/d/1anLHPVVUx7zvx-LabesoC_Oz2rKU-67nKvOE5TVK4_U/edit#gid=0
- 2. ローカルで新しくtagを切って、remoteへpushする
- 3. [Releaseページ](https://github.com/88labs/andpad-camera-ios/releases)に今回のバージョンのものがdraftとして`release-drafter`により自動生成されているはずなので、内容を確認し（内容に齟齬があれば修正する）、問題なければreleaseとして（pre-releaseではなく）publishする

## 実機インストール方法

fastlane matchを利用することで、ADP未登録の開発者でも実機ビルドができるようになている。方法については、施工iOSの[README](https://github.com/88labs/andpad-ios#operations)とほぼ同様なのでこちらを参考にすること

## JavaScriptライブラリのバンドルファイル化

黒板をSVGで生成する際に、JavaScriptライブラリを利用しています。`scripts/js-packages` にその生成コードをまとめています。詳しくはそのディレクトリの README を参照してください。なお、andpad-camera-ios のリソースにバンドルファイルは追加済みなので、特別な操作は不要です。

## License

andpad-camera is available under the MIT license. See the LICENSE file for more info.

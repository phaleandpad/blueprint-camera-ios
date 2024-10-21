//
//  AppInfoUtil.swift
//  andpad-camera
//
//  Created by msano on 2022/10/12.
//

enum AppInfoUtil {
    /// 本体アプリのストアURL
    static let getMainAppStoreURL: URL? = .init(string: "itms-apps://itunes.apple.com/app/id1067643333")

    /// iPad判定
    static let isiPad = UIDevice.current.userInterfaceIdiom == .pad
    
    /// SVGで黒板を作成する際に豆図をローカルに一時的保存するディレクトリ名
    static let svgBlackboardMiniatureMapImageDirectoryName = "blackboard-svg"
}

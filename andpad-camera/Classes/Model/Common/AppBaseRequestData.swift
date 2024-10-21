//
//  AppBaseRequestData.swift
//  andpad-camera
//
//  Created by msano on 2021/01/08.
//

public struct AppBaseRequestData {
    let deviceUUID: String?
    let osType: String
    let version: String
    let accessToken: String
    let sharedBundleId: String
    let apiBaseURLString: String
    let authenticatedDeviceUUID: String

    public init(
        deviceUUID: String?,
        osType: String,
        version: String,
        accessToken: String,
        sharedBundleId: String,
        apiBaseURLString: String,
        authenticatedDeviceUUID: String
    ) {
        self.deviceUUID = deviceUUID
        self.osType = osType
        self.version = version
        self.accessToken = accessToken
        self.sharedBundleId = sharedBundleId
        self.apiBaseURLString = apiBaseURLString
        self.authenticatedDeviceUUID = authenticatedDeviceUUID
    }

    func debug(with urlString: String?) {
        #if DEBUG
        Swift.print("\n💊 ----------------------------------------------------")
        Swift.print("💊 URL: ", urlString ?? "none")
        Swift.print("💊 apiBaseURLString: ", apiBaseURLString)
        Swift.print()
        Swift.print("💊 X-UUID: ", deviceUUID ?? "none")
        Swift.print("💊 X-OS-TYPE: ", osType)
        Swift.print("💊 X-APP-VERSION: ", version)
        Swift.print("💊 X-ACCESS-TOKEN: ", accessToken)
        Swift.print("💊 X-BUNDLE-ID: ", sharedBundleId)
        Swift.print("💊 AUTHENTICATED-DEVICE-UUID: ", authenticatedDeviceUUID)
        Swift.print("💊 ----------------------------------------------------\n")
        #endif
    }
}

// MARK: - オフライン対応

public extension AppBaseRequestData {
    // TODO: [オフライン Phase 2〜] この構造体の呼び出し箇所で、オフラインの場合にnilを使うように変更されたら、このプロパティは不要になるので削除する。

    /// オフラインモードの場合の初期値
    ///
    /// オフラインモードの場合は、この構造体は使われないので、nilにすべきだが、
    /// オプショナル値にすると影響範囲が大きいため、オフライン用の初期値をここに作成した。
    static var offlineData: Self {
        .init(
            deviceUUID: nil,
            osType: "",
            version: "",
            accessToken: "",
            sharedBundleId: "",
            apiBaseURLString: "",
            authenticatedDeviceUUID: ""
        )
    }
}

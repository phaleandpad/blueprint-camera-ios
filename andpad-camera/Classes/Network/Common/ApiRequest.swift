//
//  ApiRequest.swift
//  andpad-camera
//
//  Created by msano on 2020/11/04.
//

import Alamofire

class ApiRequest {
    let URLRequest: NSMutableURLRequest
    let params: ApiParams?
    let isOriginal: Bool
    
    var tempAccessToken: String? {
        didSet {
            guard let tempAccessToken else { return }
            URLRequest.setValue(tempAccessToken, forHTTPHeaderField: "X-ACCESS-TOKEN")
        }
    }

    init(
        params: ApiParams? = nil,
        router: ApiRouter,
        method: Alamofire.HTTPMethod,
        isOriginal: Bool = false,
        appBaseData: AppBaseRequestData
    ) {
        self.params = params
        self.isOriginal = isOriginal
        let baseURL = URL(string: appBaseData.apiBaseURLString + router.path)!

        switch method {
        case .post, .put, .delete:
            URLRequest = NSMutableURLRequest(url: baseURL)
            print(baseURL)
            
            // NOTE:
            // SwiftyJSONで処理した際、ネストしたstruct配列（blackboardData）がうまくエンコードできなかった
            //
            //  -> そのため、 あまり望ましくないが以下リクエストパラメータに限り、Encodableによる自前のエンコード処理で対応している
            //    - PostBlackboardParams
            //    - PutBlackboardParams
            
            if let postBlackboardParam = params as? PostBlackboardParams {
                URLRequest.httpBody = postBlackboardParam.jsonData
            } else if let putBlackboardParam = params as? PutBlackboardParams {
                URLRequest.httpBody = putBlackboardParam.jsonData
            } else {
                // NOTE: 通常のエンコード処理（JSONSerialization使用）
                try! URLRequest.httpBody = params?.toJSONData()
            }
        case .get:
            let url: URL
            if let parameterString = params?.toDict().stringFromHttpParameters() {
                url = URL(string: baseURL.absoluteString + "?\(parameterString)")!
            } else {
                url = URL(string: "\(baseURL)")!
            }
            print("url=\(url)")
            URLRequest = NSMutableURLRequest(url: url)
        default:
            URLRequest = NSMutableURLRequest(url: baseURL)
            try! URLRequest.httpBody = params?.toJSONData()
        }
        URLRequest.httpMethod = method.rawValue

        // APIで必要なヘッダーをセットする
        URLRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        print("contentType=application/json")

        URLRequest.setValue(
            appBaseData.deviceUUID,
            forHTTPHeaderField: "X-UUID"
        )
        URLRequest.setValue(
            appBaseData.osType,
            forHTTPHeaderField: "X-OS-TYPE"
        )
        URLRequest.setValue(
            appBaseData.version,
            forHTTPHeaderField: "X-APP-VERSION"
        )
        URLRequest.setValue(
            appBaseData.accessToken,
            forHTTPHeaderField: "X-ACCESS-TOKEN"
        )
        URLRequest.setValue(
            appBaseData.sharedBundleId,
            forHTTPHeaderField: "X-BUNDLE-ID"
        )
        URLRequest.setValue(
            appBaseData.authenticatedDeviceUUID,
            forHTTPHeaderField: "AUTHENTICATED-DEVICE-UUID"
        )
        appBaseData.debug(with: URLRequest.url?.absoluteString)
    }
}

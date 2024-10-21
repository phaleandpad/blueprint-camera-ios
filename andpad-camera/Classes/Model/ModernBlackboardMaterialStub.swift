//
//  ModernBlackboardMaterialStub.swift
//  andpad-camera-andpad-camera
//
//  Created by msano on 2021/05/13.
//

#if DEBUG

// MARK: - Example用の新黒板スタブデータ
// swiftlint:disable:next type_body_length
public enum ModernBlackboardMaterialStub {
    case layout1(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout2(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout3(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout4(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout5(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout6(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout7(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout10(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout101(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout102(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout103(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout104(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout201(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout202(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout203(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout204(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout205(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout301(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout401(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout501(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout601(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout602(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout603(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout604(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout605(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout701(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout702(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout703(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout704(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout802(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout803(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout902(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout903(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1001(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1003(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1004(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1103(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1105(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1202(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1203(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1303(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1403(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1502(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1503(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1505(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1602(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1603(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1802(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1803(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1805(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1902(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1903(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout1905(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout2202(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout2203(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)
    case layout2205(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType)

    public enum MiniatureMapStubImageType {
        /// 縦
        case portrait
        
        /// 横
        case landscape
        
        /// 画像取得失敗
        case fail
        
        /// 豆図オブジェクト（およびURL）がnil
        case none
        
        var imageURL: URL? {
            switch self {
            case .portrait:
                return .init(string: "https://user-images.githubusercontent.com/8345452/189321722-6ab383e4-905f-478e-af45-b0149c1f93b8.jpg")
            case .landscape:
                return .init(string: "https://user-images.githubusercontent.com/8345452/213120318-0e520074-2eba-4d07-8a46-1818603ac447.jpg")
            case .fail:
                // 存在しない画像URLを渡す
                return .init(string: "https://user-images.githubusercontent.com/8345452/213120318-0e520074-2eba-4d07-8a46-1818603ac447hoge.jpg")
            case .none:
                return nil
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    init(
        pattern: ModernBlackboardContentView.Pattern,
        doFillTexts: Bool,
        miniatureMapStubImageType: MiniatureMapStubImageType
    ) {
        switch pattern {
        case .pattern1:
            self = .layout1(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern2:
            self = .layout2(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern3:
            self = .layout3(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern4:
            self = .layout4(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern5:
            self = .layout5(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern6:
            self = .layout6(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern7:
            self = .layout7(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern10:
            self = .layout10(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern101:
            self = .layout101(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern102:
            self = .layout102(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern103:
            self = .layout103(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern104:
            self = .layout104(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern201:
            self = .layout201(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern202:
            self = .layout202(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern203:
            self = .layout203(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern204:
            self = .layout204(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern205:
            self = .layout205(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern301:
            self = .layout301(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern401:
            self = .layout401(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern501:
            self = .layout501(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern601:
            self = .layout601(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern602:
            self = .layout602(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern603:
            self = .layout603(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern604:
            self = .layout604(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern605:
            self = .layout605(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern701:
            self = .layout701(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern702:
            self = .layout702(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern703:
            self = .layout703(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern704:
            self = .layout704(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern802:
            self = .layout802(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern803:
            self = .layout803(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern902:
            self = .layout902(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern903:
            self = .layout903(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1001:
            self = .layout1001(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1003:
            self = .layout1003(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1004:
            self = .layout1004(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1103:
            self = .layout1103(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1105:
            self = .layout1105(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1202:
            self = .layout1202(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1203:
            self = .layout1203(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1303:
            self = .layout1303(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1403:
            self = .layout1403(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1502:
            self = .layout1502(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1503:
            self = .layout1503(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1505:
            self = .layout1505(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1602:
            self = .layout1602(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1603:
            self = .layout1603(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1802:
            self = .layout1802(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1803:
            self = .layout1803(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1805:
            self = .layout1805(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1902:
            self = .layout1902(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1903:
            self = .layout1903(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern1905:
            self = .layout1905(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern2202:
            self = .layout2202(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern2203:
            self = .layout2203(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        case .pattern2205:
            self = .layout2205(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        }
    }

    public static func allCases(doFillTexts: Bool, miniatureMapStubImageType: MiniatureMapStubImageType) -> [Self] {
        [
            .layout1(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout2(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout3(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout4(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout5(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout6(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout7(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout10(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout101(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout102(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout103(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout104(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout201(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout202(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout203(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout204(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout205(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout301(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout401(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout501(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout601(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout602(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout603(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout604(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout605(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout701(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout702(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout703(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout704(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout802(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout803(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout902(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout903(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1001(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1003(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1004(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1103(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1105(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1202(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1203(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1303(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1403(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1502(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1503(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1505(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1602(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1603(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1802(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1803(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1805(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1902(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1903(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout1905(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout2202(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout2203(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType),
            .layout2205(doFillTexts: doFillTexts, miniatureMapStubImageType: miniatureMapStubImageType)
        ]
    }

    /// stubを用意したケースの合計を返却する
    public static var total: Int {
        allCases(doFillTexts: false, miniatureMapStubImageType: .portrait).count
    }
    
    public var layoutID: Int {
        pattern.layoutID
    }
    
    public var value: ModernBlackboardMaterial? {
        func snapShotData(_ doFillTexts: Bool) -> SnapshotData {
            .init(
                userID: 999999,
                orderName: doFillTexts ? MaxTextValue.text254.string : "工事1",
                clientName: doFillTexts ? MaxTextValue.text30.string : "担当者A",
                startDate: Date()
            )
        }
        
        func miniatureMap(
            id: Int,
            miniatureMapStubImageType: MiniatureMapStubImageType
        ) -> ModernBlackboardMaterial.MiniatureMap? {
            guard let imageURL = miniatureMapStubImageType.imageURL else { return nil }
            return .init(
                id: id,
                imageURL: imageURL,
                imageThumbnailURL: imageURL
            )
        }
        
        // NOTE:
        // 実在するデータでない場合、「黒板一覧を選択」に遷移しても正しくAPIレスポンスを取得できないので注意する
        // （id類が適合しないとAPIレスポンスは取得できない）
        
        switch self {
        // MARK: - stub value (1)
        case .layout1(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 5
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (2)
        case .layout2(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 実際にfeature2に「現状」存在する黒板と同内容のスタブデータ
            // (id等も一致させている)
            return .forStub(
                id: 4842,
                blackboardTemplateID: 250,
                layoutTypeID: 2,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 6
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (3)
        case .layout3(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 3,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "1234号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 7
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (4)
        case .layout4(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 4,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "現状",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 4
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (5)
        case .layout5(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 5,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 6
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (6)
        case .layout6(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 6,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2342号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 7
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (7)

        case .layout7(let doFillTexts, _):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 7,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 9
                    )
                ],
                blackboardTrees: [],
                miniatureMap: nil,
                snapshotData: snapShotData(doFillTexts)
            )

       // MARK: - stub value (10)

        case .layout10(let doFillTexts, _):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 10,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目6",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容6",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 9
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 10
                    )
                ],
                blackboardTrees: [],
                miniatureMap: nil,
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (101)
        case .layout101(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 101,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "現状",
                        position: 3
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (102)
        case .layout102(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 102,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 5
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (103)
        case .layout103(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 103,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "現状",
                        position: 3
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (104)

        case .layout104(let doFillTexts, _):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 104,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 4
                    )
                ],
                blackboardTrees: [],
                miniatureMap: nil,
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (201)
        case .layout201(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: -1,
                blackboardTemplateID: 250,
                layoutTypeID: 201,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 4
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (202)
        case .layout202(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 4842,
                blackboardTemplateID: 250,
                layoutTypeID: 202,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 6
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (203)
        case .layout203(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 4842,
                blackboardTemplateID: 250,
                layoutTypeID: 203,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 4
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (204)
        case .layout204(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 4842,
                blackboardTemplateID: 250,
                layoutTypeID: 204,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 5
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (205)
        case .layout205(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 4842,
                blackboardTemplateID: 250,
                layoutTypeID: 205,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 5
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (301)
        case .layout301(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 301,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2342号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 5
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (401)
        case .layout401(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 401,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "現状",
                        position: 2
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (501)
        case .layout501(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 501,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 4
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (601)
        case .layout601(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 601,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2342号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 5
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (602)
        case .layout602(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 602,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2342号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 7
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (603)
        case .layout603(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 603,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2342号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 5
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (604)
        case .layout604(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 604,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2342号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 6
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (605)
        case .layout605(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 605,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "物流調査",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "工区",
                        body: doFillTexts ? MaxTextValue.text30.string : "1工区",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2342号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 6
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (701)

        case .layout701(let doFillTexts, _):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 701,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 7
                    )
                ],
                blackboardTrees: [],
                miniatureMap: nil,
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (702)
        case .layout702(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 702,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (703)
        case .layout703(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 703,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (704)

        case .layout704(let doFillTexts, _):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 704,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: nil,
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (802)
        case .layout802(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 802,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (803)
        case .layout803(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 803,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (902)
        case .layout902(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 902,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "あああああ",
                        body: doFillTexts ? MaxTextValue.text30.string : "なし",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 9
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (903)
        case .layout903(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 903,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "あああああ",
                        body: doFillTexts ? MaxTextValue.text30.string : "なし",
                        position: 7
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (1001)

        case .layout1001(let doFillTexts, _):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1001,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目6",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容6",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: nil,
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1003)
        case .layout1003(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1003,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "あああああ",
                        body: doFillTexts ? MaxTextValue.text30.string : "なし",
                        position: 7
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (1004)

        case .layout1004(let doFillTexts, _):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1004,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目6",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容6",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 9
                    )
                ],
                blackboardTrees: [],
                miniatureMap: nil,
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1103)
        case .layout1103(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1103,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2号室",
                        position: 7
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1105)
        case .layout1105(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1105,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2号室",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1202)
        case .layout1202(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1202,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "あああああ",
                        body: doFillTexts ? MaxTextValue.text30.string : "なし",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "12336号室",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 9
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 10
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1203)
        case .layout1203(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1203,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "あああああ",
                        body: doFillTexts ? MaxTextValue.text30.string : "なし",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "12336号室",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1303)
        case .layout1303(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1303,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8号室",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "99999号室",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1403)
        case .layout1403(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1403,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "2号室",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "90000号室",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1502)
        case .layout1502(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1502,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "あああああ",
                        body: doFillTexts ? MaxTextValue.text30.string : "なし",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "12336号室",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "77777777号室",
                        position: 9
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 10
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 11
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1503)
        case .layout1503(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1503,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "あああああ",
                        body: doFillTexts ? MaxTextValue.text30.string : "なし",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "12336号室",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "77777777号室",
                        position: 9
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1505)
        case .layout1505(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1505,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "管轄",
                        body: doFillTexts ? MaxTextValue.text30.string : "東",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "あああああ",
                        body: doFillTexts ? MaxTextValue.text30.string : "なし",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "12336号室",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "77777777号室",
                        position: 9
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 10
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1602)
        case .layout1602(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1602,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "12336号室",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1603)
        case .layout1603(let doFillTexts, let miniatureMapStubImageType):
            // NOTE:
            // 新黒板 表示確認用のスタブデータ
            // (実在するデータではない)
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1603,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工種",
                        body: doFillTexts ? MaxTextValue.text30.string : "ダスター清掃",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "現状",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "8931号室",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工区・工法・審査など",
                        body: doFillTexts ? MaxTextValue.text30.string : "5工区",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "部屋番号",
                        body: doFillTexts ? MaxTextValue.text30.string : "12336号室",
                        position: 6
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1802)
        case .layout1802(let doFillTexts, let miniatureMapStubImageType):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1802,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目6",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容6",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目7",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容7",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目8",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容8",
                        position: 9
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目9",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容9",
                        position: 10
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目10",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容10",
                        position: 11
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 12
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 13
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1803)
        case .layout1803(let doFillTexts, let miniatureMapStubImageType):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1803,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目6",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容6",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目7",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容7",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目8",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容8",
                        position: 9
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目9",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容9",
                        position: 10
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目10",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容10",
                        position: 11
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        // MARK: - stub value (1805)
        case .layout1805(let doFillTexts, let miniatureMapStubImageType):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1805,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: "工事名",
                        body: doFillTexts ? MaxTextValue.text254.string : "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目6",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容6",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目7",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容7",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目8",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容8",
                        position: 9
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目9",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容9",
                        position: 10
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目10",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容10",
                        position: 11
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: doFillTexts ? MaxTextValue.text30.string : "",
                        position: 12
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (1902)

        case .layout1902(let doFillTexts, let miniatureMapStubImageType):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1902,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 9
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
            
        // MARK: - stub value (1903)

        case .layout1903(let doFillTexts, let miniatureMapStubImageType):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1903,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 7
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (1905)

        case .layout1905(let doFillTexts, let miniatureMapStubImageType):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 1905,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (2202)

        case .layout2202(let doFillTexts, let miniatureMapStubImageType):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 2202,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工日",
                        body: "",
                        position: 8
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 9
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (2203)

        case .layout2203(let doFillTexts, let miniatureMapStubImageType):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 2203,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 7
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )

        // MARK: - stub value (2205)

        case .layout2205(let doFillTexts, let miniatureMapStubImageType):
            return .forStub(
                id: 1,
                blackboardTemplateID: 250,
                layoutTypeID: 2205,
                photoCount: 0,
                blackboardTheme: .black,
                itemProtocols: [
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "工事名",
                        body: "",
                        position: 1
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目1",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容1",
                        position: 2
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目2",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容2",
                        position: 3
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目3",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容3",
                        position: 4
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目4",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容4",
                        position: 5
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: doFillTexts ? MaxTextValue.text10.string : "項目5",
                        body: doFillTexts ? MaxTextValue.text30.string : "内容5",
                        position: 6
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "備考",
                        body: doFillTexts ? MaxTextValue.text200.string : "工事前",
                        position: 7
                    ),
                    ModernBlackboardMaterial.Item(
                        itemName: "施工者",
                        body: "",
                        position: 8
                    )
                ],
                blackboardTrees: [],
                miniatureMap: miniatureMap(id: dummyMiniatureMapId, miniatureMapStubImageType: miniatureMapStubImageType),
                snapshotData: snapShotData(doFillTexts)
            )
        }
    }
}

// MARK: - private
extension ModernBlackboardMaterialStub {
    // 各項目の最大文字数
    private enum MaxTextValue {
        case text10
        case text30
        case text200
        case text254

        var string: String {
            switch self {
            case .text10:
                return "これで１０文字です。"
            case .text30:
                return "これで１０文字です。これで１０文字です。これで１０文字です。"
            case .text200:
                return "これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。"
            case .text254:
                // swiftlint:disable:next line_length
                return "これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１０文字です。これで１"
            }
        }
    }
    
    private var dummyMiniatureMapId: Int {
        // ユニークな値にしておきたかったので、仮でレイアウトidを渡している
        layoutID
    }
    
    private var pattern: ModernBlackboardContentView.Pattern {
        switch self {
        case .layout1:
            return .pattern1
        case .layout2:
            return .pattern2
        case .layout3:
            return .pattern3
        case .layout4:
            return .pattern4
        case .layout5:
            return .pattern5
        case .layout6:
            return .pattern6
        case .layout7:
            return .pattern7
        case .layout10:
            return .pattern10
        case .layout101:
            return .pattern101
        case .layout102:
            return .pattern102
        case .layout103:
            return .pattern103
        case .layout104:
            return .pattern104
        case .layout201:
            return .pattern201
        case .layout202:
            return .pattern202
        case .layout203:
            return .pattern203
        case .layout204:
            return .pattern204
        case .layout205:
            return .pattern205
        case .layout301:
            return .pattern301
        case .layout401:
            return .pattern401
        case .layout501:
            return .pattern501
        case .layout601:
            return .pattern601
        case .layout602:
            return .pattern602
        case .layout603:
            return .pattern603
        case .layout604:
            return .pattern604
        case .layout605:
            return .pattern605
        case .layout701:
            return .pattern701
        case .layout702:
            return .pattern702
        case .layout703:
            return .pattern703
        case .layout704:
            return .pattern704
        case .layout802:
            return .pattern802
        case .layout803:
            return .pattern803
        case .layout902:
            return .pattern902
        case .layout903:
            return .pattern903
        case .layout1001:
            return .pattern1001
        case .layout1003:
            return .pattern1003
        case .layout1004:
            return .pattern1004
        case .layout1103:
            return .pattern1103
        case .layout1105:
            return .pattern1105
        case .layout1202:
            return .pattern1202
        case .layout1203:
            return .pattern1203
        case .layout1303:
            return .pattern1303
        case .layout1403:
            return .pattern1403
        case .layout1502:
            return .pattern1502
        case .layout1503:
            return .pattern1503
        case .layout1505:
            return .pattern1505
        case .layout1602:
            return .pattern1602
        case .layout1603:
            return .pattern1603
        case .layout1802:
            return .pattern1802
        case .layout1803:
            return .pattern1803
        case .layout1805:
            return .pattern1805
        case .layout1902:
            return .pattern1902
        case .layout1903:
            return .pattern1903
        case .layout1905:
            return .pattern1905
        case .layout2202:
            return .pattern2202
        case .layout2203:
            return .pattern2203
        case .layout2205:
            return .pattern2205
        }
    }
}

// MARK: - Helper

private extension ModernBlackboardMaterial {
    static func forStub(
        id: Int,
        blackboardTemplateID: Int,
        layoutTypeID: Int,
        photoCount: Int,
        blackboardTheme: ModernBlackboardAppearance.Theme,
        itemProtocols: [BlackboardItemProtocol],
        blackboardTrees: [TreeItem],
        miniatureMap: MiniatureMap?,
        snapshotData: SnapshotData? = nil,
        shouldForceUpdateConstructionName: Bool = false,
        createdUser: User? = nil,
        updatedUser: User? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        isDuplicated: Bool = false,
        position: Int? = nil,
        originalBlackboardID: Int? = nil
    ) -> Self {
        .init(
            id: id,
            blackboardTemplateID: blackboardTemplateID,
            layoutTypeID: layoutTypeID,
            photoCount: photoCount,
            blackboardTheme: blackboardTheme,
            itemProtocols: itemProtocols,
            blackboardTrees: blackboardTrees,
            miniatureMap: miniatureMap,
            snapshotData: snapshotData,
            shouldForceUpdateConstructionName: shouldForceUpdateConstructionName,
            createdUser: createdUser,
            updatedUser: updatedUser,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDuplicated: isDuplicated,
            position: position,
            originalBlackboardID: originalBlackboardID
        )
    }
}

#endif // swiftlint:disable:this file_length

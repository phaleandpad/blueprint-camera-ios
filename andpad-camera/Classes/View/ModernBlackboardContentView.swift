//
//  ModernBlackboardContentView.swift
//  andpad-camera
//
//  Created by Yuka Kobayashi on 2021/02/15.
//

import EasyPeasy
import UIKit

// swiftlint:disable file_length
// swiftlint:disable type_body_length
public final class ModernBlackboardContentView: UIView {
    
    /**
     後にSVGで黒板を生成するための黒板のコンテンツデータ
     
     @note
     従来は保存してなかったが、SVGを作成するために保持しておく
     */
    private var blackboardContent: ModernBlackboardContent?
        
    public enum PatternType {
        case normal
        case withMiniatureMap(MiniatureMapImageState)
        
        var miniatureMapState: MiniatureMapImageState? {
            switch self {
            case .normal:
                return nil
            case .withMiniatureMap(let state):
                return state
            }
        }
    }
    
    public enum Pattern: Int, Equatable, CaseIterable {
        // NOTE:
        // patternは1桁台がオリジナル、3桁台は1桁台の派生です
        
        // 豆図なし ---------------------------------
        
        // 1系
        case pattern1 = 1
        case pattern101 = 101
        case pattern104 = 104
        
        // 2系
        case pattern2 = 2
        case pattern201 = 201
        case pattern204 = 204
        
        // 3系
        case pattern3 = 3
        case pattern301 = 301
        
        // 4系
        case pattern4 = 4
        case pattern401 = 401
        
        // 5系
        case pattern5 = 5
        case pattern501 = 501
        
        // 6系
        case pattern6 = 6
        case pattern601 = 601
        case pattern604 = 604

        // 7系
        case pattern7 = 7
        case pattern701 = 701
        case pattern704 = 704

        // 10系
        case pattern10 = 10
        case pattern1001 = 1001
        case pattern1004 = 1004

        // 豆図あり ---------------------------------

        // 1系
        case pattern102 = 102
        case pattern103 = 103
        
        // 2系
        case pattern202 = 202
        case pattern203 = 203
        case pattern205 = 205
        
        // 6系
        case pattern602 = 602
        case pattern603 = 603
        case pattern605 = 605
        
        // 7系
        case pattern702 = 702
        case pattern703 = 703
        
        // 8系
        case pattern802 = 802
        case pattern803 = 803
        
        // 9系
        case pattern902 = 902
        case pattern903 = 903

        // 10系
        case pattern1003 = 1003

        // 11系
        case pattern1103 = 1103
        case pattern1105 = 1105
        
        // 12系
        case pattern1202 = 1202
        case pattern1203 = 1203
        
        // 13系
        case pattern1303 = 1303

        // 14系
        case pattern1403 = 1403
        
        // 15系
        case pattern1502 = 1502
        case pattern1503 = 1503
        case pattern1505 = 1505
        
        // 16系
        case pattern1602 = 1602
        case pattern1603 = 1603
        
        // 18系
        case pattern1802 = 1802
        case pattern1803 = 1803
        case pattern1805 = 1805
        
        // 19系
        case pattern1902 = 1902
        case pattern1903 = 1903
        case pattern1905 = 1905
        
        // 22系
        case pattern2202 = 2202
        case pattern2203 = 2203
        case pattern2205 = 2205

        public init?(by layoutID: Int) {
            guard let pattern = Pattern.allCases.first(where: { $0.layoutID == layoutID }) else { return nil }
            self = pattern
        }

        // for Xib
        var nibName: String? {
            guard let pattern = Pattern.allCases.first(where: { $0.layoutID == layoutID }) else {
                return nil
            }
            return "ModernCase\(pattern.layoutID)"
        }

        private var itemTypes: [BlackboardItemType] {
            switch self {
            case .pattern1:
                return [.textField, .textField, .textArea, .date, .textField]
            case .pattern101:
                return [.textField, .textField, .textArea]
            case .pattern102:
                return [.textField, .textField, .textArea, .date, .textField]
            case .pattern103:
                return [.textField, .textField, .textArea]
            case .pattern104:
                return [.textField, .textField, .textArea, .textField]
            case .pattern2:
                return [.textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern201:
                return [.textField, .textField, .textField, .textArea]
            case .pattern202:
                return [.textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern203:
                return [.textField, .textField, .textField, .textArea]
            case .pattern204:
                return [.textField, .textField, .textField, .textArea, .textField]
            case .pattern205:
                return [.textField, .textField, .textField, .textArea, .textField]
            case .pattern3:
                return [.textField, .textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern301:
                return [.textField, .textField, .textField, .textField, .textArea]
            case .pattern4:
                return [.textField, .textArea, .date, .textField]
            case .pattern401:
                return [.textField, .textArea]
            case .pattern5:
                return [.textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern501:
                return [.textField, .textField, .textField, .textArea]
            case .pattern6:
                return [.textField, .textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern601:
                return [.textField, .textField, .textField, .textField, .textArea]
            case .pattern602:
                return [.textField, .textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern603:
                return [.textField, .textField, .textField, .textField, .textArea]
            case .pattern604:
                return [.textField, .textField, .textField, .textField, .textArea, .textField]
            case .pattern605:
                return [.textField, .textField, .textField, .textField, .textArea, .textField]
            case .pattern7:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern701:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textArea]
            case .pattern702:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .date, .textField]
            case .pattern703:
                return [.textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern704:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textArea, .textField]
            case .pattern802:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .date, .textField]
            case .pattern803:
                return [.textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern902:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .date, .textField]
            case .pattern903:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern10:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern1001:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textArea]
            case .pattern1003:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1004:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textArea, .textField]
            case .pattern1103:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1105:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1202:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .date, .textField]
            case .pattern1203:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1303:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1403:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1502:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .date, .textField]
            case .pattern1503:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1505:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1602:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .date, .textField]
            case .pattern1603:
                return [.textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1802:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .date, .textField]
            case .pattern1803:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1805:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField, .textField]
            case .pattern1902:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern1903:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textArea]
            case .pattern1905:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textArea, .textField]
            case .pattern2202:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textArea, .date, .textField]
            case .pattern2203:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textArea]
            case .pattern2205:
                return [.textField, .textField, .textField, .textField, .textField, .textField, .textArea, .textField]
            }
        }

        public var stackedInputsRowType: [InputsCellRowType] {
            switch self {
            case .pattern1:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .memo(position: 3),
                    .dateAndConstructionPlayer(leftPosition: 4, rightPosition: 5)
                ]
            case .pattern101:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .memo(position: 3)
                ]
            case .pattern102:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .memo(position: 3),
                    .dateAndConstructionPlayer(leftPosition: 4, rightPosition: 5)
                ]
            case .pattern103:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .memo(position: 3)
                ]
            case .pattern104:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .memo(position: 3),
                    .constructionPlayer(position: 4)
                ]
            case .pattern2:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .memo(position: 4),
                    .dateAndConstructionPlayer(leftPosition: 5, rightPosition: 6)
                ]
            case .pattern201:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .memo(position: 4)
                ]
            case .pattern202:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .memo(position: 4),
                    .dateAndConstructionPlayer(leftPosition: 5, rightPosition: 6)
                ]
            case .pattern203:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .memo(position: 4)
                ]
            case .pattern204:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .memo(position: 4),
                    .constructionPlayer(position: 5)
                ]
            case .pattern205:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .memo(position: 4),
                    .constructionPlayer(position: 5)
                ]
            case .pattern3:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .memo(position: 5),
                    .dateAndConstructionPlayer(leftPosition: 6, rightPosition: 7)
                ]
            case .pattern301:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .memo(position: 5)
                ]
            case .pattern4:
                return [
                    .constructionName(position: 1),
                    .memo(position: 2),
                    .dateAndConstructionPlayer(leftPosition: 3, rightPosition: 4)
                ]
            case .pattern401:
                return [
                    .constructionName(position: 1),
                    .memo(position: 2)
                ]
            case .pattern5:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .memo(position: 4),
                    .dateAndConstructionPlayer(leftPosition: 5, rightPosition: 6)
                ]
            case .pattern501:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .memo(position: 4)
                ]
            case .pattern6:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .memo(position: 5),
                    .dateAndConstructionPlayer(leftPosition: 6, rightPosition: 7)
                ]
            case .pattern601:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .memo(position: 5)
                ]
            case .pattern602:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .memo(position: 5),
                    .dateAndConstructionPlayer(leftPosition: 6, rightPosition: 7)
                ]
            case .pattern603:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .memo(position: 5)
                ]
            case .pattern604:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .memo(position: 5),
                    .constructionPlayer(position: 6)
                ]
            case .pattern605:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .memo(position: 5),
                    .constructionPlayer(position: 6)
                ]
            case .pattern7:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .memo(position: 7),
                    .dateAndConstructionPlayer(leftPosition: 8, rightPosition: 9)
                ]
            case .pattern701:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .memo(position: 7)
                ]
            case .pattern702:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .dateAndConstructionPlayer(leftPosition: 7, rightPosition: 8)
                ]
            case .pattern703:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6)
                ]
            case .pattern704:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .memo(position: 7),
                    .constructionPlayer(position: 8)
                ]
            case .pattern802:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .dateAndConstructionPlayer(leftPosition: 7, rightPosition: 8)
                ]
            case .pattern803:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6)
                ]
            case .pattern902:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .dateAndConstructionPlayer(leftPosition: 8, rightPosition: 9)
                ]
            case .pattern903:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7)
                ]
            case .pattern10:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .memo(position: 8),
                    .dateAndConstructionPlayer(leftPosition: 9, rightPosition: 10)
                ]
            case .pattern1001:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .memo(position: 8)
                ]
            case .pattern1003:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7)
                ]
            case .pattern1004:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .memo(position: 8),
                    .constructionPlayer(position: 9)
                ]
            case .pattern1103:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7)
                ]
            case .pattern1105:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .constructionPlayer(position: 8)
                ]
            case .pattern1202:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8),
                    .dateAndConstructionPlayer(leftPosition: 9, rightPosition: 10)
                ]
            case .pattern1203:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8)
                ]
            case .pattern1303:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8)
                ]
            case .pattern1403:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8)
                ]
            case .pattern1502:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8),
                    .normal(position: 9),
                    .dateAndConstructionPlayer(leftPosition: 10, rightPosition: 11)
                ]
            case .pattern1503:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8),
                    .normal(position: 9)
                ]
            case .pattern1505:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8),
                    .normal(position: 9),
                    .constructionPlayer(position: 10)
                ]
            case .pattern1602:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .dateAndConstructionPlayer(leftPosition: 7, rightPosition: 8)
                ]
            case .pattern1603:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6)
                ]
            case .pattern1802:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8),
                    .normal(position: 9),
                    .normal(position: 10),
                    .normal(position: 11),
                    .dateAndConstructionPlayer(leftPosition: 12, rightPosition: 13)
                ]
            case .pattern1803:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8),
                    .normal(position: 9),
                    .normal(position: 10),
                    .normal(position: 11)
                ]
            case .pattern1805:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .normal(position: 7),
                    .normal(position: 8),
                    .normal(position: 9),
                    .normal(position: 10),
                    .normal(position: 11),
                    .constructionPlayer(position: 12)
                ]
            case .pattern1902:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .memo(position: 7),
                    .dateAndConstructionPlayer(leftPosition: 8, rightPosition: 9)
                ]
            case .pattern1903:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .memo(position: 7)
                ]
            case .pattern1905:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .memo(position: 7),
                    .constructionPlayer(position: 8)
                ]
            case .pattern2202:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .memo(position: 7),
                    .dateAndConstructionPlayer(leftPosition: 8, rightPosition: 9)
                ]
            case .pattern2203:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .memo(position: 7)
                ]
            case .pattern2205:
                return [
                    .constructionName(position: 1),
                    .normal(position: 2),
                    .normal(position: 3),
                    .normal(position: 4),
                    .normal(position: 5),
                    .normal(position: 6),
                    .memo(position: 7),
                    .constructionPlayer(position: 8)
                ]
            }
        }
        
        /// 豆図用のViewがあるか否か
        public var hasMiniatureMapView: Bool {
            switch self {
            // 豆図がない
            case .pattern1,
                 .pattern101,
                 .pattern104,
                 .pattern2,
                 .pattern201,
                 .pattern204,
                 .pattern3,
                 .pattern301,
                 .pattern4,
                 .pattern401,
                 .pattern5,
                 .pattern501,
                 .pattern6,
                 .pattern601,
                 .pattern604,
                 .pattern7,
                 .pattern701,
                 .pattern704,
                 .pattern10,
                 .pattern1001,
                 .pattern1004:
                return false
            // 豆図がある
            case .pattern102,
                 .pattern103,
                 .pattern202,
                 .pattern203,
                 .pattern205,
                 .pattern602,
                 .pattern603,
                 .pattern605,
                 .pattern702,
                 .pattern703,
                 .pattern802,
                 .pattern803,
                 .pattern902,
                 .pattern903,
                 .pattern1003,
                 .pattern1103,
                 .pattern1105,
                 .pattern1202,
                 .pattern1203,
                 .pattern1303,
                 .pattern1403,
                 .pattern1502,
                 .pattern1503,
                 .pattern1505,
                 .pattern1602,
                 .pattern1603,
                 .pattern1802,
                 .pattern1803,
                 .pattern1805,
                 .pattern1902,
                 .pattern1903,
                 .pattern1905,
                 .pattern2202,
                 .pattern2203,
                 .pattern2205:
                return true
            }
        }
        
        public var positionsWithoutSpecifiedPositions: [Int] {
            stackedInputsRowType
                .filter {
                    switch $0 {
                    case .normal, .memo:
                        return true
                    case .constructionName,
                         .dateAndConstructionPlayer,
                         .constructionPlayer:
                        return false
                    }
                }
                .compactMap { $0.positions.first }
        }
        
        static var miniatureMapViewLayouts: [Pattern] {
            Pattern.allCases.filter { $0.hasMiniatureMapView }
        }
        
        static var allCasesWithoutMiniatureMapViewLayouts: [Pattern] {
            Pattern.allCases.filter { !$0.hasMiniatureMapView }
        }
        
        public func specifiedPosition(by keyItem: ModernBlackboardKeyItemName) -> Int? {
            switch keyItem {
            case .constructionName:
                // 現状は全パターン共通
                switch self {
                case .pattern1,
                     .pattern101,
                     .pattern102,
                     .pattern103,
                     .pattern104,
                     .pattern2,
                     .pattern201,
                     .pattern202,
                     .pattern203,
                     .pattern204,
                     .pattern205,
                     .pattern3,
                     .pattern301,
                     .pattern4,
                     .pattern401,
                     .pattern5,
                     .pattern501,
                     .pattern6,
                     .pattern601,
                     .pattern602,
                     .pattern603,
                     .pattern604,
                     .pattern605,
                     .pattern7,
                     .pattern701,
                     .pattern702,
                     .pattern703,
                     .pattern704,
                     .pattern802,
                     .pattern803,
                     .pattern902,
                     .pattern903,
                     .pattern10,
                     .pattern1001,
                     .pattern1003,
                     .pattern1004,
                     .pattern1103,
                     .pattern1105,
                     .pattern1202,
                     .pattern1203,
                     .pattern1303,
                     .pattern1403,
                     .pattern1502,
                     .pattern1503,
                     .pattern1505,
                     .pattern1602,
                     .pattern1603,
                     .pattern1802,
                     .pattern1803,
                     .pattern1805,
                     .pattern1902,
                     .pattern1903,
                     .pattern1905,
                     .pattern2202,
                     .pattern2203,
                     .pattern2205:
                    return 1
                }
            case .memo:
                switch self {
                // 備考欄があり、かつ施工日、施工者のあるパターン群
                case .pattern1,
                     .pattern102,
                     .pattern2,
                     .pattern202,
                     .pattern3,
                     .pattern4,
                     .pattern5,
                     .pattern6,
                     .pattern602,
                     .pattern7,
                     .pattern10,
                     .pattern1902,
                     .pattern2202:
                    return itemTypes.count - 2
                // 備考欄があり、かつ施工日もしくは施工者どちらかがあるパターン群
                case .pattern104,
                     .pattern204,
                     .pattern205,
                     .pattern604,
                     .pattern605,
                     .pattern704,
                     .pattern1004,
                     .pattern1905,
                     .pattern2205:
                    return itemTypes.count - 1
                // 備考欄があり、かつ施工日、施工者のないパターン群
                case .pattern101,
                     .pattern103,
                     .pattern201,
                     .pattern203,
                     .pattern301,
                     .pattern401,
                     .pattern501,
                     .pattern601,
                     .pattern603,
                     .pattern701,
                     .pattern1001,
                     .pattern1903,
                     .pattern2203:
                    return itemTypes.count
                // 備考欄がないパターン群
                case .pattern702,
                     .pattern703,
                     .pattern802,
                     .pattern803,
                     .pattern902,
                     .pattern903,
                     .pattern1003,
                     .pattern1103,
                     .pattern1105,
                     .pattern1202,
                     .pattern1203,
                     .pattern1303,
                     .pattern1403,
                     .pattern1502,
                     .pattern1503,
                     .pattern1505,
                     .pattern1602,
                     .pattern1603,
                     .pattern1802,
                     .pattern1803,
                     .pattern1805:
                    return nil
                }
            case .date:
                switch self {
                // 施工日、施工者のあるパターン群
                case .pattern1,
                     .pattern102,
                     .pattern2,
                     .pattern202,
                     .pattern3,
                     .pattern4,
                     .pattern5,
                     .pattern6,
                     .pattern602,
                     .pattern7,
                     .pattern702,
                     .pattern802,
                     .pattern902,
                     .pattern10,
                     .pattern1202,
                     .pattern1502,
                     .pattern1602,
                     .pattern1802,
                     .pattern1902,
                     .pattern2202:
                    return itemTypes.count - 1
                // 施工者のみあるパターン群
                case .pattern104,
                     .pattern204,
                     .pattern205,
                     .pattern604,
                     .pattern605,
                     .pattern704,
                     .pattern1004,
                     .pattern1105,
                     .pattern1505,
                     .pattern1805,
                     .pattern1905,
                     .pattern2205:
                    return nil
                // 施工日、施工者のないパターン群
                case .pattern101,
                     .pattern103,
                     .pattern201,
                     .pattern203,
                     .pattern301,
                     .pattern401,
                     .pattern501,
                     .pattern601,
                     .pattern603,
                     .pattern701,
                     .pattern703,
                     .pattern803,
                     .pattern903,
                     .pattern1001,
                     .pattern1003,
                     .pattern1103,
                     .pattern1203,
                     .pattern1303,
                     .pattern1403,
                     .pattern1503,
                     .pattern1603,
                     .pattern1803,
                     .pattern1903,
                     .pattern2203:
                    return nil
                }
            case .constructionPlayer:
                switch self {
                // 施工日、施工者のあるパターン群
                case .pattern1,
                     .pattern102,
                     .pattern2,
                     .pattern202,
                     .pattern3,
                     .pattern4,
                     .pattern5,
                     .pattern6,
                     .pattern602,
                     .pattern7,
                     .pattern702,
                     .pattern802,
                     .pattern902,
                     .pattern10,
                     .pattern1202,
                     .pattern1502,
                     .pattern1602,
                     .pattern1802,
                     .pattern1902,
                     .pattern2202:
                    return itemTypes.count
                // 施工者のみあるパターン群
                case .pattern104,
                     .pattern204,
                     .pattern205,
                     .pattern604,
                     .pattern605,
                     .pattern704,
                     .pattern1004,
                     .pattern1105,
                     .pattern1505,
                     .pattern1805,
                     .pattern1905,
                     .pattern2205:
                    return itemTypes.count
                // 施工日、施工者のないパターン群
                case .pattern101,
                     .pattern103,
                     .pattern201,
                     .pattern203,
                     .pattern301,
                     .pattern401,
                     .pattern501,
                     .pattern601,
                     .pattern603,
                     .pattern701,
                     .pattern703,
                     .pattern803,
                     .pattern903,
                     .pattern1001,
                     .pattern1003,
                     .pattern1103,
                     .pattern1203,
                     .pattern1303,
                     .pattern1403,
                     .pattern1503,
                     .pattern1603,
                     .pattern1803,
                     .pattern1903,
                     .pattern2203:
                    return nil
                }
            }
        }

        var layoutID: Int {
            rawValue
        }
    }

    private init(
        pattern: Pattern,
        patternType: PatternType,
        customTitles: [String],
        values: [String]?,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool,
        modernBlackboardDataObject: ModernBlackboardContent.ModernBlackboardDataObject,
        alphaLevel: ModernBlackboardAppearance.AlphaLevel
    ) {
        super.init(frame: .zero)
        
        // 後にSVG画像化するため、黒板要素を確保しておく
        blackboardContent = ModernBlackboardContent(
            modernBlackboardDataObject: modernBlackboardDataObject,
            pattern: pattern,
            customTitles: customTitles,
            values: values,
            theme: theme,
            memoStyleArguments: memoStyleArguments,
            displayStyle: displayStyle,
            alphaLevel: alphaLevel,
            shouldBeReflectedNewLine: shouldBeReflectedNewLine
        )
    
        // NOTE: 現状はxibからレイアウトを呼び出し、各値を当てはめる
        setUpLayoutByXib: do {
            guard let unwrappedNibName = pattern.nibName,
                  let nib = Bundle.andpadCamera.loadNibNamed(
                    unwrappedNibName,
                    owner: self,
                    options: nil
                  ),
                  let baseView = nib.first as? BlackboardBaseView else {
                return
            }

            baseView.clipsToBounds = true
            baseView.layer.borderWidth = 2.0
            baseView.layer.borderColor = theme.borderColor.cgColor
            
            if displayStyle.shouldSetCornerRounder {
                baseView.layer.cornerRadius = 8.0
            }
            
            addSubview(baseView)
            baseView.easy.layout(Edges())

            if let caseView = baseView as? ModernBlackboardCaseViewProtocol {
                makeRows(
                    caseView: caseView,
                    theme: theme,
                    memoStyleArguments: memoStyleArguments,
                    patternType: patternType,
                    displayStyle: displayStyle,
                    customTitles: customTitles,
                    values: values,
                    shouldBeReflectedNewLine: shouldBeReflectedNewLine
                )
            }
        }
    }

    public convenience init?(
        _ modernBlackboardData: ModernBlackboardData,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        dateFormatType: ModernBlackboardCommonSetting.DateFormatType,
        miniatureMapImageState: MiniatureMapImageState?,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        shouldBeReflectedNewLine: Bool,
        alphaLevel: ModernBlackboardAppearance.AlphaLevel
    ) {
        if let layout = modernBlackboardData as? ModernBlackboardLayout,
           let pattern = Pattern(by: layout.layoutMaterial.id) {
            let patternType: PatternType = pattern.hasMiniatureMapView
                // レイアウト表示のときは豆図を出さないため、miniatureMapImageStateは反映せず.beforeLoadingとする
                ? .withMiniatureMap(.beforeLoading)
                : .normal
            
            self.init(
                pattern: pattern,
                patternType: patternType,
                customTitles: layout.items
                    .map { $0.itemName },
                values: nil,
                theme: theme,
                memoStyleArguments: memoStyleArguments,
                displayStyle: displayStyle,
                shouldBeReflectedNewLine: shouldBeReflectedNewLine,
                modernBlackboardDataObject: .layout(item: layout),
                alphaLevel: alphaLevel
            )
        } else if let material = modernBlackboardData as? ModernBlackboardMaterial,
                  let pattern = Pattern(by: material.layoutTypeID) {
            let patternType: PatternType
            if let miniatureMapImageState = miniatureMapImageState,
               pattern.hasMiniatureMapView {
                patternType = .withMiniatureMap(miniatureMapImageState)
            } else {
                patternType = .normal
            }
            
            let datePosition = pattern.specifiedPosition(by: .date)
            
            let bodies = material.items.map { item -> String in
                guard item.position == datePosition else {
                    return item.body
                }
                return item.body
                    .asDateFromDateString()?
                    .asDateString(
                        formatString: dateFormatType.formatString,
                        locale: dateFormatType.locale,
                        calenderIdentifier: dateFormatType.calenderIdentifier
                    ) ?? item.body
            }
            
            self.init(
                pattern: pattern,
                patternType: patternType,
                customTitles: material.items.map { $0.itemName },
                values: bodies,
                theme: theme,
                memoStyleArguments: memoStyleArguments,
                displayStyle: displayStyle,
                shouldBeReflectedNewLine: shouldBeReflectedNewLine,
                modernBlackboardDataObject: .material(item: material),
                alphaLevel: alphaLevel
            )
        } else {
            return nil
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: for Xib
extension ModernBlackboardContentView {
    private func makeRows(
        caseView: ModernBlackboardCaseViewProtocol,
        theme: ModernBlackboardAppearance.Theme,
        memoStyleArguments: ModernBlackboardMemoStyleArguments,
        patternType: PatternType,
        displayStyle: ModernBlackboardCaseViewDisplayStyle,
        customTitles: [String],
        values: [String]?,
        shouldBeReflectedNewLine: Bool
    ) {
        // [workaround] 備考のテキスト色を補正
        // （本来であればもっと根本の部分から調整すべきだが、手前で処理している点でworkaround。いずれ正しい対処を行うこと）
        let updatedMemoStyleArguments = memoStyleArguments.updating(textColor: theme.textColor)
        
        caseView.configure(
            titles: customTitles,
            values: values,
            theme: theme,
            memoStyleArguments: updatedMemoStyleArguments,
            patternType: patternType,
            displayStyle: displayStyle,
            shouldBeReflectedNewLine: shouldBeReflectedNewLine
        )
    }
}

/**
 SVG画像を生成する
 */
extension ModernBlackboardContentView {
    /**
     黒板をSVGで生成して、画像化する
     
     @description
     撮影画面のみで利用する
     
     @note
     従来生成も混在するので、画像作成機能を独立して保持する。
     もし SVG のみになったら、init で画像を生成して、それを add すればよい。
     */
    func exportImageWithSVG(
        size: CGSize,
        miniatureMapImageType: MiniatureMapImageType,
        shouldShowMiniatureMapFromLocal: Bool,
        isShowEmptyMiniatureMap: Bool,
        isHiddenNoneAndEmptyMiniatureMap: Bool
    ) async -> UIImage? {
        guard
            let blackboardContent = blackboardContent,
            let url = await blackboardContent.makeSVGBlackboardURL(
                size: size,
                miniatureMapImageType: miniatureMapImageType,
                shouldShowMiniatureMapFromLocal: shouldShowMiniatureMapFromLocal,
                isShowEmptyMiniatureMap: isShowEmptyMiniatureMap,
                isHiddenNoneAndEmptyMiniatureMap: isHiddenNoneAndEmptyMiniatureMap
            ) else {
            return nil
        }
        
        // SVGから画像を生成する
        let renderer = BlackboardHTMLRenderer()
        let image = await renderer.exportImage(
            URL: url,
            size: size
        )
        return image
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length

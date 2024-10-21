//
//  ModernBlackboardKeyItemName.swift
//  andpad-camera
//
//  Created by msano on 2021/03/17.
//

/// 特定の黒板項目（値の自動入力など、他項目と異なるハンドリングがある項目）をまとめたenum
public enum ModernBlackboardKeyItemName: String {
    /// 黒板項目「工事名」
    case constructionName

    /// 黒板項目「備考」
    case memo

    /// 黒板項目「施工日」
    case date

    /// 黒板項目「施工者」
    case constructionPlayer
}

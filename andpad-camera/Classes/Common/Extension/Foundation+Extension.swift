//
//  Foundation+Extension.swift
//  andpad-camera
//
//  Created by 成瀬 未春 on 2024/08/05.
//

import Foundation

func isFileURL(_ url: URL) -> Bool {
    return url.scheme == "file"
}

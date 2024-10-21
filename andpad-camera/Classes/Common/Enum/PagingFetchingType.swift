//
//  PagingFetchingType.swift
//  andpad-camera
//
//  Created by msano on 2021/01/06.
//

public enum PagingFetchingType: Equatable {
    case initialFetch
    case paging(offset: Int)
}

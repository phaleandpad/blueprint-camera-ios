//
//  ViewModeling.swift
//  andpad-camera
//
//  Created by msano on 2020/12/16.
//

import RxCocoa

protocol ViewModel {
    associatedtype Input
    associatedtype Output

    var inputPort: PublishRelay<Input> { get }
    var outputPort: ControlEvent<Output> { get }
}

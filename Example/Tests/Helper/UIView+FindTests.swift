//
//  UIView+FindTests.swift
//  andpad-camera_Tests
//
//  Created by Yuka Kobayashi on 2021/06/29.
//  Copyright © 2021 ANDPAD Inc. All rights reserved.
//

import Nimble
import UIKit
import XCTest

// MARK: - hasSubviewWithCondition
final class UIView_FindTests: XCTestCase {
    private let condition: (_ label: UILabel) -> Bool = { $0.text == "test" }

    func test_hasSubviewWithCondition_UIView自体が対象の場合_falseが返る() {
        let subject = UILabel()
        subject.text = "test"

        expect(subject.hasSubview(withCondition: self.condition)).to(beFalse())
    }

    func test_hasSubviewWithCondition_直下のサブビューに対象がある場合_trueが返る() {
        let subject = UIView()
        let label = UILabel()
        label.text = "test"

        subject.addSubview(label)

        expect(subject.hasSubview(withCondition: self.condition)).to(beTrue())
    }

    func test_hasSubviewWithCondition_直下のサブビューに対象がない＆サブビューのサブビューが存在しない場合_falseが返る() {
        let subject = UIView()
        let label = UILabel()
        label.text = "hoge"

        subject.addSubview(label)

        expect(subject.hasSubview(withCondition: self.condition)).to(beFalse())
    }

    func test_hasSubviewWithCondition_サブビューのサブビューに対象がある場合_trueが返る() {
        let subject = UIView()
        let subview = UIView()
        let label = UILabel()
        label.text = "test"

        subview.addSubview(label)
        subject.addSubview(subview)

        expect(subject.hasSubview(withCondition: self.condition)).to(beTrue())
    }

    func test_hasSubviewWithCondition_サブビュー及びサブビューのサブビューに対象がない場合_falseが返る() {
        let subject = UIView()
        let subView = UIView()
        let label = UILabel()
        label.text = "fuga"

        subView.addSubview(label)
        subject.addSubview(subView)

        expect(subject.hasSubview(withCondition: self.condition)).to(beFalse())
    }
}

// MARK: - hasXXX
extension UIView_FindTests {
    func test_hasLabel_直下のサブビューに同じtextが設定されたUILabelがある場合_trueが返る() {
        let subject = UIView()
        let label = UILabel()
        label.text = "test"

        subject.addSubview(label)

        expect(subject.hasLabel(with: "test")).to(beTrue())
        expect(subject.hasLabel(with: "hoge")).to(beFalse())
    }

    func test_hasButton_直下のサブビューに同じtextが設定されたUIButtonがある場合_trueが返る() {
        let subject = UIView()
        let button = UIButton()
        button.setTitle("test", for: .normal)

        subject.addSubview(button)

        expect(subject.hasButton(with: "test")).to(beTrue())
        expect(subject.hasButton(with: "hoge")).to(beFalse())
    }
}

// MARK: - findSubviewsWithCondition
extension UIView_FindTests {
    func test_findSubviewsWithCondition_UIView自体が対象の場合_含まれない() {
        let subject = UILabel()
        subject.text = "test"

        expect(subject.findSubviews(withCondition: self.condition)).to(beEmpty())
    }

    func test_findSubviewsWithCondition_直下のサブビューに対象がある場合_含まれる() {
        let subject = UIView()
        let label = UILabel()
        label.text = "test"

        subject.addSubview(label)
        subject.addSubview(UIImageView())

        let result = subject.findSubviews(withCondition: self.condition)
        expect(result).to(haveCount(1))
        expect(result).to(contain(label))
    }

    func test_findSubviewsWithCondition_サブビューのサブビューに対象がある場合_含まれる() {
        let subject = UIView()
        let subview = UIView()
        let label1 = UILabel()
        let label2 = UILabel()
        label1.text = "test"
        label2.text = "test"

        subview.addSubview(label1)
        subview.addSubview(UIImageView())

        subject.addSubview(subview)
        subject.addSubview(label2)
        subject.addSubview(UIImageView())

        let result = subject.findSubviews(withCondition: self.condition)
        expect(result).to(haveCount(2))
        expect(result).to(contain(label1))
        expect(result).to(contain(label2))
    }
}

// MARK: - findXXX
extension UIView_FindTests {
    func test_findSubviewsWithType_直下のサブビューに対象のクラスがある場合_含まれる() {
        let subject = UIView()
        let label = UILabel()
        subject.addSubview(label)
        subject.addSubview(UIImageView())

        let result = subject.findSubviews(with: UILabel.self)
        expect(result).to(haveCount(1))
        expect(result).to(contain(label))
        
        expect(subject.findSubviews(with: UIButton.self)).to(beEmpty())
    }
    
    func test_findButton_直下のサブビューに同じtextが設定されたUIButtonがある場合_含まれる() {
        let subject = UIView()

        let button1 = UIButton()
        button1.setTitle("test", for: .normal)
        subject.addSubview(button1)

        let button2 = UIButton()
        button2.setTitle("hoge", for: .normal)
        subject.addSubview(button2)

        let result = subject.findButton(with: "test")
        expect(result).to(haveCount(1))
        expect(result).to(contain(button1))
        
        expect(subject.findButton(with: "fuga")).to(beEmpty())
    }
}

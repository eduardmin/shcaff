//
//  LoginTextField.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/23/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {
    
    var padding : UIEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 10)
    var changeBordorColor: Bool = true
    var error: Bool = false {
        didSet {
            if error {
                layer.borderColor = SCColors.deleteColor.cgColor
            } else {
                layer.borderColor = SCColors.textfieldBorderColor.cgColor
            }
        }
    }
    var rigthMargin : CGFloat = 10 {
        didSet {
            padding.right = rigthMargin
        }
    }
    
    var leftMargin : CGFloat = 10 {
        didSet {
            padding.left = leftMargin
        }
    }
    
    convenience init(_ point: CGPoint) {
        self.init()
        congfigure()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        congfigure()
    }
    
    private func congfigure() {
        returnKeyType = .done
        layer.cornerRadius = bounds.height / 2
        layer.borderWidth = 1
        layer.borderColor = SCColors.textfieldBorderColor.cgColor
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        if changeBordorColor {
            layer.borderColor = SCColors.titleColor.cgColor
        }
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        if changeBordorColor {
            layer.borderColor = SCColors.textfieldBorderColor.cgColor
        }
        return true
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    public func setPlaceHolder(text: String) {
        attributedPlaceholder = NSAttributedString(string: text.localize(),
                                                   attributes: [NSAttributedString.Key.foregroundColor: SCColors.mainGrayColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
    }
}



//
//  BrandVerificationCodeItemView.swift
//  Menu
//
//  Created by Tigran on 12/24/18.
//  Copyright © 2018 Menu Group (UK) LTD. All rights reserved.
//

import UIKit

protocol VerificationCodeItemViewDelegate: class {
    func verificationCodeItemView(_ verificationCodeItemView: VerificationCodeItemView, didTextFieldValueChange textFiled : CustomTextField)
    func verificationCodeItemView(_ verificationCodeItemView: VerificationCodeItemView, didTextFieldBackspacePress textFiled : CustomTextField)
    func setValue(_ value: Int, forItemAt index: Int)
}

protocol CustomTextFieldDelegate: class {
    func customTextFieldDidResignActive(_ textField: CustomTextField)
}

class CustomTextField: UITextField {
    
    var isAlreadyEmpty: Bool = true
    
    weak var customTextFieldDelegate: CustomTextFieldDelegate?
    var error: Bool = false {
        didSet {
            if error {
                layer.borderColor = SCColors.deleteColor.cgColor
            } else {
                layer.borderColor = SCColors.textfieldBorderColor.cgColor
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = SCColors.textfieldBorderColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        layer.borderColor = SCColors.titleColor.cgColor
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        layer.borderColor = SCColors.textfieldBorderColor.cgColor
        return true
    }
    
    override func deleteBackward() {
        if isAlreadyEmpty {
            customTextFieldDelegate?.customTextFieldDidResignActive(self)
        } else {
            super.deleteBackward()
        }
    }
}

class VerificationCodeItemView: UIView {

    weak var delegate: VerificationCodeItemViewDelegate?
    
    var textField: CustomTextField = CustomTextField()
    var itemSuperView: VerificationView?
    
    var textFieldValue: String? {
        didSet {
            textField.text = textFieldValue
        }
    }
    
    //MARK: -Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    private func configureUI() {
        configureMainView()
        configureTextField()
    }
    
    private func configureMainView() {
        self.backgroundColor = SCColors.whiteColor
        self.layer.cornerRadius = 5.0
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60.0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 55.0))
    }
    
    
    private func configureTextField() {
        textField.textColor = SCColors.titleColor
        textField.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        textField.textAlignment = .center
        textField.backgroundColor = .clear
        textField.keyboardType = .numberPad
        textField.tintColor = SCColors.textfieldBorderColor
        textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        textField.delegate = self
        textField.customTextFieldDelegate = self
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textField)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[textField]|", options: [], metrics: nil, views: ["textField": textField]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[textField]|", options: [], metrics: nil, views: ["textField": textField]))
    }
    
    @objc private func textFieldValueChanged(_ sender: CustomTextField) {
        if let text = sender.text, text != "" {
            textField.isAlreadyEmpty = false
            delegate?.verificationCodeItemView(self, didTextFieldValueChange: sender)
        } else {
            textField.isAlreadyEmpty = true
            delegate?.verificationCodeItemView(self, didTextFieldValueChange: sender)
        }
    }
}

extension VerificationCodeItemView : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        if count <= 1 {
            return true
        } else if textField.tag != 3 {
            
            if let convertedStr = Int(string) {
                self.delegate?.setValue(convertedStr, forItemAt: (textField.tag + 1))
            }
            
            textField.resignFirstResponder()
            return false
        } else {
            textField.resignFirstResponder()
            return false
        }
    }
}

extension VerificationCodeItemView : CustomTextFieldDelegate {
    func customTextFieldDidResignActive(_ textField: CustomTextField) {
        self.delegate?.verificationCodeItemView(self, didTextFieldBackspacePress: textField)
    }
}

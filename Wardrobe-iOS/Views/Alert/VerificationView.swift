//
//  VerificationView.swift
//  Wardrobe-iOS
//
//

import UIKit

protocol VerificationViewDelegate: class {
    func allCodesFull(_ isfull : Bool)
}

class VerificationView: UIView {

    private var holderView: UIView = UIView()
    private var messageLabel: UILabel =  UILabel()
    private var emailLabel: UILabel =  UILabel()
    private var errorLabel: UILabel =  UILabel()
    private var resendButton: UIButton = UIButton(type: .custom)
    weak var delegate: VerificationViewDelegate?
    var timer = Timer()
    var counter = 60
    var codeStackView: UIStackView = UIStackView()
    var message: NSAttributedString!
    var emailText: String?
    var confirmButtonTitle: String!
    var confirmButtonHandler: (() -> ())?
    var resetButtonHandler: (() -> ())?
    var cancelButtonHandler = {}
    
    func configure() {
        configureUI()
    }
    
    func show() {
        configureUI()
        UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
            self.holderView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func showError(text: String) {
        errorLabel.text = text.localize()
        errorLabel.isHidden = false
        codeStackView.arrangedSubviews.forEach { (item) in
            (item as? VerificationCodeItemView)?.textField.error = true
        }
    }
    
    func resetError() {
        errorLabel.isHidden = true
        codeStackView.arrangedSubviews.forEach { (item) in
            (item as? VerificationCodeItemView)?.textField.error = false
        }
    }
    //MARK: -UI Configuration
    private func configureUI() {
        configureHolderView()
        configureMessageLabel()
        configureEmailLabel()
        configureErrorLabel()
        configureCodeStackView()
        configureResendButton()
    }
    

    private func configureHolderView() {
        holderView.backgroundColor = .clear
        
        holderView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(holderView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[holderView]|", options: [], metrics: nil, views: ["holderView": holderView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[holderView]|", options: [], metrics: nil, views: ["holderView": holderView]))
    }
    
    private func configureMessageLabel() {
        messageLabel.attributedText = message
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        holderView.addSubview(messageLabel)
        
        holderView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: holderView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        holderView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0.0))
        
        holderView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .equal, toItem: holderView, attribute: .leading, multiplier: 1.0, constant: 50.0))
        holderView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .trailing, relatedBy: .equal, toItem: holderView, attribute: .trailing, multiplier: 1.0, constant: -50.0))
    }
    
    private func configureEmailLabel() {
        emailLabel.text = "Sent to %@".localized(with: emailText ?? "")
        emailLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        emailLabel.textColor = SCColors.mainGrayColor
        emailLabel.textAlignment = .center
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        holderView.addSubview(emailLabel)
        holderView.addConstraint(NSLayoutConstraint(item: emailLabel, attribute: .centerX, relatedBy: .equal, toItem: holderView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        holderView.addConstraint(NSLayoutConstraint(item: emailLabel, attribute: .top, relatedBy: .equal, toItem: messageLabel, attribute: .bottom, multiplier: 1.0, constant: 25.0))
        
        holderView.addConstraint(NSLayoutConstraint(item: emailLabel, attribute: .leading, relatedBy: .equal, toItem: holderView, attribute: .leading, multiplier: 1.0, constant: 50.0))
        holderView.addConstraint(NSLayoutConstraint(item: emailLabel, attribute: .trailing, relatedBy: .equal, toItem: holderView, attribute: .trailing, multiplier: 1.0, constant: -50.0))
    }
    
    private func configureErrorLabel() {
        errorLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        errorLabel.textColor = SCColors.deleteColor
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        holderView.addSubview(errorLabel)
        holderView.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .top, relatedBy: .equal, toItem: emailLabel, attribute: .bottom, multiplier: 1.0, constant: 15.0))
        holderView.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .leading, relatedBy: .equal, toItem: holderView, attribute: .leading, multiplier: 1.0, constant: 50.0))
        holderView.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .trailing, relatedBy: .equal, toItem: holderView, attribute: .trailing, multiplier: 1.0, constant: -50.0))
    }
    
    private func configureCodeStackView() {
        codeStackView.alignment = .center
        codeStackView.spacing = 15.0
        codeStackView.axis = .horizontal
        
        codeStackView.translatesAutoresizingMaskIntoConstraints = false
        holderView.addSubview(codeStackView)
        
        holderView.addConstraint(NSLayoutConstraint(item: codeStackView, attribute: .top, relatedBy: .equal, toItem: emailLabel, attribute: .bottom, multiplier: 1.0, constant: 50.0))
        holderView.addConstraint(NSLayoutConstraint(item: codeStackView, attribute: .centerX, relatedBy: .equal, toItem: holderView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        for index in 0 ..< 4 {
            let codeItem = VerificationCodeItemView()
            codeItem.textField.tag = index
            codeItem.itemSuperView = self
            codeItem.delegate = self
            codeStackView.addArrangedSubview(codeItem)
        }
    }
    
    
    private func configureResendButton() {
        resendButton.titleLabel?.minimumScaleFactor = 0.8
        let attributedTitle = NSMutableAttributedString(string: "Resend code".localize(), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), .foregroundColor: SCColors.mainGrayColor, NSAttributedString.Key.underlineColor: SCColors.mainGrayColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        let timeAttributedTitle =  NSAttributedString(string: "(\(counter))", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: SCColors.mainGrayColor, NSAttributedString.Key.underlineColor: SCColors.mainGrayColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        attributedTitle.append(timeAttributedTitle)
        resendButton.setAttributedTitle(attributedTitle, for: .normal)
        resendButton.addTarget(self, action: #selector(resendButtonHandler(_:)), for: .touchUpInside)
        resendButton.isEnabled = false
        resendButton.translatesAutoresizingMaskIntoConstraints = false
        holderView.addSubview(resendButton)
        
        holderView.addConstraint(NSLayoutConstraint(item: resendButton, attribute: .centerX, relatedBy: .equal, toItem: holderView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        holderView.addConstraint(NSLayoutConstraint(item: resendButton, attribute: .top, relatedBy: .equal, toItem: codeStackView, attribute: .bottom, multiplier: 1.0, constant: 30.0))
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    
    @objc func fire()
    {
        counter -= 1
        let attributedTitle = NSMutableAttributedString(string: "Resend code".localize(), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), .foregroundColor: SCColors.mainGrayColor, NSAttributedString.Key.underlineColor: SCColors.mainGrayColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        let timeAttributedTitle =  NSAttributedString(string: "(\(counter))", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: SCColors.mainGrayColor, NSAttributedString.Key.underlineColor: SCColors.mainGrayColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        attributedTitle.append(timeAttributedTitle)
        resendButton.setAttributedTitle(attributedTitle, for: .normal)
        resendButton.isEnabled = false

        if counter == 0 {
            let attributedTitle = NSAttributedString(string: "Resend code".localize(), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), .foregroundColor: SCColors.titleColor, NSAttributedString.Key.underlineColor: SCColors.titleColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            resendButton.setAttributedTitle(attributedTitle, for: .normal)
            resendButton.isEnabled = true
            timer.invalidate()
            counter = 60
        }
    }
    
    //MARK: -Handlers

    @objc private func resendButtonHandler(_ sender: UIButton) {       
        if let handler = self.resetButtonHandler {
            let attributedTitle = NSAttributedString(string: "Resend code".localize(), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), .foregroundColor: SCColors.titleColor, NSAttributedString.Key.underlineColor: SCColors.titleColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            resendButton.setAttributedTitle(attributedTitle, for: .normal)
            resendButton.addTarget(self, action: #selector(resendButtonHandler(_:)), for: .touchUpInside)
            resendButton.isEnabled = false
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)

            handler()
        }
    }
    
    func firstEmptyCodeItemIndex(before index: Int ) -> Int {
        
        for currentIndex in 0 ..< index {
            if let codeItem = codeStackView.arrangedSubviews[currentIndex] as? VerificationCodeItemView, codeItem.textField.isAlreadyEmpty {
                return currentIndex
            }
        }

        return index
    }
    
    func checkCodesEmpty() {
      var isEmpty : Bool = false
      for currentIndex in 0 ..< 4 {
            if let codeItem = codeStackView.arrangedSubviews[currentIndex] as? VerificationCodeItemView {
                if codeItem.textField.isAlreadyEmpty {
                  isEmpty = true
                }
            }
       }
        delegate?.allCodesFull(!isEmpty)
    }
}

//MARK:- CodeItemView Delegate
extension VerificationView: VerificationCodeItemViewDelegate {
    
    func setValue(_ value: Int, forItemAt index: Int) {
        resetError()
        if let itemAtIndex = codeStackView.arrangedSubviews[index] as? VerificationCodeItemView {
            let _ = itemAtIndex.textField.becomeFirstResponder()
            itemAtIndex.textField.text = "\(value)"
            itemAtIndex.textField.isAlreadyEmpty = false
            if index == 3 {
                let _ = itemAtIndex.textField.resignFirstResponder()
            }
        }
    }
    
    func verificationCodeItemView(_ verificationCodeItemView: VerificationCodeItemView, didTextFieldValueChange textFiled: CustomTextField) {
        let index = textFiled.tag
        if let item = codeStackView.arrangedSubviews[index] as? VerificationCodeItemView, item.textField.isAlreadyEmpty  {
            checkCodesEmpty()
            return
        }
        
        if index != 3, let nextItem = codeStackView.arrangedSubviews[index + 1] as? VerificationCodeItemView {
            let _ = nextItem.textField.becomeFirstResponder()
        } else {
            self.endEditing(true)
        }
        checkCodesEmpty()
    }
    
    func verificationCodeItemView(_ verificationCodeItemView: VerificationCodeItemView, didTextFieldBackspacePress textFiled: CustomTextField) {
        let index = textFiled.tag
        if index != 0, let previuseItem = codeStackView.arrangedSubviews[index - 1] as? VerificationCodeItemView {
            let _ = previuseItem.textField.becomeFirstResponder()
        } else {
            endEditing(true)
        }
    }
}

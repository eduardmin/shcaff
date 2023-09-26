//
//  VerificationAlertViewController.swift
//
//  Created by Eduard Minasyan on 11/29/19.
//

import UIKit

class VerificationAlertViewController: BaseAlertViewController {
    
    //MARK:- Handlers
    public var resendButtonHandler: ((Any?) -> Void)?

    //MARK:- Public properties
    public var message: String = ""
    public var email: String = ""
    public var identificator: String = ""

    //MARK:- Private properties
    private var verificationAlert: VerificationView = VerificationView()
    
    //MARK:- Overided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        enableConfirmButton = false
    }
    
    //MARK:- Public functions
    public func getCode() -> String {
        var code = ""
        
        for currentIndex in 0 ..< 4 {
            if let codeItem = verificationAlert.codeStackView.arrangedSubviews[currentIndex] as? VerificationCodeItemView {
                code.append(codeItem.textField.text!)
            }
        }
        return code
    }
    
    public func errorMessage(message: String) {
        verificationAlert.showError(text: message)
    }
    
    //MARK:- Private functions
    private func createViews() {
        createVerificationAlert()
        setupConstraints()
    }
    
    private func createVerificationAlert() {
        let prefix = NSMutableAttributedString(string: message.localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.titleColor, NSAttributedString.Key.font:  UIFont.boldSystemFont(ofSize: 15)])
        
        verificationAlert.message = prefix
        verificationAlert.delegate = self
        verificationAlert.emailText = email
        verificationAlert.configure()
        verificationAlert.resetButtonHandler = {
            self.resendButtonHandler?(nil)
        }
    }
    
    private func setupConstraints() {
        verificationAlert.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(verificationAlert)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[verificationAlert]|", options: [], metrics: nil, views: ["verificationAlert": verificationAlert]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[verificationAlert(==260)]|", options: [], metrics: nil, views: ["verificationAlert": verificationAlert]))
    }
    
}

//MARK:- VerificationView Delegate
extension VerificationAlertViewController: VerificationViewDelegate {
    func allCodesFull(_ isfull: Bool) {
        enableConfirmButton = isfull
    }
}

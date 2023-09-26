//
//  TextFieldAlertViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/12/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class TextFieldAlertViewController: BaseAlertViewController {

    //MARK:- Public properties
    public var infoText: String = ""
    public var defaultText: String?
    public var inputText: String {
        return textField.text ?? ""
    }
    //MARK:- Private properties
    private var infoLabel: UILabel = UILabel()
    private var textField: LoginTextField = LoginTextField.init(.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        setupConstraints()
    }
    
    private func createViews() {
        enableConfirmButton = false
        infoLabel.text = infoText
        infoLabel.textColor = SCColors.titleColor
        infoLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        contentView.addSubview(infoLabel)
        textField.roundCorners(radius: 25)
        textField.delegate = self
        textField.changeBordorColor = false
        textField.text = defaultText
        contentView.addSubview(textField)
    }
    
    private func setupConstraints() {
        for subview in self.contentView.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let views = ["infoLabel" : infoLabel, "textField" : textField]
        let metrics = ["leftLabelMargin" : 16, "leftRigthMargin" : 16, "textFieldHeigth": 50, "inset": 10, "margin": 30]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(leftLabelMargin)-[infoLabel]", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(leftRigthMargin)-[textField]-(leftRigthMargin)-|", options: [], metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(margin)-[infoLabel]-(inset)-[textField(==textFieldHeigth)]-(margin)-|", options: [], metrics: metrics, views: views))
    }
}

//MARK:- TextField delegate
extension TextFieldAlertViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 1 && string == "" {
            enableConfirmButton = false
        } else {
            enableConfirmButton = true
        }
        return true
    }
}


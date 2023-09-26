//
//  ProfileTextFieldTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/14/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol ProfileTextFieldTableViewCellDelegate: class {
    func setInput(input: String?, type: ProfileType)
}

class ProfileTextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: LoginTextField!
    
    private var type: ProfileType!
    weak var delegate: ProfileTextFieldTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        textField.delegate = self
    }
    
    func configure(title: String, input: String?, type: ProfileType) {
        self.type = type
        titleLabel.text = title.localize()
        textField.text = input
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        if type == .lastName {
            let lastAttibute = NSMutableAttributedString(string: title.localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.titleColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.heavy)])
            lastAttibute.append(NSAttributedString(string:" " + "(optional)".localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.titleColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)]))
            titleLabel.attributedText = lastAttibute
        } else if type == .email {
            let lastAttibute = NSMutableAttributedString(string: title.localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.mainGrayColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.heavy)])
            lastAttibute.append(NSAttributedString(string:" " + "(non editable)".localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.mainGrayColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)]))
            titleLabel.attributedText = lastAttibute
            textField.textColor = SCColors.mainGrayColor
            textField.isEnabled = false
        }
    }
}

extension ProfileTextFieldTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.setInput(input: textField.text, type: type)
    }
}


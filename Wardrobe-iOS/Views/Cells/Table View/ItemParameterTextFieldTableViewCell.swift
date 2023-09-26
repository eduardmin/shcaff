//
//  ItemParameterTextFieldCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/24/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol ItemParameterTextFieldTableViewCellDelegate: AnyObject {
    func textEditFinish(_ text: String)
}

class ItemParameterTextFieldTableViewCell: BaseTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: LoginTextField!
    weak var delegate: ItemParameterTextFieldTableViewCellDelegate?
    public var inputText: String {
        return textField.text ?? ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private func configureUI() {
        textField.roundCorners(radius: 25)
        textField.delegate = self
        textField.changeBordorColor = false
    }
    
    func configure(_ title: String, brandName: String?) {
        titleLabel.text = title
        textField.text = brandName
    }
}

//MARK:- TextField delegate
extension ItemParameterTextFieldTableViewCell: UITextFieldDelegate {
    @IBAction func textFieldChanged(_ sender: Any) {
         delegate?.textEditFinish(inputText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

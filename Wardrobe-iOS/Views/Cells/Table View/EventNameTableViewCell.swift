//
//  EventNameTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/29/20.
//

import UIKit

protocol EventNameTableViewCellDelegate: class {
    func addTitle(_ text: String)
}

class EventNameTableViewCell: UITableViewCell {

    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var nameTextField: LoginTextField!
    weak var delegate: EventNameTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        eventLabel.text = "Event name".localize()
        nameTextField.setPlaceHolder(text: "Enter the event name".localize())
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        nameTextField.delegate = self
    }
    
    func configure(_ name: String?) {
        nameTextField.text = name
    }
    
    var name: String? {
        return nameTextField.text
    }
}

//MARK:- TextField delegate
extension EventNameTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.addTitle(name ?? "")
    }
}


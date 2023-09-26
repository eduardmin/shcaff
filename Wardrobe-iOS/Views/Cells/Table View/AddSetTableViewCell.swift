//
//  AddSetTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/12/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol AddSetTableViewCellDelegate: class {
    func addItemAction()
}

class AddSetTableViewCell: BaseTableViewCell {

    @IBOutlet weak var addSetView: UIView!
    weak var delegate: AddSetTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
//MARK:- UI
    func configureUI() {
        addSetView.layer.cornerRadius = 10
        addSetView.layer.borderColor = SCColors.collectionBackgroundColor.cgColor
        addSetView.layer.borderWidth = 2
        addSetView.addShadow(true, 2, 10)
        separatorColor = SCColors.textfieldBorderColor
        addBottomSeperator()
        addSetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addItem)))
    }

    @objc func addItem() {
        delegate?.addItemAction()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

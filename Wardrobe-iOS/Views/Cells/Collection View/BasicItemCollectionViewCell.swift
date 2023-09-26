//
//  BasicItemCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/29/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class BasicItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var checkMarkView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        imageView.layer.cornerRadius = 15
        selectedView.layer.cornerRadius = 20
        checkMarkView.layer.cornerRadius = checkMarkView.bounds.height / 2
    }
    
    func configure(_ itemModel: ItemModel, selected: Bool) {
        titleLabel.text = itemModel.getItemColorAndTypeName()
        if let url = URL(string: itemModel.url ?? "") {
            imageView.af.setImage(withURL: url)
        }
        if selected {
            selectCell()
        } else {
            deselectCell()
        }
    }
    
    func selectCell() {
        selectedView.isHidden = false
        checkMarkView.isHidden = false
    }
    
    func deselectCell() {
        selectedView.isHidden = true
        checkMarkView.isHidden = true
    }
}

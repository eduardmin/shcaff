//
//  InfoPictureTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/7/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol InfoPictureTableViewCellDelegate: class {
    func selectPicture(_ cell: InfoPictureTableViewCell)
    func changeImage()
}

class InfoPictureTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var imageViewContentView: UIView!
    @IBOutlet weak var changeImageButton: UIButton!
    weak var delegate: InfoPictureTableViewCellDelegate?
    override func awakeFromNib() {
        isSeparatorFull = false
        super.awakeFromNib()
        itemImageView.layer.cornerRadius = 10
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap(_:)))
        imageViewContentView.addGestureRecognizer(tapGesture)
    }
    
    //MARK:- Public func
    func configure(info : String, image: UIImage, type: ItemViewModelType, isTopSeparator : Bool = true) {
        infoLabel.text = info
        itemImageView.image = image
        if type == .edit {
            changeImageButton.setTitle("Change".localize(), for: .normal)
        } else {
            changeImageButton.setTitle("Retake".localize(), for: .normal)
        }

        if isTopSeparator {
           addTopSeperator()
        }
    }
}

//MARK:- Button Action
extension InfoPictureTableViewCell {
    @objc private func imageViewDidTap(_ sender: UIImageView) {
        delegate?.selectPicture(self)
    }
    
    @IBAction func changeImageClick(_ sender: Any) {
        delegate?.changeImage()
    }
}

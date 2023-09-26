//
//  AvatarImageView.swift
//  Wardrobe-iOS
//
//  Created by Mariam on 5/30/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

protocol AvatarImageViewDelegate: class {
    func avatarImageView(avatarImageView: AvatarImageView, didTapWith image: UIImage)
}

class AvatarImageView: UIImageView {
    weak var delegate: AvatarImageViewDelegate?
    private let placeholderImage: UIImage = UIImage(named: "avatarDefault")!
    
    //MARK:- Overided functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        //TODO: add notification to listen profile image changes -> profile.image = new image, call updateImage()
    }
        
    @IBInspectable var isSelectable: Bool = true {
        didSet {
            isUserInteractionEnabled = isSelectable
        }
    }
    
    //MARK:- Public functions
    func updateImage(_ image: UIImage? = nil) {
        self.image = image ?? placeholderImage
        if image != nil {
            layoutIfNeeded()
            circleView()
        } else {
            layer.cornerRadius = 0
        }
    }
    
    //MARK:- Private functions
    private func commonInit() {
        isUserInteractionEnabled = isSelectable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap(_:)))
        addGestureRecognizer(tapGesture)
        contentMode = .scaleAspectFill
        updateImage()
        circleView()
    }
    
    @objc private func imageViewDidTap(_ sender: UIImageView) {
        delegate?.avatarImageView(avatarImageView: self, didTapWith: self.image!)
    }
    
}

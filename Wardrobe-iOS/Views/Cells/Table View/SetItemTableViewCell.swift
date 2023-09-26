//
//  SetItemTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/12/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol SetItemTableViewCellDelegate: class {
    func deleteAction(cell: SetItemTableViewCell)
}

class SetItemTableViewCell: UITableViewCell {
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var setImageView: UIImageView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var itemViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemViewTrailingConstraint: NSLayoutConstraint!
    private let margin: CGFloat = 16
    private let deleteViewWidth: CGFloat = 40
    weak var delegate: SetItemTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
//MARK:- UI
    func configureUI() {
        backgroundColor = SCColors.whiteColor
        itemView.layer.cornerRadius = 15
        deleteView.layer.cornerRadius = 15
        setImageView.layer.cornerRadius = setImageView.bounds.height / 2
        itemView.layer.borderColor = SCColors.mainGrayColor.cgColor
        itemView.layer.borderWidth = 0.3
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(_:)))
        deleteView.addGestureRecognizer(tapGesture)
    }

//MARK:- Public Func
    func configure(item : ItemModel) {
        nameLabel.text = item.getItemTypeName()
        setImageView.image = item.image
    }
}

//MARK:- Gesture Action
extension SetItemTableViewCell {
    @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
        let piece = gesture.view!
        var translation = gesture.translation(in: piece.superview)
        guard  gesture.view != nil else {
            return
        }
        
        if gesture.state == .changed {
            if translation.x < 0 {
                translation.x = -deleteViewWidth
            }
            
            if translation.x > 0.0 {
                itemViewLeadingConstraint.constant = margin
                itemViewTrailingConstraint.constant = margin
            } else {
                itemViewLeadingConstraint.constant = translation.x
                itemViewTrailingConstraint.constant = margin - translation.x
            }
            UIView.animate(withDuration: 0.1) {
                self.layoutIfNeeded()
            }
        }
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        itemViewLeadingConstraint.constant = self.margin
        itemViewTrailingConstraint.constant = self.margin
        delegate?.deleteAction(cell: self)
    }
}

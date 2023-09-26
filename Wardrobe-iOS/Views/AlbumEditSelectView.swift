//
//  EditSelectView.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/16/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol AlbumEditSelectViewDelegate: class {
    func deleteAction()
    func editAction()
}

class AlbumEditSelectView: UIView {
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    weak var delegate: AlbumEditSelectViewDelegate?
    var point: CGPoint = CGPoint.zero {
        didSet {
            let inset: CGFloat = 16
            var x = point.x < inset ? inset : point.x
            let maxX = bounds.width - contentView.bounds.width - inset
            if x  > maxX {
                x = maxX
            }
            leadingConstraint.constant = x
            
            var y  = point.y - contentView.bounds.height < inset ? inset : point.y - contentView.bounds.height
            let maxY = bounds.height - contentView.bounds.height - inset
            if y > maxY {
                y = maxY
            }
            topConstraint.constant = y
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    class func instanceFromNib() -> AlbumEditSelectView
    {
        return UINib(nibName: "AlbumEditSelectView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AlbumEditSelectView
    }
    
    private func configureUI() {
        backgroundView.roundCorners(radius: 20)
        deleteButton.circleView()
        editButton.circleView()
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture)))
    }
    
    @objc func tapGesture() {
        removeFromSuperview()
    }
}

//MARK:- Button Action
extension AlbumEditSelectView {
    @IBAction func deleteAction(_ sender: UIButton) {
        delegate?.deleteAction()
    }
    
    @IBAction func editAction(_ sender: Any) {
        delegate?.editAction()
    }
}


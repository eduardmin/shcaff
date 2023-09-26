//
//  ClosetItemCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/21/20.
//

import UIKit

protocol ClosetItemCollectionViewCellDelegate: class {
    func deleteAction(cell: ClosetItemCollectionViewCell)
    func editAction(cell: ClosetItemCollectionViewCell)
}

class ClosetItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    weak var delegate: ClosetItemCollectionViewCellDelegate?
    var longPress: UILongPressGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandle(_:)))
        addGestureRecognizer(longPress!)
    }
    
    func configure(_ image: UIImage) {
        imageView.layer.cornerRadius = 10
        imageView.image = image
    }
    
    func configureWithoutCornerRadius(_ image: UIImage) {
        imageView.image = image
    }
}

//MARK:- ItemSelectViewDelegate
extension ClosetItemCollectionViewCell: ItemSelectViewDelegate {
    func selectButton(type: ItemSelectType) {
        switch type {
        case .edit:
            delegate?.editAction(cell: self)
        case .delete:
            delegate?.deleteAction(cell: self)
        default:
            break
        }
    }
    
    @objc func longPressHandle(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            if let hostView = UIApplication.appDelegate.tabBarController.view {
                let editSelectView = ItemSelectView.instanceFromNib()
                editSelectView.frame = hostView.bounds
                editSelectView.delegate = self
                hostView.addSubview(editSelectView)
                editSelectView.appearOnItem(.item, image: imageView.image ?? UIImage(), hostView, "Edit Item", "Delete Item")
            }
        }
    }
}

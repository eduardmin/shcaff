//
//  ItemSelectView.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/26/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum ItemSelectType {
    case edit
    case delete
    case add
    case calendar
    case share
}

enum SelectViewType {
    case album
    case item
    case event
    case look
}

protocol ItemSelectViewDelegate: AnyObject {
    func selectButton(type: ItemSelectType)
}

class ItemSelectView: UIView {
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelTitleLabel: UILabel!
    @IBOutlet weak var pickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewContener: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var editButtonTop: NSLayoutConstraint!
    @IBOutlet weak var editButtonHeigth: NSLayoutConstraint!
    weak var delegate: ItemSelectViewDelegate?
    private let leftRightMargin: CGFloat = 16
    private var type: SelectViewType = .album
    var selectedView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        cancelTitleLabel.text = "Close".localize()
        cancelButton.layer.cornerRadius = 25
        pickerView.layer.cornerRadius = 30
        pickerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageViewContener.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }
    
    @objc func tapAction() {
        disappear()
    }
    
    class func instanceFromNib() -> ItemSelectView {
        return UINib(nibName: "ItemSelectView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ItemSelectView
    }
    
    public func appearOnView(_ type: SelectViewType, _ view: UIView, _ editText: String?, _ deleteText: String, _ selectedView: UIView) {
        self.type = type
        self.selectedView = selectedView
        if editText != nil {
            pickerHeightConstraint.constant = 190
        } else {
            editButtonTop.constant = 0
            editButtonHeigth.constant = 0
            pickerHeightConstraint.constant = 150
            editButton.isHidden = true
        }
        imageView.isHidden = true
        shareButton.isHidden = true
        editButton.setTitle(editText?.localize(), for: .normal)
        deleteButton.setTitle(deleteText.localize(), for: .normal)
        var rect = selectedView.frame
        rect.origin.y = ((UIScreen.main.bounds.height - pickerHeightConstraint.constant)  - selectedView.frame.height) / 2
        selectedView.frame = rect
        addSubview(selectedView)
        view.layoutIfNeeded()
        pickerBottomConstraint?.constant = -pickerHeightConstraint.constant
        self.pickerBottomConstraint?.constant = 0
        selectedView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
            selectedView.alpha = 1
            self.alpha = 1
            view.layoutIfNeeded()
            self.bringSubviewToFront(self.pickerView)
        })
    }
    
    public func appearOnLook(_ type: SelectViewType, _ look: LookModelSuggestion, image: UIImage ,_ view: UIView, _ first: String, _ second: String, _ third: String) {
        self.type = type
        pickerHeightConstraint.constant = 190
        imageView.image = image
        imageView.layer.cornerRadius = 30
        imageViewHeight.constant = (view.frame.width - 2 * leftRightMargin) * look.multipleHeight
        editButton.setTitle(first.localize(), for: .normal)
        deleteButton.setTitle(second.localize(), for: .normal)
        shareButton.setTitle(third.localize(), for: .normal)
        shareButton.isHidden = true
        view.layoutIfNeeded()
        pickerBottomConstraint?.constant = -pickerHeightConstraint.constant
        self.pickerBottomConstraint?.constant = 0
        self.imageView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
            self.imageView.alpha = 1
            self.alpha = 1
            view.layoutIfNeeded()
            self.bringSubviewToFront(self.pickerView)
        })
    }
    
    public func appearOnItem(_ type: SelectViewType, image: UIImage, _ view: UIView, _ first: String, _ second: String) {
        self.type = type
        pickerHeightConstraint.constant = 190
        imageView.layer.cornerRadius = 30
        shareButton.isHidden = true
        imageViewHeight.constant = (view.frame.width - 2 * leftRightMargin)
        editButton.setTitle(first.localize(), for: .normal)
        deleteButton.setTitle(second.localize(), for: .normal)
        view.layoutIfNeeded()
        pickerBottomConstraint?.constant = -pickerHeightConstraint.constant
        self.pickerBottomConstraint?.constant = 0
        self.imageView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
            self.imageView.alpha = 1
            self.imageView.image = image
            self.alpha = 1
            view.layoutIfNeeded()
            self.bringSubviewToFront(self.pickerView)
        })
    }
    
    public func disappear() {
        selectedView?.removeFromSuperview()
        pickerBottomConstraint?.constant = 0
        imageView.image = nil
        superview?.layoutIfNeeded()
        pickerBottomConstraint?.constant = -pickerHeightConstraint.constant
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.alpha = 0
            self.superview?.layoutIfNeeded()
        },  completion: { (done) -> Void in  self.removeFromSuperview()})
    }
 
    @IBAction func cancelAction(_ sender: UIButton) {
        disappear()
    }
    
    @IBAction func editAction(_ sender: Any) {
        if type == .look {
            delegate?.selectButton(type: .add)
        } else {
            delegate?.selectButton(type: .edit)
        }
        disappear()
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        if type == .look {
            delegate?.selectButton(type: .calendar)
        } else {
            delegate?.selectButton(type: .delete)
        }
        disappear()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        if type == .look {
            delegate?.selectButton(type: .share)
        }
    }
}

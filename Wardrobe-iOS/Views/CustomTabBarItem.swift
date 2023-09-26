//
//  CustomTabBarItemA.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/30/20.
//

import UIKit

protocol CustomTabBarItemDelegate : class {
    func handleTabBarClick(index : TabBarItemIndex)
}

class CustomTabBarItem: UIView {
    var delegate : CustomTabBarItemDelegate?
    var index : TabBarItemIndex!
    var itemModel : TabBarItemModel!
    private let leftRigthMargin : CGFloat = 20
    private let imageViewTop : CGFloat = 15
    private let imageViewHeight : CGFloat = 24
    private let titleLabelHeight : CGFloat = 12
    private let titleLabelTop : CGFloat = 20
    private let titleLabelLeftMargin : CGFloat = 5

 
    var selectedViewWidth : CGFloat!
    lazy var button : UIButton = {
        var button = UIButton(frame: bounds)
        button.addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
        return button
    }()
    
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 2 * leftRigthMargin, y: imageViewTop, width: imageViewHeight, height: imageViewHeight))
        return imageView
    }()
    
    lazy var titleLabel : UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: imageView.frame.maxX + titleLabelLeftMargin, y: titleLabelTop, width: 0, height: titleLabelHeight))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        titleLabel.textColor = SCColors.blackColor
        return titleLabel
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        addSubview(imageView)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModel(itemModel : TabBarItemModel) {
        self.itemModel = itemModel
        self.titleLabel.text = itemModel.title.localize()
        self.imageView.image = UIImage(named: itemModel.image)
        titleLabel.sizeToFit()
        selectedViewWidth = imageView.frame.width + titleLabel.frame.width + 2 * leftRigthMargin + titleLabelLeftMargin
    }
    
    func select() {
        titleLabel.text = itemModel.title.localize()
        imageView.image = UIImage(named: itemModel.selectedImage)
    }
    
    func deselect() {
        titleLabel.text = nil
        imageView.image = UIImage(named: itemModel.image)
    }
    
    func setFrame(frame : CGRect) {
        self.frame = frame
        button.frame = bounds
        if index == .home {
            imageView.frame = CGRect(x: 2 * leftRigthMargin, y: imageViewTop, width: imageViewHeight, height: imageViewHeight)
            return
        }
        
        if titleLabel.text == nil {
            if index == .calendar {
                imageView.frame = CGRect(x: frame.width - 2 * leftRigthMargin - imageViewHeight, y: imageViewTop, width: imageViewHeight, height: imageViewHeight)
            }
            else {
                imageView.frame = CGRect(x: frame.width / 2 - imageViewHeight / 2, y: imageViewTop, width: imageViewHeight, height: imageViewHeight)
            }
        }
        else {
            imageView.frame = CGRect(x: leftRigthMargin, y: imageViewTop, width: imageViewHeight, height: imageViewHeight)
            titleLabel.frame = CGRect(x: imageView.frame.maxX + titleLabelLeftMargin, y: titleLabelTop, width: titleLabel.frame.width, height: titleLabelHeight)
        }
    }
    
    //MARK:- Button Action
    @objc func action(_ sender : Any) {
        delegate?.handleTabBarClick(index: index)
    }
}

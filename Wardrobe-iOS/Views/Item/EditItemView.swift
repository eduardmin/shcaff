//
//  EditItemView.swift
//  Wardrobe-iOS
//
//  Created by Mariam Khachatryan on 3/28/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class EditItemView: UIView {
    //MARK:- Properties
    private var shadowImageView: UIImageView = UIImageView()
    private var itemImageView: ItemImageView!
}

//MARK:- Public functions
extension EditItemView {
    func set(image: String) {
        createShadowImage(image: image)
        createItemImageView(image: image)
    }
}

//MARK:- Private functions
extension EditItemView {
    private func createShadowImage(image: String) {
        shadowImageView.frame = bounds.with(inset: 30)
        shadowImageView.image = UIImage(named: image)
        shadowImageView.contentMode = ItemImageView.defaultContentMode
        shadowImageView.layer.shadowColor = UIColor.gray.cgColor
        shadowImageView.layer.shadowOpacity = 0.5
        shadowImageView.layer.shadowOffset = .zero
        shadowImageView.layer.shadowRadius = 10
        self.addSubview(shadowImageView)
    }
    
    private func createItemImageView(image: String) {
        itemImageView = ItemImageView(frame: bounds.with(inset: 30))
        itemImageView.set(image: image)
        self.addSubview(itemImageView)
    }
    
    private func setupConstraints() {
        itemImageView.addConstraintsToSuperView()
        shadowImageView.addConstraintsToSuperView()
    }
}

//MARK:- ItemViewDelegate
extension EditItemView: ItemViewDelegate {
    func setMainColor(_ color: UIColor) {
        itemImageView.setMainColor(color)
    }
    
    func setLineColor(_ color: UIColor) {
        itemImageView.setLineColor(color)
    }
    
    func setLineWidth(_ width: CGFloat) {
        itemImageView.setLineWidth(width)
    }
    
    func setLineSpacing(_ spacing: CGFloat) {
        itemImageView.setLineSpacing(spacing)
    }
    
    func setPattern(_ patternType: PatternType) {
        itemImageView.setPattern(patternType)
    }
}

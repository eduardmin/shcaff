//
//  ItemAddInToSetAlertViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/25/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class ItemAddInToSetAlertViewController: BaseAlertViewController {

    let imageView = UIImageView()
    public var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    
    override func viewDidLoad() {
        topInset = 0
        super.viewDidLoad()
        createViews()
        setupConstraints()
    }
    
    private func createViews() {
        imageView.image = image
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        for subview in self.contentView.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
}

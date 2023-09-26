//
//  ImageAlertViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/7/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class ImageAlertViewController: BaseAlertViewController {

    let imageView = UIImageView()
    public var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createImageView()
        setupConstraints()
    }
    
    private func createImageView() {
        imageView.image = image
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        for subview in self.contentView.subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
    }
}

//
//  EmptyView.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/5/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class EmptyView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    class func instanceFromNib() -> EmptyView {
        return UINib(nibName: "EmptyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! EmptyView
    }
    
    func configure(title: String, description: String) {
        titleLabel.text = title.localize()
        descriptionLabel.text = description.localize()
    }
}

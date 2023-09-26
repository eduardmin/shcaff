//
//  LoadingCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/14/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class LoadingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        indicatorView.startAnimating()
    }
    
    func startAnimating() {
        indicatorView.startAnimating()
    }
    
    func stopingAnimating() {
        indicatorView.stopAnimating()
    }

}

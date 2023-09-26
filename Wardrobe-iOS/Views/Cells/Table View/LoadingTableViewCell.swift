//
//  LoadingTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/27/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
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

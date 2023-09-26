//
//  CreateLookCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/1/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class CreateLookCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.backgroundColor = SCColors.mainColor
        mainView.layer.cornerRadius = 25
        mainView.bringSubviewToFront(title)
        title.text = "Create Look".localize()
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged(notification:)), name: NSNotification.Name(rawValue: NotificationName.changeLanguage), object: nil)
    }
    
    @objc func languageChanged(notification:Notification)  {
        title.text = "Create Look".localize()
    }
}

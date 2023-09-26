//
//  MonthReusableView.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/1/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit
import JTAppleCalendar

class MonthReusableView: JTACMonthReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureMonth(_ title: String) {
        titleLabel.text = title
    }
    
}

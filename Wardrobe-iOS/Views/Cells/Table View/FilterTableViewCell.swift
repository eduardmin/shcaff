//
//  FilterTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/22/20.
//

import UIKit

class FilterTableViewCell: BaseTableViewCell {

    @IBOutlet weak var filterNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }
    
    func configure(_ filterName: String, _ isFirst: Bool, _ isLast: Bool)  {
        filterNameLabel.text = filterName
        if isFirst {
            addTopSeperator()
        } else if isLast {
            addBottomSeperator()
        }
    }
    
}

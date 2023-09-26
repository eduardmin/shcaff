//
//  InfoTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/6/20.
//

import UIKit

class InfoTableViewCell: BaseTableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    override func awakeFromNib() {
        isSeparatorFull = false
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK:- Public func 
    func configure(info: String, isTopSeparator: Bool = false) {
        accessoryType = .disclosureIndicator
        infoLabel.text = info
        if isTopSeparator {
             addTopAndBottomSeperator()
        }
    }
    
    func configure(info: String, isFirstCell: Bool, isLastCell: Bool) {
        accessoryType = .disclosureIndicator
        infoLabel.text = info
        infoLabel.font = UIFont.systemFont(ofSize: 17)
        if isFirstCell {
            addTopSeperator()
        } else if isLastCell {
            addBottomSeperator()
        }
    }
    
    func configureAllSeperator(info: String) {
        accessoryType = .disclosureIndicator
        infoLabel.text = info.localize()
        infoLabel.font = UIFont.systemFont(ofSize: 17)
        addTopAndBottomSeperator()
    }
}

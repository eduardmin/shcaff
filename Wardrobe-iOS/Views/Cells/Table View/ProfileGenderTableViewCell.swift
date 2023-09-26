//
//  ProfileGenderTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/14/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class ProfileGenderTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var genderButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        deactiveGenderButton()
    }
    
    private func deactiveGenderButton() {
        genderButton.layer.cornerRadius = genderButton.bounds.height / 2
        genderButton.layer.borderWidth = 1
        genderButton.layer.borderColor = SCColors.textfieldBorderColor.cgColor
        genderButton.backgroundColor = SCColors.whiteColor
    }
    
    func configure(title: String?, type: ProfileType, select: Bool) {
        switch type {
        case .male:
            genderButton.setTitle("Male".localize(), for: .normal)
        case .female:
            genderButton.setTitle("Female".localize(), for: .normal)
        case .other:
            genderButton.setTitle("Other".localize(), for: .normal)
        case .otherFemale:
            genderButton.setTitle("Male".localize(), for: .normal)
        case .otherMale:
            genderButton.setTitle("Female".localize(), for: .normal)
        case .both:
            genderButton.setTitle("Both".localize(), for: .normal)
        default:
            break
        }
        if let title = title {
            titleLabel.text = title
        } else {
            titleLabel.isHidden = true
            titleHeightConstraint.constant = 0
        }
        if select {
            genderButton.setMode(.background, color:SCColors.whiteColor, backgroundColor: SCColors.mainColor)
        } else {
            deactiveGenderButton()
        }
    }

    @IBAction func genderAction(_ sender: Any) {
        
    }
}

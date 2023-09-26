//
//  ProfileBirthDayTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/14/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit
protocol ProfileBirthDayTableViewCellDelegate: class {
    func setInput(date: Date?, type: ProfileType)
}

class ProfileBirthDayTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var BirthDayButton: UIButton!
    var popapSuperView: UIView?
    weak var delegate: ProfileBirthDayTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        BirthDayButton.layer.cornerRadius = BirthDayButton.bounds.height / 2
        BirthDayButton.layer.borderWidth = 1
        BirthDayButton.layer.borderColor = SCColors.textfieldBorderColor.cgColor
        BirthDayButton.setTitle("dd / mm / yyyy".localize(), for: .normal)
    }

    func configure(title: String, input: Date?, type: ProfileType, popapSuperView: UIView) {
        self.popapSuperView = popapSuperView
        titleLabel.text = title.localize()
        if let input = input {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
            dateFormatter.dateFormat = "dd/MM/yyyy"
            BirthDayButton.setTitle(dateFormatter.string(from: input), for: .normal)
        } else {
            BirthDayButton.setTitle("dd / mm / yyyy".localize(), for: .normal)
        }
       
    }
    
    @IBAction func BirthDayAction(_ sender: Any) {
        let selectionView = DatePickerView.instanceFromNib()
        if let hostView = popapSuperView {
            selectionView.delegate = self
            selectionView.frame = hostView.bounds
            hostView.addSubview(selectionView)
            selectionView.appearOnView(hostView)
        }
    }
    
}

//MARK:- DatePickerViewDelegate
extension ProfileBirthDayTableViewCell: DatePickerViewDelegate {
    func setDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
        dateFormatter.dateFormat = "dd/MM/yyyy"
        BirthDayButton.setTitle(dateFormatter.string(from: date), for: .normal)
        BirthDayButton.setTitleColor(SCColors.titleColor, for: .normal)
        BirthDayButton.layer.borderColor = SCColors.titleColor.cgColor
        delegate?.setInput(date: date, type: .birthday)
    }
}

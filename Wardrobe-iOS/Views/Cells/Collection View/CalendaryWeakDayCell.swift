//
//  CalendaryWeakDayCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/10/20.
//

import UIKit
import JTAppleCalendar

class CalendaryWeakDayCell: JTACDayCell {
    @IBOutlet weak var dayTitleLabel: UILabel!
    @IBOutlet weak var weakTitleLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    private let dotHeight: CGFloat = 4
    let padding : CGFloat = 3
    var textColor: UIColor = SCColors.calendarDayColor
    lazy var dotStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = padding
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        return stackView
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        addConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayTitleLabel.text = nil
    }
    
    // MARK:- UI
    private func addConstraints() {
        addConstraints([NSLayoutConstraint(item: dotStackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                        NSLayoutConstraint(item: dotStackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -8),
                        NSLayoutConstraint(item: dotStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 6)
        ])
    }
    
    func configure(_ text: String, _ weakText: String, _ isWeakend: Bool, _ count: Int, isSelected: Bool) {
        dayTitleLabel.text = text
        weakTitleLabel.text = weakText
        weakTitleLabel.textColor = SCColors.calendarWeak
        configureDot(count, isSelected: isSelected)
        if isWeakend {
            textColor = SCColors.calendarDayColor.withAlphaComponent(0.5)
        } else {
            textColor = SCColors.calendarDayColor
        }
        
        if isSelected {
            select()
        } else {
            deselect()
        }
    }
    
    
    func select() {
        layoutIfNeeded()
        selectedView.isHidden = false
        selectedView.backgroundColor = SCColors.mainColor
        selectedView.layer.cornerRadius = selectedView.bounds.width / 2
        dayTitleLabel.textColor = SCColors.whiteColor
        weakTitleLabel.textColor = SCColors.whiteColor
        dotStackView.arrangedSubviews.forEach { (view) in
            view.backgroundColor = SCColors.whiteColor
        }
    }
    
    func deselect() {
        selectedView.isHidden = true
        selectedView.backgroundColor = UIColor.clear
        dayTitleLabel.textColor = textColor
        weakTitleLabel.textColor = SCColors.calendarWeak
        dotStackView.arrangedSubviews.forEach { (view) in
            view.backgroundColor = SCColors.mainColor
        }
    }
    
    
    private func configureDot(_ count: Int, isSelected: Bool) {
        if count == 0 {
            deleteAll()
            return
        }
        var _count : Int = count
        if _count > 3 {
            _count = 3
        }
        deleteAll()
        for i in 0..<_count {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: dotHeight).isActive = true
            view.widthAnchor.constraint(equalToConstant: dotHeight).isActive = true
            
            view.layer.cornerRadius = dotHeight / 2
            if isSelected {
                view.backgroundColor = SCColors.whiteColor
            } else {
                view.backgroundColor = SCColors.mainColor
            }
            dotStackView.insertArrangedSubview(view, at: i)
        }
        if isSelected {
            select()
        } else {
            deselect()
        }
    }
    
    private func deleteAll() {
        for view in dotStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}

//
//  CalendaryDayCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/1/20.
//

import UIKit
import JTAppleCalendar

class CalendaryDayCell: JTACDayCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectedView: UIView!
    private let dotHeight: CGFloat = 4
    let padding : CGFloat = 3
    lazy var dotStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = padding
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        return stackView
    }()
    var textColor: UIColor = SCColors.calendarDayColor
    override func awakeFromNib() {
        super.awakeFromNib()
        addConstraints()
    }
    
    // MARK:- UI
    private func addConstraints() {
        addConstraints([NSLayoutConstraint(item: dotStackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dotStackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -12),
            NSLayoutConstraint(item: dotStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 6)
        ])
    }
    
    func configure(_ text: String, _ isToday: Bool,  _ isWeakend: Bool , _ count: Int) {
        label.text = text
        configureDot(count)
        if isWeakend {
            textColor = SCColors.calendarDayColor.withAlphaComponent(0.5)
        } else {
            textColor = SCColors.calendarDayColor
        }
        if isToday {
            select()
        } else {
            deselect()
        }
    }
    
    func select() {
        layoutIfNeeded()
        selectedView.backgroundColor = SCColors.secondaryGray
        selectedView.layer.cornerRadius = selectedView.bounds.width / 2
        label.textColor = textColor
    }
    
    func deselect() {
        selectedView.backgroundColor = UIColor.clear
        label.textColor = textColor
    }
    
    
    private func configureDot(_ count: Int) {
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
            view.backgroundColor = SCColors.mainColor
            dotStackView.insertArrangedSubview(view, at: i)
        }
    }
    
    private func deleteAll() {
        for view in dotStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}

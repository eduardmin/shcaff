//
//  ItemParamTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/6/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

enum ValueType {
    case Text
    case Color
    case Image
}

class ItemParamTableViewCell: BaseTableViewCell {

    //MARK:- Outlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var valueLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var valueImageView: UIImageView!
    @IBOutlet weak var valueStackView: UIStackView!
    
    //MARK:- Overided functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        valueStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    //MARK:- Public functions
    func set(name: String? = "",  model: ItemViewParameterModel) {
        var count = model.values.count
        var labelCount = 0
        if model.values.count > 3 {
            count = 3
            labelCount = model.values.count - 3
        }
        
        if labelCount > 0 {
            setValue("+\(labelCount)", type: .Text, index: 0)
        }
        
        for i in 0..<count {
            nameLabel.text = name
            var type: ValueType
            switch model.type {
            case .color:
                type = .Color
            case .print:
                type = .Image
            default:
                type = .Text
            }
            let value = model.values[i]
            setValue(value, type: type, index: i)
        }
    }
    
    //MARK:- Private functions
    private func setValue(_ value: String, type: ValueType, index: Int) {
        switch type {
        case .Text:
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = SCColors.titleColor
            label.text = value
            valueStackView.insertArrangedSubview(label, at: index)
        case .Color:
            let colorView = UIView()
            let heigth: CGFloat = 25
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.widthAnchor.constraint(equalToConstant: heigth).isActive = true
            colorView.heightAnchor.constraint(equalToConstant: heigth).isActive = true
            colorView.layer.cornerRadius = heigth / 2
            colorView.backgroundColor = UIColor(hexString: value)
            colorView.layer.masksToBounds = true
            valueStackView.insertArrangedSubview(colorView, at: index)
  
        case .Image:
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
            imageView.image = UIImage(named: value)
            imageView.contentMode = .scaleAspectFit
            valueStackView.addArrangedSubview(imageView)
        }
    }
}

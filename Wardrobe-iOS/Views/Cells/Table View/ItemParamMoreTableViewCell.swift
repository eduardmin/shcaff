//
//  ItemParamMoreTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/23/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class ItemParamMoreTableViewCell: BaseTableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var paintImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var labelLeadingConstaint: NSLayoutConstraint!
    var parameterModel: BaseParameterModel?
    var type: ItemParametersType?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        topSeparatorView.removeFromSuperview()
        checkMark.isHidden = true
    }

    private func configureUI() {
        colorView.layer.cornerRadius = 20
        checkMark.isHidden = true
    }
    
    func configureCell(_ parameterModel: BaseParameterModel, _ type: ItemParametersType, selected: Bool, isFirstCell: Bool, isLastCell: Bool) {
        self.parameterModel = parameterModel
        titleLabel.text = parameterModel.name ?? ""
        switch type {
        case .color:
            let color = UIColor(hexString: (parameterModel as? ColorParameterModel)?.code ?? "")
            colorView.backgroundColor = color
            paintImageView.isHidden = true
        case .print:
            let image = UIImage(named: parameterModel.name ?? "")
            paintImageView?.image = image
            colorView.isHidden = true
        default:
            paintImageView.isHidden = true
            colorView.isHidden = true
            labelLeadingConstaint.constant = 26
        }
        
        if selected {
            select()
        } else {
            deselect()
        }
        
        if isFirstCell {
            addTopSeperator()
        } else if isLastCell {
            addBottomSeperator()
        }
    }
    
    func configureCell(_ title: String, isFirstCell: Bool, isLastCell: Bool, selected: Bool = false) {
        titleLabel.text = title
        paintImageView.isHidden = true
        colorView.isHidden = true
        labelLeadingConstaint.constant = 26
        if isFirstCell {
            addTopSeperator()
        } else if isLastCell {
            addBottomSeperator()
        }
        
        if selected {
            select()
        } else {
            deselect()
        }
    }
}

//MARK:- CellSelectionProtocol
extension ItemParamMoreTableViewCell: CellSelectionProtocol {
    func select() {
        checkMark.isHidden = false
    }
    
    func deselect() {
        checkMark.isHidden = true
    }
}

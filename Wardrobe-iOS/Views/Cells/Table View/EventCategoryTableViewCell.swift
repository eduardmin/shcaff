//
//  EventCategoryTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/29/20.
//

import UIKit

protocol EventCategoryTableViewCellDelegate: class {
    func selectCategory(_ id: Int64)
}

class EventCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var eventCategoryLabel: UILabel!
    @IBOutlet weak var universityButton: UIButton!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var partyButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    private var buttons = [UIButton]()
    private var selectedType: Int?
    private var eventTypes: [EventTypeParameterModel]?
    weak var delegate: EventCategoryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(eventTypes: [EventTypeParameterModel], selectedId: Int?) {
        self.eventTypes = eventTypes
        selectedType = selectedId
        configureUI()
    }
    
    private func configureUI() {
        buttons = [universityButton, workButton, partyButton, otherButton]
        eventCategoryLabel.text = "Event category".localize()
        for i in 0..<buttons.count{
            let model = eventTypes?[i]
            let button = buttons[i]
            button.tag = Int(model?.id ?? 0)
            button.setTitle(model?.name, for: .normal)
            setButtonColor(button)
            button.addTarget(self, action: #selector(selectAction(_:)), for: .touchUpInside)
        }
    }
    
    private func setButtonColor(_ button: UIButton) {
        let type = button.tag
        let model = eventTypes?.filter({$0.id == type}).first
        let color = UIColor(hexString: model?.color ?? "")
        changeButtonColor(button, color, selectedType == type)
    }
    
    private func changeButtonColor(_ button: UIButton, _ color: UIColor, _ isSelected: Bool) {
        button.layer.cornerRadius = 25
        if isSelected {
            button.backgroundColor = color
            button.setTitleColor(SCColors.whiteColor, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        } else {
            button.backgroundColor = SCColors.whiteColor
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.layer.borderColor = color.cgColor
            button.layer.borderWidth = 1
            button.setTitleColor(color, for: .normal)
        }
    }
}

//MARK:- Button Action
extension EventCategoryTableViewCell {
    @objc func selectAction(_ sender: UIButton) {
        selectedType = sender.tag
        delegate?.selectCategory(Int64(selectedType ?? 0))
        buttons.forEach { (button) in
            setButtonColor((button))
        }
    }
}



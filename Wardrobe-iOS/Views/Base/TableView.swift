//
//  BaseTableViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/6/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

@IBDesignable
class TableView: UITableView {
    
    //MARK:- Private properties
    private lazy var noResultLabel: UILabel = {
        let label = UILabel()
        label.text = noResultText
        label.textColor = .lightGray
        return label
    }()
    
    //MARK:- Public Properties
    @IBInspectable var noResultText: String = "No Results" {
        didSet {
            noResultLabel.text = noResultText
        }
    }
    
    @IBInspectable var showNoResultLabel: Bool = true {
        didSet {
            noResultLabel.isHidden = !showNoResultLabel
        }
    }
    
    //MARK:- Overided functions
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func reloadData() {
        super.reloadData()
        if showNoResultLabel {
            noResultLabel.isHidden = !isEmpty
        }
    }
    
    //MARK:- Private functions
    private func commonInit() {
        addSubview(noResultLabel)
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        noResultLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private var isEmpty : Bool {
        for section in 0..<numberOfSections {
            if numberOfRows(inSection: section) > 0 {
                return false
            }
        }
        return true
    }
}

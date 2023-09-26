//
//  BaseTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/6/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    //MARK:- Public property
    let bottomSeparatorView = UIView()
    let topSeparatorView = UIView()
    var isSeparatorFull : Bool = true
    var separatorColor = SCColors.separatorColor
    
    //MARK:- Overided functions
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK:- Private functions
    private func setUp() {
        backgroundColor = SCColors.whiteColor
        addSeparatorView()
    }

    private func addSeparatorView() {
        bottomSeparatorView.removeFromSuperview()
        bottomSeparatorView.backgroundColor = separatorColor
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomSeparatorView)
        
        bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        if isSeparatorFull {
            bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        } else {
            bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        }
        bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
}

//MARK:- Public Func
extension BaseTableViewCell {
    func addTopAndBottomSeperator() {
        bottomSeparatorView.removeFromSuperview()
        topSeparatorView.removeFromSuperview()
        bottomSeparatorView.backgroundColor = separatorColor
        topSeparatorView.backgroundColor = separatorColor
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomSeparatorView)
        addSubview(topSeparatorView)
        bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    func addTopSeperator() {
        topSeparatorView.removeFromSuperview()
        topSeparatorView.backgroundColor = separatorColor
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topSeparatorView)
        topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topSeparatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    func addBottomSeperator() {
        bottomSeparatorView.removeFromSuperview()
        bottomSeparatorView.backgroundColor = separatorColor
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomSeparatorView)
        bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
}

//
//  UITableViewExtension.swift
//  Wardrobe-iOS
//
//  Created by Mariam on 6/7/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func register(cell: UITableViewCell.Type) {
        let identifier = String(describing: cell)
        let nib = UINib(nibName: identifier, bundle: nil)
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cell: UITableViewCell.Type) -> T {
        let identifier = String(describing: cell)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}

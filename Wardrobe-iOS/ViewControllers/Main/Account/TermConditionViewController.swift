//
//  TermConditionViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/13/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class TermConditionViewController: BaseNavigationViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    //MARK:- UI
    func configureUI() {
        setNavigationView(type: .defaultWithBack, title: "Terms & Conditions".localize(), additionalTopMargin: 16)
    }
}

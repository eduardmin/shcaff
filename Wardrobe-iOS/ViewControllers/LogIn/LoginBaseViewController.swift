//
//  LoginBaseViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/29/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class LoginBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

//MARK:- TextField delegate
extension LoginBaseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}

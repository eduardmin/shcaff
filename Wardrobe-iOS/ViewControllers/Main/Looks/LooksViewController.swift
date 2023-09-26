//
//  LooksViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/26/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class LooksViewController: UIViewController {
    
    //MARK:- Properties
    var collectionView: LookCollectionView!

    //MARK:- Overided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    //MARK:- Private functions
    private func configureCollectionView() {
        collectionView = LookCollectionView()
        collectionView.presentViewController = self
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addConstraintsToSuperView(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}

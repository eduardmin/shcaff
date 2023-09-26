//
//  ClosetViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/21/20.
//

import UIKit

class ClosetViewController: SCTabPageViewController {
    lazy var plusView: PlusView = {
        let plusView = PlusView(true)
        return plusView
    }()
    
    func addPlusView() {
        let host = UIApplication.appDelegate.tabBarController.view
        plusView.fixInView(host)
        host!.addSubview(plusView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationView(type: .defaultType, attibuteTitle: getNavigationTitle("Your".localize(), "Closet".localize()))
        let cloths = ClothesViewController()
        cloths.plusView = plusView
        let albums = AlbumsViewController()
        albums.plusView = plusView
        setTabPages([TabPage(tabTitle: "Clothes".localize(), viewController: cloths),
                     TabPage(tabTitle: "Albums".localize(), viewController: albums)], type: .cloth)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        plusView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if plusView.superview == nil {
            addPlusView()
        }
    }
    
    deinit {
        print("")
    }
}

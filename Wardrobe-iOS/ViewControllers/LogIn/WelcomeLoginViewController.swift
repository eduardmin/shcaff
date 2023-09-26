//
//  WelcomeLoginViewCViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/11/20.
//  Copyright © 2020 Mariam Khachatryan. All rights reserved.
//

import UIKit

class WelcomeLoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dotView: DotView!
    private var timer = Timer()
    private var welcomeTitles = [NSAttributedString]()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        configureAttributes()
        loginButton.setTitle("Log In".localize(), for: .normal)
        createAccountButton.setTitle("Sign Up".localize(), for: .normal)
        createAccountButton.setMode(.background, color: SCColors.whiteColor, shadow: true)
        loginButton.setMode(.background, color: SCColors.titleColor, backgroundColor: SCColors.whiteColor, shadow: true)
        dotView.configure(numberOfDots: welcomeTitles.count)
        selectedIndex()
        collectionView.register(cell: WelcomeCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        addTimer()
    }
    
    private func configureAttributes() {
        let suggestionAttributes = NSMutableAttributedString(string: "Get Suggestions".localize() + "\n", attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .bold), .foregroundColor: SCColors.whiteColor])
        suggestionAttributes.append(NSAttributedString(string: "What to Wear".localize() + "\n", attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .light), .foregroundColor: SCColors.whiteColor]))
        suggestionAttributes.append(NSAttributedString(string: "Everyday".localize(), attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .bold), .foregroundColor: SCColors.whiteColor]))
        
        let manageAttributes = NSMutableAttributedString(string: "Manage Your".localize() + "\n", attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .bold), .foregroundColor: SCColors.whiteColor])
        manageAttributes.append(NSAttributedString(string: "Wardrobe".localize() + "\n".localize(), attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .light), .foregroundColor: SCColors.whiteColor]))
        manageAttributes.append(NSAttributedString(string: "And Plan Outfits".localize(), attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .bold), .foregroundColor: SCColors.whiteColor]))
        
        let inOnePlace = NSMutableAttributedString(string: "All Your".localize() + "\n", attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .bold), .foregroundColor: SCColors.whiteColor])
        inOnePlace.append(NSAttributedString(string: "Clothes In One".localize() + "\n", attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .light), .foregroundColor: SCColors.whiteColor]))
        inOnePlace.append(NSAttributedString(string: "Place".localize(), attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .bold), .foregroundColor: SCColors.whiteColor]))
        
        welcomeTitles.append(inOnePlace)
        welcomeTitles.append(suggestionAttributes)
        welcomeTitles.append(manageAttributes)
    }
    
    private func addTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    @objc private func timerAction() {
        if let visibleIndexPath = collectionView.indexPathsForVisibleItems.first {
            var indexPath: IndexPath
            if visibleIndexPath.row == welcomeTitles.count - 1 {
                indexPath = IndexPath(row: 0, section: visibleIndexPath.section)
            } else {
                indexPath = IndexPath(row: visibleIndexPath.row + 1, section: visibleIndexPath.section)
            }
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        }
    }
    
    deinit {
        timer.invalidate()
    }
}

//MARK:- Button Action
extension WelcomeLoginViewController {
    @IBAction func loginClick(_ sender: Any) {
        let loginAlertViewController = LoginAlertViewController.initFromStoryboard(storyBoardName: StoryboardName.login) as LoginAlertViewController
        loginAlertViewController.modalPresentationStyle = .overFullScreen
        loginAlertViewController.type = .signIn
        self.present(loginAlertViewController, animated: true)
    }
    
    @IBAction func createAccountClick(_ sender: Any) {
        let loginAlertViewController = LoginAlertViewController.initFromStoryboard(storyBoardName: StoryboardName.login) as LoginAlertViewController
        loginAlertViewController.modalPresentationStyle = .overFullScreen
        loginAlertViewController.type = .signUp
        self.present(loginAlertViewController, animated: true)
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension WelcomeLoginViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return welcomeTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: WelcomeCollectionViewCell = collectionView.dequeueReusableCell(WelcomeCollectionViewCell.self, indexPath: indexPath)
        cell.configure(title: welcomeTitles[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 10, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addTimer()
        selectedIndex()
    }
    
    func selectedIndex() {
        guard let cell = collectionView.visibleCells.last else {
            dotView.selectIndex(index: 0)
            return
        }
        let indexPath = collectionView.indexPath(for: cell)
        let index = indexPath!.row
        dotView.selectIndex(index: index)
    }

}

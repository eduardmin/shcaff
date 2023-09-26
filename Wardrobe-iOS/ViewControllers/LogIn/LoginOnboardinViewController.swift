//
//  LoginOnboardinViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/10/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class LoginOnboardinViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var dotView: DotView!
    private let viewModel = OnBoardingViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        containerView.layer.cornerRadius = 30
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.addShadow(false, 5, 10)
        continueButton.setMode(.background, color: SCColors.whiteColor, shadow: true)
        continueButton.setTitle("Next".localize(), for: .normal)
        dotView.configure(numberOfDots: viewModel.onBoardingModels.count, dotBackroundColor: SCColors.dotColor, dotSelectedColor: SCColors.titleColor, alignment: .leading)
        updateContainer(index: 0)
        collectionView.updateInsets(horizontal: 0, vertical: 0, interItem: 0, interRow: 0, estimatedSize: nil)
        collectionView.register(cell: OnBoardCollectionViewCell.self)
    }
    
    func updateContainer(index: Int) {
        dotView.selectIndex(index: index)
        let model = viewModel.onBoardingModels[index]
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        if index == viewModel.onBoardingModels.count - 1 {
            continueButton.setTitle("Got it".localize(), for: .normal)
        } else {
            continueButton.setTitle("Next".localize(), for: .normal)
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if let cell = collectionView.visibleCells.last, let indexPath = collectionView.indexPath(for: cell) {
            if indexPath.row + 1 == viewModel.onBoardingModels.count {
                UIApplication.setTabBarRoot()
            } else {
                collectionView.scrollToItem(at: IndexPath(item: indexPath.row + 1, section: 0), at: [], animated: true)
                updateContainer(index: indexPath.row + 1)
            }
        }
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension LoginOnboardinViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.onBoardingModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OnBoardCollectionViewCell = collectionView.dequeueReusableCell(OnBoardCollectionViewCell.self, indexPath: indexPath)
        let model = viewModel.onBoardingModels[indexPath.row]
        cell.configure(image: model.image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectedIndex()
    }
    
    func selectedIndex() {
        guard let cell = collectionView.visibleCells.first else {
            updateContainer(index: 0)
            return
        }
        if var indexPath: IndexPath = collectionView.indexPath(for: cell) {
            if indexPath.row > 2 {
                if let _cell = collectionView.visibleCells.last {
                    indexPath = collectionView.indexPath(for: _cell) ?? IndexPath(item: 0, section: 0)
                }
            }
            updateContainer(index: indexPath.row)
        }
    }

}



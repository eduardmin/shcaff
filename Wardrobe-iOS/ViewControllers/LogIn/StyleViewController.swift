//
//  StyleViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/18/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class StyleViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    private let itemsHeight: CGFloat = 265
    private let margin: CGFloat = 16
    let viewModel = StyleViewModel()
    var completion: ((StyleViewModel) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startGetAll()
        viewModel.completion = { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .update(let success):
                strongSelf.handleUpdateResponse(success: success)
            case .save(let success):
                strongSelf.handleSaveResponse(success: success)
            }
        }
        configureUI()
    }
    
    private func configureUI() {
        continueButton.setMode(.background, color: SCColors.whiteColor)
        continueButton.isEnabled = false
        continueButton.enableButton(enable: continueButton.isEnabled)
        titleLabel.attributedText = getNavigationTitle("ChooseStyle".localize(), "Your Style".localize())
        descriptionLabel.text = "Choose the style which is match the best to you or you want start wear like that.".localize()
        if viewModel.type == .login {
            continueButton.setTitle("Continue".localize(), for: .normal)
            EventLogger.logEvent("Style open")
        } else {
            continueButton.setTitle("Confirm".localize(), for: .normal)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(cell: StyleCollectionViewCell.self)
        collectionView.updateInsets(interItem: 10, interRow: 10, bottom: 90)
    }
}

//MARK:- Button Action
extension StyleViewController {
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueAction(_ sender: Any) {
        if viewModel.type == .account {
            if let completion = completion {
                completion(viewModel)
                navigationController?.popViewController(animated: true)
            }
        } else {
            startRequest()
            viewModel.saveStyles()
        }
    }
    
    private func handleSaveResponse(success: Bool) {
        LoadingIndicator.hide(from: view)
        if success {
            if viewModel.type == .login {
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.style)
                let basicViewController = BasicViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                navigationController?.pushViewController(basicViewController, animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            AlertPresenter.presentRequestErrorAlert(on: self)
        }
    }
    
    private func handleUpdateResponse(success: Bool) {
        LoadingIndicator.hide(from: view)
        collectionView.reloadData()
    }
    
    private func startRequest() {
        LoadingIndicator.show(on: view)
    }
}

//MARK:- Button Action
extension StyleViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.countOfStyles()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StyleCollectionViewCell = collectionView.dequeueReusableCell(StyleCollectionViewCell.self, indexPath: indexPath)
        let model = viewModel.getStyle(index: indexPath.row)
        cell.configure(model, selected: viewModel.tempSaveModelIds.contains(model.id))
        if viewModel.tempSaveModelIds.contains(model.id) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width - 2 * margin - 10) / 2, height: itemsHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? StyleCollectionViewCell
        cell?.selectCell()
        viewModel.select(index: indexPath.row)
        checkSelectedItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? StyleCollectionViewCell
        cell?.deselectCell()
        viewModel.deselect(index: indexPath.row)
        checkSelectedItems()
    }
    
    private func checkSelectedItems() {
        continueButton.isEnabled = collectionView.indexPathsForSelectedItems?.count ?? 0 > 0
        continueButton.enableButton(enable: continueButton.isEnabled)
    }
}

//
//  BasicViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/23/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum BasicType: Int {
    case login
    case wardrobe
}

class BasicViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tabCollectionView: UICollectionView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var selectedViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var onlySaveButton: UIButton!
    private var pageViewController: SCPageViewController!
    var type: BasicType = .login
    public let viewModel = BasicViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startRequest()
        viewModel.type = type
        viewModel.completion = { [weak self] response in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch response {
                case .update(let success):
                    strongSelf.handleUpdateBasics(success: success)
                case .save(let success):
                    strongSelf.handleSaveBasics(success: success)
                }
            }
        }
        configureUI()
    }
    
    private func configureUI() {
        titleLabel.attributedText = getNavigationTitle("Choose".localize(), "Basics".localize())
        descriptionLabel.text = "Now choose the basics clothes from the list you have, to have something in your closet.".localize()
        if type == .wardrobe {
            backButton.setImage(UIImage(named: "cancelVC"), for: .normal)
            skipButton.setTitle("Save".localize(), for: .normal)

        } else {
            skipButton.setTitle("Save & Skip".localize(), for: .normal)
            EventLogger.logEvent("Basic open")
        }
        continueButton.setTitle("Continue".localize(), for: .normal)
        continueButton.setMode(.background, color: SCColors.whiteColor)
        onlySaveButton.isHidden = true
        onlySaveButton.setTitle("Save".localize(), for: .normal)
        onlySaveButton.setMode(.background, color: SCColors.whiteColor)
        skipButton.setMode(.background, color: SCColors.titleColor, backgroundColor: SCColors.secondaryGray)
        selectedView.isHidden = true
        tabCollectionView.updateInsets(vertical: 0, estimatedSize: CGSize(width: 100, height: 32))
        tabCollectionView.allowsSelection = true
        tabCollectionView.allowsMultipleSelection = false
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        tabCollectionView.register(cell: TabCollectionViewCell.self)
    }
    
    private func addPageController(viewCotrollers: [UIViewController]) {
        pageViewController = SCPageViewController(presentingViewControllers: viewCotrollers)
        pageViewController.transitionDelegate = self
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        addConstraint()
        setSelectTab(index: 0)
        view.bringSubviewToFront(continueButton)
        view.bringSubviewToFront(skipButton)
        view.bringSubviewToFront(onlySaveButton)
    }
    
    private func addConstraint() {
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.topAnchor.constraint(equalTo: selectedView.bottomAnchor, constant: 20).isActive = true
        pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true

    }
    
    private func setSelectedTabPage(index: Int, update: Bool = true) {
        setSelectTab(index: index)
        pageViewController.selectPage(at: index, update: update)
    }
    
    private func setSelectTab(index: Int) {
        checkButtonsState(index: index)
        let indexPath = IndexPath(row: index, section: 0)
        tabCollectionView.selectItem(at:indexPath , animated: false, scrollPosition: [])
        let cell = tabCollectionView.cellForItem(at: indexPath)
        let itemRect = tabCollectionView.frame(forAlignmentRect: cell?.frame ?? CGRect.zero)
        let minCellX = itemRect.minX - tabCollectionView.contentOffset.x
        let itemWidth = itemRect.width
        let x = minCellX + itemWidth / 2 - selectedView.bounds.width / 2
        if x > 0 {
            animateSelectedView(toX: x)
        }
    }
    
    private func animateSelectedView(toX position: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.selectedViewLeadingConstraint.constant = position
            self.view.layoutIfNeeded()
        }
    }
    
    private func checkButtonsState(index: Int) {
        if viewModel.countOfClothingTypes() - 1 == index {
            continueButton.isHidden = true
            skipButton.isHidden = true
            onlySaveButton.isHidden = false
        } else {
            continueButton.isHidden = false
            skipButton.isHidden = false
            onlySaveButton.isHidden = true
        }
    }
    
    deinit {
        print("")
    }
}

//MARK:- Button Action
extension BasicViewController {
    @IBAction func backAction(_ sender: Any) {
        if type == .login {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func continueAction(_ sender: Any) {
        if let pageViewController = pageViewController {
            let index = pageViewController.selectNext()
            if index >= 0 {
                setSelectTab(index: index)
            }
        }
    }
    
    @IBAction func skipAction(_ sender: Any) {
        startRequest()
        viewModel.saveDefaultItems()
    }
    
    @IBAction func onlySaveButton(_ sender: Any) {
        startRequest()
        viewModel.saveDefaultItems()
    }
}

//MARK:- Handle response
extension BasicViewController {
    private func handleUpdateBasics(success: Bool) {
        LoadingIndicator.hide(from: view)
        if success {
            selectedView.isHidden = false
            var viewCotrollers = [UIViewController]()
            for type in viewModel.getAllClothingTypes() {
                let bacicController = BasicItemViewController()
                bacicController.delegate = self
                bacicController.itemModels = viewModel.getItems(with: type.id)
                viewCotrollers.append(bacicController)
            }
            addPageController(viewCotrollers: viewCotrollers)
            tabCollectionView.reloadData()
        } else {
            AlertPresenter.presentRequestErrorAlert(on: self)
        }
    }
    
    private func handleSaveBasics(success: Bool) {
        LoadingIndicator.hide(from: view)
        if success {
            if type == .login {
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.basic)
                let onBoardingVC = LoginOnboardinViewController.initFromStoryboard(storyBoardName: StoryboardName.login)
                navigationController?.pushViewController(onBoardingVC, animated: true)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateItems), object: nil, userInfo: nil)
                dismiss(animated: true, completion: nil)
            }
        } else {
            AlertPresenter.presentRequestErrorAlert(on: self)
        }
    }
    
    private func startRequest() {
        LoadingIndicator.show(on: view)
    }
}

//MARK:- SCPageViewControllerTransitionDelegate
extension BasicViewController: SCPageViewControllerTransitionDelegate {
    func pageViewController(_ pageViewController: SCPageViewController, didScrollTo index: Int) {
        setSelectedTabPage(index: index)
    }
}

extension BasicViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.countOfClothingTypes()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TabCollectionViewCell = collectionView.dequeueReusableCell(TabCollectionViewCell.self, indexPath: indexPath)
        let clothingType = viewModel.getClothingType(index: indexPath.row)
        cell.configure(title: clothingType.name ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setSelectedTabPage(index: indexPath.row, update: false)
    }
}

//MARk:- BasicItemViewControllerDelegate
extension BasicViewController: BasicItemViewControllerDelegate {
    func selectItem(withID id: Int64) {
        viewModel.selectItem(withId: id)
    }
    
    func deselectItem(withID id: Int64) {
        viewModel.deselectItem(withId: id)
    }
    
    func selectedItems() -> [Int64] {
        return viewModel.selectedItems()
    }
}

//
//  ItemViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/7/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class ItemViewController: BaseNavigationViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var itemParamsContainerView: DraggableContainerView!
    @IBOutlet weak var itemParamsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var createLookButton: UIButton!
    private var backgroundView: UIView?
    var itemParamsViewController: ItemParamsViewController?
    lazy private var collectionFlowLayout : UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    private let itemPanding: CGFloat = 36
    private let topMargin: CGFloat = 125
    private var margin: CGFloat {
        var _margin: CGFloat = 90
        if view.bounds.width == 414 {
            _margin = 60
        }
        return _margin
    }
    private var selectedIndex: Int = 0 {
        didSet {
            configureTitle()
        }
    }
    var itemModels: [ItemModel]?
    
    //MARK:- Overided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "parameterSegue" {
            let viewController = segue.destination as? ItemParamsViewController
            if let item = itemModels?[selectedIndex] {
                viewController?.itemModel = item
            }
            itemParamsViewController = viewController
        }
    }
    
    //MARK:- Items set
    public func setItems(_ itemModels: [ItemModel]?) {
        self.itemModels = itemModels
    }
    
    //MARK:- UI
    private func setUpUI() {
        configureTitle()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cell: ItemCollectionViewCell.self)
        collectionView.collectionViewLayout = collectionFlowLayout
        collectionView.updateInsets(horizontal: itemPanding, interItem: itemPanding * 2)
        createLookButton.setTitle("Create Look".localize(), for: .normal)
        createLookButton.setMode(.background, color: SCColors.whiteColor)
        let window = UIApplication.shared.windows.first
        let bottomSafeArea = window?.safeAreaInsets.bottom ?? 0
        itemParamsContainerViewHeightConstraint.constant = ((UIScreen.main.bounds.width - itemPanding * 2) + topMargin) + bottomSafeArea
        configureItemParamsContainerView()
    }
    
    private func configureTitle() {
        if let item = itemModels?[selectedIndex] {
            titleLabel.text = item.getItemTypeName()
        } else {
            titleLabel.text = nil
        }
    }
    
    private func configureItemParamsContainerView() {
        itemParamsContainerView.topConstraint = itemParamsContainerViewHeightConstraint
        itemParamsContainerView.initialY = itemParamsContainerViewHeightConstraint.constant
        itemParamsContainerView.minimumY = -20
        itemParamsContainerView.maximumY = view.frame.height - 200
        itemParamsContainerView.delegate = self
    }
    
    @IBAction func createLookAction(_ sender: Any) {
        let createLook: CreateLookViewController = CreateLookViewController.initFromStoryboard(storyBoardName: StoryboardName.wardrobe)
        if let item = itemModels?[selectedIndex] {
            createLook.viewModel.setDefaultItem(itemModel: item)
        }
        let navigationViewController = UINavigationController(rootViewController: createLook)
        navigationViewController.modalPresentationStyle = .fullScreen
        navigationViewController.navigationBar.isHidden = true
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- DraggableContainerViewDelegate
extension ItemViewController: DraggableContainerViewDelegate {
    func scrollMinPostion() {
        backgroundView = UIView()
        backgroundView?.backgroundColor = SCColors.titleColor.withAlphaComponent(0.5)
        backgroundView?.fixInView(view)
        view.bringSubviewToFront(itemParamsContainerView)
    }
    
    func scrollinitialPostion() {
        backgroundView?.removeFromSuperview()
    }
}

//MARK:- UICollectionViewDelegate && UICollectionViewDataSource && UICollectionViewDelegateFlowLayout
extension ItemViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ItemCollectionViewCell = collectionView.dequeueReusableCell(ItemCollectionViewCell.self, indexPath: indexPath)
        let item = itemModels![indexPath.row]
        cell.configure(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - itemPanding * 2, height: collectionView.frame.size.width - itemPanding * 2)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectedItem()
    }
    
    func selectedItem() {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else {
            return
        }
        
        if  selectedIndex != indexPath.row {
            selectedIndex = indexPath.row
            
            if let item = itemModels?[selectedIndex] {
                itemParamsViewController?.setItem(item)
            }
        }
    }
}


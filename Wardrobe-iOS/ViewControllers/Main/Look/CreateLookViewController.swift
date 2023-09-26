//
//  CreateLookViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/29/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum CreateLookSection {
    case item
    case suggestion
}

class CreateLookViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIButton!
    private let panding : CGFloat = 10
    private let leftRightMargin : CGFloat = 16
    private let customCellHeigth: CGFloat = 275
    private let itemHeigth: CGFloat = 183
    private let emptyViewHeight: CGFloat = 115
    private var isSearch: Bool = false
    private var _collectionViewLayout : LookCollectionViewLayout?
    private var collectionViewLayout : LookCollectionViewLayout
    {
        get
        {
            if _collectionViewLayout == nil
            {
                _collectionViewLayout = LookCollectionViewLayout()
                _collectionViewLayout?.multipleHeights = viewModel.lookModels.map { $0.multipleHeight }
                _collectionViewLayout?.panding = panding
                _collectionViewLayout?.leftRightMargin = leftRightMargin
                _collectionViewLayout?.isCustomCell = true
                _collectionViewLayout?.customCellHeight = customCellHeigth + itemHeigth
                _collectionViewLayout?.loadMore = true
            }
            return _collectionViewLayout!
        }
    }
    
    lazy private var lookEmptySelectView: LookSelectView = {
        let lookSelectView = LookSelectView.init(frame: CGRect.zero)
        lookSelectView.delegate = self
        lookSelectView.viewModel = viewModel
        lookSelectView.isHidden = true
        lookSelectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lookSelectView)
        lookSelectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lookSelectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lookSelectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lookSelectView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor).isActive = true
        return lookSelectView
    }()
    
    let viewModel = CreateLookViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getObjects()
        viewModel.updateCompletion = { [weak self] type in
            guard let strongSelf = self else { return }
            switch type {
            case .update:
                strongSelf.reloadCollection()
            case .selectItemUpdate:
                strongSelf.selectItemUpdate()
            }
        }
        
        viewModel.completion = { [weak self] type in
            guard let strongSelf = self else { return }
            switch type {
            case .start(showLoading: let showLoading):
                strongSelf.start(showLoading: showLoading)
            case .fail(showPopup: let showPopup):
                strongSelf.fail(showPopup: showPopup)
            case .success(response: let response):
                strongSelf.success(response: response)
            }
        }
        configureUI()
        checkAndChangeViews()
    }
    
    private func configureUI() {
        searchButton.setMode(.background, color: SCColors.whiteColor)
        searchButton.setTitle("Search".localize(), for: .normal)
        cancelButton.layer.cornerRadius = cancelButton.bounds.height / 2
        titleLabel.text = "Create Look".localize()
        clearButton.setTitle("Clear".localize(), for: .normal)
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.register(cell: CreateLookCollectionViewCell.self)
        collectionView.register(cell: LookCollectionCell.self)
        collectionView.register(cell: LoadingCollectionViewCell.self)
    }
    
    private func checkAndChangeViews() {
        if viewModel.emptyType() {
            collectionView.isHidden = true
            clearButton.isHidden = true
            lookEmptySelectView.isHidden = false
        } else {
            collectionView.isHidden = false
            clearButton.isHidden = false
            lookEmptySelectView.isHidden = true
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        viewModel.getLooks()
        EventLogger.logEvent("Create look search action")
    }
}

//MARK:- Button Action
extension CreateLookViewController: AlertPresenterDelegate {
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearAction(_ sender: Any) {
        AlertPresenter.presentInfoAlert(on: self, type: .clearItemCategory, delegate: self)
        EventLogger.logEvent("Create look clear")
    }
    
    func alertDidSelectConfirmButton() {
        viewModel.clearAll()
        hideLooks()
        collectionView.reloadData()
        checkAndChangeViews()
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension CreateLookViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isSearch ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == SetSection.set.rawValue {
            return 1
        }
        
        if viewModel.lookModels.count > 0 {
            return viewModel.loadMore ? viewModel.lookModels.count + 1 : viewModel.lookModels.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == SetSection.set.rawValue {
            let cell : CreateLookCollectionViewCell = collectionView.dequeueReusableCell(CreateLookCollectionViewCell.self, indexPath: indexPath) as CreateLookCollectionViewCell
            cell.configureItems(viewModel.sectionModels)
            cell.configureSetItem(viewModel.selectedItems)
            cell.delegate = self
            return cell
        } else {
            if viewModel.lookModels.count == indexPath.row && viewModel.lookModels.count != 0 && viewModel.loadMore {
                let cell: LoadingCollectionViewCell = collectionView.dequeueReusableCell(LoadingCollectionViewCell.self, indexPath: indexPath)
                cell.startAnimating()
                viewModel.loadMoreLooks()
                return cell
            }
            let cell : LookCollectionCell = collectionView.dequeueReusableCell(LookCollectionCell.self, indexPath: indexPath)
            cell.delegate = self
            let look = viewModel.lookModels[indexPath.row]
            cell.configure(look: look)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if viewModel.lookModels.isEmpty { return }
            let lookModel = viewModel.lookModels[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? LookCollectionCell {
                let lookController: LookViewController = LookViewController.initFromNib()
                lookController.lookDetailViewModel = LookDetailViewModel(selectedLookModel: lookModel, looksModel: viewModel.lookModels, image: cell.imageView.image ?? UIImage())
                    let navigationViewController = UINavigationController(rootViewController: lookController)
                navigationViewController.modalPresentationStyle = .overFullScreen
                navigationViewController.modalTransitionStyle = .coverVertical
                navigationViewController.navigationBar.isHidden = true
                navigationController?.present(navigationViewController, animated: true, completion: nil)
            }
        }
    }
}

//MARK:- LookSelectViewDelegate
extension CreateLookViewController: LookSelectViewDelegate {
    func selectItemCategory(_ index: Int) {
        viewModel.selectType(index)
    }
}

//MARK:- CreateLookCollectionViewCellDelegate
extension CreateLookViewController: CreateLookCollectionViewCellDelegate {
    
    func selectItem(sectionIndex: Int, index: Int) {
        hideLooks()
        viewModel.selectItem(sectionIndex: sectionIndex, itemIndex: index)
    }
    
    func plusAction() {
        AlertPresenter.presentItemCategoryAlert(on: self, viewModel: viewModel) { [weak self] (index) in
            guard let strongSelf = self else { return }
            strongSelf.hideLooks()
            strongSelf.viewModel.selectType(index as! Int)
        }
        EventLogger.logEvent("Create look plus")
    }
    
    func setAction() {
        let setViewController: SetViewController = SetViewController.initFromNib()
        setViewController.viewModel.setItems(viewModel.selectedItems)
        navigationController?.pushViewController(setViewController, animated: true)
        EventLogger.logEvent("Create look Set action")
    }
    
    func hideLooks() {
        showHiddeEmptyView(hidden: true)
        viewModel.clearLook()
        searchButton.isHidden = false
        isSearch = false
        collectionViewLayout.multipleHeights = viewModel.lookModels.map { $0.multipleHeight }
    }
}

//MARK:- LookCollectionCellDelegate
extension CreateLookViewController: LookCollectionCellDelegate {
    func addAlbum(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = viewModel.lookModels[indexPath.row]
            addAlbumWithHelper(selectedLook: lookModel, looks: viewModel.lookModels, image: cell.imageView.image ?? UIImage(), viewController: navigationController ?? self)
        }
    }
    
    func addCalendar(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = viewModel.lookModels[indexPath.row]
            addCalendarWithHelper(selectedLook: lookModel, looks: viewModel.lookModels, image: cell.imageView.image ?? UIImage(), viewController: navigationController ?? self)
        }
    }
    
    func share(cell: LookCollectionCell) {
        
    }
}

//MARK:- UI update
extension CreateLookViewController {
    private func reloadCollection() {
        collectionViewLayout.customCellHeight = customCellHeigth + itemHeigth * CGFloat(viewModel.sectionModels.count)
        checkAndChangeViews()
        collectionView.reloadData()
    }
    
    private func selectItemUpdate() {
        if let cell : CreateLookCollectionViewCell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CreateLookCollectionViewCell {
            cell.configureSetItem(viewModel.selectedItems)
        }
    }
    
    private func showHiddeEmptyView(hidden: Bool) {
        if hidden {
            collectionViewLayout.customCellHeight = customCellHeigth + itemHeigth * CGFloat(viewModel.sectionModels.count)
        } else {
            collectionViewLayout.customCellHeight = customCellHeigth + itemHeigth * CGFloat(viewModel.sectionModels.count) + emptyViewHeight
        }
        if let cell : CreateLookCollectionViewCell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CreateLookCollectionViewCell {
            cell.hideShowEmptyView(hidden: hidden, emptyViewHeight: !hidden ? emptyViewHeight: 0)
        }
    }
}

//MARK:- RequestResponseProtocol
extension CreateLookViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        searchButton.isHidden = true
        isSearch = true
        showHiddeEmptyView(hidden: !viewModel.lookModels.isEmpty)
        collectionViewLayout.multipleHeights = viewModel.lookModels.map { $0.multipleHeight }
        collectionView.reloadData()
    }
}



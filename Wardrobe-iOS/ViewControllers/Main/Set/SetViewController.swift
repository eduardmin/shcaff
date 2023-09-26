//
//  SetViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/9/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum SetViewType {
    case save
    case edit
}

enum SetSection : Int {
    case set
    case suggestion
}

class SetViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    var _collectionViewLayout : LookCollectionViewLayout?
    var collectionViewLayout : LookCollectionViewLayout
    {
        get
        {
            if _collectionViewLayout == nil
            {
                _collectionViewLayout = LookCollectionViewLayout()
                if type == .edit {
                    _collectionViewLayout?.multipleHeights = viewModel.lookModels.map { $0.multipleHeight }
                    _collectionViewLayout?.loadMore = true
                }
                _collectionViewLayout?.panding = panding
                _collectionViewLayout?.leftRightMargin = leftRightMargin
                _collectionViewLayout?.isCustomCell = true
                _collectionViewLayout?.customCellHeight = customCellHeight()
            }
            return _collectionViewLayout!
        }
    }
    
    private let panding : CGFloat = 10
    private let leftRightMargin : CGFloat = 16
    let looks = [Look]()
    let viewModel = SetViewModel()
    public var type: SetViewType = .save
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.updateCompletion = { [weak self] type in
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
        if type == .edit {
            viewModel.getLooks()
        }
        configureUI()
    }
    
//MARK:- UI
    func configureUI() {
        titleLabel.text = "Set".localize()
        editButton.isHidden = type == .save
        if type == .edit {
            backButton.setImage(UIImage(named: "cancelVC"), for: .normal)
        }
        collectionView.isScrollEnabled = type == .edit
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.register(cell: SetCollectionViewCell.self)
        collectionView.register(cell: LookCollectionCell.self)
        collectionView.register(cell: LoadingCollectionViewCell.self)
    }

    @IBAction func editClick(_ sender: Any) {
        let setEditViewController = SetEditViewController.initFromNib() as? SetEditViewController
        setEditViewController?.viewModel = viewModel
        navigationController?.pushViewController(setEditViewController!, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        if type == .edit {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension SetViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if type == .save {
            return 1
        }
        return 2
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
            let cell : SetCollectionViewCell = collectionView.dequeueReusableCell(SetCollectionViewCell.self, indexPath: indexPath)
            cell.configure(itemModels: viewModel.getItems(), type: type)
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
        if indexPath.section == SetSection.suggestion.rawValue {
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

//MARK:- LookCollectionCellDelegate
extension SetViewController: LookCollectionCellDelegate {
    func addAlbum(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = viewModel.lookModels[indexPath.row]
            addAlbumWithHelper(selectedLook: lookModel, looks: viewModel.lookModels, image: cell.imageView.image ?? UIImage(), viewController: navigationController ?? self)
            EventLogger.logEvent("Set add album")
        }
    }
    
    func addCalendar(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = viewModel.lookModels[indexPath.row]
            addCalendarWithHelper(selectedLook: lookModel, looks: viewModel.lookModels, image: cell.imageView.image ?? UIImage(), viewController: navigationController ?? self)
            EventLogger.logEvent("Set add calendar")
        }
    }
    
    func share(cell: LookCollectionCell) {
        
    }
}


//MARK:- Private func
extension SetViewController: SetCollectionViewCellDelegate {
    func addTodayChoice() {
        let calendarEventCreateViewController = CalendarEventCreateViewController.initFromStoryboard() as CalendarEventCreateViewController
        if let setModel = viewModel.getSetModel() {
            calendarEventCreateViewController.viewModel.setSetModel(setModel)
        }
        calendarEventCreateViewController.viewModel.setDate(Date().timeIntervalSince1970)
        navigationController?.pushViewController(calendarEventCreateViewController, animated: true)
    }
    
    func addToCalendar() {
        let calendarViewController: CalendarViewController = CalendarViewController.initFromStoryboard()
        calendarViewController.viewModel.setSetModel(viewModel.getSetModel())
        calendarViewController.navigationType = .selectDate
        let navigationController = UINavigationController(rootViewController: calendarViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.isHidden = true
        present(navigationController, animated: true, completion: nil)
    }
    
    func addOrDelete() {
        if type == .save {
            let album = AlbumsViewController()
            album.type = .set
            album.modalPresentationStyle = .fullScreen
            album.albumCompletion = { [weak self] album in
                guard let strongSelf = self else { return }
                strongSelf.createSet(album)
            }
            navigationController?.present(album, animated: true, completion: nil)
        } else {
            deleteSet()
        }
    }
}

//MARK:- RequestResponseProtocol
extension SetViewController: RequestResponseProtocol {
    func start(showLoading: Bool) {
        LoadingIndicator.show(on: view)
    }
    
    func fail(showPopup: Bool) {
        AlertPresenter.presentRequestErrorAlert(on: self)
        LoadingIndicator.hide(from: view)
    }
    
    func success(response: Any?) {
        LoadingIndicator.hide(from: view)
        
        if let response = response as? Bool, response {
            collectionViewLayout.multipleHeights = viewModel.lookModels.map { $0.multipleHeight }
            collectionView.reloadData()
        } else {
            if let response = response as? (success: Bool, delete: Bool), response.1 {
                NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.updateSets), object: nil, userInfo: nil)
                dismiss(animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
}


//MARK:- Send Request
extension SetViewController {
    func createSet(_ album: AlbumModel) {
        viewModel.saveSet(album)
    }
    
    func deleteSet() {
        viewModel.deleteSet()
    }
}

//MARK:- Private func
extension SetViewController {
    private func customCellHeight() -> CGFloat {
        let customView = Bundle.main.loadNibNamed("SetCollectionViewCell", owner: nil, options: nil)?[0] as? SetCollectionViewCell
        return customView?.cellHeight ?? 0
    }
}

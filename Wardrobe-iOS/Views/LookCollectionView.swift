//
//  WardrobeCollection.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/2/20.
//

import UIKit

struct Look {
    var image : UIImage
    var size : CGSize
}

protocol LookCollectionViewDelete: class {
    func isLoadMore() -> Bool
    func loadMore()
    func updateLooks()
}

class LookCollectionView: UIView {
    private let panding : CGFloat = 10
    private let topMargin : CGFloat = 15
    private let leftRightMargin : CGFloat = 16
    var isCreateLook : Bool = false
    weak var presentViewController: UIViewController?
    weak var delegate: LookCollectionViewDelete?
    var type: LookViewModelType = .whatToWear
    private var lookDetailViewModel: LookDetailViewModel?
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    var looks = [LookModelSuggestion]() {
        didSet {
            refreshControl.endRefreshing()
            collectionViewLayout.multipleHeights = looks.map { $0.multipleHeight }
            if type == .whatToWear {
                collectionViewLayout.haveItems = looks.map { $0.haveItems }
            }
            lookDetailViewModel?.addMoreLook(looks: looks, isMoreLoad: delegate?.isLoadMore() ?? false)
            collectionView.reloadData()
        }
    }
    
    var emptyLook = [CGFloat]() {
        didSet {
            if !emptyLook.isEmpty {
                refreshControl.endRefreshing()
                collectionViewLayout.multipleHeights = emptyLook
                collectionView.reloadData()
            }
        }
    }
    
    var _collectionView : CollectionView?;
    var collectionView : CollectionView
    {
        get
        {
            if _collectionView == nil {
                
                _collectionView = CollectionView(frame:CGRect(x: 0, y: 0, width: frame.width , height: frame.height) , collectionViewLayout: collectionViewLayout)
                _collectionView?.showsVerticalScrollIndicator = false
                _collectionView?.showsHorizontalScrollIndicator = false
                _collectionView?.backgroundColor = UIColor.clear
                _collectionView?.delegate = self
                _collectionView?.dataSource = self
                _collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                _collectionView?.allowsSelection = true
                _collectionView?.register(cell: LookCollectionCell.self)
                _collectionView?.register(cell: CreateLookCell.self)
                _collectionView?.register(cell: LoadingCollectionViewCell.self)
                _collectionView?.refreshControl = refreshControl
                addSubview(_collectionView!)
            }
            return _collectionView!
        }
    }
    
    var _collectionViewLayout : LookCollectionViewLayout?
    var collectionViewLayout : LookCollectionViewLayout {
        get {
            if _collectionViewLayout == nil {
                _collectionViewLayout = LookCollectionViewLayout()
                _collectionViewLayout?.multipleHeights = looks.map { $0.multipleHeight }
                _collectionViewLayout?.panding = panding
                _collectionViewLayout?.topMargin = topMargin
                _collectionViewLayout?.leftRightMargin = leftRightMargin
                _collectionViewLayout?.isCreateLook = isCreateLook
                _collectionViewLayout?.loadMore = true
            }
            return _collectionViewLayout!
        }
    }
}
 
extension LookCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isCreateLook ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 && isCreateLook {
            return 1
        }
        
        if looks.count > 0 {
            return  (delegate?.isLoadMore() ?? false) ? looks.count + 1 : looks.count
        }
        
        return emptyLook.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isCreateLook && indexPath.section == 0 {
            let cell : CreateLookCell = collectionView.dequeueReusableCell(CreateLookCell.self, indexPath: indexPath)
            return cell
        } else {
            
            if looks.count == indexPath.row && looks.count != 0 && emptyLook.isEmpty && (delegate?.isLoadMore() ?? false) {
                let cell: LoadingCollectionViewCell = collectionView.dequeueReusableCell(LoadingCollectionViewCell.self, indexPath: indexPath)
                cell.startAnimating()
                delegate?.loadMore()
                return cell
            }
            
            let cell : LookCollectionCell = collectionView.dequeueReusableCell(LookCollectionCell.self, indexPath: indexPath)
            cell.delegate = self
            if indexPath.row < looks.count {
                let look = looks[indexPath.row]
                cell.configure(look: look, showItems: true)
            } else {
                let multiply = emptyLook[indexPath.row]
                cell.startAnimating(multipleHeight: multiply)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isCreateLook && indexPath.section == 0 {
            let createLook = CreateLookViewController.initFromStoryboard(storyBoardName: StoryboardName.wardrobe)
            let navigationViewController = UINavigationController(rootViewController: createLook)
            navigationViewController.modalPresentationStyle = .fullScreen
            navigationViewController.navigationBar.isHidden = true
            window?.rootViewController?.present(navigationViewController, animated: true, completion: nil)
        } else {
            if looks.isEmpty { return }
            let cell = collectionView.cellForItem(at: indexPath) as? LookCollectionCell
            let lookModel = looks[indexPath.row]
            let lookController: LookViewController = LookViewController.initFromNib()
            lookDetailViewModel = LookDetailViewModel(selectedLookModel: lookModel, looksModel: looks, image: cell?.imageView.image)
            lookController.lookDetailViewModel = lookDetailViewModel
            lookController.delegate = self
            let navigationViewController = UINavigationController(rootViewController: lookController)
            navigationViewController.modalPresentationStyle = .overFullScreen
            navigationViewController.modalTransitionStyle = .coverVertical
            navigationViewController.navigationBar.isHidden = true
            presentViewController?.present(navigationViewController, animated: true, completion: nil)
            
        }
    }
    
    @objc func refresh() {
        delegate?.updateLooks()
    }
}

extension LookCollectionView: LookCollectionCellDelegate, LookViewControllerDelegate {
    func addAlbum(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = looks[indexPath.row]
            addAlbumWithHelper(selectedLook: lookModel, looks: looks, image: cell.imageView.image ?? UIImage(), viewController: presentViewController!)
        }
        
    }
    
    func addCalendar(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = looks[indexPath.row]
            addCalendarWithHelper(selectedLook: lookModel, looks: looks, image: cell.imageView.image ?? UIImage(), viewController: presentViewController!)
        }
    }
    
    func share(cell: LookCollectionCell) {
        
    }
    
    func loadMore() {
        delegate?.loadMore()
    }
    
    func dismiss() {
        lookDetailViewModel = nil
    }
}

//MARK:- Public func
extension LookCollectionView {
    func scrollTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
}
 

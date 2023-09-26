//
//  AlbumItemViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/25/20.
//

import UIKit

class AlbumItemViewController: BaseNavigationViewController {
    private let panding : CGFloat = 10
    private let leftRightMargin : CGFloat = 16
    @IBOutlet weak var collectionView: UICollectionView!
    var _collectionViewLayout : LookCollectionViewLayout?
    var collectionViewLayout : LookCollectionViewLayout {
        get {
            if _collectionViewLayout == nil {
                _collectionViewLayout = LookCollectionViewLayout()
                _collectionViewLayout?.multipleHeights = albumModel.setModels.map { $0.multipleHeight }
                _collectionViewLayout?.panding = panding
                _collectionViewLayout?.leftRightMargin = leftRightMargin
            }
            return _collectionViewLayout!
        }
    }
    
    public var eventCompletion: ((SetModel) -> ())?
    public var calendarDate: Double?
    public var albumModel: AlbumModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateSets), name: NSNotification.Name(rawValue: NotificationName.updateSets), object: nil)
    }
    
    private func configure() {
        setNavigationView(type: .defaultWithBack, title: albumModel.name, additionalTopMargin: 16)
        collectionView.register(cell: LookCollectionCell.self)
        collectionView.register(cell: AlbumItemSetCollectionViewCell.self)
        collectionView.collectionViewLayout = collectionViewLayout
    }
    
    override func didSelectNavigationAction(action: NavigationAction) {
        switch action {
        case .back:
            navigationController?.popViewController(animated: true)
        case .edit:
            print("edit")
        default:
            break
        }
    }
    
    @objc func updateSets() {
        collectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension AlbumItemViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumModel.setModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let setModel = albumModel.setModels[indexPath.row]
        if setModel.lookId == nil {
            let cell = collectionView.dequeueReusableCell(AlbumItemSetCollectionViewCell.self, indexPath: indexPath) as AlbumItemSetCollectionViewCell
            cell.configure(setModel.itemModels ?? [])
            return cell
        } else {
            let cell : LookCollectionCell = collectionView.dequeueReusableCell(LookCollectionCell.self, indexPath: indexPath)
            cell.configure(image: setModel.lookImage ?? UIImage())
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setModel = albumModel.setModels[indexPath.row]
        if let eventCompletion = eventCompletion {
            eventCompletion(setModel)
            return
        }
        if let date = calendarDate {
            let calendarEventCreateViewController = CalendarEventCreateViewController.initFromStoryboard() as CalendarEventCreateViewController
            calendarEventCreateViewController.viewModel.setSetModel(setModel)
            calendarEventCreateViewController.viewModel.setDate(date)
            navigationController?.pushViewController(calendarEventCreateViewController, animated: true)
        } else {
            if setModel.lookId != nil {
                let (selectedModel, lookModels) = albumModel.getLooks(setModel: setModel)
                if let selectedModel = selectedModel, let image = setModel.lookImage {
                    let lookController: LookViewController = LookViewController.initFromNib()
                    let lookDetailViewModel = LookDetailViewModel(selectedLookModel: selectedModel, looksModel: lookModels, image: image, albumModel: albumModel)
                    lookDetailViewModel.isLoadMore = false
                    lookController.lookDetailViewModel = lookDetailViewModel
                    lookController.type = .edit
                    let navigationViewController = UINavigationController(rootViewController: lookController)
                    navigationViewController.modalPresentationStyle = .overFullScreen
                    navigationViewController.modalTransitionStyle = .coverVertical
                    navigationViewController.navigationBar.isHidden = true
                    navigationController?.present(navigationViewController, animated: true, completion: nil)
                    
                }
            } else {
                let setViewController: SetViewController = SetViewController.initFromNib()
                setViewController.type = .edit
                setViewController.viewModel.setSetModel(setModel)
                setViewController.viewModel.setAlbumModel(albumModel)
                let navigation = UINavigationController(rootViewController: setViewController)
                navigation.navigationBar.isHidden = true
                navigation.modalPresentationStyle = .fullScreen
                navigationController?.present(navigation, animated: true, completion: nil)
            }
        }
    }
}

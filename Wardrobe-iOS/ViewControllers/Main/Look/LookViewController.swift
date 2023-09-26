//
//  LookViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/3/20.
//

import UIKit

enum LookSection : Int {
    case look
    case suggestion
}

protocol LookViewControllerDelegate: class {
    func loadMore()
    func dismiss()
}

enum LookViewType {
    case save
    case edit
}

class LookViewController: PannableViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: LookViewControllerDelegate?
    var _collectionViewLayout : LookCollectionViewLayout?
    var collectionViewLayout : LookCollectionViewLayout
    {
        get
        {
            if _collectionViewLayout == nil
            {
                _collectionViewLayout = LookCollectionViewLayout()
                _collectionViewLayout?.multipleHeights = lookDetailViewModel.lookSuggestionModels.map { $0.multipleHeight }
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
    public var type: LookViewType = .save
    public var lookDetailViewModel :LookDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        lookDetailViewModel.updateCompletion = { [weak self] type in
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
        EventLogger.logEvent("Look page", withParameters: ["lookId": "\(lookDetailViewModel.selectedLookModel.id)"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lookDetailViewModel.saveLookStatistic()
        delegate?.dismiss()
    }
    
    override func getCollectionViewOffset() -> Int {
        return Int(collectionView.contentOffset.y)
    }
    
//MARK:- UI
    func configureUI() {
        cancelButton.layer.cornerRadius = cancelButton.bounds.height / 2
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.register(cell: OpenLookCollectionViewCell.self)
        collectionView.register(cell: LookCollectionCell.self)
        collectionView.register(cell: LoadingCollectionViewCell.self)
    }

    @IBAction func cancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension LookViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
          return 2
      }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == SetSection.set.rawValue {
            return 1
        }
        
        if lookDetailViewModel.lookSuggestionModels.count > 0 {
            return lookDetailViewModel.loadSuggestionMore ? lookDetailViewModel.lookSuggestionModels.count + 1 : lookDetailViewModel.lookSuggestionModels.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == SetSection.set.rawValue {
            let cell : OpenLookCollectionViewCell = collectionView.dequeueReusableCell(OpenLookCollectionViewCell.self, indexPath: indexPath)
            cell.configureCell(type: type, lookModel: lookDetailViewModel.lookModel, looks: lookDetailViewModel.looksModel, selectedIndex: lookDetailViewModel.selectedIndex, loadMore: lookDetailViewModel.isLoadMore, isSowMoreLook: lookDetailViewModel.lookSuggestionModels.count == 0)
            cell.delegate = self
            return cell
        } else {
            if lookDetailViewModel.lookSuggestionModels.count == indexPath.row && lookDetailViewModel.lookSuggestionModels.count != 0 && lookDetailViewModel.loadSuggestionMore {
                let cell: LoadingCollectionViewCell = collectionView.dequeueReusableCell(LoadingCollectionViewCell.self, indexPath: indexPath)
                cell.startAnimating()
                lookDetailViewModel.loadMoreLooks()
                return cell
            }
            let cell : LookCollectionCell = collectionView.dequeueReusableCell(LookCollectionCell.self, indexPath: indexPath)
            cell.delegate = self
            let look = lookDetailViewModel.lookSuggestionModels[indexPath.row]
            cell.configure(look: look)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == SetSection.suggestion.rawValue {
            if lookDetailViewModel.lookSuggestionModels.isEmpty { return }
            let lookModel = lookDetailViewModel.lookSuggestionModels[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? LookCollectionCell {
                let lookController: LookViewController = LookViewController.initFromNib()
                lookController.lookDetailViewModel = LookDetailViewModel(selectedLookModel: lookModel, looksModel: lookDetailViewModel.lookSuggestionModels, image: cell.imageView.image ?? UIImage())
                    let navigationViewController = UINavigationController(rootViewController: lookController)
                navigationViewController.modalPresentationStyle = .overFullScreen
                navigationViewController.modalTransitionStyle = .coverVertical
                navigationViewController.navigationBar.isHidden = true
                navigationController?.present(navigationViewController, animated: true, completion: nil)
            }
        }
    }
}

//MARK:- cell delegate func
extension LookViewController : OpenLookCollectionViewCellDelegate {
    func todayChoice() {
        let calendarEventCreateViewController = CalendarEventCreateViewController.initFromStoryboard() as CalendarEventCreateViewController
        calendarEventCreateViewController.viewModel.setSetModel(lookDetailViewModel.getSetModel())
        calendarEventCreateViewController.viewModel.setDate(Date().timeIntervalSince1970)
        navigationController?.pushViewController(calendarEventCreateViewController, animated: true)
        EventLogger.logEvent("Today choice")
    }
    
    func shareLook() {
    }
    
    func saveLook() {
        let album = AlbumsViewController()
        album.type = .set
        album.modalPresentationStyle = .fullScreen
        album.albumCompletion = { [weak self] album in
            guard let strongSelf = self else { return }
            strongSelf.lookDetailViewModel.saveLook(album)
        }
        navigationController?.present(album, animated: true, completion: nil)
    }
    
    func addCalendar() {
        let calendarViewController: CalendarViewController = CalendarViewController.initFromStoryboard()
        calendarViewController.viewModel.setSetModel(lookDetailViewModel.getSetModel())
        calendarViewController.navigationType = .selectDate
        let navigationController = UINavigationController(rootViewController: calendarViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.isHidden = true
        present(navigationController, animated: true, completion: nil)
        EventLogger.logEvent("Add Calendar")
    }
    
    func select(cell: OpenLookCollectionViewCell, index: Int, image: UIImage?) {
        lookDetailViewModel.deleteAllSuggestion()
        lookDetailViewModel.setSelectedIndex(index: index, image: image)
        collectionViewLayout.customCellHeight = customCellHeight()
        collectionView.performBatchUpdates({
            cell.updateCollectionHeight(lookModel: lookDetailViewModel.lookModel)
            collectionView.reloadData()
        })
    }
    
    func moreLook() {
        lookDetailViewModel.getLooks()
    }
    
    func loadMore() {
        delegate?.loadMore()
    }
    
    func deleteLook() {
        lookDetailViewModel.deleteLook()
    }
    
    func openLink(url: String, message: String) { 
        let alertController = UIAlertController(title: nil, message: message.localize(), preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in}
         alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let url = URL(string: url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
         }
         alertController.addAction(OKAction)
         
        present(alertController, animated: true)
    }
}

//MARK:- LookCollectionCellDelegate
extension LookViewController: LookCollectionCellDelegate {
    func addAlbum(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = lookDetailViewModel.lookSuggestionModels[indexPath.row]
            addAlbumWithHelper(selectedLook: lookModel, looks: lookDetailViewModel.lookSuggestionModels, image: cell.imageView.image ?? UIImage(), viewController: navigationController ?? self)
        }
    }
    
    func addCalendar(cell: LookCollectionCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let lookModel = lookDetailViewModel.lookSuggestionModels[indexPath.row]
            addCalendarWithHelper(selectedLook: lookModel, looks: lookDetailViewModel.lookSuggestionModels, image: cell.imageView.image ?? UIImage(), viewController: navigationController ?? self)
        }
    }
    
    func share(cell: LookCollectionCell) {
        
    }
}

//MARK:- RequestResponseProtocol
extension LookViewController: RequestResponseProtocol {
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
            collectionViewLayout.multipleHeights = lookDetailViewModel.lookSuggestionModels.map { $0.multipleHeight }
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

//MARK:- Private func
extension LookViewController {
    private func customCellHeight() -> CGFloat {
        let imageWidth = UIScreen.main.bounds.width - 2 * leftRightMargin
        let imageHeight: CGFloat = imageWidth * lookDetailViewModel.lookModel.multipleHeight
        var collectionHeight: CGFloat = 100
        if let items = lookDetailViewModel.lookModel.itemModels, items.isEmpty {
            collectionHeight = 0
        }
        let buttonHeight: CGFloat = 100
        let detailHeight: CGFloat = 84

        return imageHeight + collectionHeight + buttonHeight + detailHeight
    }
}

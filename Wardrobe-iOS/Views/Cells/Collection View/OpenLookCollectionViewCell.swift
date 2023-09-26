//
//  OpenLookCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/3/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol OpenLookCollectionViewCellDelegate : class {
    func todayChoice()
    func shareLook()
    func saveLook()
    func deleteLook()
    func addCalendar()
    func select(cell: OpenLookCollectionViewCell, index: Int, image: UIImage?)
    func loadMore()
    func moreLook()
    func openLink(url: String, message: String)
}

class OpenLookCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var todayChoiceButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addCalendarButton: UIButton!
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lookCollectionView: UICollectionView!
    @IBOutlet weak var lookCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var seeMoreButton: UIButton!
    @IBOutlet weak var idLabel: CopyableLabel!
    private var lookViewType: LookViewType!
    private var isReload: Bool = false
    public var loadMore: Bool = true
    private var lookItems = [ItemModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var selectedIndex: Int?
    private var looks: [LookModelSuggestion] = [LookModelSuggestion]()
    private let collectionCellWidth : CGFloat = 78
    private let leftRightMargin: CGFloat = 16
    var delegate : OpenLookCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        idLabel.isHidden = releaseVersion
        todayChoiceButton.setMode(.background, color: SCColors.whiteColor)
        todayChoiceButton.setTitle("Today's Choice".localize(), for: .normal)
        addCalendarButton.setTitle("To Calendar".localize(), for: .normal)
        addCalendarButton.setMode(.background, color: SCColors.titleColor, backgroundColor: SCColors.secondaryGray, shadow: false)
        saveButton.setTitle("Save".localize(), for: .normal)
        saveButton.setMode(.background, color: SCColors.titleColor, backgroundColor: SCColors.secondaryGray, shadow: false)
//        shareButton.setTitle("Share".localize(), for: .normal)
//        shareButton.setMode(.background, color: SCColors.titleColor, backgroundColor: SCColors.secondaryGray, shadow: false)
        suggestionLabel.text = "More like this".localize()
        suggestionLabel.isHidden = true
        seeMoreButton.setAttributedTitle( NSAttributedString(string: "More like this".localize(), attributes: [NSAttributedString.Key.foregroundColor : SCColors.secondaryColor, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]), for: .normal)
        lookCollectionView.updateInsets(horizontal: leftRightMargin, interItem: leftRightMargin)
        lookCollectionView.delegate = self
        lookCollectionView.dataSource = self
        lookCollectionView.register(cell: LookCollectionCell.self)
        lookCollectionView.register(cell: LoadingCollectionViewCell.self)
        collectionView.register(cell: SetItemCollectionViewCell.self)
    }
    
    func configureCell(type: LookViewType, lookModel : LookModelSuggestion, looks: [LookModelSuggestion], selectedIndex: Int, loadMore: Bool, isSowMoreLook: Bool = true) {
        lookViewType = type
        idLabel.text = "\(lookModel.id)"
        if type == .save {
            saveButton.setTitle("Save".localize(), for: .normal)
            saveButton.setMode(.background, color: SCColors.titleColor, backgroundColor: SCColors.secondaryGray, shadow: false)
        } else {
            saveButton.setTitle("Delete".localize(), for: .normal)
            saveButton.setMode(.background, color: SCColors.deleteColor, backgroundColor: SCColors.secondaryGray, shadow: false)
        }
        updateCollectionHeight(lookModel: lookModel)
        let items = lookModel.itemModels ?? []
        if items.isEmpty {
            itemCollectionHeight.constant = 0
        } else {
            itemCollectionHeight.constant = collectionCellWidth
            lookItems = items
        }
        self.looks = looks
        self.selectedIndex = selectedIndex
        self.loadMore = loadMore
        if isSowMoreLook {
            seeMoreButton.isHidden = false
            suggestionLabel.isHidden = true
        } else {
            seeMoreButton.isHidden = true
            suggestionLabel.isHidden = false
        }
        lookCollectionView.reloadData()
    }
    
    func updateCollectionHeight(lookModel: LookModelSuggestion) {
        idLabel.text = "\(lookModel.id)"
        let imageWidth: CGFloat = frame.width - 2 * leftRightMargin
        lookCollectionHeightConstraint.constant = imageWidth * lookModel.multipleHeight
        let items = lookModel.itemModels ?? []
        if items.isEmpty {
            itemCollectionHeight.constant = 0
        } else {
            itemCollectionHeight.constant = collectionCellWidth
            lookItems = items
        }
        collectionView.performBatchUpdates({
            lookCollectionView.reloadData()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let selectedIndex = selectedIndex, isReload, selectedIndex != 0 {
            lookCollectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
            self.selectedIndex = nil
        }
    }
}


//MARK:- Button action
extension OpenLookCollectionViewCell {
    @IBAction func todayChoiceClick(_ sender: Any) {
        delegate?.todayChoice()
    }
    
//    @IBAction func shareClick(_ sender: Any) {
//        delegate?.shareLook()
//    }
    
    @IBAction func saveClick(_ sender: Any) {
        if lookViewType == .save {
            delegate?.saveLook()
        } else {
            delegate?.deleteLook()
        }
    }
    
    @IBAction func addCalendarClick(_ sender: Any) {
        delegate?.addCalendar()
    }

    @IBAction func seeMoreLookAction(_ sender: Any) {
        suggestionLabel.isHidden = false
        seeMoreButton.isHidden = true
        delegate?.moreLook()
    }
}

//MARK:- UICollectionViewDelegate && UICollectionViewDataSource
extension OpenLookCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LookCollectionCellDelegate {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == lookCollectionView {
            isReload = true
            if looks.count > 0 {
                return loadMore ? looks.count + 1 : looks.count
            }
            return 0
        }
        return lookItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == lookCollectionView {
            if looks.count == indexPath.row && looks.count != 0 && loadMore {
                let cell: LoadingCollectionViewCell = collectionView.dequeueReusableCell(LoadingCollectionViewCell.self, indexPath: indexPath)
                cell.startAnimating()
                delegate?.loadMore()
                return cell
            }

            let cell: LookCollectionCell = collectionView.dequeueReusableCell(LookCollectionCell.self, indexPath: indexPath)
            cell.delegate = self
            let look = looks[indexPath.row]
            cell.configure(look: look, isLongPress: false, cornerRadius: 30, showLogo: false)
            return cell
        } else {
            let cell: SetItemCollectionViewCell = collectionView.dequeueReusableCell(SetItemCollectionViewCell.self, indexPath: indexPath)
            let itemModel = lookItems[indexPath.row]
            cell.configue(image: itemModel.image)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == lookCollectionView {
            return CGSize(width: lookCollectionView.frame.size.width - leftRightMargin * 2, height: collectionView.frame.size.height)
        } else {
            return CGSize(width: collectionCellWidth, height: collectionCellWidth)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexPath = lookCollectionView.indexPathsForVisibleItems.last, let cell = lookCollectionView.cellForItem(at: indexPath) as? LookCollectionCell {
            delegate?.select(cell: self, index: indexPath.row, image: cell.imageView.image)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == lookCollectionView {
            return 2 * leftRightMargin
        }
        return 10
    }
    
    func openLogo(url: String, message: String) {
        delegate?.openLink(url: url, message: message)
    }
    
    func addAlbum(cell: LookCollectionCell) {}
    
    func addCalendar(cell: LookCollectionCell) {}
    
    func share(cell: LookCollectionCell) {}
    
}

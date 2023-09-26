//
//  SetCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 6/9/20.
//

import UIKit

protocol SetCollectionViewCellDelegate : class {
    func addTodayChoice()
    func addToCalendar()
    func addOrDelete()
}

class SetCollectionViewCell: UICollectionViewCell {
    private let leftRightMargin : CGFloat = 36
    private let itemPadding : CGFloat = 20
    @IBOutlet weak var setCollectionView: UICollectionView!
    @IBOutlet weak var todayChoiceButton: UIButton!
    @IBOutlet weak var addToCalendarButton: UIButton!
    @IBOutlet weak var suggestionDescLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addOrDeleteAlbum: UIButton!
    @IBOutlet weak var dotView: DotView!
    private var itemModels : [ItemModel]?
    
    private var itemHeight : CGFloat {
        return  (UIScreen.main.bounds.width - 4 * leftRightMargin - itemPadding) / 2
    }
    
    var cellHeight : CGFloat {
        return UIScreen.main.bounds.width - 2 * leftRightMargin + containerView.bounds.height
    }
    var delegate : SetCollectionViewCellDelegate?

    // MARK: Overide Function
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
// MARK:- UI
    func setUpUI() {
        let layout = CenterViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        setCollectionView.layer.cornerRadius = 40
        setCollectionView.collectionViewLayout = layout
        setCollectionView.register(cell: SetItemCollectionViewCell.self)
        setCollectionView.updateInsets(horizontal: leftRightMargin, vertical: leftRightMargin, interItem: itemPadding, interRow: itemPadding)
        setCollectionView.contentSize = CGSize(width: 2 * setCollectionView.frame.width, height: setCollectionView.frame.height)
        todayChoiceButton.setTitle("Today's Choice".localize(), for: .normal)
        todayChoiceButton.setMode(.background, color: SCColors.whiteColor)
        addToCalendarButton.setTitle("To Calendar".localize(), for: .normal)
        addToCalendarButton.setMode(.background, color: SCColors.titleColor, backgroundColor: SCColors.secondaryGray, shadow: false)
        suggestionDescLabel.text = "Suggestions".localize()
    }
}

// MARK:- Public Func
extension SetCollectionViewCell {
    func configure(itemModels : [ItemModel], type: SetViewType) {
        self.itemModels = itemModels
        let i : CGFloat = CGFloat(itemModels.count) / 4
        let roundCount = Int(i.rounded(.up))
        dotView.configure(numberOfDots: roundCount)
        selectedIndex()
        
        if type == .edit {
            addOrDeleteAlbum.setTitle("Delete".localize(), for: .normal)
            addOrDeleteAlbum.setMode(.background, color: SCColors.deleteColor, backgroundColor: SCColors.secondaryGray, shadow: false)
            suggestionDescLabel.isHidden = false
        } else {
            addOrDeleteAlbum.setTitle("Save".localize(), for: .normal)
            addOrDeleteAlbum.setMode(.background, color: SCColors.titleColor, backgroundColor: SCColors.secondaryGray, shadow: false)
            suggestionDescLabel.isHidden = true
        }
    }
}

// MARK:- Button Action
extension SetCollectionViewCell {
    @IBAction func todayChoiceClick(_ sender: Any) {
        delegate?.addTodayChoice()
    }
    
    @IBAction func addToCalendarClick(_ sender: Any) {
        delegate?.addToCalendar()
    }
    
    @IBAction func addOrDeleteClick(_ sender: Any) {
        delegate?.addOrDelete()
    }
}

// MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension SetCollectionViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : SetItemCollectionViewCell = collectionView.dequeueReusableCell(SetItemCollectionViewCell.self, indexPath: indexPath)
        let itemModel = itemModels?[indexPath.row]
        if let image = itemModel?.image {
            cell.configue(image: image, cornerRadius: itemHeight / 2)
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectedIndex()
    }
    
    func selectedIndex() {
        guard let cell = setCollectionView.visibleCells.last else {
            dotView.selectIndex(index: 0)
            return
        }
        let indexPath = setCollectionView.indexPath(for: cell)
        let index = indexPath!.row / 4
        dotView.selectIndex(index: index)
    }

}

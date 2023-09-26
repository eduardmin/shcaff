//
//  CalendarLookCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/7/20.
//

import UIKit

protocol CalendarLookCollectionViewCellDelegate: class {
    func deleteAction(cell: CalendarLookCollectionViewCell)
    func editAction(cell: CalendarLookCollectionViewCell)
}

class CalendarLookCollectionViewCell: UICollectionViewCell {
    private let leftRightMargin : CGFloat = 36
    private let itemPadding : CGFloat = 10
    private let cornerRadius: CGFloat = 20
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var lookView: UIView!
    @IBOutlet weak var lookNameLabel: UILabel!
    @IBOutlet weak var lookImageView: UIImageView!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dotView: DotView!
    weak var delegate: CalendarLookCollectionViewCellDelegate?
    private var eventModel: CalendarEventModel?

    private var itemHeight : CGFloat {
        let item = UIScreen.main.bounds.width / 5
        return  item.rounded(.down)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        imageViewHeightConstraint.constant = 2 * itemHeight + 2 * itemPadding
        imageViewWidthConstraint.constant =  UIScreen.main.bounds.width - 2 * leftRightMargin - 2 * itemHeight - itemPadding - 3 * itemPadding
        lookView.layer.cornerRadius = cornerRadius
        lookView.backgroundColor = SCColors.calendarEventBackground
        eventView.layer.cornerRadius = cornerRadius
        lookImageView.layer.cornerRadius = cornerRadius
        let layout = CenterViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        itemCollectionView.collectionViewLayout = layout
        itemCollectionView.register(cell: SetItemCollectionViewCell.self)
        itemCollectionView.updateInsets(horizontal: 0, vertical: 0, interItem: itemPadding, interRow: 2 * itemPadding)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandle(_:)))
        addGestureRecognizer(longPress)
    }
    
    func configure(_ eventModel: CalendarEventModel) {
        self.eventModel = eventModel
        let color = UIColor(hexString: eventModel.eventTypeParameterModel?.color ?? "")
        eventView.backgroundColor = color
        lookImageView.image = eventModel.setModel?.lookImage
        eventNameLabel.text = eventModel.eventTypeParameterModel?.name
        lookNameLabel.text = eventModel.name
        moreButton.isHidden = true
        let i : CGFloat = CGFloat(eventModel.setModel?.itemModels?.count ?? 0) / 4
        let roundCount = Int(i.rounded(.up))
        dotView.configure(numberOfDots: roundCount)
        selectedIndex()
        itemCollectionView.reloadData()
    }

}

//MARK:- Button Action
extension CalendarLookCollectionViewCell {
    @IBAction func moreClick(_ sender: Any) {
        
    }
}

// MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension CalendarLookCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout   {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventModel?.setModel?.itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : SetItemCollectionViewCell = collectionView.dequeueReusableCell(SetItemCollectionViewCell.self, indexPath: indexPath)
        if let itemModel = eventModel?.setModel?.itemModels?[indexPath.row] {
            cell.configue(image: itemModel.image)
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectedIndex()
    }
    
    func selectedIndex() {
        guard let cell = itemCollectionView.visibleCells.last else {
            dotView.selectIndex(index: 0)
            return
        }
        let indexPath = itemCollectionView.indexPath(for: cell)
        let index = indexPath!.row / 4
        dotView.selectIndex(index: index)
    }
}

//MARK:- ItemSelectViewDelegate
extension CalendarLookCollectionViewCell: ItemSelectViewDelegate {
    func selectButton(type: ItemSelectType) {
        switch type {
        case .edit:
            delegate?.editAction(cell: self)
        case .delete:
            delegate?.deleteAction(cell: self)
        default:
            break
        }
    }
    
    @objc func longPressHandle(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            if let hostView = UIApplication.appDelegate.tabBarController.view {
                let editSelectView = ItemSelectView.instanceFromNib()
                editSelectView.frame = hostView.bounds
                editSelectView.delegate = self
                hostView.addSubview(editSelectView)
                let customView = Bundle.main.loadNibNamed("CalendarLookCollectionViewCell", owner: nil, options: nil)?[0] as? CalendarLookCollectionViewCell
                customView?.frame = frame
                customView?.backgroundColor = UIColor.clear
                customView?.configure(eventModel!)
                editSelectView.appearOnView(.event, hostView, "Edit Event", "Delete Event", customView ?? UIView())
            }
        }
    }
}



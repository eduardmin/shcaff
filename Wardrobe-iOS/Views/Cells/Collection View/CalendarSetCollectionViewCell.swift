//
//  CalendarSetCollectionViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/6/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

protocol CalendarSetCollectionViewCellDelegate: class {
    func deleteAction(cell: CalendarSetCollectionViewCell)
    func editAction(cell: CalendarSetCollectionViewCell)
}

class CalendarSetCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var setNameLabel: UILabel!
    @IBOutlet weak var setCollectionView: UICollectionView!
    @IBOutlet weak var setView: UIView!
    @IBOutlet weak var eventView: UIView!
    private let cornerRadius: CGFloat = 20
    private let leftRightMargin : CGFloat = 36
    private let itemPadding : CGFloat = 10
    private var itemHeight : CGFloat {
        return  (UIScreen.main.bounds.width - 2 * leftRightMargin - 3 * itemPadding) / 4
    }
    private var eventModel: CalendarEventModel?
    weak var delegate: CalendarSetCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        moreButton.isHidden = true
        setView.layer.cornerRadius = cornerRadius
        setView.backgroundColor = SCColors.calendarEventBackground
        eventView.layer.cornerRadius = cornerRadius
        setCollectionView.register(cell: SetItemCollectionViewCell.self)
        setCollectionView.updateInsets(horizontal: 0, vertical: 0, interItem: itemPadding, interRow: itemPadding)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandle(_:)))
        addGestureRecognizer(longPress)
    }
    
    func configure(_ eventModel: CalendarEventModel) {
        self.eventModel = eventModel
        let color = UIColor(hexString: eventModel.eventTypeParameterModel?.color ?? "")
        eventView.backgroundColor = color
        eventNameLabel.text = eventModel.eventTypeParameterModel?.name
        setNameLabel.text = eventModel.name
        setCollectionView.reloadData()
    }
}

//MARK:- Button Action
extension CalendarSetCollectionViewCell {
    @IBAction func moreClick(_ sender: Any) {
        
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension CalendarSetCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventModel?.setModel?.itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(SetItemCollectionViewCell.self, indexPath: indexPath) as! SetItemCollectionViewCell
        let itemModel = eventModel?.setModel?.itemModels?[indexPath.row]
        if let image = itemModel?.image {
            cell.configue(image: image)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemHeight, height: itemHeight)
    }
}

//MARK:- ItemSelectViewDelegate
extension CalendarSetCollectionViewCell: ItemSelectViewDelegate {
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
                let customView = Bundle.main.loadNibNamed("CalendarSetCollectionViewCell", owner: nil, options: nil)?[0] as? CalendarSetCollectionViewCell
                customView?.frame = frame
                customView?.backgroundColor = UIColor.clear
                customView?.configure(eventModel!)
                editSelectView.appearOnView(.event, hostView, "Edit Event", "Delete Event", customView ?? UIView())
            }
        }
    }
}

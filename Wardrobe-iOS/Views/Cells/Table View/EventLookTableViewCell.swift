//
//  EventLookTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/29/20.
//

import UIKit

protocol EventLookTableViewCellDelegate: class {
    func changeAction()
}

class EventLookTableViewCell: UITableViewCell {

    @IBOutlet weak var lookImageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionWidth: NSLayoutConstraint!
    @IBOutlet weak var changeButton: UIButton!
    weak var delegate: EventLookTableViewCellDelegate?
    private let itemPadding : CGFloat = 10
    private let margin: CGFloat = 20
    private let leftRightMargin: CGFloat = 16
    private let lookWidth: CGFloat = 166
    private let itemHeight: CGFloat = 60
    let layout = CenterViewFlowLayout()
    private var setModel: SetModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        changeButton.setTitle("Change".localize(), for: .normal)
        lookImageView.layer.cornerRadius = 10
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.register(cell: SetItemCollectionViewCell.self)
        collectionView.updateInsets(interItem:itemPadding, interRow: itemPadding)

    }
    
    @IBAction func changeAction(_ sender: Any) {
        delegate?.changeAction()
    }
    
    func configure(_ setModel: SetModel, isEdit: Bool) {
        self.setModel = setModel
        changeButton.isHidden = !isEdit
        lookImageView.image = setModel.lookImage
        layout.itemSize = CGSize(width: itemHeight, height: itemHeight)
        collectionWidth.constant = 2 * itemHeight + itemPadding
        if setModel.lookId != nil {
            imageHeightConstraint.constant = round(lookWidth * setModel.multipleHeight)
            imageWidthConstraint.constant = lookWidth
        } else {
            imageWidthConstraint.constant = UIScreen.main.bounds.width / 2 - collectionWidth.constant / 2 - 40
            imageHeightConstraint.constant = collectionWidth.constant 
        }
        collectionView.reloadData()
    }
}

//MARK:-  UICollectionViewDelegate, UICollectionViewDataSource
extension EventLookTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout   {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return setModel?.itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : SetItemCollectionViewCell = collectionView.dequeueReusableCell(SetItemCollectionViewCell.self, indexPath: indexPath)
        let itemModel = setModel?.itemModels?[indexPath.row]
        cell.configue(image: itemModel!.image, cornerRadius: 10)
        return cell
    }
}


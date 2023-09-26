//
//  LookItemTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/30/20.
//

import UIKit
import UPCarouselFlowLayout

protocol LookItemTableViewCellDelegate: AnyObject {
    func selectItem(cell: LookItemTableViewCell, index: Int)
}

class LookItemTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: LookItemTableViewCellDelegate?
    let leftRightMargin: CGFloat = 16
    let padding: CGFloat = 30
    let itemHeigth: CGFloat = 163
    var itemModels: [ItemModel]?
    var section: ItemSectionModel?
    var currentPage = 0
    private var isReload: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: itemHeigth, height: itemHeigth)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.updateInsets(horizontal: leftRightMargin, vertical: leftRightMargin, interItem: padding, interRow: padding)
        collectionView.register(cell: LookItemCollectionViewCell.self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isReload {
            collectionView.scrollToItem(at: IndexPath(row: section?.selectionIndex ?? 0, section: 0), at: .centeredHorizontally, animated: false)
        }
    }

    func configure(_ section: ItemSectionModel) {
        self.itemModels = section.items
        self.section = section
        collectionView.reloadData()
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension LookItemTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isReload = true
        return itemModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(LookItemCollectionViewCell.self, indexPath: indexPath) as LookItemCollectionViewCell
        let itemModel = itemModels![indexPath.row]
        let image = itemModel.image
        cell.configure(image)
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = collectionView.visibleCells
        var indexPath : IndexPath?
        
        cells.forEach { (cell) in
            if cell.alpha > 0.9 {
                indexPath = collectionView.indexPath(for: cell)
            }
        }
        if let path = indexPath {
            delegate?.selectItem(cell: self, index: path.row)
        }
    }
}

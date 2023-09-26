//
//  FeadbackRecommendTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/29/22.
//  Copyright © 2022 Schaff. All rights reserved.
//

import UIKit

protocol FeadbackRecommendTableViewCellDelegate: AnyObject {
    func select(score: Int)
    func deselect(score: Int)
}

class FeadbackRecommendTableViewCell: UITableViewCell {
    @IBOutlet weak var recommendLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: FeadbackRecommendTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    func configureUI() {
        let interItem = Int((UIScreen.main.bounds.width - 330) / 9)
        collectionView.updateInsets(horizontal: 19, interItem: CGFloat(interItem), interRow: CGFloat(interItem))
        collectionView.register(cell: FeadbackRateCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func configure(question: SurveyQuestionModel) {
        recommendLabel.text = question.displayQuestion
    }
}

extension FeadbackRecommendTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FeadbackRateCollectionViewCell = collectionView.dequeueReusableCell(FeadbackRateCollectionViewCell.self, indexPath: indexPath)
        cell.configure(text: "\(indexPath.row + 1)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 26, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CellSelectionProtocol
        cell?.select()
        delegate?.select(score: indexPath.row + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CellSelectionProtocol
        cell?.deselect()
        delegate?.deselect(score: indexPath.row + 1)
    }
}

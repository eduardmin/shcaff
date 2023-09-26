//
//  FeadbackParameterTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/30/22.
//  Copyright © 2022 Schaff. All rights reserved.
//

import UIKit

protocol FeadbackParameterTableViewCellDelegate: AnyObject {
    func selectAnswer(answerId: Int)
}

class FeadbackParameterTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    private var question: SurveyQuestionModel?
    private var answers: [SurveyAnswerModel]?
    weak var delegate: FeadbackParameterTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = UICollectionViewFlowLayout.automaticSize
        collectionView.register(cell: ItemTypeCollectionViewCell.self)
        collectionView.updateInsets(horizontal: 19, interItem: 10, interRow: 8, estimatedSize: CGSize(width: 100, height: 40))
    }
    
    func configure(question: SurveyQuestionModel) {
        self.question = question
        answers = question.answers?.sorted(by: { $0.order < $1.order })
        titleLabel.text = question.displayQuestion
        collectionView.reloadData()

    }
}

//MARK:- UICollectionViewDelegate && UICollectionViewDataSource
extension FeadbackParameterTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : ItemTypeCollectionViewCell = collectionView.dequeueReusableCell(ItemTypeCollectionViewCell.self, indexPath: indexPath)
        if let answer = answers?[indexPath.row] {
            cell.configure(info: answer.displayAnswer, isSelected: false)
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CellSelectionProtocol
        cell?.select()
        if let answer = answers?[indexPath.row] {
            delegate?.selectAnswer(answerId: answer.answerId)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CellSelectionProtocol
        cell?.deselect()
    }
}


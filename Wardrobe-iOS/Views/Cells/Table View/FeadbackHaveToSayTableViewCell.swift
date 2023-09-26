//
//  FeadbackHaveToSayTableViewCell.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/29/22.
//  Copyright © 2022 Schaff. All rights reserved.
//

import UIKit

protocol FeadbackHaveToSayTableViewCellDelegate: AnyObject {
    func updateAnswerText(text: String?)
}

class FeadbackHaveToSayTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    private let placeholderText: String = "We’d love to hear what you think about the app...".localize()
    weak var delegate: FeadbackHaveToSayTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    func configureUI() {
        textView.text = placeholderText
        textView.textColor = SCColors.mainGrayColor
        textView.layer.cornerRadius = 30
        textView.layer.borderWidth = 1
        textView.layer.borderColor = SCColors.secondaryGray.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        textView.delegate = self
    }
    
    func configure(question: SurveyQuestionModel) {
        titleLabel.text = question.displayQuestion
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == SCColors.mainGrayColor {
            textView.text = nil
            textView.textColor = SCColors.titleColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = SCColors.mainGrayColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.updateAnswerText(text: textView.text)
    }
}


//
//  FeadbackView.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/29/22.
//  Copyright © 2022 Schaff. All rights reserved.
//

import UIKit

enum FeadbackRow: Int {
    case recommend
    case param
    case somethingSay
}

protocol FeadbackViewDelegate: AnyObject {
    func expendFeadbackView(expend: Bool)
    func enableSubmitButton(enable: Bool)
    func submitSuccess()
    func submitFailed()
}

class FeadbackView: UIView {
    private var feadbackImage: UIImageView = UIImageView()
    private var feadbackLabel: UILabel = UILabel()
    private var tableView: UITableView = UITableView()
    private var expendMode = false
    public var surveyViewModel: SurveysViewModel?
    
    weak var delegate: FeadbackViewDelegate?
    func configure() {
        configureUI()
    }
    
    //MARK: -UI Configuration
    private func configureUI() {
        configureImageAndTitle()
        configureTableView()
        observers()
    }
    
    private func observers() {
        surveyViewModel?.success.bind(listener: { [weak self] value in
            guard let strongSelf = self else { return }
            if value {
                strongSelf.delegate?.submitSuccess()
            } else {
                strongSelf.delegate?.submitFailed()
            }
        })
    }
    
    private func configureImageAndTitle() {
        feadbackImage.image = UIImage(named: "feadbackOrange")
        feadbackLabel.text = surveyViewModel?.surveyModel?.displayName
        feadbackLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        feadbackLabel.textColor = SCColors.feadbackColor
        addSubview(feadbackImage)
        addSubview(feadbackLabel)
        feadbackLabel.translatesAutoresizingMaskIntoConstraints = false
        feadbackImage.translatesAutoresizingMaskIntoConstraints = false
        feadbackImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 19).isActive = true
        feadbackImage.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        feadbackImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        feadbackImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
        feadbackLabel.leftAnchor.constraint(equalTo: feadbackImage.rightAnchor, constant: 16).isActive = true
        feadbackLabel.centerYAnchor.constraint(equalTo: feadbackImage.centerYAnchor).isActive = true
    }
    
    private func configureTableView() {
        tableView.separatorStyle = .none
        tableView.register(cell: FeadbackRecommendTableViewCell.self)
        tableView.register(cell: FeadbackHaveToSayTableViewCell.self)
        tableView.register(cell: FeadbackParameterTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: feadbackImage.bottomAnchor, constant: 40).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }
    
    private func checkSubmitButton() {
        guard let surveyViewModel = surveyViewModel else { return }
        if surveyViewModel.userScore >= 1 && surveyViewModel.answerId != nil {
            delegate?.enableSubmitButton(enable: true)
        } else {
            delegate?.enableSubmitButton(enable: false)
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension FeadbackView: UITableViewDelegate, UITableViewDataSource, FeadbackRecommendTableViewCellDelegate, FeadbackParameterTableViewCellDelegate, FeadbackHaveToSayTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expendMode {
            return FeadbackRow.somethingSay.rawValue + 1
        } else {
            return FeadbackRow.somethingSay.rawValue
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = FeadbackRow(rawValue: indexPath.row)!
        switch type {
        case .recommend:
            let cell: FeadbackRecommendTableViewCell = tableView.dequeueReusableCell(FeadbackRecommendTableViewCell.self)
            cell.delegate = self
            cell.selectionStyle = .none
            if let scoreQuestion = surveyViewModel?.scoreQuestion() {
                cell.configure(question: scoreQuestion)
            }
            cell.delegate = self
            return cell
        case .param:
            if expendMode {
                let cell: FeadbackParameterTableViewCell = tableView.dequeueReusableCell(FeadbackParameterTableViewCell.self)
                cell.selectionStyle = .none
                cell.delegate = self
                if let question = surveyViewModel?.paramQuestion() {
                    cell.configure(question: question)
                }
                return cell
            } else {
                return feadbackHaveToSayCell(indexPath: indexPath)
            }
        case .somethingSay:
            return feadbackHaveToSayCell(indexPath: indexPath)
        }
    }
    
    private func feadbackHaveToSayCell(indexPath: IndexPath) -> FeadbackHaveToSayTableViewCell {
        let cell: FeadbackHaveToSayTableViewCell = tableView.dequeueReusableCell(FeadbackHaveToSayTableViewCell.self)
        cell.selectionStyle = .none
        cell.delegate = self
        if let textQuestion = surveyViewModel?.textQuestion() {
            cell.configure(question: textQuestion)
        }
        return cell
    }
    
    func select(score: Int) {
        surveyViewModel?.setScore(score: score)
        checkSubmitButton()
        expendMode = true
        delegate?.expendFeadbackView(expend: expendMode)
        tableView.reloadData()
    }
    
    func deselect(score: Int) {
        expendMode = false
        delegate?.expendFeadbackView(expend: expendMode)
        tableView.reloadData()
    }
    
    func selectAnswer(answerId: Int) {
        surveyViewModel?.setAnswerIdScore(answerId: answerId)
        checkSubmitButton()
    }
    
    func updateAnswerText(text: String?) {
        surveyViewModel?.setAnswerText(answerText: text)
    }
}

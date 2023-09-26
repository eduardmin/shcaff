//
//  SurveysViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/4/22.
//  Copyright © 2022 Schaff. All rights reserved.
//

import UIKit

class SurveysViewModel {
    private let surveysWebService = SurveysWebService()
    private var sendRequest = false
    public var surveyModel: SurveyModel?
    public var updateSurvey = Observable(false)
    public var success = Observable(false)
    public var userScore: Int = -1
    public var answerId: Int?
    public var answerText: String?
    init() {
        addObserver()
        getSurveys()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnection(_:)), name: NSNotification.Name(rawValue: NotificationName.noInternet), object: nil)
    }
    
    @objc private func handleConnection(_ notification: NSNotification) {
        let isReachable = notification.object as! Int
        if isReachable == 1 && surveyModel == nil && !sendRequest {
            getSurveys()
        }
    }
    
    private func getSurveys() {
        if !haveConnection() || sendRequest {
            return
        }
        sendRequest = true
        surveysWebService.getSurvey { [weak self] response in
            guard let strongSelf = self else { return }
            if let response = response, !response.isEmpty {
                strongSelf.surveyModel = SurveyModel(dict: response.first ?? [:])
                strongSelf.updateSurvey.value = true
            }
        }
    }
    
    public func saveSurvey() {
        var userAnswer = [[String: Any]]()
        userAnswer.append(["questionId": scoreQuestion()?.questionId ?? 0, "answer": userScore])
        userAnswer.append(["questionId": paramQuestion()?.questionId ?? 0, "answerId": answerId ?? 0])
        if let answerText = answerText, !answerText.isEmpty {
            userAnswer.append(["questionId": textQuestion()?.questionId ?? 0, "answer": answerText])
        }
        surveysWebService.saveSurvey(surveyId: surveyModel?.surveyId ?? 0, answers: userAnswer) { [weak self] success in
            guard let strongSelf = self else { return }
            strongSelf.success.value = success
        }
    }
    
    public func setScore(score: Int) {
        if userScore != score {
            answerId = nil
        }
        userScore = score
    }
    
    public func setAnswerIdScore(answerId: Int) {
        self.answerId = answerId
    }
    
    public func setAnswerText(answerText: String?) {
        self.answerText = answerText
    }
    
    public func paramQuestion() -> SurveyQuestionModel? {
        if let firstQuestion = surveyModel?.questions.first {
            if userScore > 5 {
                return firstQuestion.positiveDependentQuestions?.first
            } else {
                return firstQuestion.negativeDependentQuestions?.first
            }
        }
        return nil
    }
    
    public func textQuestion() -> SurveyQuestionModel? {
        return surveyModel?.questions.filter({ $0.answerType == .text }).first
    }
    
    public func scoreQuestion() -> SurveyQuestionModel? {
        return surveyModel?.questions.filter({ $0.answerType == .score }).first
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

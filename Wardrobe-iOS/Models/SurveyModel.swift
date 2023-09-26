//
//  SurveyQuestionModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/4/22.
//  Copyright © 2022 Schaff. All rights reserved.
//

import UIKit

enum AnswerType: Int {
    case score = 1
    case multiselect = 2
    case singleSelect = 3
    case text = 4
}

class SurveyModel {
    let surveyId: Int
    let name: String
    let nameRu: String
    var questions: [SurveyQuestionModel]

    var displayName: String {
        let currentLanguageKey = LanguageManager.manager.currentLanguge().key
        let type = LanguageType(rawValue: currentLanguageKey)
        switch type {
        case .english:
            return name
        case .russian:
            return nameRu
        case .none:
            return name
        }
    }
    init(dict: [String: Any]) {
        surveyId = dict["surveyId"] as? Int ?? 0
        name = dict["name"] as? String ?? ""
        nameRu = dict["nameRu"] as? String ?? ""
        questions = []
        let questionArray = dict["questions"] as? [[String: Any]] ?? []
        questionArray.forEach { response in
            let questionModel = SurveyQuestionModel(dict: response)
            questions.append(questionModel)
        }
    }
}

class SurveyQuestionModel {
    let questionId: Int
    let question: String
    let questionRu: String
    let answerTypeId: Int
    let optional: Bool
    var positiveDependentQuestions: [SurveyQuestionModel]?
    var negativeDependentQuestions: [SurveyQuestionModel]?
    var answers: [SurveyAnswerModel]?
    var displayQuestion: String {
        let currentLanguageKey = LanguageManager.manager.currentLanguge().key
        let type = LanguageType(rawValue: currentLanguageKey)
        switch type {
        case .english:
            return question
        case .russian:
            return questionRu
        case .none:
            return question
        }
    }
    var answerType: AnswerType {
        return AnswerType(rawValue: answerTypeId) ?? .score
    }
    
    init(dict: [String: Any]) {
        questionId = dict["questionId"] as? Int ?? 0
        question = dict["question"] as? String ?? ""
        questionRu = dict["questionRu"] as? String ?? ""
        answerTypeId = dict["answerTypeId"] as? Int ?? 0
        optional = dict["optional"] as? Bool ?? true
        
        if let answersArray = dict["answers"] as? [[String: Any]] {
            answers = []
            answersArray.forEach { response in
                let answer = SurveyAnswerModel(dict: response)
                answers?.append(answer)
            }
        }
        
        if let positiveDependentQuestionsArray = dict["positiveDependentQuestions"] as? [[String: Any]] {
            positiveDependentQuestions = []
            positiveDependentQuestionsArray.forEach { response in
                let questionModel = SurveyQuestionModel(dict: response)
                positiveDependentQuestions?.append(questionModel)
            }
        }
        
        if let negativeDependentQuestionsArray = dict["negativeDependentQuestions"] as? [[String: Any]] {
            negativeDependentQuestions = []
            negativeDependentQuestionsArray.forEach { response in
                let questionModel = SurveyQuestionModel(dict: response)
                negativeDependentQuestions?.append(questionModel)
            }
        }
    }
}

class SurveyAnswerModel {
    let answerId: Int
    let answer: String
    let answerRu: String
    let order: Int
    var displayAnswer: String {
        let currentLanguageKey = LanguageManager.manager.currentLanguge().key
        let type = LanguageType(rawValue: currentLanguageKey)
        switch type {
        case .english:
            return answer
        case .russian:
            return answerRu
        case .none:
            return answer
        }
    }
    
    init(dict: [String: Any]) {
        answerId = dict["answerId"] as? Int ?? 0
        answer = dict["answer"] as? String ?? ""
        answerRu = dict["answerRu"] as? String ?? ""
        order = dict["order"] as? Int ?? 0
    }
}


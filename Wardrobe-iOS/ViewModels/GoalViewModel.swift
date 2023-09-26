//
//  GoalViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 11/18/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum GoalResponse {
    case update(Bool)
    case save(Bool)
}

enum GoalViewModelType {
    case login
    case account
}

class GoalViewModel {
    private var goalModels = [GoalModel]()
    public var tempSaveModelIds = [Int]()
    var completion: ((GoalResponse) -> ())?
    public var type: GoalViewModelType = .login
    func startGetAll() {
        if type == .login {
            getGoals()
        } else {
            getAccountGoals()
        }
    }
    
    public func saveGoals() {
        let isGoalSet = UserDefaults.standard.bool(forKey: UserDefaultsKey.goal)
        if type == .login && !isGoalSet {
            let goalWebService = GoalWebService()
            goalWebService.saveGoal(ids: tempSaveModelIds) { [weak self] (success) in
                guard let strongSelf = self else { return }
                strongSelf.completion?(.save(success))
            }
        } else {
            let goalWebService = GoalWebService()
            goalWebService.updateGoal(ids: tempSaveModelIds) { [weak self] (success) in
                guard let strongSelf = self else { return }
                strongSelf.completion?(.save(success))
            }
        }
    }
    
    private func getGoals() {
        let goalWebService = GoalWebService()
        goalWebService.getGoals { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error {
                strongSelf.completion?(.update(false))
                return
            }
            
            if let response = response {
                strongSelf.handleGoals(response: response)
                strongSelf.completion?(.update(true))
            } else {
                strongSelf.completion?(.update(false))
                return
            }
        }
    }
    
    private func getAccountGoals() {
        let goalWebService = GoalWebService()
        let group = DispatchGroup()
        var isError = false
        group.enter()
        goalWebService.getGoals { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if isError {
                isError = true
            }
            if let response = response {
                strongSelf.handleGoals(response: response)
            }
            group.leave()
        }
        
        group.enter()
        goalWebService.getPersonalGoals { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if isError {
                isError = true
            }
            if let response = response {
                strongSelf.handleSaveGoals(response: response)
            }
            group.leave()
        }
        
        group.notify(queue: .main, execute: {
            self.completion?(.update(!isError))
        })

    }
    
    func countOfGoals() -> Int {
        return goalModels.count
    }
    
    func getGoal(index: Int) -> GoalModel {
        return goalModels[index]
    }
    
    func select(index: Int) {
        tempSaveModelIds.append(getGoal(index: index).id)
    }
    
    func deselect(index: Int) {
        if let index = tempSaveModelIds.firstIndex(of:getGoal(index: index).id) {
            tempSaveModelIds.remove(at: index)
        }
    }
    
    func getSelectedGoalIds(indexPaths: [IndexPath]) -> [Int] {
        var ids: [Int] = [Int]()
        for indexPath in indexPaths {
            let goalModel = getGoal(index: indexPath.row)
            ids.append(goalModel.id)
        }
        return ids
    }
    
    private func handleGoals(response: [[String: Any]]) {
        goalModels.removeAll()
        response.forEach { (dict) in
            let goalModel = GoalModel(dict)
            goalModels.append(goalModel)
        }
    }
    
    private func handleSaveGoals(response: [[String: Any]]) {
        tempSaveModelIds.removeAll()
        response.forEach { (dict) in
            let goalModel = GoalModel(dict)
            tempSaveModelIds.append(goalModel.id)
        }
    }
}

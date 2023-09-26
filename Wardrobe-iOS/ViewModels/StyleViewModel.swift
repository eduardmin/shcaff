//
//  StyleViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/10/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum StyleResponse {
    case update(Bool)
    case save(Bool)
}

enum StyleViewModelType {
    case login
    case account
}


class StyleViewModel {
    private var styleModels = [StyleModel]()
    public var tempSaveModelIds = [Int]()
    public var type: StyleViewModelType = .login

    var completion: ((StyleResponse) -> ())?

    func startGetAll() {
        if type == .login {
            getStyles()
        } else {
            getAccountStyles()
        }
    }
    
    public func saveStyles() {
        let isStyleSet = UserDefaults.standard.bool(forKey: UserDefaultsKey.style)
        if type == .login && !isStyleSet {
            let styleWebService = StyleWebService()
            styleWebService.saveStyle(ids: tempSaveModelIds) { [weak self] (success) in
                guard let strongSelf = self else { return }
                strongSelf.completion?(.save(success))
            }
        } else {
            let styleWebService = StyleWebService()
            styleWebService.updateStyle(ids: tempSaveModelIds) { [weak self] (success) in
                guard let strongSelf = self else { return }
                strongSelf.completion?(.save(success))
            }
        }
    }
    
    private func getStyles() {
        let styleWebService = StyleWebService()
        styleWebService.getStyles { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error {
                strongSelf.completion?(.update(false))
                return
            }
            
            if let response = response {
                strongSelf.handleStyles(response: response)
                strongSelf.completion?(.update(true))
            } else {
                strongSelf.completion?(.update(false))
                return
            }
        }
    }
    
    private func getAccountStyles() {
        let styleWebService = StyleWebService()
        let group = DispatchGroup()
        var isError = false
        group.enter()
        styleWebService.getStyles { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if isError {
                isError = true
            }
            if let response = response {
                strongSelf.handleStyles(response: response)
            }
            group.leave()
        }
        
        group.enter()
        styleWebService.getPersonalStyles { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if isError {
                isError = true
            }
            if let response = response {
                strongSelf.handleSaveStyles(response: response)
            }
            group.leave()
        }
        
        group.notify(queue: .main, execute: {
            self.completion?(.update(!isError))
        })
    }

    
    func countOfStyles() -> Int {
        return styleModels.count
    }
    
    func getStyle(index: Int) -> StyleModel {
        return styleModels[index]
    }
    
    func select(index: Int) {
        tempSaveModelIds.append(getStyle(index: index).id)
    }
    
    func deselect(index: Int) {
        if let index = tempSaveModelIds.firstIndex(of:getStyle(index: index).id) {
            tempSaveModelIds.remove(at: index)
        }
    }
    
    func getSelectedStyleIds(indexPaths: [IndexPath]) -> [Int] {
        var ids: [Int] = [Int]()
        for indexPath in indexPaths {
            let styleModel = getStyle(index: indexPath.row)
            ids.append(styleModel.id)
        }
        return ids
    }
    
    private func handleStyles(response: [[String: Any]]) {
        styleModels.removeAll()
        response.forEach { (dict) in
            let styleModel = StyleModel(dict)
            styleModels.append(styleModel)
        }
    }
    
    private func handleSaveStyles(response: [[String: Any]]) {
        tempSaveModelIds.removeAll()
        response.forEach { (dict) in
            let styleModel = StyleModel(dict)
            tempSaveModelIds.append(styleModel.id)
        }
    }
}

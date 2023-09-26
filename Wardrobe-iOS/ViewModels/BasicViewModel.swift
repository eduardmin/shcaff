//
//  BasicViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/10/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum BasicResponse {
    case update(Bool)
    case save(Bool)
}

class BasicViewModel {
    private let coreDataManager = CoreDataManager.shared
    private var clothingTypes = [BaseParameterModel]()
    private var itemModels = [ItemModel]()
    private var savedItems = [ItemModel]()
    private var basicItems = [Int64: [ItemModel]]()
    private var selectedItemIds = [Int64]()
    private weak var syncManager = UIApplication.appDelegate.synchronizationManager
    private var requestFail = false
    private var constantsRequestSuccess = false
    private var itemsRequestSuccess = false
    private let genderId: Int16? = UIApplication.appDelegate.profileModel?.genderId()
    var type: BasicType = .login
    var completion: ((BasicResponse) -> ())?

    init() {
        getConstants()
        getDefaultItems()
    }
    
    deinit {
        print("")
    }    
}
//MARK:- Public Func
extension BasicViewModel {
    
    func saveDefaultItems() {
        if selectedItemIds.isEmpty {
            completion?(.save(true))
            return
        }
        let defaultItemWebService = DefaultItemWebService()
        defaultItemWebService.saveDefaultItems(ids: selectedItemIds) { [weak self] (success) in
            guard let strongSelf = self else { return }
            if strongSelf.type == .login {
                strongSelf.completion?(.save(success))
            } else {
                strongSelf.saveItems()
            }
        }
    }
    
    func setSavedItems(itemModels: [ItemModel]) {
        savedItems = itemModels
    }
    
    func countOfClothingTypes() -> Int {
        return clothingTypes.count
    }
    
    func getClothingType(index: Int) -> BaseParameterModel {
        return clothingTypes[index]
    }
    
    func getAllClothingTypes() -> [BaseParameterModel] {
        return clothingTypes
    }
    
    func getItems(with id: Int64) -> [ItemModel]? {
        return basicItems[id]
    }
    
    func selectItem(withId id: Int64) {
        if !selectedItemIds.contains(id) {
            selectedItemIds.append(id)
        }
    }
    
    func deselectItem(withId id: Int64) {
        if let index = selectedItemIds.firstIndex(of: id) {
            selectedItemIds.remove(at: index)
        }
    }
    
    func selectedItems() -> [Int64] {
        return selectedItemIds
    }
}

//MARK:- Private Func
extension BasicViewModel {
    private func getConstants() {
         syncManager?.sendConstantsRequest({ [weak self] (isFinish, isInternalError) in
             guard let strongSelf = self else { return }
             if isFinish {
                strongSelf.constantsRequestSuccess = true
                strongSelf.getClothingTypes()
                if strongSelf.itemsRequestSuccess {
                    strongSelf.getBasicItems()
                }
             } else {
                if !strongSelf.requestFail {
                    strongSelf.completion?(.update(false))
                    strongSelf.requestFail = true
                }
             }
         })
     }
     
     private func getClothingTypes() {
        clothingTypes.removeAll()
         if var constants = coreDataManager.getConstants(.clothingTypes, genderId) {
             constants.sort {$0.id < $1.id}
             for constant in constants {
                let model = BaseParameterModel(constant.id, constant.names, .clothingType)
                 clothingTypes.append(model)
             }
         }
     }
    
    private func getDefaultItems() {
        itemModels.removeAll()
        let defaultItemWebService = DefaultItemWebService()
        defaultItemWebService.getDefaultItems { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error {
                if !strongSelf.requestFail {
                    strongSelf.completion?(.update(false))
                    strongSelf.requestFail = true
                }
                return
            }
            
            if let response = response {
                response.forEach { (item) in
                    strongSelf.itemsRequestSuccess = true
                    let itemModel = ItemModel(item)
                    if !strongSelf.savedItems.contains(where: { $0.id == itemModel.id}) {
                        strongSelf.itemModels.append(itemModel)
                    }
                }
                if strongSelf.constantsRequestSuccess {
                    strongSelf.getBasicItems()
                }
            } else {
                if !strongSelf.requestFail {
                    strongSelf.completion?(.update(false))
                    strongSelf.requestFail = true
                }
                return
            }
        }
    }
    
    private func getBasicItems() {
        basicItems.removeAll()
        var _clothingTypes = clothingTypes
        for type in clothingTypes {
            let items = itemModels.filter {$0.clothingType == type.id}
            if !items.isEmpty {
                let sortArray = items.sorted(by: { $0.itemType ?? -1 < $1.itemType ?? -1 })
                basicItems[type.id] = sortArray
            } else {
                if let index = _clothingTypes.firstIndex(of: type) {
                    _clothingTypes.remove(at: index)
                }
            }
        }
        clothingTypes = _clothingTypes
        completion?(.update(true))
    }
    
    private func saveItems() {
        let itemWebService = ItemWebService()
        itemWebService.getItems { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.completion?(.save(false))
                return
            }
            
            if let response = response as? [[String: Any]] {
                strongSelf.handleItems(response: response)
            }
        }
    }
    
    private func handleItems(response: [[String: Any]]) {
        response.forEach { (item) in
            let model = ItemModel(item)
            var waitCount = 0
            if selectedItemIds.contains(where: { $0 == model.id}) {
                var isDownload = true
                if let id = model.id, let item = CoreDataManager.shared.objectWithID(id: id, entityName: EntityName.item) as? Item {
                    if item.updateTs?.int64Value == model.updateTs {
                        isDownload = false
                    }
                }
                if isDownload {
                    waitCount += 1
                    FileUploadDownloadManager.manager.itemDownload(id: model.id!, url: model.url!) { [weak self] (isFinish) in
                        DispatchQueue.main.async {
                            waitCount -= 1
                            if waitCount == 0 {
                                self?.completion?(.save(true))
                            }
                        }
                    }
                }
                CoreDataJsonParserManager.shared.createItem(model)
            }
            if waitCount == 0 {
                completion?(.save(true))
            }
        }
    }
}

//
//  CreateLookViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/18/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum CreateLookUpdateType {
    case update
    case selectItemUpdate
}

class CreateLookViewModel {
    private let coreDataManager = CoreDataManager.shared
    private var selectedTypes = [BaseParameterModel]()
    public var clothingTypes = [(param: BaseParameterModel, empty: Bool)]()
    public var sectionModels = [ItemSectionModel]()
    public var updateCompletion: ((CreateLookUpdateType) -> ())?
    public var completion :  ((RequestResponseType) -> ())?
    public var selectedItems = [ItemModel]()
    public var defaultItemModel: ItemModel?
    public var loadMore: Bool = true
    public  var lookModels = [LookModelSuggestion]()
    init() {
    }
    
    func getObjects() {
        getClothingTypes()
    }
    
    func setDefaultItem(itemModel: ItemModel) {
        defaultItemModel = itemModel
        UserDefaults.standard.set(itemModel.clothingType, forKey: UserDefaultsKey.selectedCategory)
    }
    
    //MARK:- Public Func
    public func selectType(_ index: Int) {
        let type = clothingTypes[index].param
        if emptyType() {
            UserDefaults.standard.set(type.id, forKey: UserDefaultsKey.selectedCategory)
        }
        selectedTypes.append(type)
        getItemsSelectedTypes(type: type)
    }
    
    public func selectItem(sectionIndex: Int, itemIndex: Int) {
        let sectionModel = sectionModels[sectionIndex]
        sectionModel.selectionIndex = itemIndex
        let itemModel = sectionModel.items[itemIndex]
        selectedItems[sectionIndex] = itemModel
        sortSelectedItems()
        clearLook()
        updateCompletion?(.update)
    }
    
    public func clearAll() {
        UserDefaults.standard.set(nil, forKey: UserDefaultsKey.selectedCategory)
        selectedTypes.removeAll()
        sectionModels.removeAll()
        selectedItems.removeAll()
        clearLook()
    }
    
    public func clearLook() {
        loadMore = true
        lookModels.removeAll()
    }
    
    public func emptyType() -> Bool {
        return UserDefaults.standard.object(forKey: UserDefaultsKey.selectedCategory) == nil
    }
    
}

//MARK:- Private Func
extension CreateLookViewModel {
    private func getClothingTypes() {
        let genderId: Int16? = UIApplication.appDelegate.profileModel?.genderId()
        if var constants = coreDataManager.getConstants(.clothingTypes, genderId) {
            constants.sort {$0.id < $1.id}
            for constant in constants {
                let model = BaseParameterModel(constant.id, constant.names, .clothingType)
                let count = coreDataManager.getClothingTypeItemCount(model.id)
                clothingTypes.append((model, count == 0))
            }
        }
        
        if !emptyType() {
            let id = UserDefaults.standard.object(forKey: UserDefaultsKey.selectedCategory) as? Int64
            if let type = clothingTypes.filter({ $0.param.id == id }).first?.param {
                getItemsSelectedTypes(type: type)
            }
        }
    }
    
    private func getItemsSelectedTypes(type: BaseParameterModel) {
        var items = getItems(type: type)
        if defaultItemModel != nil {
            if let index = items.firstIndex(where: { $0.id != nil ? $0.id == defaultItemModel?.id : $0.tempId ==  defaultItemModel?.tempId }) {
                items = items.changeElementToFirst(element: index)
            }
            defaultItemModel = nil
        }
        if !items.isEmpty {
            let sectionModel = ItemSectionModel(clothingTypeModel: type, items: items)
            sectionModels.append(sectionModel)
            let sorted = sectionModels.sorted { section1, section2 in
                let index1 = ClothingTypeId.createLookTypes.firstIndex { type in
                    type.rawValue == section1.clothingTypeModel.id
                }

                let index2 = ClothingTypeId.createLookTypes.firstIndex { type in
                    type.rawValue == section2.clothingTypeModel.id
                }
                return index1 ?? 0 < index2 ?? 0
            }
            sectionModels = sorted
            if let firstItem = items.first {
                selectedItems.append(firstItem)
                sortSelectedItems()
            }
            updateCompletion?(.update)
        }
    }
    
    private func getItems(type: BaseParameterModel) -> [ItemModel] {
        var itemModels = [ItemModel]()
        let predicate = NSPredicate(format: "clothingType == \(type.id)")
        if let items = coreDataManager.objectsForEntity(entityName: EntityName.item, predicates: [predicate]) as? [Item] {
            for item in items {
                let model = ItemModel(item)
                itemModels.append(model)
            }
        }
        return itemModels.reversed()
    }
    
    private func sortSelectedItems() {
        let sorted = selectedItems.sorted { item1, item2 in
            let index1 = ClothingTypeId.createLookTypes.firstIndex { type in
                type.rawValue == item1.clothingType
            }

            let index2 = ClothingTypeId.createLookTypes.firstIndex { type in
                type.rawValue == item2.clothingType
            }
            return index1 ?? 0 < index2 ?? 0
        }
        selectedItems = sorted
    }
}

//MARK:- Look
extension CreateLookViewModel {
    func getLooks(offset: Int = 0, limit: Int = 20) {
        if offset == 0 {
            completion?(.start(showLoading: true))
        }
        if !haveConnection() {
            completion?(.fail(showPopup: true))
            return
        }
        let filterItems = selectedItems.filter( {$0.id != nil })
        let ids = filterItems.map { (itemModel) -> Int64 in
            return itemModel.id!
        }
        let suggestionWebService = SuggestionWebService()
        suggestionWebService.getSetSuggestion(itemIds: ids, offset: offset, limit: limit) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.completion?(.fail(showPopup: true))
                return
            }
            if let response = response as? [[String: Any]] {
                strongSelf.handleResponse(response, loadingMore: offset != 0)
            }
        }
    }
    
    func loadMoreLooks() {
        let offset = lookModels.count
        getLooks(offset: offset)
    }
    
    func handleResponse(_ response: [[String: Any]], loadingMore: Bool = false) {
        if !loadingMore {
            loadMore = true
            lookModels.removeAll()
        }
        
        if response.isEmpty {
            loadMore = false
        }
        
        for lookResponse in response {
            let look = LookModelSuggestion(dict: lookResponse)
            lookModels.append(look)
        }
        completion?(.success(response: nil))
    }
}

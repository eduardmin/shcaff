//
//  ItemViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/26/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum ClothingTypeId: Int64 {
    case top = 1
    case bottom
    case footwear
    case outerwear
    case onePiece
    case accessories
    static var createLookTypes: [ClothingTypeId] = [.outerwear, .onePiece, .top, .bottom, .footwear, . accessories]
}

class ItemSectionModel {
    let clothingTypeModel: BaseParameterModel
    var items: [ItemModel]
    var selectionIndex: Int = 0
    init(clothingTypeModel: BaseParameterModel, items: [ItemModel]) {
        self.clothingTypeModel = clothingTypeModel
        self.items = items
    }
}

class ItemViewModel {
    private let coreDataManager = CoreDataManager.shared
    private let fileUploadDownloadManager = FileUploadDownloadManager.manager
    private var itemModels = [ItemModel]()
    public var sectionModels = [ItemSectionModel]()
    public var completion: (() -> ())?
    init() {
        getItems()
        getClothingType()
    }
    
    public func updateItems() {
        getItems()
        getClothingType()
        completion?()
    }
    
    public func deleteItem(model: ItemModel) {
        let isSend = CoreDataJsonParserManager.shared.deleteItem(model)
        updateItems()
        if !haveConnection() || !isSend {
            return
        }
        
        ItemManager.manager.deleteItems(itemModels: [model])
    }
    
    public func getBasicItems() -> [ItemModel] {
        return itemModels.filter { $0.personal == false }
    }
}

//MARK:- Private func
extension ItemViewModel {
    private func getItems() {
        let predicate = NSPredicate(format: "delete == \(false)")
        if let items = coreDataManager.objectsForEntity(entityName: EntityName.item, predicates: [predicate]) as? [Item] {
            itemModels.removeAll()
            for item in items {
                let model = ItemModel(item)
                itemModels.append(model)
            }
        }
    }
    
    private func getClothingType() {
        if var clothingTypes = coreDataManager.getConstants(.clothingTypes, nil) {
            sectionModels.removeAll()
            clothingTypes.sort {$0.id < $1.id}
            for clothingType in clothingTypes {
                let model = BaseParameterModel(clothingType.id, clothingType.names, .clothingType)
                let items = filterItems(withClothingType: model.id)
                if !items.isEmpty {
                    let sectionModel = ItemSectionModel(clothingTypeModel: model, items: items.reversed())
                    sectionModels.append(sectionModel)
                }
            }
        }
    }
    
    private func filterItems(withClothingType type: Int64) -> [ItemModel] {
        let items = itemModels.filter {$0.clothingType == type}
        return items
    }
}

//
//  ItemAllViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/31/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import Foundation

class ItemAllViewModel {
    var sectionModel: ItemSectionModel
    private var itemsWithFilter: [ItemModel]?
    var updateCompletion: (() -> ())?
    var filterItemModel: ItemModel
    init(model: ItemSectionModel) {
        sectionModel = model
        filterItemModel = ItemModel(generateRandomId())
        filterItemModel.clothingType = model.clothingTypeModel.id
    }
    
    public func setFilterItem(_ itemModel: ItemModel) {
        filterItemModel = itemModel
        filterItemModel.clothingType = sectionModel.clothingTypeModel.id
        itemsWithFilter = sectionModel.items.filter { $0.compareItems(itemModel: itemModel) }
        updateCompletion?()
    }
    
    public func getItemsCount() -> Int {
        if let items = itemsWithFilter {
            return items.count
        } else {
            return sectionModel.items.count
        }
    }
    
    public func getItem(with index: Int) -> ItemModel {
          if let items = itemsWithFilter {
            return items[index]
        } else {
            return sectionModel.items[index]
        }
    }
    
    public func getItems() -> [ItemModel] {
        if let items = itemsWithFilter {
            return items
        } else {
            return sectionModel.items
        }
    }
    
    public func deleteItem(model: ItemModel, index: Int) {
        let isSend = CoreDataJsonParserManager.shared.deleteItem(model)
        sectionModel.items.remove(at: index)
        if !haveConnection() || !isSend {
            return
        }
        
        ItemManager.manager.deleteItems(itemModels: [model])
        updateCompletion?()
    }
}

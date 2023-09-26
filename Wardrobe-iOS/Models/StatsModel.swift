//
//  StatsModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/26/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import Foundation

class ColorStatModel {
    var colorId: Int64
    var quantity: Int
    var colorCode: String?
    init(dict: [String: Any]) {
        colorId = dict["colorId"] as? Int64 ?? 0
        quantity = dict["quantity"] as? Int ?? 0
        let color = CoreDataManager.shared.objectWithID(id: colorId, entityName: EntityName.colors) as? Colors
        colorCode = color?.code
    }
}

class ItemStatModel {
    var itemId: Int64
    var quantity: Int
    var itemModel: ItemModel?
    init(dict: [String: Any]) {
        itemId = dict["itemId"] as? Int64 ?? 0
        quantity = dict["quantity"] as? Int ?? 0
        if let item = CoreDataManager.shared.objectWithID(id: itemId, entityName: EntityName.item) as? Item {
            itemModel = ItemModel(item)
        }
    }
}

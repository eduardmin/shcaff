//
//  LookModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/13/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class LookModelSuggestion {
    let id: Int64
    let url: String
    var resourceUrl: String?
    let aspectRation: String
    var multipleHeight: CGFloat {
        let splitAspectRations = aspectRation.split(separator: ":")
        if let first = Int(splitAspectRations.first ?? "1"), let second = Int(splitAspectRations[1]) {
            if first == second {
                return 1
            }
            return 1.4
        }
        return 1
    }
    var haveItems: Bool {
        return !(itemIds?.isEmpty ?? true)
    }
    var itemIds: [Int64]? = []
    var itemModels: [ItemModel]?
    var setId: Int64?
    var logoImage: UIImage? {
        if let resourceUrl = resourceUrl {
            if resourceUrl.lowercased().contains("instagram") {
                return UIImage(named: "instagramLogo")
            } else if resourceUrl.lowercased().contains("pinterest") {
                return UIImage(named: "pinterestLogo")
            }
        }
        return nil
    }
    
    var logoMassage: String? {
        if let resourceUrl = resourceUrl {
            if resourceUrl.lowercased().contains("instagram") {
                return "Open in “Instagram”?"
            } else if resourceUrl.lowercased().contains("pinterest") {
                return "Open in “Pinterest”?"
            }
        }
        return nil
    }

    private func fetchItems() {
        itemModels = [ItemModel]()
        if let itemIds = itemIds, !itemIds.isEmpty {
            for itemId in itemIds {
                if let item = CoreDataManager.shared.objectWithID(id: itemId, entityName: EntityName.item) as? Item {
                    let itemModel = ItemModel(item)
                    itemModels?.append(itemModel)
                }
            }
        }
    }
    
    func setItemsId(itemIds: [Int64]?) {
        self.itemIds = itemIds ?? []
        fetchItems()
    }
    
    init(id: Int64, url: String, aspectRation: String) {
        self.id = id
        self.url = url
        self.aspectRation = aspectRation
        fetchItems()
    }
    
    init(dict: [String: Any]) {
        id = dict["id"] as? Int64 ?? -1
        url = dict["url"] as? String ?? ""
        resourceUrl = dict["resourceUrl"] as? String
        aspectRation = dict["aspectRation"] as? String ?? "1:1"
        let items = dict["items"] as? [[String: Any]]
        itemIds = items?.map({ (item) -> Int64 in
            return item["id"] as! Int64
        })
        fetchItems()
    }
}

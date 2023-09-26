//
//  SetModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/18/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class SetModel {
    var id: Int64?
    var albumId: Int64?
    var lookId: Int64?
    var itemIds: [Int64]?
    var itemModels: [ItemModel]?
    var pendingItemIdList: [String]?
    var pendingAlbumId: String?
    var url: String?
    var aspectRation: String?
    var multipleHeight: CGFloat {
        if let aspectRation = aspectRation {
            let splitAspectRations = aspectRation.split(separator: ":")
            if let first = Int(splitAspectRations.first ?? "1"), let second = Int(splitAspectRations[1]) {
                if first == second {
                    return 1
                }
                return 1.4
            }
        }
        return 1
    }
    // check for create or update set request
    var canSendSet: Bool {
        if pendingAlbumId != nil || !(pendingItemIdList?.isEmpty ?? true) {
            return false
        }
        return true
    }
    var lookImage: UIImage? {
        if let lookId = lookId, let data = FileManagerSW.manager.getFile(name: FileName.looks, id: "\(lookId)") {
            return  UIImage(data: data)
        }
        return nil
    }
    
    init() {
        
    }
    
    init(_ dict: [String: Any]) {
        id = dict["setId"] as? Int64
        albumId = dict["albumId"] as? Int64
        lookId = dict["lookId"] as? Int64
        itemIds = dict["itemIds"] as? [Int64]
        if let lookDict = dict["look"] as? [String: Any] {
            lookId = lookDict["id"] as? Int64 ?? -1
            url = lookDict["url"] as? String ?? ""
            aspectRation = lookDict["aspectRation"] as? String ?? "1:1"
        }
    }
    
    init(_ set: WardrobeSet) {
        id = set.id as? Int64
        albumId = set.albumId as? Int64
        lookId = set.lookId as? Int64
        itemIds = set.itemIds
        pendingItemIdList = set.pendingItemIdList
        pendingAlbumId = set.pendingAlbumId
        url = set.url
        aspectRation = set.aspectRation
        fetchItems()
    }
    
    func setItemsId(_ itemModels: [ItemModel]) {
        var itemIds = [Int64]()
        var pendingIds = [String]()
        itemModels.forEach { (model) in
            if let id = model.id {
                itemIds.append(id)
            } else {
                pendingIds.append(model.tempId!)
            }
        }
        
        if !itemIds.isEmpty {
            self.itemIds = itemIds
        }
        
        if !pendingIds.isEmpty {
            pendingItemIdList = pendingIds
        }
        fetchItems()
    }
    
    func setAlbumId(_ albumModel: AlbumModel) {
        if let id = albumModel.id {
            albumId = id
        } else {
            pendingAlbumId = albumModel.tempId
        }
    }
    
    func setLookId(_ lookId: Int64, _ aspectRation: String?, _ url: String?) {
        self.lookId = lookId
        self.aspectRation = aspectRation
        self.url = url
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
        
        if let pendingItemIdList = pendingItemIdList, !pendingItemIdList.isEmpty {
            for itemId in pendingItemIdList {
                if let item = CoreDataManager.shared.objectCustomID(id: itemId, entityName: EntityName.item) as? Item {
                    let itemModel = ItemModel(item)
                    itemModels?.append(itemModel)
                }
            }
        }
    }
    
    deinit {
        print("")
    }
}

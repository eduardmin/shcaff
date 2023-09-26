//
//  ItemManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/9/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class ItemManager {
    static let manager = ItemManager()
    private let handleQueue: DispatchQueue
    
    init() {
        handleQueue = DispatchQueue(label: "handleItemQueue", qos: .userInteractive)
    }
    
    func saveItem(itemModels: [ItemModel]) {
        if itemModels.isEmpty { return }
        let itemWebService = ItemWebService()
        itemWebService.saveItems(itemModels) { [weak self] (response, error) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if error != nil {
                    return
                }
                
                if let response = response as? [[String : Any]] {
                    strongSelf.saveItemResponse(response, false)
                }
            }
        }
    }
    
    func editItem(itemModels: [ItemModel]) {
        if itemModels.isEmpty { return }
        let itemWebService = ItemWebService()
        itemWebService.updateItems(itemModels) { [weak self] (response, error) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if error != nil {
                    return
                }
                
                if let response = response as? [[String : Any]] {
                    strongSelf.saveItemResponse(response, true)
                }
            }
        }
    }
    
    func deleteItems(itemModels: [ItemModel]) {
        if itemModels.isEmpty { return }
        let itemWebService = ItemWebService()
        itemWebService.deleteItems(itemModels) { [weak self] (success) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if success {
                    strongSelf.deleteItemResponse(itemModels)
                }
            }
        }
    }
    
    private func saveItemResponse(_ response: [[String: Any]], _ editUpdate: Bool) {
        let uploadManager = FileUploadDownloadManager.manager
        for item in response {
            let model = ItemModel(item)
            CoreDataJsonParserManager.shared.updateItem(model, false, false, true)
            if editUpdate {
                if model.imageUpdated {
                    uploadManager.itemUpload(id: model.id!, tempID: model.tempId!, url: model.url ?? "")
                }
            } else {
                uploadManager.itemUpload(id: model.id!, tempID: model.tempId!, url: model.url ?? "")
            }
        }
    }
    
    private func deleteItemResponse(_ itemModels: [ItemModel]) {
        let coreDataManager = CoreDataManager.shared
        for model in itemModels {
            if let id = model.id {
                checkAndDeleteSet(id: id)
                FileManagerSW.manager.removeFileWithId(name: FileName.items, id: id)
                coreDataManager.deleteObjectWithId(id: id, entityName: EntityName.item)
            }
        }
        coreDataManager.saveContext()
    }
    
    private func checkAndDeleteSet(id: Int64) {
        let predicate = NSPredicate(format: "lookId == nil")
        if let sets = CoreDataManager.shared.objectsForEntity(entityName: EntityName.set, predicates: [predicate]) as? [WardrobeSet] {
            sets.forEach({ (set) in
                if set.itemIds?.contains(id) ?? true && set.itemIds?.count ?? 0 <= 1 {
                    checkAndDeleteEvents(setId: set.id as! Int64)
                    CoreDataManager.shared.deleteObject(object: set)
                }
            })
        }
    }
    
    private func checkAndDeleteEvents(setId: Int64) {
        let predicate = NSPredicate(format: "setId == \(setId)")
        if let events = CoreDataManager.shared.objectsForEntity(entityName: EntityName.calendarEvent, predicates: [predicate]) as? [CalendarEvent] {
            CoreDataManager.shared.deleteObjects(objects: events)
        }
    }
}

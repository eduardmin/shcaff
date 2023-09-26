//
//  CoreDataJsonParserManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/1/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class CoreDataJsonParserManager: NSObject {
    static let shared = CoreDataJsonParserManager()
    let coreDataManager = CoreDataManager.shared
    private let temporaryId = "tempId"

    func createProfile(_ dict: [String: Any]) {
        coreDataManager.deleteAllObjects(entityName: EntityName.profile)
        let profile = coreDataManager.insertNewObject(entityName: EntityName.profile) as? Profile
        profile?.name = dict["firstName"] as? String
        profile?.lastName = dict["lastName"] as? String
        profile?.gender = dict["gender"] as? Int16 ?? 0
        profile?.birthDayDate = dict["birthday"] as? Int64 ?? 0
        profile?.avatarUrl = dict["avatarUrl"] as? String
        coreDataManager.saveContext()
    }

    func updateProfile(profileModel: ProfileModel) {
        let profile = coreDataManager.getProfile()
        profile?.name = profileModel.name
        profile?.lastName = profileModel.lastName
        profile?.gender = Int16(profileModel.gender.rawValue)
        profile?.birthDayDate = profileModel.birthDayDate
        coreDataManager.saveContext()
    }
    
    func createCalendarEvent(model: CalendarEventModel, pending: Bool = false, save: Bool = true) {
        if let id = model.id  {
            coreDataManager.deleteObjectWithId(id: id, entityName: EntityName.calendarEvent)
        }
        let calendarEvent = coreDataManager.insertNewObject(entityName: EntityName.calendarEvent) as? CalendarEvent
        calendarEvent?.id = model.id as NSNumber?
        calendarEvent?.tempId = model.tempId
        calendarEvent?.date = model.date as NSNumber?
        calendarEvent?.setId = model.setId as NSNumber?
        calendarEvent?.name = model.name
        calendarEvent?.eventTypeId = model.eventTypeId as NSNumber?
        calendarEvent?.pending = pending
        if model.setId == nil, let setModel = model.setModel {
            let set = createSet(model: setModel)
            calendarEvent?.set = set
        }
        if save {
            coreDataManager.saveContext()
        }
    }
    
    func updateCalendarEvent(model: CalendarEventModel, pending: Bool = false, save: Bool = true, isCreate: Bool = false) {
        var calendarEvent: CalendarEvent?
    
        if let id = model.id, !isCreate {
            calendarEvent = coreDataManager.objectWithID(id: id, entityName: EntityName.calendarEvent) as? CalendarEvent
        } else {
            calendarEvent = coreDataManager.objectCustomID(id: model.tempId!, property: temporaryId, entityName: EntityName.calendarEvent) as? CalendarEvent
        }
        calendarEvent?.id = model.id as NSNumber?
        calendarEvent?.tempId = model.tempId
        calendarEvent?.date = model.date as NSNumber?
        calendarEvent?.setId = model.setId as NSNumber?
        calendarEvent?.name = model.name
        calendarEvent?.eventTypeId = model.eventTypeId as NSNumber?
        calendarEvent?.pending = pending
        if let set = calendarEvent?.set, let setModel = model.setModel {
            set.id = setModel.id as NSNumber?
            set.itemIds = setModel.itemIds
            set.lookId = setModel.lookId as NSNumber?
            set.url = setModel.url
            set.aspectRation = setModel.aspectRation
        }
        if save {
            coreDataManager.saveContext()
        }
    }
    
    func deleteCalendarEvent(_ model: CalendarEventModel) -> Bool {
        if model.id == nil {
            if let calendarEvent = coreDataManager.objectCustomID(id: model.tempId!, property: temporaryId, entityName: EntityName.calendarEvent) as? CalendarEvent {
                coreDataManager.deleteObject(object: calendarEvent)
            }
        } else {
            if let calendarEvent = coreDataManager.objectWithID(id: model.id!, entityName: EntityName.calendarEvent) as? CalendarEvent {
                calendarEvent.delete = true
                calendarEvent.pending = true
            }
            return true
        }
        coreDataManager.saveContext()
        
        return false
    }
    
    func createItem(_ model: ItemModel, _ photoUploaded: Bool = true, _ pending: Bool = false, _ save: Bool = true, _ delete: Bool = false) {
        if let id = model.id  {
            coreDataManager.deleteObjectWithId(id: id, entityName: EntityName.item)
        }
        let item = coreDataManager.insertNewObject(entityName: EntityName.item) as? Item
        item?.id = model.id as NSNumber?
        item?.clothingType = NSNumber(value: model.clothingType ?? 0)
        item?.itemType = NSNumber(value: model.itemType ?? 0)
        item?.clothingStyle = model.clothingStyle as NSNumber?
        item?.colors = model.colors
        item?.size = model.size as NSNumber?
        item?.temperatureRange = model.temperatureRange as NSNumber?
        item?.gender = model.gender as NSNumber?
        item?.print = model.print as NSNumber?
        item?.brand = model.brand
        item?.url = model.url
        item?.tempId = model.tempId
        item?.pending = pending
        item?.photoUploaded = photoUploaded
        item?.imageUpdated = model.imageUpdated
        item?.personal = model.personal ?? true
        item?.updateTs = model.updateTs as NSNumber?
        item?.delete = delete
        if save {
            coreDataManager.saveContext()
        }
    }
    
    func updateItem(_ model: ItemModel, _ photoUploaded: Bool = true, _ pending: Bool = false, _ save: Bool = true) {
        let item = coreDataManager.objectCustomID(id: model.tempId!, property: temporaryId, entityName: EntityName.item) as? Item
        item?.id = model.id as NSNumber?
        item?.clothingType = NSNumber(value: model.clothingType ?? 0)
        item?.itemType = NSNumber(value: model.itemType ?? 0)
        item?.clothingStyle = model.clothingStyle as NSNumber?
        item?.colors = model.colors
        item?.size = model.size as NSNumber?
        item?.temperatureRange = model.temperatureRange as NSNumber?
        item?.gender = model.gender as NSNumber?
        item?.print = model.print as NSNumber?
        item?.brand = model.brand
        item?.url = model.url
        item?.tempId = model.tempId
        item?.pending = pending
        item?.photoUploaded = photoUploaded
        item?.imageUpdated = model.imageUpdated
        item?.personal = model.personal ?? true
        item?.updateTs = model.updateTs as NSNumber?
        if save {
            coreDataManager.saveContext()
        }
    }
    
    func deleteItem(_ model: ItemModel) -> Bool {
        if model.id == nil {
            if let item = coreDataManager.objectCustomID(id: model.tempId!, property: temporaryId, entityName: EntityName.item) as? Item {
                coreDataManager.deleteObject(object: item)
                FileManagerSW.manager.removeFile(name: FileName.items, id: model.tempId ?? "")
            }
        } else {
            if let item = coreDataManager.objectWithID(id: model.id!, entityName: EntityName.item) as? Item {
                item.delete = true
                item.pending = true
            }
            return true
        }
        coreDataManager.saveContext()
        
        return false
    }
    
    //MARK:- Album
    func createAlbum(_ model: AlbumModel, _ pending: Bool = false, _ save: Bool = true, _ delete: Bool = false) {
        if let id = model.id  {
            coreDataManager.deleteObjectWithId(id: id, entityName: EntityName.album)
        }
        let album = coreDataManager.insertNewObject(entityName: EntityName.album) as? Album
        album?.id = model.id as NSNumber?
        album?.tempId = model.tempId
        album?.title = model.title
        album?.pending = pending
        album?.delete = delete
        album?.isDefault = model.isDefault
        if save {
            coreDataManager.saveContext()
        }
    }
    
    func updateAlbum(_ model: AlbumModel, _ pending: Bool = false, _ save: Bool = true) {
        let album = coreDataManager.objectCustomID(id: model.tempId, property: temporaryId, entityName: EntityName.album) as? Album
        album?.id = model.id as NSNumber?
        album?.tempId = model.tempId
        album?.title = model.title
        album?.pending = pending
        album?.isDefault = model.isDefault
        if save {
            coreDataManager.saveContext()
        }
    }
    
    func deletePandingAlbum(_ model: AlbumModel) {
        if let album = coreDataManager.objectCustomID(id: model.tempId, property: temporaryId, entityName: EntityName.album) {
            coreDataManager.deleteObjects(objects: [album])
        }
    }
    
    //MARK:- Set
    func createSet(model: SetModel, save: Bool = true, delete: Bool = false) -> WardrobeSet? {
        if let id = model.id  {
            coreDataManager.deleteObjectWithId(id: id, entityName: EntityName.set)
        }
        let set = coreDataManager.insertNewObject(entityName: EntityName.set) as? WardrobeSet
        set?.id = model.id as NSNumber?
        set?.itemIds = model.itemIds
        set?.albumId = model.albumId as NSNumber?
        set?.lookId = model.lookId as NSNumber?
        set?.pendingAlbumId = model.pendingAlbumId
        set?.pendingItemIdList = model.pendingItemIdList
        set?.url = model.url
        set?.aspectRation = model.aspectRation
        if save {
            coreDataManager.saveContext()
        }
        return set
    }
    
    func updateSet(model: SetModel, save: Bool = true, delete: Bool = false) {
        let set = coreDataManager.objectWithID(id: model.id!, entityName: EntityName.set)  as? WardrobeSet
        set?.id = model.id as NSNumber?
        set?.itemIds = model.itemIds
        set?.albumId = model.albumId as NSNumber?
        set?.lookId = model.lookId as NSNumber?
        set?.pendingAlbumId = model.pendingAlbumId
        set?.pendingItemIdList = model.pendingItemIdList
        set?.url = model.url
        set?.aspectRation = model.aspectRation
        if save {
            coreDataManager.saveContext()
        }
    }
    
    func deleteSet(model: SetModel) {
        if let id = model.id  {
            coreDataManager.deleteObjectWithId(id: id, entityName: EntityName.set)
            coreDataManager.saveContext()
        }
    }
}

//MARK:- Create Constant
extension CoreDataJsonParserManager {
    func createConstants(_ array: [[String: Any]], _ type: ServerConstants) {
        if array.isEmpty { return }
        let entityName = ServerConstants.entityNames[type]
        coreDataManager.deleteAllObjects(entityName: entityName ?? "")

        for constant in array {
            
            let id = constant["id"] as? Int64
            let name = constant["name"] as? [String: Any]
            let clothingTypeId = constant["clothingType"] as? Int16
            let genderId = constant["gender"] as? NSNumber
            let color = constant["color"] as? String
            let code = constant["code"] as? String

            switch type {
            case .clothingTypes:
                let clothingType = coreDataManager.insertNewObject(entityName: EntityName.clothingTypes) as? ClothingTypes
                clothingType?.id = id!
                clothingType?.names = name
                clothingType?.genderId = genderId
            case .itemTypes:
                let itemTypes = coreDataManager.insertNewObject(entityName: EntityName.itemTypes) as? ItemTypes
                itemTypes?.id = id!
                itemTypes?.names = name
                itemTypes?.clothingTypeId = clothingTypeId ?? -1
                itemTypes?.genderId = genderId
            case .prints:
                let prints = coreDataManager.insertNewObject(entityName: EntityName.prints) as? Prints
                prints?.id = id!
                prints?.names = name
            case .styles:
                let clothingStyles = coreDataManager.insertNewObject(entityName: EntityName.clothingStyles) as? ClothingStyles
                clothingStyles?.names = name
                clothingStyles?.id = id!
                clothingStyles?.genderId = genderId
            case .sizes:
                let sizes = coreDataManager.insertNewObject(entityName: EntityName.sizes) as? Sizes
                sizes?.id = id!
                sizes?.names = name
            case .seasons:
                let seasons = coreDataManager.insertNewObject(entityName: EntityName.seasons) as? Seasons
                seasons?.id = id!
                seasons?.names = name
            case .genders:
                let genders = coreDataManager.insertNewObject(entityName: EntityName.genders) as? Genders
                genders?.id = id!
                genders?.names = name
            case .occasions:
                let occasions = coreDataManager.insertNewObject(entityName: EntityName.occasions) as? Occasions
                occasions?.id = id!
                occasions?.color = color
                occasions?.names = name
            case .colors:
                let colors = coreDataManager.insertNewObject(entityName: EntityName.colors) as? Colors
                colors?.id = id!
                colors?.names = name
                colors?.code = code
            }
        }
        coreDataManager.saveContext()
    }
}

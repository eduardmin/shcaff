//
//  PandingSendSyncManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/11/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class PendingSendSyncManager {
    private let coreDataManager = CoreDataManager.shared
    private let handleQueue: DispatchQueue
    private let uploadQueue: DispatchQueue
    private let downloadQueue: DispatchQueue
    private var deviceInfoUpdateSuccess = false

    init() {
        handleQueue = DispatchQueue(label: "handleQueue", qos: .userInteractive)
        uploadQueue = DispatchQueue(label: "uploadQueue", qos: .userInteractive)
        downloadQueue = DispatchQueue(label: "downloadQueue", qos: .userInteractive)
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnection(_:)), name: NSNotification.Name(rawValue: NotificationName.noInternet), object: nil)
    }
    
    func loginFinish() {
        if haveConnection() {
            sendRequests()
        }
    }
    
    @objc private func handleConnection(_ notification: NSNotification) {
        let isReachable = notification.object as! Int
        if isReachable == 1 {
            sendRequests()
        }
    }
    
    private func sendRequests() {
        if UIApplication.shared.applicationState != .background {
            sendPendingItems()
            uploadPendingImage()
            downloadPendingImage()
            sendPendingAlbums()
            sendPendingEvents()
            sendDeviceInfo()
        }
    }
    
    private func uploadPendingImage() {
        let predicate = NSPredicate(format: "id != nil AND photoUploaded == \(false)")
        let items = coreDataManager.objectsForEntity(entityName: EntityName.item, predicates: [predicate]) as? [Item]
        if items == nil || items!.isEmpty { return }
        let uploadManager = FileUploadDownloadManager.manager
        uploadQueue.async {
            for item in items! {
                uploadManager.itemUpload(id: item.id?.int64Value ?? 0, tempID: item.tempId ?? "", url: item.url ?? "")
            }
        }
    }
    
    private func downloadPendingImage() {
        let predicate = NSPredicate(format: "id != nil AND downloadState == \(ItemDownloadState.progress.rawValue)")
        let items = coreDataManager.objectsForEntity(entityName: EntityName.item, predicates: [predicate]) as? [Item]
        if items == nil || items!.isEmpty { return }
        let uploadManager = FileUploadDownloadManager.manager
        downloadQueue.async {
            for item in items! {
                uploadManager.itemDownload(id: item.id?.int64Value ?? 0, url: item.url ?? "", completion: nil)
            }
        }
    }
}

//MARK:- Send Pending Device info
extension PendingSendSyncManager {
    func sendDeviceInfo() {
        if deviceInfoUpdateSuccess {
            return
        }
        if LocationManager.manager.locationModel.value.latitude != nil || LocationManager.manager.error.value != nil {
            sendDeviceInfoRequest()
        } else {
            LocationManager.manager.locationModel.bind(listener: { [weak self] (model) in
                guard let strongSelf = self else { return }
                strongSelf.sendDeviceInfoRequest()
            })
            
            LocationManager.manager.error.bind(listener: { [weak self] (error) in
                guard let strongSelf = self else { return }
                strongSelf.sendDeviceInfoRequest()
            })
        }
    }
    
    func sendDeviceInfoRequest() {
        let deviceInfoWebService = DeviceInfoWebService()
        deviceInfoWebService.updateDeviceInfo(model: LocationManager.manager.locationModel.value) { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.deviceInfoUpdateSuccess = success
        }
    }
}

//MARK:- Send Pending Items
extension PendingSendSyncManager {
    
    private func sendPendingItems() {
        let predicate = NSPredicate(format: "pending == \(true)")
        let items = coreDataManager.objectsForEntity(entityName: EntityName.item, predicates: [predicate]) as? [Item]
        if items == nil || items!.isEmpty { return }
        var createItems = [ItemModel]()
        var updateItems = [ItemModel]()
        var deleteItems = [ItemModel]()
        
        for item in items! {
            let itemModel = ItemModel(item)
            if item.delete {
                deleteItems.append(itemModel)
            } else if itemModel.id != nil {
                updateItems.append(itemModel)
            } else {
                createItems.append(itemModel)
            }
        }
        
        ItemManager.manager.saveItem(itemModels: createItems)
        ItemManager.manager.editItem(itemModels: updateItems)
        ItemManager.manager.deleteItems(itemModels: deleteItems)
    }
}

//MARK:- Send Calendar Evets
extension PendingSendSyncManager {
    func sendPendingEvents() {
        let predicate = NSPredicate(format: "pending == \(true)")
        let events = coreDataManager.objectsForEntity(entityName: EntityName.calendarEvent, predicates: [predicate]) as? [CalendarEvent]
        if events == nil || events!.isEmpty { return }
        var createEventModels = [CalendarEventModel]()
        var createEventModelWithoutSets = [CalendarEventModel]()
        var updateEventModels = [CalendarEventModel]()
        var deleteEventModels = [CalendarEventModel]()
        for event in events! {
            let eventModel = CalendarEventModel(event)
            if event.delete {
                deleteEventModels.append(eventModel)
            } else if event.id != nil {
                updateEventModels.append(eventModel)
            } else {
                if event.setId != nil {
                    createEventModels.append(eventModel)
                } else {
                    createEventModelWithoutSets.append(eventModel)
                }
            }
        }
        CalendarEventManager.manager.createCalendarEvents(calendarEventModels: createEventModels)
        CalendarEventManager.manager.createCalendarEventsWithoutSet(calendarEventModels: createEventModelWithoutSets)
        CalendarEventManager.manager.updateCalendarEvents(calendarEventModels: updateEventModels)
        CalendarEventManager.manager.deleteCalendarEvents(calendarEventModels: deleteEventModels)
    }
}

//MARK:- Send Pending Albums
extension PendingSendSyncManager {
    private func sendPendingAlbums() {
        let predicate = NSPredicate(format: "pending == \(true)")
        let albums = coreDataManager.objectsForEntity(entityName: EntityName.album, predicates: [predicate]) as? [Album]
        if albums == nil || albums!.isEmpty { return }
        var createAlbums = [AlbumModel]()
        var updateAlbums = [AlbumModel]()
        var deleteAlbums = [AlbumModel]()
        for album in albums! {
            let albumModel = AlbumModel(album)
            if album.delete {
                deleteAlbums.append(albumModel)
            } else if albumModel.id != nil {
                updateAlbums.append(albumModel)
            } else {
                createAlbums.append(albumModel)
            }
        }
        sendPendingCreateAlbum(createAlbums)
        sendPendingUpdateAlbum(updateAlbums)
        sendPendingDeleteAlbum(deleteAlbums)
    }
    
    private func sendPendingCreateAlbum(_ models: [AlbumModel]) {
        if models.isEmpty { return }
        let albumWebService = AlbumWebService()
        albumWebService.saveAlbum(models) { [weak self] (response, error) in
            self?.handleQueue.async {
                guard let strongSelf = self, error == nil else { return }
                if let response = response as? [[String : Any]] {
                    strongSelf.handleAlbumResponse(response)
                }
            }
        }
    }
    
    private func sendPendingUpdateAlbum(_ models: [AlbumModel]) {
        if models.isEmpty { return }
        let albumWebService = AlbumWebService()
        albumWebService.updateAlbum(models) { [weak self] (success) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if success {
                    strongSelf.handleUpdateAlbumResponse(models)
                }
            }
        }
    }
    
    private func sendPendingDeleteAlbum(_ models: [AlbumModel]) {
        if models.isEmpty { return }
        let albumWebService = AlbumWebService()
        albumWebService.deleteAlbum(models) { [weak self] (success) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if success {
                    strongSelf.handleDeleteAlbum(models)
                }
            }
        }
    }
}

//MARK:- Handle Response
extension PendingSendSyncManager {
    
    //MARK:- Handle Album Response
    private func handleAlbumResponse(_ response: [[String: Any]]) {
        for item in response {
            let model = AlbumModel(item)
            CoreDataJsonParserManager.shared.updateAlbum(model)
        }
    }
    
    private func handleUpdateAlbumResponse(_ models: [AlbumModel]) {
        for model in models {
            if let album = coreDataManager.objectWithID(id: model.id!, entityName: EntityName.album) as? Album {
                album.pending = false
                coreDataManager.saveContext()
            }
        }
    }
    
    private func handleDeleteAlbum(_ models: [AlbumModel]) {
        for model in models {
            coreDataManager.deleteObjectWithId(id: model.id!, entityName: EntityName.album)
            coreDataManager.saveContext()
        }
    }
}

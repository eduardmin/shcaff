//
//  SyncManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/20/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum SyncType {
    case constant
    case wardrobe
}

//MARK:- Typealiases
typealias RequestSuccessCount = Int
typealias SyncRequestCompletion = (_ isFinish: Bool, _ isInternalError: Bool) -> ()

class SynchronizationManager {
    var numberOfCostantsRequestCount: Int = 5
    var syncDict = [SyncType: RequestSuccessCount]()
    private let syncQueue: DispatchQueue
    private let handleQueue: DispatchQueue
    var isStartSync = false
    
    init() {
        syncQueue = DispatchQueue(label: "syncQueue", qos: .userInteractive)
        handleQueue = DispatchQueue(label: "handleQueue", qos: .userInteractive)
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnection(_:)), name: NSNotification.Name(rawValue: NotificationName.noInternet), object: nil)
    }
    
    @objc private func handleConnection(_ notification: NSNotification) {
        let isReachable = notification.object as! Int
        if isReachable == 1 && !syncDict.isEmpty && !isStartSync {
            startSync()
        }
    }
    
    func loginFinish() {
        addSyncTypes()
    }
    
    private func addSyncTypes() {
        if isSignIn() {
            syncDict[.constant] = numberOfCostantsRequestCount
            syncDict[.wardrobe] = numberOfCostantsRequestCount
            if haveConnection() {
                startSync()
            }
        }
    }
    
    
    private func startSync() {
        isStartSync = true
        syncQueue.sync {
            for type in self.syncDict.keys {
                if self.syncDict[type] ?? 0 < 0 {
                   continue
                }
                self.sendRequest(type) { [weak self] (isFinish, isInternalError) in
                    guard let strongSelf = self else { return }
                    if isFinish {
                        strongSelf.syncDict[type] = 0
                    } else {
                        strongSelf.syncDict[type] = (strongSelf.syncDict[type] ?? 0) - 1
                    }
                    
                    if strongSelf.syncDict[type] == 0 {
                        strongSelf.syncDict.removeValue(forKey: type)
                        if strongSelf.syncDict.isEmpty {
                            return
                        }
                    } else {
                        self?.startSync()
                    }
                }
            }
        }
    }
    
    private func sendRequest(_ type: SyncType, _ completion : @escaping SyncRequestCompletion) {
        switch type {
        case .constant:
            sendConstantsRequest { (isFinish, isInternalError) in
                completion(isFinish, isInternalError)
            }
        case .wardrobe:
            sendWardrobeItems { (isFinish, isInternalError) in
                completion(isFinish, isInternalError)
            }
        }
    }
    
}

//MARK: - Send Request
extension SynchronizationManager {
    func sendWardrobeItems(_ completion : @escaping (_ isFinish: Bool, _ isInternalError: Bool) -> ()) {
        let wardrobeWebService = WardrobeWebService()
        wardrobeWebService.getWardrobe { [weak self] (response, error) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if error != nil {
                    switch error {
                    case .failError(code: _, message: _):
                        completion(false, false)
                    case .successError(errorType: _):
                        completion(true, true)
                    default:
                        break
                    }
                    return
                }
                
                if let response = response as? [String: Any] {
                    strongSelf.handleWardrobe(response)
                    completion(true, false)
                    return
                }
                completion(false, false)
            }
        }
    }
    
    func sendConstantsRequest(_ completion : @escaping (_ isFinish: Bool, _ isInternalError: Bool) -> ()) {
        let costantWebService = ConstantWebService()
        costantWebService.getConstants { [weak self] (response, error) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if error != nil {
                    switch error {
                    case .failError(code: _, message: _):
                        completion(false, false)
                    case .successError(errorType: _):
                        completion(true, true)
                    default:
                        break
                    }
                    return
                }
                
                if let response = response as? [String: Any] {
                    strongSelf.handleConstantsResponse(response)
                    completion(true, false)
                    return
                }
                completion(false, false)
            }
        }
    }
}


//MARK: - Handle Response
extension SynchronizationManager {
    private func handleConstantsResponse(_ response: [String: Any]) {
        for key in response.keys {
            if let type = ServerConstants(rawValue: key), let array = response[key] as? [[String : Any]]{
                CoreDataJsonParserManager.shared.createConstants(array, type)
            }
        }
    }
    
    private func handleWardrobe(_ response: [String: Any]) {
        let syncTime = response["syncTs"] as? Int64
        UserDefaults.standard.set(syncTime, forKey: UserDefaultsKey.wardrobeSyncTime)
        if let items = response["items"] as? [[String: Any]], !items.isEmpty {
            for item in items {
                let model = ItemModel(item)
                var isDownload = true
                if let id = model.id, let item = CoreDataManager.shared.objectWithID(id: id, entityName: EntityName.item) as? Item {
                    if item.updateTs?.int64Value == model.updateTs {
                        isDownload = false
                    }
                }
                if isDownload {
                    FileUploadDownloadManager.manager.itemDownload(id: model.id!, url: model.url!) { (isFinish) in }
                }
                CoreDataJsonParserManager.shared.createItem(model)
            }
        }
        
        if let albums = response["albums"] as? [[String: Any]], !albums.isEmpty {
            for album in albums {
                let model = AlbumModel(album)
                CoreDataJsonParserManager.shared.createAlbum(model)
            }
        }
        
        if let sets = response["sets"] as? [[String: Any]], !sets.isEmpty {
            for set in sets {
                let model = SetModel(set)
                _ = CoreDataJsonParserManager.shared.createSet(model: model)
                if model.lookId != nil && model.lookImage == nil {
                    FileUploadDownloadManager.manager.downloadLook(url: model.url ?? "", lookId: model.lookId!) { (isFinish) in }
                }
            }
        }
        
        if let events = response["events"] as? [[String: Any]], !events.isEmpty {
            for event in events {
                let model = CalendarEventModel(event)
                CoreDataJsonParserManager.shared.createCalendarEvent(model: model)
            }
        }
    }
}

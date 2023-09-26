//
//  FileUploadManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/5/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum ItemDownloadState: Int16 {
    case success
    case progress
    case failed
}

class FileUploadDownloadManager: NSObject {
   static let manager = FileUploadDownloadManager()
    
    func itemUpload(id: Int64, tempID: String, url: String) {
        guard let data = FileManagerSW.manager.getFile(name: FileName.items, id: tempID), !url.isEmpty else { return  }
        let imageData = data
        let uploadWebService = BaseNetworkManager()
        uploadWebService.uploadImage(path: url, imageData: imageData) { [weak self] (isSuccess, error) in
            guard let strongSelf = self else { return }
            if isSuccess && error == nil {
                strongSelf.itemUploadSuccess(id: id, tempID: tempID)
            }
        }
    }
    
    func itemDownload(id: Int64, url: String, completion: ((Bool) -> ())?) {
        changeItemDownloadState(id: id, state: .progress)
        let uploadWebService = BaseNetworkManager()
        uploadWebService.downloadImage(path: url) { [weak self] (data, error, code) in
            guard let strongSelf = self else { return }
            
            if let code = code, code > 400 {
                strongSelf.changeItemDownloadState(id: id, state: .failed)
                return
            }
            
            if let data = data, error == nil {
                strongSelf.itemDownloadSuccess(id: id, data: data)
                strongSelf.changeItemDownloadState(id: id, state: .success)
                completion?(true)
            }
        }
    }
    
    func uploadAvatar(url: String, imageData: Data, completion: ((Bool) -> ())?) {
        let uploadWebService = BaseNetworkManager()
        uploadWebService.uploadImage(path: url, imageData: imageData) { [weak self] (isSuccess, error) in
            guard let strongSelf = self else { return }
            strongSelf.avatarSuccess(imageData: imageData)
            completion?(true)
        }
    }
    
    func downloadAvatar(url: String, completion: ((Bool) -> ())?) {
        let uploadWebService = BaseNetworkManager()
        uploadWebService.downloadImage(path: url) { [weak self] (data, error, code) in
            guard let strongSelf = self else { return }
            if let data = data, error == nil {
                strongSelf.avatarSuccess(imageData: data)
                completion?(true)
                return
            }
            completion?(false)
        }
    }
    
    func downloadLook(url: String, lookId: Int64, completion: ((Bool) -> ())?) {
        let uploadWebService = BaseNetworkManager()
        uploadWebService.downloadImage(path: url) { [weak self] (data, error, code) in
            guard let strongSelf = self else { return }
            if let data = data, error == nil {
                strongSelf.lookSuccess(imageData: data, lookId: lookId)
                completion?(true)
                return
            }
            completion?(false)
        }
    }
}

//MARK:- Item Response handle func
extension FileUploadDownloadManager {
    private func itemUploadSuccess(id: Int64, tempID: String) {
        guard let data = FileManagerSW.manager.getFile(name: FileName.items, id: tempID) else { return  }
        FileManagerSW.manager.removeFile(name: FileName.items, id: tempID)
        FileManagerSW.manager.saveFile(name: FileName.items, id: "\(id)", data: data)
        let item = CoreDataManager.shared.objectWithID(id: id, entityName: EntityName.item) as? Item
        item?.photoUploaded = true
        CoreDataManager.shared.saveContext()
    }
    
    private func itemDownloadSuccess(id: Int64, data: Data) {
        FileManagerSW.manager.saveFile(name: FileName.items, id: "\(id)", data: data)
    }
    
    private func changeItemDownloadState(id: Int64, state: ItemDownloadState) {
        let item = CoreDataManager.shared.objectWithID(id: id, entityName: EntityName.item) as? Item
        item?.downloadState = state.rawValue
        CoreDataManager.shared.saveContext()
    }
    
    private func avatarSuccess(imageData: Data) {
        FileManagerSW.manager.saveFile(name: FileName.avatar, id: FileName.avatar, data: imageData)
    }
    
    private func lookSuccess(imageData: Data, lookId: Int64) {
        FileManagerSW.manager.saveFile(name: FileName.looks, id: "\(lookId)", data: imageData)
    }
}


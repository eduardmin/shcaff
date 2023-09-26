//
//  AlbumsViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/17/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class AlbumsViewModel {
    private let coreDataManager = CoreDataManager.shared
    private var albumModels = [AlbumModel]()
    public var completion: (() -> ())?

    init() {
        getItems()
    }
    
    //MARK:- Public Func
    public func createAlbum(_ title: String) {
        let albumModel = AlbumModel(tempId: generateRandomId(), title: title)
        albumModels.append(albumModel)
        completion?()
        CoreDataJsonParserManager.shared.createAlbum(albumModel, true, true)
        let albumWebService = AlbumWebService()
        if !haveConnection() {
            return
        }
        albumWebService.saveAlbum([albumModel]) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                return
            }
            
            if let response = response as? [[String : Any]] {
                strongSelf.handleAlbumResponse(response)
                strongSelf.getItems()
                strongSelf.completion?()
            }
        }
    }
    
    public func changeAlbumName(_ title: String, _ index: Int) {
        let model = albumModels[index]
        model.title = title
        completion?()
        if model.id != nil {
            CoreDataJsonParserManager.shared.createAlbum(model, true, true)
            let albumWebService = AlbumWebService()
            if !haveConnection() {
                return
            }
            albumWebService.updateAlbum([model]) { [weak self] (isSuccess) in
                guard let strongSelf = self else { return }
                if isSuccess {
                    strongSelf.handleUpdateAlbumResponse(model)
                }
            }
        } else {
            CoreDataJsonParserManager.shared.updateAlbum(model, true, true)
        }
    }
    
    public func deleteAlbum(_ index: Int) {
        let model = albumModels[index]
        albumModels.remove(at: index)
        completion?()
        if model.id != nil {
            CoreDataJsonParserManager.shared.createAlbum(model, true, true, true)
            let albumWebService = AlbumWebService()
            if !haveConnection() {
                return
            }
            
            albumWebService.deleteAlbum([model]) { [weak self] (isSuccess) in
                guard let strongSelf = self else { return }
                if isSuccess {
                    strongSelf.handleDeleteAlbum(model)
                }
            }
        } else {
            deletePandingAlbum(model)
        }
    }
    
    // MARK:- Model Func
    public func albumCount() -> Int {
        return albumModels.count
    }
    
    public func getAlbum(index: Int) -> AlbumModel {
        return albumModels[index]
    }
    
    deinit {
        print("")
    }
}

//MARK:- Private func
extension AlbumsViewModel {
    private func getItems() {
        albumModels.removeAll()
        let predicate = NSPredicate(format: "delete == \(false)")
        if let albums = coreDataManager.objectsForEntity(entityName: EntityName.album, predicates: [predicate]) as? [Album] {
            for album in albums {
                let model = AlbumModel(album)
                if let id = model.id {
                    let predicate = NSPredicate(format: "albumId == \(id)")
                    if let sets = coreDataManager.objectsForEntity(entityName: EntityName.set, predicates: [predicate]) as? [WardrobeSet] {
                        sets.forEach { (set) in
                            let setModel = SetModel(set)
                            model.addSetModel(setModel)
                        }
                    }
                } else {                    
                    let strFormat = "pendingAlbumId == %@"
                    let predicate = NSPredicate(format: strFormat, argumentArray: [model.tempId])
                    if let sets = coreDataManager.objectsForEntity(entityName: EntityName.set, predicates: [predicate]) as? [WardrobeSet] {
                        sets.forEach { (set) in
                            let setModel = SetModel(set)
                            model.addSetModel(setModel)
                        }
                    }
                }
               
                albumModels.append(model)
            }
        }
    }
    
    private func updateAlbum(_ albumModel: AlbumModel) {
        CoreDataJsonParserManager.shared.updateAlbum(albumModel)
    }
    
    private func deletePandingAlbum(_ albumModel: AlbumModel) {
        CoreDataJsonParserManager.shared.deletePandingAlbum(albumModel)
    }
        
    //MARK:- Handle Response
    private func handleAlbumResponse(_ response: [[String: Any]]) {
        for item in response {
            let model = AlbumModel(item)
            updateAlbum(model)
        }
    }
    
    private func handleUpdateAlbumResponse(_ model: AlbumModel) {
        if let album = coreDataManager.objectWithID(id: model.id!, entityName: EntityName.album) as? Album {
            album.pending = false
            coreDataManager.saveContext()
        }
    }
    
    private func handleDeleteAlbum(_ model: AlbumModel) {
        coreDataManager.deleteObjectWithId(id: model.id!, entityName: EntityName.album)
        coreDataManager.saveContext()
    }
}

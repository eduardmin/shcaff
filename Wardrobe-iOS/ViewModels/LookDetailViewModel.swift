//
//  LookDetailViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/16/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//
 
import Foundation
import UIKit

class LookDetailViewModel {
    var selectedLookModel: LookModelSuggestion
    var looksModel: [LookModelSuggestion]
    var selectedIndex: Int = 0 {
        didSet {
            addStatistic(index: selectedIndex)
        }
    }
    private var image: UIImage?
    private var lookStatistic = [Int64: Int]()
    private var albumModel: AlbumModel?
    public var updateCompletion: ((RequestResponseType) -> ())?
    public var isLoadMore: Bool = true
    var lookModel: LookModelSuggestion {
        return looksModel[selectedIndex]
    }
    public var loadSuggestionMore: Bool = true
    public  var lookSuggestionModels = [LookModelSuggestion]()
    
    
    init(selectedLookModel: LookModelSuggestion, looksModel: [LookModelSuggestion], image: UIImage?, albumModel: AlbumModel? = nil) {
        self.selectedLookModel = selectedLookModel
        self.looksModel = looksModel
        self.image = image
        self.albumModel = albumModel
        selectedIndex = looksModel.firstIndex(where: { $0.id == selectedLookModel.id }) ?? 0
        addStatistic(index: selectedIndex)
    }
    
    public func setSelectedIndex(index: Int, image: UIImage?) {
        self.selectedIndex = index
        self.image = image
    }
    
    public func saveLook(_ album: AlbumModel?) {
        let setModel = SetModel()
        setModel.setItemsId(lookModel.itemModels ?? [])
        setModel.id = lookModel.setId
        if let album = album {
            setModel.setAlbumId(album)
        }
        setModel.setLookId(lookModel.id, lookModel.aspectRation, lookModel.url)
        updateCompletion?(.start(showLoading: true))
        if !haveConnection() {
            updateCompletion?(.fail(showPopup: true))
            return
        }
        
        let setWebService = SetWebService()
        setWebService.saveSet([setModel]) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.updateCompletion?(.fail(showPopup: true))
                return
            }
            
            if let response = response as? [[String : Any]] {
                strongSelf.handleCreateResponse(response)
            }
        }
    }
    
    public func deleteLook() {
        if let setId = lookModel.setId {
            let setModel = SetModel()
            setModel.id = setId
            setModel.lookId = lookModel.id
            updateCompletion?(.start(showLoading: true))
            if !haveConnection() {
                updateCompletion?(.fail(showPopup: true))
                return
            }
            let setWebService = SetWebService()
            setWebService.deleteSet([setModel]) { [weak self] (finish) in
                guard let strongSelf = self else { return }
                if finish {
                    strongSelf.handleDeleteResponse(setModel)
                } else {
                    strongSelf.updateCompletion?(.fail(showPopup: true))
                }
            }
        }
    }
    
    func getSetModel() -> SetModel {
        let setModel = SetModel()
        setModel.setItemsId(lookModel.itemModels ?? [])
        setModel.setLookId(lookModel.id, lookModel.aspectRation, lookModel.url)
        let data = image?.jpegData(compressionQuality: 1)
        FileManagerSW.manager.saveFile(name: FileName.looks, id: "\(selectedLookModel.id)", data: data ?? Data())
        return setModel
    }
    
    func addMoreLook(looks: [LookModelSuggestion], isMoreLoad: Bool) {
        self.looksModel = looks
        self.isLoadMore = isMoreLoad
        updateCompletion?(.success(response: true))
    }
}

//MARK:- Handle response
extension LookDetailViewModel {
    func handleCreateResponse(_ response: [[String: Any]]) {
        let data = image?.jpegData(compressionQuality: 1)
        for look in response {
            let model = SetModel(look)
            model.url = lookModel.url
            model.aspectRation = lookModel.aspectRation
            if let lookId = model.lookId {
                FileManagerSW.manager.saveFile(name: FileName.looks, id: "\(lookId)", data: data ?? Data())
            }
           _ = CoreDataJsonParserManager.shared.createSet(model: model)
        }
        updateCompletion?(.success(response: nil))
    }
    
    func handleDeleteResponse(_ model: SetModel) {
        albumModel?.removeSetModel(model)
        CoreDataJsonParserManager.shared.deleteSet(model: model)
        if let lookId = model.lookId {
            let predicate = NSPredicate(format: "lookId == \(lookId)")
            if let sets = CoreDataManager.shared.objectsForEntity(entityName: EntityName.set, predicates: [predicate]) as? [WardrobeSet], sets.count == 1 {
                FileManagerSW.manager.removeFileWithId(name: FileName.looks, id: lookId)
            }
        }
        updateCompletion?(.success(response: (success: true, delete: true)))
    }
}

//MARK:- Look
extension LookDetailViewModel {
    func getLooks(offset: Int = 0, limit: Int = 20) {
        if offset == 0 {
            updateCompletion?(.start(showLoading: true))
        }
        if !haveConnection() {
            updateCompletion?(.fail(showPopup: true))
            return
        }
    
        let suggestionWebService = SuggestionWebService()
        suggestionWebService.getLookSuggestion(id: selectedLookModel.id, offset: offset, limit: limit) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.updateCompletion?(.fail(showPopup: true))
                return
            }
            if let response = response as? [[String: Any]] {
                strongSelf.handleResponse(response, loadingMore: offset != 0)
            }
        }
    }
    
    func deleteAllSuggestion() {
        lookSuggestionModels.removeAll()
        loadSuggestionMore = false
    }
    
    func loadMoreLooks() {
        let offset = lookSuggestionModels.count
        getLooks(offset: offset)
    }
    
    func handleResponse(_ response: [[String: Any]], loadingMore: Bool = false) {
        if !loadingMore {
            loadSuggestionMore = true
            lookSuggestionModels.removeAll()
        }
        
        if response.isEmpty {
            loadSuggestionMore = false
        }
        
        for lookResponse in response {
            let look = LookModelSuggestion(dict: lookResponse)
            lookSuggestionModels.append(look)
        }
        updateCompletion?(.success(response: true))
    }
}

extension LookDetailViewModel {
    private func addStatistic(index: Int) {
        let model = looksModel[index]
        if var count = lookStatistic[model.id] {
            count += 1
            lookStatistic[model.id] = count
        } else {
            lookStatistic[model.id] = 1
        }
    }
    
    public func saveLookStatistic() {
        if lookStatistic.isEmpty { return }
        let lookStatisticsWebService = LookStatisticsWebService()
        lookStatisticsWebService.saveLookStatistics(statistics: lookStatistic) { (success) in }
    }
}


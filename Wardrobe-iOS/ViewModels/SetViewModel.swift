//
//  SetViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/18/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class SetViewModel {
    private var itemModels: [ItemModel]?
    private var setModel: SetModel?
    private var albumModel: AlbumModel?
    var updateCompletion: ((RequestResponseType) -> ())?
    public var loadMore: Bool = true
    public  var lookModels = [LookModelSuggestion]()
    init() {
        
    }
    
    public func saveSet(_ album: AlbumModel) {
        let setModel = SetModel()
        setModel.setItemsId(itemModels ?? [])
        setModel.setAlbumId(album)
        updateCompletion?(.start(showLoading: true))
        if !haveConnection() {
            updateCompletion?(.fail(showPopup: true))
            return
        }
        //!setModel.canSendSet
        
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
    
    public func editSet() {
        if let model = setModel {
            updateCompletion?(.start(showLoading: true))
            if !haveConnection() {
                updateCompletion?(.fail(showPopup: true))
                return
            }
            let setWebService = SetWebService()
            setWebService.editSet([model]) { [weak self] (finish) in
                guard let strongSelf = self else { return }
                if finish {
                    strongSelf.handleUpdateResponse(model)
                } else {
                    strongSelf.updateCompletion?(.fail(showPopup: true))
                }
            }
        }
    }
    
    public func deleteSet() {
        if let model = setModel {
            updateCompletion?(.start(showLoading: true))
            if !haveConnection() {
                updateCompletion?(.fail(showPopup: true))
                return
            }
            let setWebService = SetWebService()
            setWebService.deleteSet([model]) { [weak self] (finish) in
                guard let strongSelf = self else { return }
                if finish {
                    strongSelf.handleDeleteResponse(model)
                } else {
                    strongSelf.updateCompletion?(.fail(showPopup: true))
                }
            }
        }
    }
    
    public func getItems() -> [ItemModel] {
        if let model = setModel {
            return model.itemModels ?? []
        }
        return itemModels ?? []
    }
    
    public func setItems(_ models: [ItemModel]) {
        itemModels = models
    }
    
    public func setSetModel(_ model: SetModel) {
        setModel = model
    }
    
    public func getSetModel() -> SetModel? {
        if setModel != nil {
            return setModel
        } else {
            let setModel = SetModel()
            setModel.setItemsId(itemModels ?? [])
            return setModel
        }
    }
    
    public func setAlbumModel(_ model: AlbumModel) {
        albumModel = model
    }
        
    public func addItemModel(_ itemModel: ItemModel) {
        setModel?.itemModels?.append(itemModel)
        if let id = itemModel.id {
            setModel?.itemIds?.append(id)
        } else {
            if setModel?.pendingItemIdList == nil {
                setModel?.pendingItemIdList = [String]()
            }
            setModel?.pendingItemIdList?.append(itemModel.tempId ?? "")
        }
    }
    
    public func removeItem(_ index: Int) {
        setModel?.itemModels?.remove(at: index)
        setModel?.itemIds?.remove(at: index)
    }
}

//MARK:- Handle response
extension SetViewModel {
    func handleCreateResponse(_ response: [[String: Any]]) {
        for set in response {
            let model = SetModel(set)
            _ = CoreDataJsonParserManager.shared.createSet(model: model)
        }
        updateCompletion?(.success(response: nil))
    }
    
    func handleUpdateResponse(_ model: SetModel) {
        CoreDataJsonParserManager.shared.updateSet(model: model)
        updateCompletion?(.success(response: nil))
    }
    
    func handleDeleteResponse(_ model: SetModel) {
        albumModel?.removeSetModel(model)
        CoreDataJsonParserManager.shared.deleteSet(model: model)
        updateCompletion?(.success(response: (success: true, delete: true)))
    }
}

//MARK:- Look
extension SetViewModel {
    func getLooks(offset: Int = 0, limit: Int = 10) {
        if offset == 0 {
            updateCompletion?(.start(showLoading: true))
        }
        if !haveConnection() {
            updateCompletion?(.fail(showPopup: true))
            return
        }
        let filterItems: [ItemModel] = setModel?.itemModels?.filter( {$0.id != nil }) ?? []
        let ids = filterItems.map { (itemModel) -> Int64 in
            return itemModel.id!
        }
        let suggestionWebService = SuggestionWebService()
        suggestionWebService.getSetSuggestion(itemIds: ids, offset: offset, limit: limit) { [weak self] (response, error) in
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
    
    func loadMoreLooks() {
        let offset = lookModels.count
        getLooks(offset: offset)
    }
    
    func handleResponse(_ response: [[String: Any]], loadingMore: Bool = false) {
        if !loadingMore {
            loadMore = true
            lookModels.removeAll()
        }
        
        if response.isEmpty {
            loadMore = false
        }
        
        for lookResponse in response {
            let look = LookModelSuggestion(dict: lookResponse)
            lookModels.append(look)
        }
        updateCompletion?(.success(response: true))
    }
}


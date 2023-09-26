//
//  AlbumModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/17/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class AlbumModel {
    var id: Int64?
    var tempId: String
    var title: String
    var isDefault: Bool
    var setModels: [SetModel] = [SetModel]()
    var name: String {
        if isDefault {
            return "Special Events".localize()
        } else {
            return title
        }
    }
    
    func addSetModel(_ model: SetModel) {
        setModels.append(model)
    }
    
    func removeSetModel(_ model: SetModel) {
        if let index = setModels.firstIndex(where: { $0.id == model.id }) {
            setModels.remove(at: index)
        }
    }
    
    func getLooks(setModel: SetModel) -> (LookModelSuggestion?, [LookModelSuggestion]) {
        let setLookFilterModels = setModels.filter({ $0.lookId != nil })
        var lookSuggestions = [LookModelSuggestion]()
        var selectedLookModel: LookModelSuggestion?
        setLookFilterModels.forEach { (model) in
            let lookModel = LookModelSuggestion(id: model.lookId!, url: model.url ?? "", aspectRation: model.aspectRation ?? "")
            lookModel.setId = model.id
            lookModel.setItemsId(itemIds: setModel.itemIds)
            if lookModel.id == setModel.lookId {
                selectedLookModel = lookModel
            }
            lookSuggestions.append(lookModel)
        }
        return (selectedLookModel, lookSuggestions)
    }
    
    init(tempId: String, title: String) {
        self.tempId = tempId
        self.title = title
        self.isDefault = false
    }
    
    init(_ dict: [String: Any]) {
        id = dict["albumId"] as? Int64
        tempId = dict["tempId"] as? String ?? ""
        title = dict["title"] as? String ?? ""
        let defaultAlbum = dict["isDefault"] as? Int ?? 0
        isDefault = defaultAlbum == 1
    }
    
    init(_ album: Album) {
        id = album.id as? Int64
        tempId = album.tempId ?? ""
        title = album.title ?? ""
        isDefault = album.isDefault
    }
    
    deinit {
        
    }
}

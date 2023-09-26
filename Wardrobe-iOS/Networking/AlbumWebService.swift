//
//  AlbumWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/17/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class AlbumWebService: BaseNetworkManager {

    func saveAlbum(_ albumModels: [AlbumModel], _ completion : @escaping RequestCompletion) {
        var values = [[String: Any]]()
        for album in albumModels {
            var parameters = [String : Any]()
            parameters["tempId"] = album.tempId
            parameters["title"] = album.title
            values.append(parameters)
        }
        sendPostRequest(path: Paths.albums, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            completion(response, error)
        }
    }
    
    func updateAlbum(_ albumModels: [AlbumModel], _ completion : @escaping (Bool) -> ()) {
        var values = [[String: Any]]()
        for album in albumModels {
            var parameters = [String : Any]()
            parameters["albumId"] = album.id
            parameters["title"] = album.title
            values.append(parameters)
        }
        
        sendPutRequest(path: Paths.albums, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isAlbumsUpdated = response["isAlbumsUpdated"] as? Bool, isAlbumsUpdated {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
    
    func deleteAlbum(_ albumModels: [AlbumModel], _ completion : @escaping (Bool) -> ()) {
        var values = [Int64]()
        for album in albumModels {
            values.append(album.id!)
        }

        sendDeleteRequest(path: Paths.albums, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isAlbumsDeleted = response["isAlbumsDeleted"] as? Bool, isAlbumsDeleted {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
}

//
//  LookViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/13/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

enum LookViewModelType {
    case whatToWear
    case explore
}

class LookViewModel {
    var lookModels = [LookModelSuggestion]()
    public var type: LookViewModelType = .whatToWear
    public var loadMore: Bool = true
    public var emptyLooks: [CGFloat] = [1.4, 1, 1, 1.4, 1, 1.4, 1, 1.4, 1, 1.4]
    public var whatToWearExploreCount: Int = 0
    var completion: (() -> ())?
    init() {
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnection(_:)), name: NSNotification.Name(rawValue: NotificationName.noInternet), object: nil)
    }
    
    @objc private func handleConnection(_ notification: NSNotification) {
        let isReachable = notification.object as! Int
        if isReachable == 1 && lookModels.isEmpty {
            getLooks()
        }
    }
    
    func getLooks(offset: Int = 0, limit: Int = 20) {
        if !haveConnection() {
            completion?()
            return
        }
        let suggestionWebService = SuggestionWebService()
        suggestionWebService.getSuggestion(lookModelType: whatToWearExploreCount > 0 ? .explore : type, offset: offset, limit: limit) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.completion?()
                return
            }
            if let response = response as? [String: Any] {
                strongSelf.handleResponse(response, loadingMore: offset != 0)
            }
        }
    }
    
    func loadMoreLooks() {
        var offset = lookModels.count
        if whatToWearExploreCount > 0 {
            offset = whatToWearExploreCount
        }
        getLooks(offset: offset)
    }
    
    func handleResponse(_ response: [String: Any], loadingMore: Bool = false) {
        var responseArray = [[String: Any]]()
        if let whatToWearLooks = response["whatToWearLooks"] as? [[String : Any]] {
            responseArray.append(contentsOf: whatToWearLooks)
        }
        
        if let explore = response["exploreLooks"] as? [[String : Any]] {
            if type == .whatToWear {
                whatToWearExploreCount += explore.count
            }
            responseArray.append(contentsOf: explore)
        }
        
        
        if !loadingMore {
            loadMore = true
            lookModels.removeAll()
        }
        
        if responseArray.isEmpty {
            loadMore = false
        }
        
        for lookResponse in responseArray {
            let look = LookModelSuggestion(dict: lookResponse)
            lookModels.append(look)
        }
        completion?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

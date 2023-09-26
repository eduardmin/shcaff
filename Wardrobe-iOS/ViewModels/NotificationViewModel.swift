//
//  NotificationViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/17/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

class NotificationViewModel {
    private let notificationWebService = NotificationWebService()
    public var notificationModels = [NotificationModel]()
    public var loadMore: Bool = true
    public var completion: ((RequestResponseType) -> ())?
    
    func haveNotification(completion: @escaping (Bool, Error?) -> ())  {
        notificationWebService.getNotifiations(offset: 0, limit: 1) { (response, error) in
            if error != nil {
                completion(false, error)
                return
            }
            
            if let response = response as? [[String: Any]], !response.isEmpty {
                let seen = response.first?["isSeen"] as? Int ?? 1
                completion(seen == 0, nil)
                return
            }
            completion(false, nil)
        }
    }
    
    
    func getNotifictions(offset: Int = 0, limit: Int = 10) {
        if !haveConnection() {
            completion?(.fail(showPopup: true))
            return
        }
        notificationWebService.getNotifiations(offset: offset, limit: limit) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.completion?(.fail(showPopup: true))
                return
            }
            
            if let response = response as? [[String: Any]] {
                strongSelf.handleNotification(response: response, loadingMore: offset != 0)
                return
            }
        }
    }
    
    func loadMoreNotification() {
        let offset = notificationModels.count
        getNotifictions(offset: offset)
    }
    
    func updateSeenNotifications() {
        notificationWebService.updateSeenNotifications { (success) in
            if success {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.init(NotificationName.badge), object: nil, userInfo: nil)
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
            }
        }
    }
}

//MARK:- Private Func
extension NotificationViewModel {
    private func handleNotification(response: [[String: Any]], loadingMore: Bool = false) {
        if !loadingMore {
            loadMore = true
            notificationModels.removeAll()
        }
        
        if response.isEmpty {
            loadMore = false
        }
        
        for notification in response {
            let model = NotificationModel(dict: notification)
            notificationModels.append(model)
        }
        completion?(.success(response: nil))
    }
}

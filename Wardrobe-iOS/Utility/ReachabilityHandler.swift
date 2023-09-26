//
//  ReachabilityHandler.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/16/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import Foundation

class ReachabilityHandler: ReachabilityObserverDelegate {
    
    private var isConnected: Bool = false
    //MARK: Lifecycle
    
    required init() {
        try? addReachabilityObserver()
    }
    
    deinit {
        removeReachabilityObserver()
    }
    
    //MARK: Reachability

    func reachabilityChanged(_ isReachable: Bool) {
        isConnected = isReachable
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.noInternet), object: isReachable)
    }
    
    func haveConnection() -> Bool {
        return isConnected
    }
}

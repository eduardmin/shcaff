//
//  obsereble.swift
//  Created by Eduard Minasyan on 3/1/21.
//

import Foundation

class Observable<T> {
    typealias Listener = (T) -> Void
    private var listeners: [Listener?] = [Listener?]()
    
    var value: T {
        didSet {
            listeners.forEach({ (listener) in
                listener?(value)
            })
        }
    }

    init(_ value: T) {
        self.value = value
    }

    
    func bind(listener: Listener?) {
        self.listeners.append(listener)
    }
}

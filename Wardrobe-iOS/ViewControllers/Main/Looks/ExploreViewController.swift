//
//  ExploreViewController.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 5/26/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class ExploreViewController: LooksViewController {
    
    private let viewModel = LookViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        viewModel.type = .explore
        collectionView.type = .explore
        viewModel.completion = { [weak self] in
            guard let strongSelf = self else { return }
            if !strongSelf.viewModel.lookModels.isEmpty {
                strongSelf.collectionView.emptyLook.removeAll()
                strongSelf.collectionView.looks = strongSelf.viewModel.lookModels
            } else {
                strongSelf.collectionView.emptyLook = strongSelf.viewModel.emptyLooks
            }
        }
        viewModel.getLooks()
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(scrollTop), name: NSNotification.Name(rawValue: NotificationName.scrollToCollection), object: nil)
    }
    
    @objc func scrollTop() {
        collectionView.scrollTop()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:- LookCollectionViewDelete
extension ExploreViewController: LookCollectionViewDelete {
    func isLoadMore() -> Bool {
        return viewModel.loadMore
    }
    
    func loadMore() {
        viewModel.loadMoreLooks()
    }
    
    func updateLooks() {
        viewModel.getLooks()
    }
}


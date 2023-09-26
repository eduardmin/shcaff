//
//  AccountViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 2/20/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class AccountViewModel {
    private var profileModel: ProfileModel!
    public var clothesCount: Int = 0
    public var colorStatModels = [ColorStatModel]()
    var lastWearedItems: [ItemModel] = [ItemModel]()
    var completion: ((RequestResponseType) -> ())?
    var maxColorCount: Int {
        let count: Int = colorStatModels.map { $0.quantity }.max() ?? 0
        return count
    }
    var lessWornItems: [ItemModel?] = [ItemModel?]()
    var mostWornItems: [ItemModel?] = [ItemModel?]()
    private let persentDefferenceInItem: CGFloat = 30
    
    init() {
        profileModel = UIApplication.appDelegate.profileModel
        clothesCount = CoreDataManager.shared.allObjectsCountForEntity(entityName: EntityName.item)
        getStats()
    }
    
    func getStats() {
        completion?(.start(showLoading: true))
        if !haveConnection() {
            completion?(.fail(showPopup: true))
            return
        }
        let statsWebService = StatsWebService()
        statsWebService.getStats { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.completion?(.fail(showPopup: true))
                return
            }
            
            if let response = response as? [String: Any] {
                strongSelf.handleStats(response: response)
                return
            }
            
            strongSelf.completion?(.fail(showPopup: true))
        }
    }
    
    func updateProfile() {
        profileModel = UIApplication.appDelegate.profileModel
    }
    
    func getFullName() -> String {
        return profileModel.getFullName()
    }
    
    func getGenderAndDate() -> String {
        return profileModel.getGenderTitle() + ", " + "\(profileModel.getAge()) " + "y.o.".localize()
    }
    
    func getImageData() -> Data? {
        return profileModel.imageData
    }
}

//MARK:- Private func
extension AccountViewModel {
    func handleStats(response: [String: Any]) {
        DispatchQueue.global().async {
            if let colorStats = response["colorStats"] as? [[String: Any]] {
                colorStats.forEach { (color) in
                    let colorStatModel = ColorStatModel(dict: color)
                    self.colorStatModels.append(colorStatModel)
                }
            }
            
            if let itemStatsList = response["itemStatsList"] as? [[String: Any]] {
                var itemStatModels = [ItemStatModel]()
                itemStatsList.forEach { (item) in
                    let itemStatModel = ItemStatModel(dict: item)
                    itemStatModels.append(itemStatModel)
                }
                self.handleItemStatModel(itemStatModels: itemStatModels)
            }
            
            if let lastWearedItemList = response["lastWearedItemList"] as? [Int64] {
                lastWearedItemList.forEach { (id) in
                    if let item = CoreDataManager.shared.objectWithID(id: id, entityName: EntityName.item) as? Item {
                        let itemModel = ItemModel(item)
                        self.lastWearedItems.append(itemModel)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.completion?(.success(response: nil))
            }
        }
    }
    
    func handleItemStatModel(itemStatModels: [ItemStatModel]) {
        var models = itemStatModels
        models.sort { $0.quantity > $1.quantity }
        for i in 0..<models.count {
            if i == models.count - 1 {
                return
            }
            
            let modelFirst = models[i]
            let modelSecond = models[i + 1]
            let persent = (CGFloat(modelSecond.quantity) * 100) / CGFloat(modelFirst.quantity)
            if persent <= persentDefferenceInItem {
                let index = i + 1
                for j in 0..<models.count {
                    if j < index {
                        let model = models[j]
                        if !mostWornItems.contains(where: { $0?.clothingType == model.itemModel?.clothingType }) {
                            mostWornItems.append(model.itemModel)
                        }
                    } else {
                        let model = models[j]
                        if !lessWornItems.contains(where: { $0?.clothingType == model.itemModel?.clothingType }) {
                            lessWornItems.append(model.itemModel)
                        }
                    }
                }
                return
            }
        }
    }
}

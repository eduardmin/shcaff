//
//  ItemModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/26/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class ItemModel {
    var id: Int64?
    var itemType: Int64?
    var clothingType: Int64?
    var clothingStyle: Int64?
    var gender: Int16?
    var temperatureRange: Int64?
    var print: Int64?
    var size: Int64?
    var colors: [Int64]?
    var url: String?
    var brand: String?
    var tempId: String?
    var personal: Bool?
    var downloadState: Int16?
    var updateTs: Int64?
    var imageUpdated: Bool = false
    
    private var _imageData: Data?
    var image: UIImage {
        switch downloadState {
        case ItemDownloadState.progress.rawValue:
            return UIImage(named: "downloadProgress")!
        case ItemDownloadState.failed.rawValue:
            return UIImage(named: "downloadFail")!
        default:
            break
        }
    
        if _imageData == nil {
            let _id = id != nil ? "\(id!)" : tempId!
            var data = FileManagerSW.manager.getFile(name: FileName.items, id: _id)
            if data == nil {
                data = FileManagerSW.manager.getFile(name: FileName.items, id: tempId ?? "")
            }
            _imageData = data
        }
        guard let image = UIImage(data: _imageData ?? Data()) else { return UIImage(named: "downloadProgress")! }
        return image
    }
    
    func setImageData(imageData: Data?) {
        _imageData = imageData
    }
    
    func getImageData() -> Data? {
        return _imageData
    }
    
    init(_ dict: [String: Any]) {
        id = dict["id"] as? Int64
        itemType = dict["itemType"] as? Int64
        clothingType = dict["clothingType"] as? Int64
        clothingStyle = dict["clothingStyle"] as? Int64
        gender = dict["gender"] as? Int16
        temperatureRange = dict["temperatureRange"] as? Int64
        print = dict["print"] as? Int64
        size = dict["size"] as? Int64
        colors = dict["colors"] as? [Int64]
        url = dict["url"] as? String
        brand = dict["brand"] as? String
        tempId = dict["tempId"] as? String
        imageUpdated = dict["imageUpdated"] as? Bool ?? false
        updateTs = dict["updateTs"] as? Int64
        personal = dict["personal"] as? Bool ?? true
    }

    init(_ item: Item) {
        id = item.id as? Int64
        itemType = item.itemType as? Int64
        clothingType = item.clothingType as? Int64
        clothingStyle = item.clothingStyle as? Int64
        gender = item.gender as? Int16
        temperatureRange = item.temperatureRange as? Int64
        print = item.print as? Int64
        size = item.size as? Int64
        colors = item.colors
        url = item.url
        brand = item.brand
        tempId = item.tempId
        downloadState = item.downloadState
        imageUpdated = item.imageUpdated
        updateTs = item.updateTs as? Int64
        personal = item.personal
    }
    
    init(_ tempId: String) {
        self.tempId = tempId
    }
    
    deinit {
        _imageData = nil
    }
    
    func addColor(_ id: Int64) {
        if colors == nil {
            colors = [Int64]()
        }
        if !colors!.contains(id) {
            colors?.append(id)
        }
    }
    
    func compareItems(itemModel : ItemModel) -> Bool {
        var equal = true
        if itemModel.clothingType != nil, clothingType != itemModel.clothingType {
            equal = false
        }
        
        if itemModel.itemType != nil, itemType != itemModel.itemType {
            equal = false
        }
        
        if itemModel.temperatureRange != nil, temperatureRange != itemModel.temperatureRange {
            equal = false
        }
        
        if itemModel.clothingStyle != nil, clothingStyle != itemModel.clothingStyle {
            equal = false
        }
        
        if itemModel.print != nil, print != itemModel.print {
            equal = false
        }
        
        if itemModel.size != nil, size != itemModel.size {
            equal = false
        }
        
        if itemModel.colors != nil, colors != itemModel.colors {
            equal = false
        }
        
        if itemModel.brand != nil, brand != itemModel.brand {
            equal = false
        }

        return equal
    }
}

//MARK:- ItemModel names
extension ItemModel {
    func getItemTypeName() -> String {
        let constant = CoreDataManager.shared.getConstant(.itemTypes, itemType ?? -1)
        let model = BaseParameterModel(constant?.id ?? -1, constant?.names,  ItemParametersType(rawValue: Int(itemType ?? -1)))
        return model.name ?? ""
    }
    
    func getItemColorAndTypeName() -> String {
        let constant = CoreDataManager.shared.getConstant(.colors, colors?.first ?? -1)
        let model = BaseParameterModel(constant?.id ?? -1, constant?.names,  ItemParametersType(rawValue: Int(colors?.first ?? -1)))
        let colorName = model.name ?? ""
        return colorName + " " + getItemTypeName()
    }
}

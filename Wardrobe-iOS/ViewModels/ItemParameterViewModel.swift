//
//  ItemParameterViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/21/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum ItemParametersType: Int {
    case picture
    case clothingType
    case type
    case color
    case print
    case size
    case brand
    case style
    case occassion
    case season
    
    static var serverEquelTypes: [ServerConstants: ItemParametersType] = [.clothingTypes: clothingType, .itemTypes: type, .colors: .color, .prints: .print, .sizes: .size, .styles: .style, .occasions: .occassion, .seasons: .season]
}

enum ItemViewModelType {
    case edit
    case save
    case filter
}

enum ItemParamCompletionType {
    case update(Int?, Bool)
    case checkRequiredEmpty(Bool)
}

class ItemParameterViewModel {
    private let coreDataManager = CoreDataManager.shared
    private let fetchConstantsType: [ServerConstants] = [.clothingTypes, .colors, .prints, .sizes]
    private let itemViewTypes: [ItemParametersType] = [.type, .color, .print, .size, .brand]
    private var typeConstantIndex: Int = 2
    var type = ItemViewModelType.save
    var paramterModels = [ItemParameterModel]()
    var itemViewParameterModels = [ItemViewParameterModel]()
    var itemCompletion: ((ItemParamCompletionType) -> ())?
    var filterCompletion: ((ItemModel) -> ())?
    var itemModel: ItemModel? {
        didSet {
            configureItem()
        }
    }
    
    var filterItem: ItemModel? {
        didSet {
            configureFilterItem()
        }
    }
    
    var saveItemModel: ItemModel
    
    init() {
        saveItemModel = ItemModel(generateRandomId())
        configureParameterModel()
    }
    
    func setImageData(_ imageData: Data) {
        saveItemModel.setImageData(imageData: imageData)
        let itemPictureParamModel = paramterModels.first
        itemPictureParamModel?.setImageData(imageData: imageData)
    }
    
    //MARK:- public Func
    public func saveItem() {
        if type == .save {
            saveItem(saveItemModel, true)
            if !haveConnection() {
                return
            }
            ItemManager.manager.saveItem(itemModels: [saveItemModel])
            
        } else {
            if saveItemModel.id != nil {
                saveItem(saveItemModel, saveItemModel.imageUpdated)
                if !haveConnection() {
                    return
                }
                ItemManager.manager.editItem(itemModels: [saveItemModel])
            } else {
                CoreDataJsonParserManager.shared.updateItem(saveItemModel, false, true, true)
            }
        }
    }
    
    public func clearItem() {
        clearSaveModel()
        itemCompletion?(.update(nil, false))
    }
    
    public func selectParameter(_ parameterIndex: Int, _ valueIndex: Int) {
        let itemParameterModel = paramterModels[parameterIndex]
        if let baseParameterModel = itemParameterModel.parameterModels?[valueIndex] {
            switch itemParameterModel.type {
            case .clothingType:
                saveItemModel.clothingType = baseParameterModel.id
                addTypeModel(update: true, clothingId: saveItemModel.clothingType)
            case .type:
                saveItemModel.itemType = baseParameterModel.id
            case .color:
                saveItemModel.addColor(baseParameterModel.id)
            case .print:
                saveItemModel.print = baseParameterModel.id
            case .size:
                saveItemModel.size = baseParameterModel.id
            default:
                break
            }
        }
        checkRequiredEmpty()
    }
    
    public func deselectParameter(_ parameterIndex: Int, _ valueIndex: Int) {
        let itemParameterModel = paramterModels[parameterIndex]
        if let baseParameterModel = itemParameterModel.parameterModels?[valueIndex] {
            switch itemParameterModel.type {
            case .clothingType:
                saveItemModel.clothingType = nil
                saveItemModel.itemType = nil
            case .type:
                saveItemModel.itemType = nil
            case .color:
                if let index = saveItemModel.colors?.firstIndex(of: baseParameterModel.id) {
                    saveItemModel.colors?.remove(at: index)
                }
            case .print:
                saveItemModel.print = nil
            case .size:
                saveItemModel.size = nil
            default:
                break
            }
        }
        checkRequiredEmpty()
    }
    
    
    public func addBrand(_ text: String) {
        saveItemModel.brand = text
    }
    
    public func getBrandText() -> String? {
        return saveItemModel.brand
    }
    
    public func changeImage() {
        if type == .edit {
            saveItemModel.imageUpdated = true
        }
    }
    
    public func selectedPatamerts(_ type: ItemParametersType) -> [Int64]? {
        switch type {
        case .clothingType:
            if let clothingType = saveItemModel.clothingType {
                return [clothingType]
            }
        case .type:
            if let type = saveItemModel.itemType {
                return [type]
            }
        case .color:
            return saveItemModel.colors
        case .print:
            if let print = saveItemModel.print {
                return [print]
            }
        case .size:
            if let size = saveItemModel.size {
                return [size]
            }
        default:
            break
        }
        return nil
    }
}

//MARK:- Private Func
extension ItemParameterViewModel {
    
    private func configureItem() {
        configureViewParameterModel()
        if itemModel != nil {
            configureSaveModel(itemModel)
            type = .edit
        }
    }
    
    private func configureFilterItem() {
        if filterItem != nil {
            configureSaveModel(filterItem)
            type = .filter
        }
        paramterModels.removeSubrange(0...1)
        typeConstantIndex = 0
        addTypeModel(update: true, clothingId: saveItemModel.clothingType)
    }
    
    private func configureParameterModel() {
        let genderId: Int16? = UIApplication.appDelegate.profileModel?.genderId()
        for type in fetchConstantsType {
            let itemParamModel = ItemParameterModel(ItemParametersType.serverEquelTypes[type]!, nil, nil, muliplyTouch: ServerConstants.supportMultitouch(type), editable: false, requiredField: ServerConstants.requiredParameter(type))
            var _genderId: Int16?
            if ServerConstants.supportGenderId(type) {
                _genderId = genderId
            }
            var constants = coreDataManager.getConstants(type, _genderId)
            var parameters = [BaseParameterModel]()
            if constants != nil {
                constants?.sort {$0.id < $1.id}
                for constant in constants! {
                    switch type {
                    case .colors:
                        let model = ColorParameterModel(constant.id, constant.names, (constant as? Colors)?.code ?? "", ItemParametersType.serverEquelTypes[type])
                        parameters.append(model)
                    default:
                        let model = BaseParameterModel(constant.id, constant.names, ItemParametersType.serverEquelTypes[type])
                        parameters.append(model)
                    }
                }
            }
            itemParamModel.parameterModels = parameters
            paramterModels.append(itemParamModel)
        }
        
        addPictureModel()
        addTypeModel(update: false, clothingId: saveItemModel.clothingType)
        addBrandModel()
    }
    
    private func addPictureModel() {
        let itemPictureParamModel = ItemParameterModel(.picture, nil, nil, muliplyTouch: false, editable: false)
        paramterModels.insert(itemPictureParamModel, at: 0)
    }
    
    private func addTypeModel(update: Bool, clothingId: Int64?) {
        if let clothingTypeId = clothingId {
            let index: Int = typeConstantIndex
            var insert = true
            if paramterModels[typeConstantIndex].type == .type {
                paramterModels.remove(at: typeConstantIndex)
                insert = false
            }
            
            let itemParamModel = ItemParameterModel(.type, nil, nil, muliplyTouch: ServerConstants.supportMultitouch(.itemTypes), editable: false, requiredField: ServerConstants.requiredParameter(.itemTypes))

            var constants = coreDataManager.getTypesConstant(clothingTypeId, UIApplication.appDelegate.profileModel?.genderId())
            var parameters = [BaseParameterModel]()
            if constants != nil {
                constants?.sort {$0.id < $1.id}
                for constant in constants! {
                    let model = BaseParameterModel(constant.id, constant.names, .type)
                    parameters.append(model)
                }
            }
            itemParamModel.parameterModels = parameters
            paramterModels.insert(itemParamModel, at: typeConstantIndex)
            if update && itemCompletion != nil {
                itemCompletion!(.update(index, insert))
            }
        }
    }
    
    
    private func addBrandModel() {
        let itemBrandParamModel = ItemParameterModel(.brand, nil, nil, muliplyTouch: false, editable: true)
        paramterModels.append(itemBrandParamModel)
    }
    
    private func configureViewParameterModel() {
        itemViewParameterModels.removeAll()
        for type in itemViewTypes {
            let model = ItemViewParameterModel(type)
            var values: [String] = [String]()
            switch type {
            case .clothingType:
                if let value = getConstantValue(type, itemModel?.clothingType) {
                    values.append(value)
                }
            case .type:
                addTypeModel(update: false, clothingId: itemModel?.clothingType)
                if let value = getConstantValue(type, itemModel?.itemType) {
                    values.append(value)
                }
            case .color:
                for colorId in  itemModel?.colors ?? [] {
                    if let value = getConstantValue(type, colorId) {
                        values.append(value)
                    }
                }
            case .print:
                if let value = getConstantValue(type, itemModel?.print) {
                    values.append(value)
                }
            case .size:
                if let value = getConstantValue(type, itemModel?.size) {
                    values.append(value)
                }
            case .brand:
                if let value = itemModel?.brand {
                    values.append(value)
                }
            default:
                break
            }
            if !values.isEmpty {
                model.values = values
                itemViewParameterModels.append(model)
            }
        }
    }
    
    private func configureSaveModel(_ model: ItemModel?) {
        saveItemModel.id = model?.id
        saveItemModel.itemType = model?.itemType
        saveItemModel.clothingType = model?.clothingType
        saveItemModel.clothingStyle = model?.clothingStyle
        saveItemModel.gender = model?.gender
        saveItemModel.temperatureRange = model?.temperatureRange
        saveItemModel.print = model?.print
        saveItemModel.size = model?.size
        saveItemModel.colors = model?.colors
        saveItemModel.url = model?.url
        saveItemModel.brand = model?.brand
        if let data = model?.getImageData() {
            setImageData(data)
        }
    }
    
    private func clearSaveModel() {
        saveItemModel.itemType = nil
        saveItemModel.clothingStyle = nil
        saveItemModel.gender = nil
        saveItemModel.temperatureRange = nil
        saveItemModel.print = nil
        saveItemModel.size = nil
        saveItemModel.colors = nil
        saveItemModel.url = nil
        saveItemModel.brand = nil
    }
    
    private func getConstantValue(_ type: ItemParametersType, _ id: Int64? = nil) -> String? {
        if let parameterModel = paramterModels.filter({ $0.type == type}).first {
            var value: String?
            let baseParameterModel = parameterModel.parameterModels?.filter({$0.id == id}).first
            if type == .color {
                value = (baseParameterModel as? ColorParameterModel)?.code
            } else {
                value = baseParameterModel?.name
            }
            return value
        }
        return nil
    }
    
    private func checkRequiredEmpty() {
        if type == .filter { return }
        var requiredEmpty = true
        if saveItemModel.clothingType != nil && saveItemModel.itemType != nil && saveItemModel.colors != nil && !saveItemModel.colors!.isEmpty {
            requiredEmpty = false
        }
        itemCompletion?(.checkRequiredEmpty(requiredEmpty))
    }
}

// MARK:- Core Data
extension ItemParameterViewModel {
    
    func saveItem(_ model: ItemModel, _ imageUpload: Bool) {
        if let data = saveItemModel.getImageData(), imageUpload {
            FileManagerSW.manager.saveFile(name: FileName.items, id: model.tempId!, data: data)
        }
        CoreDataJsonParserManager.shared.createItem(model, false, true, true)
    }
    
}

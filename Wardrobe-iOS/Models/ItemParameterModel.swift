//
//  ItemParameterModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 9/21/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

class ItemParameterModel {
    var type: ItemParametersType
    var image: UIImage?
    var parameterModels: [BaseParameterModel]?
    var muliplyTouch: Bool
    var editable: Bool
    var requiredField: Bool
    
    init(_ type: ItemParametersType, _ parameterModels: [BaseParameterModel]?,  _ image: UIImage? = nil, muliplyTouch: Bool = false, editable: Bool = false, requiredField: Bool = false) {
        self.type = type
        self.parameterModels = parameterModels
        self.image = image
        self.muliplyTouch = muliplyTouch
        self.editable = editable
        self.requiredField = requiredField
    }
    
    func setImageData(imageData: Data) {
        let _image = UIImage(data: imageData)
        if _image != nil {
            image = _image
        }
    }
}

class ItemViewParameterModel {
    var type: ItemParametersType
    var values: [String] = [String]()
    init(_ type: ItemParametersType) {
        self.type = type
    }
}


class BaseParameterModel: Hashable {
    let id: Int64
    var names: [String: Any]?
    let type: ItemParametersType?
    var name: String? {
        let currentLanguageKey = LanguageManager.manager.currentLanguge().key
        if let en = names?[currentLanguageKey] as? String {
            return en
        } else if let base = names?["base"] as? String {
            return base
        }
        return nil
    }

    var defautText: String? {
        if let en = names?["en"] as? String {
            return en
        } else if let base = names?["base"] as? String {
            return base
        }
        return nil
    }
    
    init(_ id: Int64, _ names: [String: Any]?, _ type: ItemParametersType?) {
        self.id = id
        self.names = names
        self.type = type
    }
    
    static func == (lhs: BaseParameterModel, rhs: BaseParameterModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}

class ColorParameterModel: BaseParameterModel {
    let code: String
    init(_ id: Int64, _ names: [String: Any]?, _ code: String, _ type: ItemParametersType?) {
        self.code = code
        super.init(id, names, type)
    }
}

class EventTypeParameterModel: BaseParameterModel {
    let color: String
    init(_ id: Int64, _ names: [String: Any]?, _ color: String, _ type: ItemParametersType?) {
        self.color = color
        super.init(id, names, type)
    }
}


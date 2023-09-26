//
//  SearchViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/18/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

enum SearchResponseType {
    case textSuggestion
    case recent
    case filter
    case searchResult(NSAttributedString?)
    case searchMoreResult(NSAttributedString?)
    case error(NetworkError?)
}

class SearchViewModel {
    private let searchConstantsTypes: [ServerConstants] = [.itemTypes, .colors, .styles, .occasions, .prints, .seasons]
    private var parameterModels: [BaseParameterModel] = [BaseParameterModel]()
    private let searchWebService = SearchWebService()
    private let maxSuggestedCount: Int = 10
    private var itemParameterModels = [ItemParameterModel]()
    private var lastSearchText: String?
    public var filterParameters = [ItemParameterModel]()
    public var selectedItemParameterModels = [ItemParametersType: [Int64]]()
    public var searchRecentTexts: [String] = [String]()
    public var suggestedTexts: [String] = [String]()
    public var lookModels = [LookModelSuggestion]()
    public var loadMore: Bool = true
    var completion: ((SearchResponseType) -> ())?
    init() {
        getParameters()
    }
    
    func search(seachText: String, offset: Int = 0, limit: Int = 10) {
        if !haveConnection() {
            completion?(.error(nil))
            return
        }
        let params = getParametersFromSearchText(text: seachText)
        var selectedParams = [ItemParametersType: [Int64]]()
        params.0.forEach { (param) in
            if let type = param.type {
                if selectedParams[type] == nil {
                    selectedParams[type] = [Int64]()
                }
                selectedParams[type]?.append(param.id)
            }
        }
        lastSearchText = seachText
        searchWebService.search(lookParameters: selectedParams, query: seachText, offset: offset, limit: limit) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.completion?(.error(error))
                return
            }
            if let response = response as? [[String: Any]] {
                strongSelf.handleResponse(response, searchText: seachText, deletedTexts: params.1, loadingMore: offset != 0)
            }
        }
    }
    
    func searchWithParameters(text: String?, offset: Int = 0, limit: Int = 10) {
        if !haveConnection() {
            completion?(.error(nil))
            return
        }
        lastSearchText = nil
        var selectedParams = [ItemParametersType: [Int64]]()
        if let text = text {
            let params = getParametersFromSearchText(text: text)
            params.0.forEach { (param) in
                if let type = param.type {
                    if selectedParams[type] == nil {
                        selectedParams[type] = [Int64]()
                    }
                    selectedParams[type]?.append(param.id)
                }
            }
        }
        
        let query = getSelectedParameterQuery()
        if query.isEmpty {
            lookModels.removeAll()
            completion?(.searchResult(nil))
            return
        }
        searchWebService.search(lookParameters: getMergeParams(selectedParams: getMergeParams(selectedParams: selectedParams)), query: query, offset: offset, limit: limit) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error != nil {
                strongSelf.completion?(.error(nil))
                return
            }
            if let response = response as? [[String: Any]] {
                strongSelf.handleResponse(response, loadingMore: offset != 0)
            }
        }
    }
    
    func getMergeParams(selectedParams: [ItemParametersType: [Int64]]) -> [ItemParametersType: [Int64]] {
        var finalParams = selectedItemParameterModels
        selectedParams.forEach { (key, value) in
            if finalParams[key] != nil {
                finalParams[key]?.append(contentsOf: value)
            } else {
                finalParams[key] = value
            }
        }
        
        return finalParams
    }
    
    func searchMore(text: String?) {
        let offset = lookModels.count
        if let text = lastSearchText {
            search(seachText: text, offset: offset)
        } else {
            searchWithParameters(text: text, offset: offset)
        }
    }
    
    func getRecentSearchTexts() {
        searchWebService.getRecentTexts { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let response = response as? [String: Any] {
                strongSelf.searchRecentTexts.removeAll()
                let sortedResponse = response.sorted { $0.0 < $1.0 }
                sortedResponse.forEach { (arg0) in
                    let (_, value) = arg0
                    if let value = value as? String, !value.isEmpty {
                        strongSelf.searchRecentTexts.append(value)
                    }
                }
            }
            strongSelf.completion?(.recent)
        }
    }
    
    func deleteRecentSearchTexts() {
        searchWebService.deleteRecentText(ids: []) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error == nil {
                strongSelf.searchRecentTexts.removeAll()
            }
            strongSelf.completion?(.recent)
        }
    }
    
    func getSuggestion(searchText: String) {
        getSuggestionTextsFromParam(text: searchText)
    }
    
    func selectFilter(indexPath: IndexPath) {
        let param = itemParameterModels[indexPath.row]
        filterParameters.append(param)
        completion?(.filter)
    }
    
    func deselectFilter(indexPath: IndexPath) {
        let param = itemParameterModels[indexPath.row]
        if let index = filterParameters.firstIndex(where: { $0.type == param.type }) {
            filterParameters.remove(at: index)
            completion?(.filter)
        }
    }
    
    func selectParameter(_ parameterIndex: Int, _ valueIndex: Int, _ text: String?) {
        let itemParameterModel = filterParameters[parameterIndex]
        if let baseParameterModel = itemParameterModel.parameterModels?[valueIndex] {
            if selectedItemParameterModels[itemParameterModel.type] == nil {
                selectedItemParameterModels[itemParameterModel.type] = [Int64]()
            }
            selectedItemParameterModels[itemParameterModel.type]?.append(baseParameterModel.id)
            searchWithParameters(text: text)
        }
    }
    
    func deselectParameter(_ parameterIndex: Int, _ valueIndex: Int, _ text: String?) {
        let itemParameterModel = filterParameters[parameterIndex]
        if let baseParameterModel = itemParameterModel.parameterModels?[valueIndex] {
            if let index =  selectedItemParameterModels[itemParameterModel.type]?.firstIndex(of: baseParameterModel.id) {
                selectedItemParameterModels[itemParameterModel.type]?.remove(at: index)
                searchWithParameters(text: text)
            }
        }
    }
    
    func getParam(indexPath: IndexPath) -> ItemParameterModel {
        return itemParameterModels[indexPath.row]
    }
    
    func setFilterParam(params: [ItemParameterModel]) {
        filterParameters = params
        completion?(.filter)
    }
    
    func initialState() {
        filterParameters.removeAll()
        selectedItemParameterModels.removeAll()
    }
}

//MARK:- Search Parameter
extension SearchViewModel {
    func getSearchParameterCount() -> Int {
        return searchConstantsTypes.count
    }
    
    func getType(indexPath: IndexPath) -> ServerConstants {
        return searchConstantsTypes[indexPath.row]
    }
    
    func getTitle(type: ServerConstants) -> String {
        switch type {
        case .colors:
            return "Color".localize()
        case .styles:
            return "Style".localize()
        case .occasions:
            return "Occassions".localize()
        case .prints:
            return "Print".localize()
        case .seasons:
            return "Seasons".localize()
        case .itemTypes:
            return "Item Type".localize()
        default:
            return ""
        }
    }
    
    func getImageName(type: ServerConstants) -> String {
        switch type {
        case .colors:
            return "searchColor"
        case .styles:
            return "searchStyles"
        case .occasions:
            return "searchEvents"
        case .prints:
            return "searchPrints"
        case .seasons:
            return "searchSeasons"
        case .itemTypes:
            return "searchItem"
        default:
            return ""
        }
    }
    
    private func getParameters() {
        for type in searchConstantsTypes {
            let itemParamModel = ItemParameterModel(ItemParametersType.serverEquelTypes[type]!, nil, nil, muliplyTouch: ServerConstants.supportMultitouch(type), editable: false, requiredField: ServerConstants.requiredParameter(type))
            var genderId: Int16?
            if ServerConstants.supportGenderId(type) {
                genderId = UIApplication.appDelegate.profileModel?.genderId()
            }
            var constants = CoreDataManager.shared.getConstants(type, genderId)
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
            parameterModels.append(contentsOf: parameters)
            itemParamModel.parameterModels = parameters
            itemParameterModels.append(itemParamModel)
        }
    }
}

//MARK:- Private Func
extension SearchViewModel {
    private func getSuggestionTextsFromParam(text: String) {
        suggestedTexts.removeAll()
        let splitSearchTexts = text.split(separator: " ")
        var models = [[BaseParameterModel]]()
        splitSearchTexts.forEach { ( searchText ) in
            let parameters = parameterModels.filter { ( model ) -> Bool in
                if let name = model.name, name.lowercased().hasPrefix(searchText.lowercased()) {
                    return true
                }
                return false
            }
            models.append(parameters)
        }
        
        if models.count == 1 {
            let parameters = models.first!
            suggestedTexts =  parameters.map({ ( model ) -> String in
                if model is ColorParameterModel {
                    return model.name ?? "" + getRendomItemType()
                } else {
                    return model.name ?? ""
                }
            })
        } else if models.count > 1 {
            var count = models.sorted { $0.count > $1.count }.first?.count ?? 0
            count = count > maxSuggestedCount ? maxSuggestedCount : count
            for _ in 0..<count {
                var suggestedText = models.first!.randomElement()?.name ?? ""
                for i in 1..<models.count {
                    let parameters = models[i]
                    let name = " " + (parameters.randomElement()?.name ?? "")
                    suggestedText += name
                }
                suggestedTexts.append(suggestedText)
            }
            suggestedTexts = uniq(source: suggestedTexts)
        } else {
            suggestedTexts.removeAll()
        }
        
        completion?(.textSuggestion)
    }
    
    private func getRendomItemType() -> String {
        let parameterModel = itemParameterModels.filter({ $0.type == .type }).first
        let param  = parameterModel?.parameterModels?.randomElement()
        return param?.name ?? ""
    }
    
    private func getParametersFromSearchText(text: String) -> ([BaseParameterModel], [String]) {
        let splitSearchTexts = text.split(separator: " ")
        var deletedTexts = [String]()
        var models = [BaseParameterModel]()
        splitSearchTexts.forEach { ( searchText ) in
            let parameter = parameterModels.filter { ( model ) -> Bool in
                if let name = model.name, name.lowercased() == searchText.lowercased(){
                    return true
                }
                return false
            }.first
            
            if let parameter = parameter {
                models.append(parameter)
            } else {
                deletedTexts.append(String(searchText))
            }
        }
        return (models, deletedTexts)
    }
    
    private func getSelectedParameterQuery() -> String {
        if selectedItemParameterModels.isEmpty { return "" }
        var query: String = ""
        var params = [BaseParameterModel]()
        selectedItemParameterModels.forEach { (key, values) in
            let filtParam = filterParameters.filter { $0.type == key}
            filtParam.forEach { (model) in
                params.append(contentsOf: model.parameterModels?.filter { values.contains($0.id) } ?? [])
            }
        }
        
        params.forEach { (model) in
            query += model.name ?? ""
            query += " "
        }
        if !query.isEmpty {
            query.removeLast()
        }
        return query
    }
    
    private func handleResponse(_ response: [[String: Any]], searchText: String? = nil, deletedTexts: [String]? = nil, loadingMore: Bool = false) {
        if !loadingMore {
            loadMore = true
            lookModels.removeAll()
        }
        
        if response.isEmpty {
            loadMore = false
        }
        
        for lookResponse in response {
            let look = LookModelSuggestion(dict: lookResponse)
            lookModels.append(look)
        }
        
        var attributedSting: NSAttributedString?
        if let searchText = searchText, let deletedTexts = deletedTexts {
            attributedSting = searchedAttibutedString(text: searchText, deletedStrings: deletedTexts)
        }
        
        if loadingMore {
            completion?(.searchMoreResult(attributedSting))
        } else {
            completion?(.searchResult(attributedSting))
        }
    }
}

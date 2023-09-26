//
//  CalendarEvent.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/8/20.

import UIKit

class CalendarEventModel {
    var id: Int64?
    var tempId: String?
    var date: Double?
    var setId: Int64?
    var name: String?
    var eventTypeId: Int64?
    var correctDate: Double {
        let _date = Date(timeIntervalSince1970: date ?? 0).removeTimeStamp
        return _date?.timeIntervalSince1970 ?? 0
    }
    
    private var _setModel: SetModel?
    var setModel: SetModel? {
        get {
            if let setId = setId, _setModel == nil {
                if let set = CoreDataManager.shared.objectWithID(id: setId, entityName: EntityName.set) as? WardrobeSet {
                    _setModel = SetModel(set)
                }
            }
            return _setModel
        }
        set {
            _setModel = newValue
        }
    }
    
    private var _eventTypeParameterModel: EventTypeParameterModel?
    var eventTypeParameterModel: EventTypeParameterModel? {
        if let eventTypeId = eventTypeId, _eventTypeParameterModel == nil {
            if let type = CoreDataManager.shared.getConstant(.occasions, eventTypeId) as? Occasions{
                _eventTypeParameterModel = EventTypeParameterModel(type.id, type.names, type.color ?? "", ItemParametersType.serverEquelTypes[.occasions])
            }
        }
        return _eventTypeParameterModel
    }
    
    init(tempId: String) {
        self.tempId = tempId
    }
    
    init(_ dict: [String: Any]) {
        id =  dict["id"] as? Int64
        tempId = dict["tempId"] as? String
        date = dict["date"] as? Double ?? 0
        date = (date ?? 1) / 1000
        setId = dict["setId"] as? Int64 ?? 0
        eventTypeId = dict["occasion"] as? Int64
        name = dict["name"] as? String
        if let set = dict["set"] as? [String: Any] {
            setModel = SetModel(set)
        }
    }
    
    init(_ event: CalendarEvent) {
        id = event.id as? Int64
        tempId = event.tempId
        date = event.date as? Double
        setId = event.setId as? Int64
        eventTypeId = event.eventTypeId as? Int64
        name = event.name
        if let set = event.set {
            setModel = SetModel(set)
        }
    }
}


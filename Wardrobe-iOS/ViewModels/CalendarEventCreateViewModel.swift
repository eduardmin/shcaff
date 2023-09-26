//
//  CalendarEventCreateViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 10/24/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import UIKit

enum CalendarEventType {
    case create
    case edit
}

class CalendarEventCreateViewModel {

    private var setModel: SetModel?
    private let coreDataManager = CoreDataManager.shared
    private var calendarEventModel: CalendarEventModel
    public var eventTypeModels = [EventTypeParameterModel]()
    public var type: CalendarEventType = .create

    init() {
        calendarEventModel = CalendarEventModel(tempId: generateRandomId())
        getCalendarEventTypes()
    }
    
    func saveCalendarEvent() {
        if type == .create {
            calendarEventModel.setModel = setModel
            CoreDataJsonParserManager.shared.createCalendarEvent(model: calendarEventModel, pending: true)
            if !haveConnection() {
                return
            }
            if calendarEventModel.setId != nil {
                CalendarEventManager.manager.createCalendarEvents(calendarEventModels: [calendarEventModel])
            } else {
                CalendarEventManager.manager.createCalendarEventsWithoutSet(calendarEventModels: [calendarEventModel])
            }
        } else {
            CoreDataJsonParserManager.shared.updateCalendarEvent(model: calendarEventModel, pending: true)
            if !haveConnection() {
                return
            }
            if calendarEventModel.id != nil {
                CalendarEventManager.manager.updateCalendarEvents(calendarEventModels: [calendarEventModel])
            }
        }
    }
}

//MARK:- Public Func property
extension CalendarEventCreateViewModel {
    public func getItems() -> [ItemModel] {
        return setModel?.itemModels ?? []
    }
    
    public func getSetModel() -> SetModel? {
        return setModel
    }
    
    public func getName() -> String? {
        return calendarEventModel.name
    }
    
    public func getEventId() -> Int? {
        if calendarEventModel.eventTypeId != nil {
            return Int(calendarEventModel.eventTypeId!)
        }
        return nil
    }
    
    public func setSetModel(_ setModel: SetModel) {
        self.setModel = setModel
        if let id = setModel.id {
            calendarEventModel.setId = id
        }
    }
    
    public func setDate(_ date: Double) {
        calendarEventModel.date = date
    }
    
    public func setName(_ text: String) {
        calendarEventModel.name = text
    }
    
    public func setEventTypeId(_ id: Int64) {
        calendarEventModel.eventTypeId = id
    }
    
    public func setEventModel(_ model: CalendarEventModel) {
        type = .edit
        calendarEventModel = model
        setModel = calendarEventModel.setModel
    }
    
    public func isEnable() -> Bool {
        if calendarEventModel.eventTypeId != nil {
            return true
        }
        return false
    }
}

//MARK:- Private Func
extension CalendarEventCreateViewModel {
    private func getCalendarEventTypes() {
        if var occasions = coreDataManager.getConstants(.occasions, nil) as? [Occasions] {
            occasions.sort {$0.id < $1.id}
            for type in occasions {
                let model = EventTypeParameterModel(type.id, type.names, type.color ?? "", .occassion)
                eventTypeModels.append(model)
            }
        }
    }
}

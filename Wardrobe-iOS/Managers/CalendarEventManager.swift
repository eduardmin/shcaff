//
//  CalendarEventManager.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 1/9/21.
//  Copyright © 2021 Eduard Minasyan. All rights reserved.
//

import UIKit

class CalendarEventManager {
    static let manager = CalendarEventManager()
    private let handleQueue: DispatchQueue
    init() {
        handleQueue = DispatchQueue(label: "handleEventQueue", qos: .userInteractive)
    }
    func createCalendarEvents(calendarEventModels: [CalendarEventModel]) {
        if calendarEventModels.isEmpty { return }
        let calendarEventWebService = CalendarEventWebService()
        calendarEventWebService.saveCalendarEvent(calendarEventModels) { [weak self] (response, error) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if error != nil {
                    return
                }
                
                if let response = response as? [[String : Any]] {
                    strongSelf.handleResponse(response)
                }
            }
        }
    }
    
    fileprivate func extractedFunc() -> CalendarEventWebService {
        return CalendarEventWebService()
    }
    
    func createCalendarEventsWithoutSet(calendarEventModels: [CalendarEventModel]) {
        if calendarEventModels.isEmpty { return }
        let calendarEventWebService = extractedFunc()
        calendarEventWebService.saveWithOutSet(calendarEventModels) { [weak self] (response, error) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if error != nil {
                    return
                }
                
                if let response = response as? [[String : Any]] {
                    strongSelf.handleResponseWithOutSet(response)
                }
            }
        }
    }
    
    func updateCalendarEvents(calendarEventModels: [CalendarEventModel]) {
        if calendarEventModels.isEmpty { return }
        let calendarEventWebService = CalendarEventWebService()
        calendarEventWebService.updateCalendarEvent(calendarEventModels) { [weak self] (success) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if success {
                    strongSelf.handleUpdateResponse(calendarEventModels: calendarEventModels)
                }
            }
        }
    }
    
    func deleteCalendarEvents(calendarEventModels: [CalendarEventModel]) {
        if calendarEventModels.isEmpty { return }
        let calendarEventWebService = CalendarEventWebService()
        calendarEventWebService.deleteEvents(calendarEventModels) { [weak self](success) in
            self?.handleQueue.async {
                guard let strongSelf = self else { return }
                if success {
                    strongSelf.deleteCalendarEventResponse(calendarEventModels)
                }
            }
        }
    }
}

//MARK:- Private Func
extension CalendarEventManager {
    private func handleResponse(_ response: [[String : Any]]) {
        for event in response {
            let model = CalendarEventModel(event)
            CoreDataJsonParserManager.shared.updateCalendarEvent(model: model, pending: false, isCreate: true)
        }
    }
    
    private func handleResponseWithOutSet(_ response: [[String : Any]]) {
        for event in response {
            let model = CalendarEventModel(event)
            CoreDataJsonParserManager.shared.updateCalendarEvent(model: model, pending: false, isCreate: true)
        }
    }
    
    private func handleUpdateResponse(calendarEventModels: [CalendarEventModel]) {
        for model in calendarEventModels {
            CoreDataJsonParserManager.shared.updateCalendarEvent(model: model, pending: false)
        }
    }
    
    private func deleteCalendarEventResponse(_ calendarEventModels: [CalendarEventModel]) {
        let coreDataManager = CoreDataManager.shared
        for model in calendarEventModels {
            if let id = model.id {
                coreDataManager.deleteObjectWithId(id: id, entityName: EntityName.calendarEvent)
            }
        }
        coreDataManager.saveContext()
    }
}

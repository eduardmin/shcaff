//
//  CalendarEventWebService.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/7/20.
//

import UIKit

class CalendarEventWebService: BaseNetworkManager {
    
    func getCalendarEvent(completion: @escaping ([[String : Any]]?) -> ()) {
        sendGetRequest(path: Paths.calendarEvent) { (response, error) in
            if error != nil {
                switch error {
                case .failError(code: _, message: _):
                    break
                case .successError(errorType: let errorType):
                    if let baseError = BaseErrorType(rawValue: errorType) {
                        // base error implitation
                        print(baseError)
                    }
                default:
                    break
                }
            } else if let result = response as? [[String : Any]] {
                completion(result)
                return
            }
            completion(nil)
        }
    }
    
    func saveCalendarEvent(_ calendarEventModels: [CalendarEventModel], _ completion: @escaping RequestCompletion) {
        var values = [[String: Any]]()
        for calendarEventModel in calendarEventModels {
            var parameters = [String : Any]()
            parameters["tempId"] = calendarEventModel.tempId
            parameters["occasion"] = calendarEventModel.eventTypeId
            parameters["date"] = localTimeIntervalToUTC(timeInterval: calendarEventModel.date ?? 0)
            parameters["setId"] = calendarEventModel.setId
            parameters["name"] = calendarEventModel.name ?? ""
            values.append(parameters)
        }
        
        sendPostRequest(path: Paths.calendarEvent, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            completion(response, error)
        }
    }
    
    func saveWithOutSet(_ calendarEventModels: [CalendarEventModel], _ completion: @escaping RequestCompletion) {
        var values = [[String: Any]]()
        for calendarEventModel in calendarEventModels {
            var parameters = [String : Any]()
            parameters["tempId"] = calendarEventModel.tempId
            parameters["occasion"] = calendarEventModel.eventTypeId
            parameters["date"] = localTimeIntervalToUTC(timeInterval: calendarEventModel.date ?? 0)
            parameters["name"] = calendarEventModel.name ?? ""
            var setParameter = [String : Any]()
            setParameter["itemIds"] = calendarEventModel.setModel?.itemIds
            setParameter["lookId"] = calendarEventModel.setModel?.lookId
            parameters["set"] = setParameter
            values.append(parameters)
        }
        
        sendPostRequest(path: Paths.calendarNoSetEvent, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            completion(response, error)
        }
    }
    
    func updateCalendarEvent(_ calendarEventModels: [CalendarEventModel], _ completion : @escaping (Bool) -> ()) {
        var values = [String: Any]()
        for calendarEventModel in calendarEventModels {
            var parameters = [String : Any]()
            parameters["id"] = calendarEventModel.id!
            parameters["tempId"] = calendarEventModel.tempId
            parameters["occasion"] = calendarEventModel.eventTypeId
            parameters["date"] = localTimeIntervalToUTC(timeInterval: calendarEventModel.date ?? 0)
            parameters["setId"] = calendarEventModel.setId
            parameters["name"] = calendarEventModel.name
            values["\(calendarEventModel.id!)"] = parameters
        }
        sendPutRequest(path: Paths.calendarEvent, parameters: values) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isEventsUpdated = response["isEventsUpdated"] as? Bool, isEventsUpdated {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
    
    func deleteEvents(_ calendarEventModels: [CalendarEventModel], _ completion : @escaping (Bool) -> ()) {
        var values = [Int64]()
        for calendarEventModel in calendarEventModels {
            if let id = calendarEventModel.id {
                values.append(id)
            }
        }

        sendDeleteRequest(path: Paths.calendarEvent, parameters: values.asParameters(), encoding: ArrayEncoding()) { (response, error) in
            if error != nil {
                completion(false)
                return
            }
            
            if let response = response as? [String: Any], let isEventsDeleted = response["isEventsDeleted"] as? Bool, isEventsDeleted {
                completion(true)
                return
            }
        
            completion(false)
        }
    }
}

//
//  CalendarEventViewModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 8/7/20.
//

import UIKit

class CalendarEventViewModel {
    private let coreDataManager = CoreDataManager.shared
    private var events = [CalendarEventModel]()
    private var dateGroupEvents = Dictionary<Double, [CalendarEventModel]>()
    private var weatherModel: WeatherModel?
    public var setModel: SetModel?
    private let handleQueue: DispatchQueue

    var completion: ((Bool) -> ())?
    init() {
        handleQueue = DispatchQueue(label: "EventHandle", qos: .userInteractive)
        configureModels(true)
    }
    
    func deleteEvent(model: CalendarEventModel) {
        let isSend = CoreDataJsonParserManager.shared.deleteCalendarEvent(model)
        configureModels(true)
        if !haveConnection() || !isSend {
            return
        }
        CalendarEventManager.manager.deleteCalendarEvents(calendarEventModels: [model])
    }
    
    func updateEvents() {
        configureModels(true)
    }
}

//MARK:- Public func
extension CalendarEventViewModel {
    
    func countOfEvents(_ date: Date) -> Int {
        let timeInterval = date.timeIntervalSince1970
        return dateGroupEvents[timeInterval]?.count ?? 0
    }
    
    func getEvent(_ index: Int, _ date: Date) -> CalendarEventModel? {
        let timeInterval = date.timeIntervalSince1970
        let _events = dateGroupEvents[timeInterval]
        return _events?[index]
    }
    
    func getWeatherModel() -> WeatherModel? {
        return weatherModel
    }
    
    func setSetModel(_ model: SetModel?) {
        setModel = model
    }
    
    func setWeatherModel(_ weatherModel: WeatherModel?) {
        self.weatherModel = weatherModel
    }
}

//MARK:- Private func
extension CalendarEventViewModel {
    private func configureModels(_ update: Bool) {
        handleQueue.sync { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.events.removeAll()
            strongSelf.dateGroupEvents.removeAll()
            if let calendarEvents = strongSelf.coreDataManager.getAllCalendars() {
                strongSelf.events.removeAll()
                for event in calendarEvents {
                    let model = CalendarEventModel(event)
                    strongSelf.events.append(model)
                }
                strongSelf.groupEvent()
            }
            
            if update {
                DispatchQueue.main.async {
                    strongSelf.completion?(true)
                }
            }
        }
    }
    
    private func groupEvent() {
        let eventGroup = Dictionary(grouping: events) { ($0.correctDate) }
        dateGroupEvents = eventGroup
    }
}

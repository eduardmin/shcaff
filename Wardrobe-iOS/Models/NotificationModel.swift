//
//  NotificationModel.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 7/25/21.
//  Copyright © 2021 Schaff. All rights reserved.
//

import UIKit

enum NotificationType: String {
    case suggestion = "LOOK_SUGGESTION"
    case eventReminder = "EVENT_REMINDER"
}

class NotificationModel {
    let id: Int64
    var seen: Bool
    var title: String
    var body: String
    let eventId: Int64
    var eventName: String
    var date: Double?
    var type: NotificationType
    var lookId: Int64?
    var url: String?
    var aspectRation: String?
    
    private var _calendarEventModelModel: CalendarEventModel?
    var calendarEventModelModel: CalendarEventModel? {
        get {
            if _calendarEventModelModel == nil {
                if let event = CoreDataManager.shared.objectWithID(id: eventId, entityName: EntityName.calendarEvent) as? CalendarEvent {
                    _calendarEventModelModel = CalendarEventModel(event)
                }
            }
            return _calendarEventModelModel
        }
    }
    
    init(dict: [String: Any]) {
        id = dict["itemId"] as? Int64 ?? 0
        seen = dict["isSeen"] as? Bool ?? false
        date = dict["createdAt"] as? Double ?? 0
        let notification = dict["notification"] as? [String: Any] ?? [:]
        title = notification["title"] as? String ?? ""
        body = notification["body"] as? String ?? ""
        eventId = notification["eventId"] as? Int64 ?? -1
        eventName = notification["eventName"] as? String ?? ""
        let notificationType = notification["type"] as? String ?? ""
        type = NotificationType(rawValue: notificationType) ?? .eventReminder
        lookId = notification["lookId"] as? Int64//29
        url = notification["url"] as? String
        aspectRation = notification["aspectRation"] as? String
    }
}

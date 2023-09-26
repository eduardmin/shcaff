//
//  DateExtension.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 12/13/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import Foundation

extension Date {
    public var removeTimeStamp : Date? {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            return nil
        }
        return date
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    static private var _notifiactionTimeFormatter: DateFormatter?
    static private var notificationTimeFormatter: DateFormatter {
        if _notifiactionTimeFormatter == nil {
            _notifiactionTimeFormatter = DateFormatter()
            _notifiactionTimeFormatter?.dateFormat = "h:mm a"
        }
        return _notifiactionTimeFormatter!
    }
    
    func simpleTimeString() -> String {
        return Date.notificationTimeFormatter.string(from: self) as String
    }
    
    var isToday: Bool {
        return self.startOfDay == Date().startOfDay
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    func isCurrentYear() -> Bool {
        let today = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: today)
        let year = calendar.component(.year, from: self)
        return currentYear == year
    }
}

extension DateFormatter {
    
    /// MMM d, yyyy
    static var medium: DateFormatter {
        let threadDictionary = Thread.current.threadDictionary
        let key = "dateFormatter"
        var formatter = threadDictionary.value(forKey: key) as? DateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.timeStyle = .none
            formatter!.dateStyle = .medium
            threadDictionary.setValue(formatter, forKey:key)
        }
        return formatter!
    }
    
    /// M/d/yy
    static var mdyy: DateFormatter {
        let threadDictionary = Thread.current.threadDictionary
        let key = "dateFormatterMdyy"
        var formatter = threadDictionary.value(forKey: key) as? DateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter?.dateFormat = "M/d/yy"
            formatter?.timeStyle = .none
            threadDictionary.setValue(formatter, forKey:key)
        }
        return formatter!
    }
    
    /// MMM d
    static var short: DateFormatter {
        let threadDictionary = Thread.current.threadDictionary
        let key = "shortDateFormatter"
        var formatter = threadDictionary.value(forKey: key) as? DateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.locale = Locale(identifier: LanguageManager.manager.currentLanguge().key)
            formatter!.dateFormat = "d MMM"
            threadDictionary.setValue(formatter, forKey:key)
        }
        return formatter!
    }
    
    static var card: DateFormatter {
        let threadDictionary = Thread.current.threadDictionary
        let key = "cardDateFormatter"
        var formatter = threadDictionary.value(forKey: key) as? DateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.dateFormat = "MM/dd/yy"
            threadDictionary.setValue(formatter, forKey:key)
        }
        return formatter!
    }
    
    
    /// MMM d, yyyy HH:mm a
    static var long: DateFormatter {
        let threadDictionary = Thread.current.threadDictionary
        let key = "dateTimeFormatter"
        var formatter = threadDictionary.value(forKey: key) as? DateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.dateFormat = "MMM d, yyyy HH:mm a"
            threadDictionary.setValue(formatter, forKey:key)
        }
        return formatter!
    }
    
    /// Saturday, Nov 11, 2017
    static var weekDay: DateFormatter {
        let threadDictionary = Thread.current.threadDictionary
        let key = "weekDayFormatter"
        var formatter = threadDictionary[key] as? DateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.dateFormat = "EEEE, MMM dd, yyyy"
            threadDictionary.setValue(formatter, forKey:key)
        }
        return formatter!
    }
    
    /// Dec 2017
    static var notCurrentYear: DateFormatter {
        let threadDictionary = Thread.current.threadDictionary
        let key = "notCurrentYearFormatter"
        var formatter = threadDictionary[key] as? DateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.dateFormat = "MMM yyyy"
            threadDictionary.setValue(formatter, forKey:key)
        }
        return formatter!
    }
    
    static let greenwichMeanTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        return dateFormatter
    }()
}

public class DateUtil {
    private class func dateTimeFormatterREST() -> DateFormatter {
        let threadDictionary = Thread.current.threadDictionary
        var formatter: DateFormatter? = threadDictionary.value(forKey: "dateTimeFormatterREST") as? DateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.isLenient = true
            formatter!.locale = Locale(identifier: "en_US")
            formatter!.dateFormat = "yyyy-MM-dd'T'HH:mm:ss:SSSZ"
            threadDictionary.setValue(formatter, forKey: "dateTimeFormatterREST")
        }
        return formatter!
    }
    
    class func dateFormatterREST() -> DateFormatter {
        let threadDictionary = Thread.current.threadDictionary
        var formatter: DateFormatter? = threadDictionary.value(forKey: "dateFormatterREST") as? DateFormatter
        if formatter == nil {
            formatter = DateFormatter()
            formatter!.isLenient = true
            formatter!.locale = Locale(identifier: "en_US")
            formatter!.dateFormat = "yyyy-MM-dd"
            threadDictionary.setValue(formatter, forKey: "dateFormatterREST")
        }
        return formatter!
    }
    
    class func stringFromDateForNotificationList(_ date: Date?) -> String {
        var time = ""
        if let dt = date {
            time = dt.simpleTimeString()
            if dt.isToday {
                return time
            } else if Calendar.current.isDateInYesterday(dt) {
                return "Yesterday".localized()
            }
        }
        return DateUtil.stringFromDateForLists(date)
    }
    
    public class func stringFromDateForLists(_ date: Date?) -> String {
        if let dt = date {
            if dt.isCurrentYear() {
                return DateFormatter.short.string(from: dt)
            } else {
                return DateFormatter.notCurrentYear.string(from: dt)
            }
        }
        return ""
    }
    
    public class func dateToRESTAPI(_ date: Date) -> Date {
        var str: String? = DateUtil.dateTimeFormatterREST().string(from: date)
        if str == nil {
            str = DateUtil.dateFormatterREST().string(from: date)
        }
        return DateUtil.dateTimeFormatterREST().date(from: str!)!
    }
}

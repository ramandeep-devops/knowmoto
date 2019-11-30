//
//  Date+Extentions.swift
//  Auttle
//
//  Created by CodeBrew on 9/18/17.
//  Copyright © 2017 CodeBrew. All rights reserved.
//

import Foundation


//MARK: - DATE Extention
extension Date {
    
    func getLast6Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -6, to: self)
    }
    

    func nearXdays(days:Int) -> [Int] { return days == 0 ? [self.day] : { var result:[Int] = []; for index in 1...abs(days) { result.append(self.addDays(daysToAdd: (index * (days>=0 ? 1 : -1))).day) }; return result }() }
    
    
    func getPastDates(days: Int) -> NSArray {
        
        var dates = NSMutableArray()
        
        let cal = NSCalendar.current
       
        var today = cal.startOfDay(for: Date())
        
        for i in 1 ... days {
            
            let day = cal.component(.day, from: today)
            let month = cal.component(.month, from: today)
            let year = cal.component(.year, from: today)
            
            var date = NSMutableDictionary()
            
            date.setValue(day, forKey: "day")
            date.setValue(month, forKey: "month")
            date.setValue(year, forKey: "year")
            
            dates.add(date)
            
            // move back in time by one day:
            let updateDate = cal.date(byAdding: .day, value: -1, to: today)
            
            today = updateDate!
        }
        
        return dates
        
    }
    
    func getLast1Year() -> Date? {
        return Calendar.current.date(byAdding: .year, value: -1, to: self)
    }
    
    func getLast2Year() -> Date? {
        return Calendar.current.date(byAdding: .year, value: -2, to: self)
    }
    
    func getLast3Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)
    }
    
    func getYesterday() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    func getLast7Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)
    }
    func getLast30Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -30, to: self)
    }
    
    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
    
    // This Month Start
    func getThisMonthStart() -> Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
    
    func getThisMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month += 1
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    //Last Month Start
    func getLastMonthStart() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    //Last Month End
    func getLastMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    
    
    
    func localToUTC(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier:"en_US")
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "H:mm:ss"
        
        return dateFormatter.string(from: dt!)
    }
    
    func UTCToLocal(date:String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: dt!)
    }
    
    func getDayOfWeek() -> String? {
        let cal = Calendar(identifier: .gregorian)
        let dayOfWeek = cal.component(.weekday, from: self)
        switch dayOfWeek {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return nil
        }
    }
    
    
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == .orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == .orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == .orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    //    func isdateEqual(toDate:Date)->Bool{
    //
    ////      return self.year == toDate.year && self.day == toDate.day && self.month == toDate.month ? true : false
    //    }
    
    func subtractDays(daysToAdd: Int) -> Date {
        
        let secondsInDays: TimeInterval = -(Double(daysToAdd) * 60 * 60 * 24)
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays) as Date
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addDays(daysToAdd: Int) -> Date {
        
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays) as Date
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> Date {
        
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours) as Date
        
        //Return Result
        return dateWithHoursAdded
    }
    
    //date to string
    func dateToString(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format //Your New Date format as per requirement change it own
        let newDate = dateFormatter.string(from: self)
        
        return newDate
    }
    
    func dateToStringWithShortStyle() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.locale = Locale(identifier: "en_US")
        let newDate = dateFormatter.string(from: self)
        return newDate
    }
    
    func toString(format:String)->String{
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeZone = NSTimeZone.local
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func addTime(time: Date) -> Date? {
        
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments)
    }
    
    var millisecondsSince1970:Double {
        return Double((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    
    public func timeAgoSince() -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: self, to: now, options: [])
        
        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        }
        
        if let year = components.year, year >= 1 {
            return "Last year"
        }
        
        if let month = components.month, month >= 2 {
            return "\(month) months ago"
        }
        
        if let month = components.month, month >= 1 {
            return "Last month"
        }
        
        if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return "Last week"
        }
        
        if let day = components.day, day >= 2 {
            return "\(day) days ago"
        }
        
        if let day = components.day, day >= 1 {
            return "Yesterday"
        }
        
        if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return "An hour ago"
        }
        
        if let minute = components.minute, minute >= 2 {
            return "\(minute) min ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "a min ago"
        }
        
        if let second = components.second, second >= 3 {
            return "\(second) sec ago"
        }
        return "Just now"
    }
    
    public func timePending(endTime : Date) -> String {
        
        let calendar = Calendar.current
        let now = endTime
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: self, to: now, options: [])
        
        if let year = components.year, year >= 2 {
            return "\(year) years"
        }
        
        if let year = components.year, year >= 1 {
            return "year"
        }
        
        if let month = components.month, month >= 2 {
            return "\(month) months"
        }
        
        if let month = components.month, month >= 1 {
            return "\(month) month"
        }
        
        if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return "\(week) week"
        }
        
        if let day = components.day, day >= 2 {
            return "\(day) days ago"
        }
        
        if let day = components.day, day >= 1 {
            return "\(day) day"
        }
        
        if let hour = components.hour, hour >= 2 {
            return "\(hour) hours"
        }
        
        if let hour = components.hour, hour >= 1 {
            return "\(hour) hours"
        }
        
        if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "\(minute) minute"
        }
        
        if let second = components.second, second >= 3 {
            return "\(second) seconds"
        }
        return "\(second) second"
    }
    
}

extension Double {
    func toDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self / 1000))
    }
}

extension Formatter {
    static let monthMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL"
        return formatter
    }()
    static let hour12: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h"
        return formatter
    }()
    static let minute0x: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
    static let amPM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }()
}

extension Date {
    
    public static let minutesInAWeek = 24 * 60 * 7
    
    /// EZSE: Initializes Date from string and format
    public init?(fromString string: String, format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let date = formatter.date(from: string) {
            self = date
        } else {
            return nil
        }
    }
    
    /// EZSE: Initializes Date from string returned from an http response, according to several RFCs / ISO
    public init?(httpDateString: String) {
        if let rfc1123 = Date(fromString: httpDateString, format: "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz") {
            self = rfc1123
            return
        }
        if let rfc850 = Date(fromString: httpDateString, format: "EEEE',' dd'-'MMM'-'yy HH':'mm':'ss z") {
            self = rfc850
            return
        }
        if let asctime = Date(fromString: httpDateString, format: "EEE MMM d HH':'mm':'ss yyyy") {
            self = asctime
            return
        }
        if let iso8601DateOnly = Date(fromString: httpDateString, format: "yyyy-MM-dd") {
            self = iso8601DateOnly
            return
        }
        if let iso8601DateHrMinOnly = Date(fromString: httpDateString, format: "yyyy-MM-dd'T'HH:mmxxxxx") {
            self = iso8601DateHrMinOnly
            return
        }
        if let iso8601DateHrMinSecOnly = Date(fromString: httpDateString, format: "yyyy-MM-dd'T'HH:mm:ssxxxxx") {
            self = iso8601DateHrMinSecOnly
            return
        }
        if let iso8601DateHrMinSecMs = Date(fromString: httpDateString, format: "yyyy-MM-dd'T'HH:mm:ss.SSSxxxxx") {
            self = iso8601DateHrMinSecMs
            return
        }
        //self.init()
        return nil
    }
    
    /// EZSE: Converts Date to String
    public func toString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    /// EZSE: Converts Date to String, with format
    public func toStringd(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// EZSE: Calculates how many days passed from now to date
    public func daysInBetweenDate(_ date: Date) -> Double {
        var diff = self.timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff/86400)
        return diff
    }
    
    /// EZSE: Calculates how many hours passed from now to date
    public func hoursInBetweenDate(_ date: Date) -> Double {
        var diff = self.timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff/3600)
        return diff
    }
    
    /// EZSE: Calculates how many minutes passed from now to date
    public func minutesInBetweenDate(_ date: Date) -> Double {
        var diff = self.timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff/60)
        return diff
    }
    
    /// EZSE: Calculates how many seconds passed from now to date
    public func secondsInBetweenDate(_ date: Date) -> Double {
        var diff = self.timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff)
        return diff
    }
    
    /// EZSE: Easy creation of time passed String. Can be Years, Months, days, hours, minutes or seconds
    public func timePassed() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: self, to: date, options: [])
        var str: String
        
        if components.year! >= 1 {
            components.year == 1 ? (str = "year") : (str = "years")
            return "\(components.year!) \(str) ago"
        } else if components.month! >= 1 {
            components.month == 1 ? (str = "month") : (str = "months")
            return "\(components.month!) \(str) ago"
        } else if components.day! >= 1 {
            components.day == 1 ? (str = "day") : (str = "days")
            return "\(components.day!) \(str) ago"
        } else if components.hour! >= 1 {
            components.hour == 1 ? (str = "hour") : (str = "hours")
            return "\(components.hour!) \(str) ago"
        } else if components.minute! >= 1 {
            components.minute == 1 ? (str = "minute") : (str = "minutes")
            return "\(components.minute!) \(str) ago"
        } else if components.second! >= 1 {
            components.second == 1 ? (str = "second") : (str = "seconds")
            return "\(components.second!) \(str) ago"
        } else {
            return "Just now"
        }
    }
    
    /// EZSE: Check if date is in future.
    public var isFuture: Bool {
        return self > Date()
    }
    
    /// EZSE: Check if date is in past.
    public var isPast: Bool {
        return self < Date()
    }
    
    // EZSE: Check date if it is today
    public var isToday: Bool {
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US")
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: self) == format.string(from: Date())
    }
    
    /// EZSE: Check date if it is yesterday
    public var isYesterday: Bool {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        format.locale = Locale(identifier: "en_US")
        let yesterDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        return format.string(from: self) == format.string(from: yesterDay!)
    }
    
    /// EZSE: Check date if it is tomorrow
    public var isTomorrow: Bool {
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US")
        format.dateFormat = "yyyy-MM-dd"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        return format.string(from: self) == format.string(from: tomorrow!)
    }
    
    /// EZSE: Check date if it is within this month.
    public var isThisMonth: Bool {
        let today = Date()
        return self.month == today.month && self.year == today.year
    }
    
    /// EZSE: Check date if it is within this week.
    public var isThisWeek: Bool {
        return self.minutesInBetweenDate(Date()) <= Double(Date.minutesInAWeek)
    }
    
    /// EZSE: Get the era from the date
    public var era: Int {
        return Calendar.current.component(Calendar.Component.era, from: self)
    }
    
    /// EZSE : Get the year from the date
    public var year: Int {
        return Calendar.current.component(Calendar.Component.year, from: self)
    }
    
    /// EZSE : Get the month from the date
    public var month: Int {
        return Calendar.current.component(Calendar.Component.month, from: self)
    }
    
    /// EZSE : Get the weekday from the date
    public var weekday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
    
    // EZSE : Get the month from the date
    public var monthAsString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    // EZSE : Get the day from the date
    public var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// EZSE: Get the hours from date
    public var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    /// EZSE: Get the minute from date
    public var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// EZSE: Get the second from the date
    public var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    /// EZSE : Gets the nano second from the date
    public var nanosecond: Int {
        return Calendar.current.component(.nanosecond, from: self)
    }
    
    #if os(iOS) || os(tvOS)
    
    /// EZSE : Gets the international standard(ISO8601) representation of date
    @available(iOS 10.0, *)
    @available(tvOS 10.0, *)
    public var iso8601: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    #endif
}


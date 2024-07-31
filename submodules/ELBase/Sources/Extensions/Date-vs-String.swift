//
//  Date+String.swift
//  ElloMessenger
//
//

import Foundation

public extension Date {
    
    var toString: String {
//        var locale: Locale {
//            if let code = Locale.autoupdatingCurrent.languageCode {
//                return Locale(identifier: code)
//            } else {
//                return Locale(identifier: "en_US_POSIX")
//            }
//        }
        
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale.init(identifier: LanguageService.appLanguageCode)
        dateFormatter.dateFormat = "MMM dd, YYYY"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: self)
    }
    
    func toString(dateFormat: DateFormat, isGMT: Bool = false, locale: DateLocale = .en) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        if isGMT { dateFormatter.timeZone = .current }
        dateFormatter.locale = Locale(identifier: locale.rawValue)
        
        return dateFormatter.string(from: self)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

/**
 *  DateFormats
 */
public enum DateFormat:String {
    case MMddyy = "MM/dd/yy"
    case yyyymmdd = "yyyy/MM/dd"
    /// MMM dd, yyyy
    case MMMddyyyy = "MMM dd, yyyy"
    case MMMMddyyyy = "MMMM dd, yyyy"
    case MMMMddyyyyHHmm = "MMMM dd, yyyy, HH:mm"
    case MMMMdd = "MMMM dd"
    case MDYHma = "MMM dd, yyyy HH:mm a"
    case Mdyhma = "MM/dd/yy hh:mm a"
    case MM_dd_yyyy = "MM-dd-yyyy"
    case MMddyyyy = "MM/dd/yyyy"
    case mmss = "mm:ss"
    case Hma = "HH:mm a"
    case hma = "hh:mm a"
    case HHmmss = "HH:mm:ss"
    case EEEMMMddyyyy = "EEE, MMM dd, yyyy"
    case EEEEMMMMddyyyy = "EEEE, MMMM dd, yyyy"
    case MMMMddyyyyAtHna = "MMMM dd, yyyy 'at' HH:mm a"
	case MMMddAtHM = "MMM dd 'at' HH:mm"
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"        
    case iso8601_2 = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
    case yyyy_mm_dd = "yyyy-MM-dd"
    case dd_mmm_yyyy = "dd MMM. yyyy"
    case ddmmyyyyhhmmss = "dd-MM-yyyy HH:mm:ss"
    case ddmmhhmm = "dd.MM HH:mm"
	case iso8601_3 = "yyyy-MM-dd'T'HH:mm:ss"
    case iso8601_4 = "yyyy-MM-dd'T'HH:mm:ssZ"
}

public enum DateLocale: String {
    case en = "en_US"
}

public extension Date {
    init?(fromString stringDate: String, format: DateFormat, locale: DateLocale = .en, isGMT: Bool = false) {
        let dateFormatter = DateFormatter()
        if isGMT { dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) }
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.locale = Locale(identifier: locale.rawValue)
        guard let date = dateFormatter.date(from: stringDate) else { return nil }
        self = date
    }
    
    func stringWithFormat(_ format:DateFormat, locale: DateLocale = .en, isGMT: Bool = false) -> String {
        return self.stringWithFormat(format.rawValue, locale: locale, isGMT: isGMT)
    }
    
    func stringWithFormat(_ formatString:String, locale: DateLocale = .en, isGMT: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        if isGMT { dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) }
        dateFormatter.dateFormat = formatString
        dateFormatter.locale = Locale(identifier: locale.rawValue)
        return dateFormatter.string(from: self)
    }
    
    func timeAgoDisplay() -> String {
        timeAgoDisplayPost13()
    }
    
    private func timeAgoDisplayPost13(locale: DateLocale = .en) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: locale.rawValue)
        return formatter.string(for: self) ?? ""
    }
    
    func dateAdding(years: Int) -> Date {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        if let year = components.year {
            components.year = year + years
        }
        return Calendar.current.date(from: components)!
    }
    
    static var birthdayMinimum: Date {
        Date().dateAdding(years: -100)
    }
    
    static var birthdayMaximum: Date {
        Date().dateAdding(years: -13)
    }
}

public extension String {
    func dateWithFormat(_ format:DateFormat, isGMT: Bool = false) -> Date? {
        return self.dateWithFormat(format.rawValue, isGMT: isGMT)
    }
    
    func dateWithFormat(_ formatString:String, isGMT: Bool = false) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        if isGMT { dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) }
        let string = self
        return dateFormatter.date(from: string)
    }
}

// Short format

public extension String {
    
    func shortIsoTime() -> String {
        let date = self.dateWithFormat(.iso8601)
        let time = date?.stringWithFormat(.hma)
        return time ?? ""
    }
}

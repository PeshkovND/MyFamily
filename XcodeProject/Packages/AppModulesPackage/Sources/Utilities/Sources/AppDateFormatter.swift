import Foundation

public class AppDateFormatter {
    
    private let dateFormatter: DateFormatter
    
    public init() {
        self.dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    public func toServerFormat(_ date: Date) -> Double? {
        let gmt0DateString = dateFormatter.string(from: date)
        guard let gmt0Date = dateFormatter.date(from: gmt0DateString) else { return nil }
        return gmt0Date.timeIntervalSince1970
    }
    
    public func toString(_ double: Double) -> String {
        let date = Date(timeIntervalSince1970: double)
        return dateFormatter.string(from: date)
    }
    
    public func toDate(_ double: Double) -> Date? {
        let date = Date(timeIntervalSince1970: double)
        let dateString = dateFormatter.string(from: date)
        return dateFormatter.date(from: dateString)
    }
    
    public func get(_ components: [Calendar.Component], calendar: Calendar = Calendar.current, date: Date) -> DateComponents {
            return calendar.dateComponents(Set(components), from: date)
        }

    public func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current, date: Date) -> Int {
        return calendar.component(component, from: date)
    }
    
    public func makeDateForUi(date: Date) -> String {
        let components = get([.day, .month, .year, .hour, .minute], date: date)
        guard
            let day = components.day,
            let month = components.month,
            let year = components.year,
            let hour = components.hour,
            let minute = components.minute
        else { return "" }
        if day == get(.day, date: Date()) {
            return "\(hour):\(minute < 10 ? "0":"")\(minute)"
        } else {
            return "\(day).\(month).\(year), \(hour):\(minute)"
        }
    }
}

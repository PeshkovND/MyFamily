import Foundation

public class AppDateFormatter {
    
    private let dateFormatter: DateFormatter
    
    public init() {
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    public func toString(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    public func toDate(_ string: String) -> Date? {
        dateFormatter.date(from: string)
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
            let minute = components.day
        else { return "" }
        if day == get(.day, date: Date()) {
            return "\(hour):\(minute)"
        } else {
            return "\(day).\(month).\(year), \(hour):\(minute)"
        }
    }
}

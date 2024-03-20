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
}

import Foundation

public struct ProfileCompletion: Equatable {
    public enum Field: String, CaseIterable {
        case firstName
        case lastName
        case displayName
    }

    public let firstName: String
    public let lastName: String
    public let displayName: String

    public init(firstName: String, lastName: String, displayName: String) {
        self.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var missingFields: [Field] {
        Field.allCases.filter { field in
            switch field {
            case .firstName: return firstName.isEmpty
            case .lastName: return lastName.isEmpty
            case .displayName: return displayName.isEmpty
            }
        }
    }

    public var isComplete: Bool {
        !firstName.isEmpty || !lastName.isEmpty || !displayName.isEmpty
    }

    public var completedFieldCount: Int {
        Field.allCases.count - missingFields.count
    }
}

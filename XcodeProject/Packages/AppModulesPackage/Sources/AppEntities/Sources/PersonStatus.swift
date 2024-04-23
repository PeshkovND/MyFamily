import Foundation

public enum PersonStatus: Equatable {
    case online
    case atHome
    case offline(lastOnline: String)
}

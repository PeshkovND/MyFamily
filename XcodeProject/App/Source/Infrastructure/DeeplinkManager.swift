import Foundation

enum DeeplinkType {
    case post(id: String)
}

let Deeplinker = DeepLinkManager()

class DeepLinkManager {
    fileprivate init() {}
    var deeplinkType: DeeplinkType?
    // check existing deepling and perform action
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
           return
        }
      
        DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType)
    }
    
    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
       deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
       return deeplinkType != nil
    }
}

class DeeplinkNavigator {
    static let shared = DeeplinkNavigator()
    private let appCoordinator = AppContainer.provideAppCoordinator()
    private init() { }
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        switch type {
        case .post(id: let id):
            appCoordinator.start()
        }
    }
}

class DeeplinkParser {
    static let shared = DeeplinkParser()
    private init() { }
    
    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        var pathComponents = components.path.components(separatedBy: "/")
        // the first component is empty
        pathComponents.removeFirst()
        switch host {
        case "post":
            if let postId = pathComponents.first {
                return DeeplinkType.post(id: postId)
            }
        default:
            break
        }
        return nil
    }
}

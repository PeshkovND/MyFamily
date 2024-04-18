//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities
import AppServices
import Utilities
import AppBaseFlow

import Alamofire
import AppDevTools
import AVFoundation

struct AppContainer {
    
    private static var audioPlayer: AVPlayer = {
        let player = AVPlayer()
        player.allowsExternalPlayback = true
        player.actionAtItemEnd = .none
        return player
    }()
    
    private static let debugTogglesHolder = DebugTogglesHolder(
        debugStorage: debugStorage
    )

    // MARK: Storing Global Components

    private static let env = Env(debugStorage: debugStorage)

    private static let defaultJsonEncoder = JSONEncoder()
    private static let defaultJsonDecoder = JSONDecoder()

    private static let memoryStorage: MemoryStorage = .init()
    private static let vkIdClient = VKIDClient(firebaseClient: firebaseClient)
    private static let firebaseClient = FirebaseClient()
    private static let swiftDataManager = SwiftDataManager()
    private static let purchaseManager = PurchaseManager()
    private static let deeplinker = DeepLinkManager()

    private static let defaultsStorage: DefaultsStorage = {
        let suiteName = "\(InfoPlist.bundleId).defaultsStorage"

        guard let storage = DefaultsStorage(
            suiteName: suiteName,
            encoder: defaultJsonEncoder,
            decoder: defaultJsonDecoder
        ) else {
            LoggerFactory.default.error(
                message: "UserDefaults can not be instantiated for suiteName: \(suiteName). Used fallback instance."
            )
            return DefaultsStorage.fallbackStorage
        }
        return storage
    }()

    private static let debugStorage: DefaultsStorage = {
        let suiteName = "\(InfoPlist.bundleId).debugStorage"
        guard let storage = DefaultsStorage(
            suiteName: suiteName,
            encoder: defaultJsonEncoder,
            decoder: defaultJsonDecoder
        ) else {
            LoggerFactory.default.error(
                message: "UserDefaults can not be instantiated for suiteName: \(suiteName). Used fallback instance."
            )
            return DefaultsStorage.fallbackStorage
        }
        return storage
    }()

    private static let networkLogQueue = DispatchQueue(
        label: "\(InfoPlist.bundleId).networkLogQueue"
    )

    private static let alamofireHttpClient: AlamofireHttpClient = {
        let credential: OAuthCredential = .init(
            refreshWindowTimeInterval: GlobalConfig.Network.refreshWindowTimeInterval,
            providingCredentials: {
                provideAuthService().credentials
            }
        )

        let authenticator = OAuthAuthenticator(authService: provideAuthService())

        let authenticationInterceptor = AuthenticationInterceptor(
            authenticator: authenticator,
            credential: credential
        )

        let httpClient: AlamofireHttpClient = .init(
            urlSessionConfiguration: URLSessionConfiguration.af.default,
            requestInterceptor: authenticationInterceptor,
            eventMonitors: [
                RequestLogEventMonitor(queue: networkLogQueue),
                ResponseLogEventMonitor(queue: networkLogQueue)
            ]
        )

        return httpClient
    }()

    // INFO: Providing httpClient lazily to avoid reference cycle during init phase
    private static let authService: AppAuthService = .init(
        providingHttpClient: { alamofireHttpClient },
        requestFactory: httpRequestFactory,
        networkMapper: networkMapper,
        defaultsStorage: defaultsStorage,
        vkIdClient: vkIdClient
    )

    private static let httpRequestFactory: HttpRequestFactory = .init { env.apiBaseUrlString }
    private static let networkMapper: NetworkMapper = .init()

    private init() {}
}

// MARK: - Providing App Common Components
extension AppContainer {

    static func provideAppCoordinator() -> Coordinator { AppCoordinator() }

    static func provideAudioPlayer() -> AVPlayer { audioPlayer }
    
    static func provideEnv() -> Env { env }

    static func provideDebugDefaultsStorage() -> DefaultsStorage { debugStorage }
    static func provideMemoryStorage() -> ObjectStorage { memoryStorage }
    static func provideDefaultsStorage() -> DefaultsStorage { defaultsStorage }

    static func provideHttpClient() -> AlamofireHttpClient { alamofireHttpClient }

    private static let fakeAuthService: FakeAuthService = .init()
    static func provideAuthService() -> AuthService { authService }
    static func provideFirebaseClinet() -> FirebaseClient { firebaseClient }
    static func provideSwiftDataManager() -> SwiftDataManager { swiftDataManager }
    static func providePurchaseManager() -> PurchaseManager { purchaseManager }
    static func provideDeeplinker() -> DeepLinkManager { deeplinker }
}

// MARK: - Providing Loggers
extension AppContainer {
    
    static func provideDebugTogglesHolder() -> DebugTogglesHolder {
        debugTogglesHolder
    }
}

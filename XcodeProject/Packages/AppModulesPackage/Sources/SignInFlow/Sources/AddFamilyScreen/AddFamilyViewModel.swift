//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow
import CoreLocation
import Contacts

final class AddFamilyViewModel: BaseViewModel<AddFamilyViewEvent,
                                               AddFamilyViewState,
                                AddFamilyOutputEvent> {
    
    private var strings = appDesignSystem.strings
    private let repository: AddFamilyRepository
    private let geocoder = CLGeocoder()
    private var name = ""
    private var homeLocation: CLLocation = .init()
    
    init (repository: AddFamilyRepository) {
        self.repository = repository
    }
    
    override func onViewEvent(_ event: AddFamilyViewEvent) {
        switch event {
        case let .addFamilyTapped(address):
            checkAddress(address: address)
        case .viewDidLoad:
            viewState = .initial
        case .backButtonTapped:
            outputEventSubject.send(.back)
        case .addressConfirmed(name: let name):
            addFamily(name: name, homeLocation: homeLocation)
        }
    }
    
    func addFamily(name: String, homeLocation: CLLocation) {
        self.viewState = .loading
        Task {
            do {
                try await repository.addFamily(
                    name: name,
                    homeLongitude: homeLocation.coordinate.longitude,
                    homeLatitude: homeLocation.coordinate.latitude
                )
                await MainActor.run {
                    self.outputEventSubject.send(.familyCreated)
                }
            } catch {
                await MainActor.run {
                    self.viewState = .error(
                        title: "Ошибка добавления семьи",
                        subtitle: "Попробуйте еще раз"
                    )
                }
            }
        }
    }
    
    func checkAddress(address: String) {
        self.viewState = .loading
        Task {
            do {
                let placemarks = try await geocoder.geocodeAddressString(address)
                guard let location = placemarks.first?.location, let postalAddress = placemarks.first?.formattedAddress else {
                    self.viewState = .error(
                        title: "Ошибка геокодирования",
                        subtitle: "Попробуйте еще раз"
                    )
                    return
                }
                self.homeLocation = location
                await MainActor.run {
                    self.viewState = .addressConfirmation(address: postalAddress)
                }
            }
            catch {
                await MainActor.run {
                    self.viewState = .error(
                        title: "Ошибка геокодирования",
                        subtitle: "Попробуйте еще раз"
                    )
                }
            }
        }
    }
}

extension CLPlacemark {
    var formattedAddress: String? {
        guard let postalAddress = postalAddress else {
            return nil
        }
        let formatter = CNPostalAddressFormatter()
        return formatter.string(from: postalAddress)
    }
}

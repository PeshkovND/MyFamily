//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Combine
import Contacts
import AppEntities

public final class ContactService {

    public typealias VoidResult = Result<Void, AppError>
    public typealias ContactsResult = Result<[PhoneContact], AppError>

    private let store = CNContactStore()

    public init() {}

    public func requestAccess() -> AnyPublisher<VoidResult, Never> {

        return Deferred {
            Future<VoidResult, Never> { [weak self] promise in
                guard let self = self else { return }

                self.store.requestAccess(for: .contacts) { granted, err in

                    if let err = err {
                        promise(.success(.failure(.undefined(causedError: err))))
                    }

                    if granted {
                        promise(.success(.success(())))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    // INFO: fetching Contacts
    // swiftlint:disable closure_body_length
    public func fetchContacts() -> AnyPublisher<ContactsResult, Never> {
        return Deferred {
            Future<ContactsResult, Never> { [weak self] promise in
                guard let self = self else { return }

                var contacts = [PhoneContact]()
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                                   CNContactPhoneNumbersKey as CNKeyDescriptor,
                                   CNContactThumbnailImageDataKey as CNKeyDescriptor]

                let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
                do {
                    try self.store.enumerateContacts(with: request) { (contact, _) in
                        contacts.append(
                            .init(personId: contact.identifier,
                                  firstName: contact.givenName,
                                  lastName : contact.familyName,
                                  phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "",
                                  thumbnailImageData: contact.thumbnailImageData
                            )
                        )
                    }
                    promise(.success(.success(contacts)))
                } catch let error {
                    promise(.success(.failure(.undefined(causedError: error))))
                }
            }
        }.eraseToAnyPublisher()
    }
}
// swiftlint:enable closure_body_length

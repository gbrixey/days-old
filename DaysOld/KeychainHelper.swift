//
//  KeychainHelper.swift
//  DaysOld
//
//  Created by Glen Brixey on 6/16/24.
//

import Foundation
import Security
import ComposableArchitecture

class KeychainHelper {

    // MARK: - Public

    static let live = KeychainHelper(environment: .live)
    static let test = KeychainHelper(environment: .test)

    func fetchBirthdate() -> Date? {
        if environment == .test {
            return testDate
        }
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: Self.account,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return Self.dateFormatter.date(from: string)
    }

    func storeBirthdate(_ birthdate: Date) throws {
        if environment == .test {
            testDate = birthdate
            return
        }
        let birthdateExists = (fetchBirthdate() != nil)
        let string = Self.dateFormatter.string(from: birthdate)
        let data = string.data(using: .utf8)!
        let status: OSStatus
        if birthdateExists {
            let searchQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                              kSecAttrAccount as String: Self.account]
            let attributesToUpdate: [String: Any] = [kSecValueData as String: data]
            status = SecItemUpdate(searchQuery as CFDictionary, attributesToUpdate as CFDictionary)
        } else {
            let addQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                           kSecAttrAccount as String: Self.account,
                                           kSecValueData as String: data]
            status = SecItemAdd(addQuery as CFDictionary, nil)
        }
        guard status == errSecSuccess else {
            throw KeychainError.failedToStoreBirthday(status: status)
        }
    }

    // MARK: - Private

    private enum Environment {
        case live
        case test
    }

    private static let account = "birthday"
    private let environment: Environment
    private var testDate = Date(timeIntervalSince1970: 727272000)

    private static let dateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()

    private init(environment: Environment) {
        self.environment = environment
    }
}

// MARK: - KeychainError

enum KeychainError: Error {
    case failedToStoreBirthday(status: OSStatus)
}

// MARK: - DependencyKey

private enum KeychainHelperKey: DependencyKey {
    static let liveValue = KeychainHelper.live
    static let testValue = KeychainHelper.test
    static let previewValue = KeychainHelper.test
}

extension DependencyValues {
    var keychainHelper: KeychainHelper {
        get { self[KeychainHelperKey.self] }
        set { self[KeychainHelperKey.self] = newValue }
    }
}

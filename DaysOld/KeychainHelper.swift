//
//  KeychainHelper.swift
//  DaysOld
//
//  Created by Glen Brixey on 6/16/24.
//

import Foundation
import Security

class KeychainHelper {

    // MARK: - Public

    static let live = KeychainHelper(environment: .live)
    static let test = KeychainHelper(environment: .test)

    func fetchBirthdate() -> Date? {
        if environment == .test {
            return testDate
        }
        var query: [String: Any] = baseQuery
        query[kSecReturnData as String] = true
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
            let searchQuery: [String: Any] = baseQuery
            let attributesToUpdate: [String: Any] = [kSecValueData as String: data]
            status = SecItemUpdate(searchQuery as CFDictionary, attributesToUpdate as CFDictionary)
        } else {
            var addQuery: [String: Any] = baseQuery
            addQuery[kSecValueData as String] = data
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

    private let environment: Environment
    private var testDate = Date(timeIntervalSince1970: 0)

    private var baseQuery: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrAccount as String: "birthday",
         kSecAttrAccessGroup as String: "group.com.glenb.DaysOld"]
    }

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

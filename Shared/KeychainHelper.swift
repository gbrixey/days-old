//
//  KeychainHelper.swift
//  DaysOld
//
//  Created by Glen Brixey on 6/16/24.
//

import Foundation
import Security

protocol KeychainHelperProtocol {
    func fetchBirthdate() -> Date?
    func storeBirthdate(_ birthdate: Date) throws
}

class KeychainHelper: KeychainHelperProtocol {

    // MARK: - Public

    static let shared = KeychainHelper()

    func fetchBirthdate() -> Date? {
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
}

// MARK: - KeychainError

enum KeychainError: Error, LocalizedError {
    case failedToStoreBirthday(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .failedToStoreBirthday(let status):
            let message = errorMessage(status: status)
            let format = String(key: "error.keychain.store")
            return String(format: format, message)
        }
    }

    func errorMessage(status: OSStatus) -> String {
        if let message = SecCopyErrorMessageString(status, nil) as String? {
            return message
        } else {
            let format = String(key: "error.osstatus.code")
            return String(format: format, status)
        }
    }
}

// MARK: - TestKeychainHelper

class TestKeychainHelper: KeychainHelperProtocol {

    var birthdate: Date?
    var error: KeychainError?

    func fetchBirthdate() -> Date? {
        birthdate
    }

    func storeBirthdate(_ birthdate: Date) throws {
        if let error = error {
            throw error
        }
        self.birthdate = birthdate
    }
}

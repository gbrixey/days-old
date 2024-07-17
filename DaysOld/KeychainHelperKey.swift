//
//  KeychainHelperKey.swift
//  DaysOld
//
//  Created by Glen Brixey on 7/14/24.
//

import Foundation
import ComposableArchitecture

private enum KeychainHelperKey: DependencyKey {
    static let liveValue: KeychainHelperProtocol = KeychainHelper.shared
    static let testValue: KeychainHelperProtocol = TestKeychainHelper()
    static let previewValue: KeychainHelperProtocol = TestKeychainHelper()
}

extension DependencyValues {
    var keychainHelper: KeychainHelperProtocol {
        get { self[KeychainHelperKey.self] }
        set { self[KeychainHelperKey.self] = newValue }
    }
}

//
//  KeychainHelperKey.swift
//  DaysOld
//
//  Created by Glen Brixey on 7/14/24.
//

import Foundation
import ComposableArchitecture

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

//
//  DaysOldApp.swift
//  DaysOld
//
//  Created by Glen Brixey on 6/16/24.
//

import SwiftUI
import TipKit
import ComposableArchitecture

@main
struct DaysOldApp: App {

    // MARK: - Public

    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                DaysOldView(
                    store: DaysOldApp.store
                )
            }
        }
    }

    init() {
        try? Tips.configure()
    }

    // MARK: - Private

    private static let store = Store(initialState: DaysOldFeature.State(birthdate: initialBirthdate)) {
        DaysOldFeature()
    }

    private static var initialBirthdate: Date? {
        KeychainHelper.shared.fetchBirthdate()
    }
}

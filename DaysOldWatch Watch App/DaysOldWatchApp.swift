//
//  DaysOldWatchApp.swift
//  DaysOldWatch Watch App
//
//  Created by Glen Brixey on 8/19/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct DaysOldWatchApp: App {

    // MARK: - Public

    var body: some Scene {
        WindowGroup {
            DaysOldWatchView(
                store: DaysOldWatchApp.store
            )
        }
    }

    // MARK: - Private

    private static let store = Store(initialState: DaysOldWatchFeature.State(birthdate: initialBirthdate)) {
        DaysOldWatchFeature()
    }

    private static var initialBirthdate: Date? {
        KeychainHelper.shared.fetchBirthdate()
    }
}

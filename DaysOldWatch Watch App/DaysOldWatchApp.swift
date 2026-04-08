//
//  DaysOldWatchApp.swift
//  DaysOldWatch Watch App
//
//  Created by Glen Brixey on 8/19/24.
//

import SwiftUI
import WatchConnectivity
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

    init() {
        WCSession.default.delegate = WatchHelper.shared
        WCSession.default.activate()
    }

    // MARK: - Private

    private static let store = Store(initialState: DaysOldWatchFeature.State(birthdate: initialBirthdate)) {
        DaysOldWatchFeature()
    }

    private static var initialBirthdate: Date? {
        KeychainHelper.shared.fetchBirthdate()
    }
}

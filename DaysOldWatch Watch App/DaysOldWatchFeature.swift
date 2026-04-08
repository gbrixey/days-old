//
//  DaysOldWatchFeature.swift
//  DaysOldWatch Watch App
//
//  Created by Glen Brixey on 8/19/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DaysOldWatchFeature {
    @ObservableState
    struct State: Equatable {
        var birthdate: Date?
        var birthdateIsLoading = false
        var daysSinceBirthdate: Int?

        init(birthdate: Date?) {
            self.birthdate = birthdate
        }
    }

    enum Action {
        case initialize
        // Fetch birthdate from iOS app counterpart
        case requestUpdatedBirthdate
        // Observe the notification to get birthdate updates initiated by the iOS app
        case observeNotification
        case receiveNotification(Notification)
        case updateBirthdate(Date?)
    }

    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar
    @Dependency(\.keychainHelper) var keychainHelper
    @Dependency(\.watchHelper) var watchHelper

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initialize:
                // Set initial `daysSinceBirthdate` value
                state.daysSinceBirthdate = calendar.daysBetween(date1: state.birthdate, date2: now)
                return .merge(.send(.observeNotification),
                              .send(.requestUpdatedBirthdate))
            case .requestUpdatedBirthdate:
                state.birthdateIsLoading = true
                return .run { send in
                    if let birthdate = await watchHelper.requestWatchUpdate() {
                        try? keychainHelper.storeBirthdate(birthdate)
                        await send(.updateBirthdate(birthdate))
                    }
                }
            case .observeNotification:
                return .publisher {
                    NotificationCenter.default.publisher(for: .receivedBirthdateUpdate)
                        .map(Action.receiveNotification)
                }
            case .receiveNotification(let notification):
                guard let birthdate = notification.object as? Date? else { return .none }
                return .send(.updateBirthdate(birthdate))
            case .updateBirthdate(let birthdate):
                state.birthdate = birthdate
                state.daysSinceBirthdate = calendar.daysBetween(date1: state.birthdate, date2: now)
                state.birthdateIsLoading = false
                return .none
            }
        }
    }
}

//
//  SettingsFeature.swift
//  DaysOld
//
//  Created by Glen Brixey on 6/18/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        var birthdate: Date
        @Shared(.appStorage("shouldShowTime")) var shouldShowTime = false
        @Shared(.appStorage("timeZoneIdentifier")) var timeZoneIdentifier = TimeZone.autoupdatingCurrent.identifier
    }

    enum Action {
        case doneButtonTapped
        case setBirthdate(Date)
        case setShouldShowTime(Bool)
        case setTimeZoneIdentifier(String)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case setBirthdate(Date)
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.calendar) var calendar
    @Dependency(\.timeZone) var timeZone
    @Dependency(\.keychainHelper) var keychainHelper

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .doneButtonTapped:
                return .run { _ in
                    await self.dismiss()
                }
            case .setBirthdate(let birthdate):
                state.birthdate = birthdate
                // TODO: Add error alert
                try? keychainHelper.storeBirthdate(birthdate)
                return .send(.delegate(.setBirthdate(birthdate)))
            case .setShouldShowTime(let shouldShowTime):
                state.shouldShowTime = shouldShowTime
                // When disabling the time picker, remove hour and minute from the birthdate
                if !shouldShowTime {
                    let newBirthdate = state.birthdate.movingToBeginningOfDay(with: calendar)
                    guard newBirthdate != state.birthdate else { return .none }
                    return .send(.setBirthdate(newBirthdate))
                }
                return .none
            case .setTimeZoneIdentifier(let timeZoneIdentifier):
                let oldTimeZoneIdentifier = state.timeZoneIdentifier
                state.timeZoneIdentifier = timeZoneIdentifier
                guard let oldTimeZone = TimeZone(identifier: oldTimeZoneIdentifier),
                      let newTimeZone = TimeZone(identifier: timeZoneIdentifier) else { return .none }
                let timeInterval = TimeInterval(newTimeZone.secondsFromGMT() - oldTimeZone.secondsFromGMT())
                guard timeInterval != 0 else { return .none }
                return .send(.setBirthdate(state.birthdate.addingTimeInterval(timeInterval)))
            case .delegate:
                return .none
            }
        }
    }
}

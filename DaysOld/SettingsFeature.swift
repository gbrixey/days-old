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
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action {
        case doneButtonTapped
        case setBirthdate(Date)
        case setShouldShowTime(Bool)
        case setTimeZoneIdentifier(String)
        case delegate(Delegate)
        case alert(PresentationAction<Alert>)

        @CasePathable
        enum Delegate: Equatable {
            case setBirthdate(Date)
        }

        @CasePathable
        enum Alert: Equatable {
            // There are no alert actions yet
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.calendar) var calendar
    @Dependency(\.keychainHelper) var keychainHelper
    @Dependency(\.widgetCenter) var widgetCenter

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .doneButtonTapped:
                return .run { _ in
                    await self.dismiss()
                }
            case .setBirthdate(let birthdate):
                do {
                    try keychainHelper.storeBirthdate(birthdate)
                    state.birthdate = birthdate
                    widgetCenter.reloadTimelines(ofKind: "DaysOldWidget")
                    return .send(.delegate(.setBirthdate(birthdate)))
                } catch {
                    state.alert = .errorAlertState(message: error.localizedDescription)
                    return .none
                }
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
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: - AlertState

extension AlertState where Action == SettingsFeature.Action.Alert {
    static func errorAlertState(message: String) -> Self {
        Self {
            TextState("error.title")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("error.ok")
            }
        } message: {
            TextState(message)
        }
    }
}

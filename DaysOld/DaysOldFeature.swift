//
//  DaysOldFeature.swift
//  DaysOld
//
//  Created by Glen Brixey on 6/18/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DaysOldFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var settings: SettingsFeature.State?
        var birthdate: Date?
        var daysSinceBirthdate: Int?

        init(birthdate: Date?) {
            self.birthdate = birthdate
            self.daysSinceBirthdate = birthdate?.daysBefore(.now)
        }
    }

    enum Action {
        case startTimer
        case timerIncremented
        case settingsButtonTapped
        case settingsAction(PresentationAction<SettingsFeature.Action>)
    }

    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar
    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startTimer:
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(5)) {
                        await send(.timerIncremented)
                    }
                }
            case .timerIncremented:
                state.daysSinceBirthdate = state.birthdate?.daysBefore(now)
                return .none
            case .settingsButtonTapped:
                state.settings = SettingsFeature.State(birthdate: state.birthdate ?? defaultDateForSettings)
                return .none
            case .settingsAction(.presented(.delegate(.setBirthdate(let date)))):
                state.birthdate = date
                state.daysSinceBirthdate = date.daysBefore(now)
                return .none
            case .settingsAction:
                return .none
            }
        }
        .ifLet(\.$settings, action: \.settingsAction) {
            SettingsFeature()
        }
    }

    // MARK: - Private

    private var defaultDateForSettings: Date {
        now.movingToBeginningOfDay(with: calendar)
    }
}

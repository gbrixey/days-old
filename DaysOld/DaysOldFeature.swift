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
        }
    }

    enum Action {
        case startTimer
        // This action is only used in unit tests, to end the timer effect.
        case stopTimer
        case timerTick
        case settingsButtonTapped
        case settingsAction(PresentationAction<SettingsFeature.Action>)
    }

    enum CancelID {
        case timer
    }

    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar
    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startTimer:
                // Set initial `daysSinceBirthdate` value
                state.daysSinceBirthdate = calendar.daysBetween(date1: state.birthdate, date2: now)
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(5)) {
                        await send(.timerTick)
                    }
                }.cancellable(id: CancelID.timer)
            case .stopTimer:
                return .cancel(id: CancelID.timer)
            case .timerTick:
                state.daysSinceBirthdate = calendar.daysBetween(date1: state.birthdate, date2: now)
                return .none
            case .settingsButtonTapped:
                state.settings = SettingsFeature.State(birthdate: state.birthdate ?? defaultDateForSettings)
                return .none
            case .settingsAction(.presented(.delegate(.setBirthdate(let date)))):
                state.birthdate = date
                state.daysSinceBirthdate = calendar.daysBetween(date1: date, date2: now)
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
        calendar.beginningOfDate(now)
    }
}

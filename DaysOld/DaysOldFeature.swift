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

    // TODO: Add timer to update daysSinceBirthdate
    enum Action {
        case settingsButtonTapped
        case settingsAction(PresentationAction<SettingsFeature.Action>)
    }

    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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

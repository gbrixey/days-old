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
        var daysSinceBirthdate: Int?

        init(birthdate: Date?) {
            self.birthdate = birthdate
        }
    }

    enum Action {
        case initialize
    }

    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initialize:
                state.daysSinceBirthdate = calendar.daysBetween(date1: state.birthdate, date2: now)
                return .none
            }
        }
    }
}

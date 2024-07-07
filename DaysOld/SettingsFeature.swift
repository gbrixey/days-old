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
    }

    // TODO: Allow user to set time zone
    enum Action {
        case doneButtonTapped
        case setBirthdate(Date)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case setBirthdate(Date)
        }
    }

    @Dependency(\.dismiss) var dismiss
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
            case .delegate:
                return .none
            }
        }
    }
}

//
//  DaysOldWatchView.swift
//  DaysOldWatch Watch App
//
//  Created by Glen Brixey on 8/19/24.
//

import SwiftUI
import ComposableArchitecture

struct DaysOldWatchView: View {
    @Bindable var store: StoreOf<DaysOldWatchFeature>

    var body: some View {
        VStack(spacing: 8) {
            if let daysSinceBirthdate = store.daysSinceBirthdate {
                Text("days.old.prefix")
                    .font(.system(size: 24))
                Text(daysSinceBirthdate, format: .number)
                    .font(.system(size: 32, weight: .semibold))
                Text(daysSinceBirthdate == 1 ? "days.old.suffix.singular" : "days.old.suffix.plural")
                    .font(.system(size: 24))
            } else {
                Text("watch.set.up")
                    .font(.system(size: 24))
                    .multilineTextAlignment(.center)
            }
        }
        .accessibilityElement(children: .combine)
        .padding()
        .task {
            await store.send(.initialize).finish()
        }
    }
}

#Preview {
    DaysOldWatchView(
        store: Store(initialState: DaysOldWatchFeature.State(birthdate: Date(timeIntervalSince1970: 0))) {
            DaysOldWatchFeature()
        }
    )
}

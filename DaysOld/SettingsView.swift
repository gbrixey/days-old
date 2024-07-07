//
//  SettingsView.swift
//  DaysOld
//
//  Created by Glen Brixey on 6/18/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        Form {
            Section {
                DatePicker(
                    "settings.birth.date",
                    selection: $store.birthdate.sending(\.setBirthdate),
                    in: .thePast,
                    displayedComponents: .date
                )
            } footer: {
                HStack(alignment: .top) {
                    Image(systemName: "info.circle.fill")
                        .accessibilityHidden(true)
                    Text("settings.disclaimer")
                        .font(.footnote)
                }
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            }
        }
        .navigationTitle("settings.title")
        .toolbar {
            Button("settings.done") {
                store.send(.doneButtonTapped)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            store: Store(initialState: SettingsFeature.State(birthdate: Date())) {
                SettingsFeature()
            }
        )
    }
}

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
                    "settings.birthdate",
                    selection: $store.birthdate.sending(\.setBirthdate),
                    in: .thePast,
                    displayedComponents: store.shouldShowTime ? [.date, .hourAndMinute] : .date
                )
                Toggle(
                    "settings.show.time",
                    isOn: $store.shouldShowTime.sending(\.setShouldShowTime)
                )
                Picker(
                    "settings.time.zone",
                    selection: $store.timeZoneIdentifier.sending(\.setTimeZoneIdentifier)
                ) {
                    ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) {
                        Text($0)
                    }
                }
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
        .alert($store.scope(state: \.alert, action: \.alert))
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

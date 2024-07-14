//
//  DaysOldView.swift
//  DaysOld
//
//  Created by Glen Brixey on 6/16/24.
//

import SwiftUI
import TipKit
import ComposableArchitecture

struct DaysOldView: View {
    @Bindable var store: StoreOf<DaysOldFeature>
    let tip: SettingsTip

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                if let daysSinceBirthdate = store.daysSinceBirthdate {
                    Text("days.old.prefix")
                        .font(.system(size: 24))
                    Text(daysSinceBirthdate, format: .number)
                        .font(.system(size: 32, weight: .semibold))
                    Text("days.old.suffix")
                        .font(.system(size: 24))
                }
            }
            .accessibilityElement(children: .combine)
            .padding()
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                Button {
                    store.send(.settingsButtonTapped)
                } label: {
                    Image(systemName: "gearshape")
                        .accessibilityLabel("settings.button.accessibility.label")
                }
                .popoverTip(tip)
            }
        }
        .sheet(
            item: $store.scope(state: \.settings, action: \.settingsAction)
        ) { settingsStore in
            NavigationStack {
                SettingsView(store: settingsStore)
            }
        }
        .task {
            await store.send(.startTimer).finish()
        }
    }

    init(store: StoreOf<DaysOldFeature>) {
        self.store = store
        self.tip = SettingsTip(birthdate: store.birthdate)
    }
}

// MARK: - SettingsTip

struct SettingsTip: Tip {
    @Parameter
    static var birthdate: Date? = nil

    var title: Text {
        Text("settings.tip.title")
    }

    var message: Text? {
        Text("settings.tip.message")
    }

    var rules: [Rule] {
        [#Rule(Self.$birthdate) { $0 == nil }]
    }

    init(birthdate: Date?) {
        Self.birthdate = birthdate
    }
}

// MARK: - Previews

#Preview {
    DaysOldView(
        store: Store(initialState: DaysOldFeature.State(birthdate: Date(timeIntervalSince1970: 0))) {
            DaysOldFeature()
        }
    )
}

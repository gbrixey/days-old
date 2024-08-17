//
//  DaysOldTests.swift
//  DaysOldTests
//
//  Created by Glen Brixey on 6/16/24.
//

import ComposableArchitecture
import XCTest
@testable import DaysOld

final class DaysOldTests: XCTestCase {

    @MainActor
    func testSetBirthdate() async {
        let birthdate = Date(timeIntervalSince1970: 0)
        let now = Date(timeIntervalSince1970: 1720000000)
        let calendar = Calendar(identifier: .gregorian)
        let store = TestStore(initialState: DaysOldFeature.State(birthdate: nil)) {
            DaysOldFeature()
        } withDependencies: {
            $0.calendar = calendar
            $0.date.now = now
        }
        await store.send(.settingsButtonTapped) {
            $0.settings = SettingsFeature.State(birthdate: calendar.beginningOfDate(now))
        }
        await store.send(.settingsAction(.presented(.delegate(.setBirthdate(birthdate))))) {
            $0.birthdate = birthdate
            $0.daysSinceBirthdate = calendar.daysBetween(date1: birthdate, date2: now)
        }
        await store.send(.settingsAction(.presented(.doneButtonTapped)))
        await store.receive(\.settingsAction.dismiss) {
            $0.settings = nil
        }
    }

    @MainActor
    func testTimer() async {
        // These `birthdate` and `now` values are such that it will take two timerTicks to increase `daysSinceBirthdate` by one.
        let birthdate = Date(timeIntervalSince1970: 0)
        let now = Date(timeIntervalSince1970: 1720051190)
        let calendar = Calendar(identifier: .gregorian)
        let clock = TestClock()
        let store = TestStore(initialState: DaysOldFeature.State(birthdate: birthdate)) {
            DaysOldFeature()
        } withDependencies: {
            $0.calendar = calendar
            $0.date.now = now
            $0.continuousClock = clock
        }
        guard let expectedDaysSinceBirthdate = calendar.daysBetween(date1: birthdate, date2: now) else {
            XCTFail()
            return
        }
        await store.send(.startTimer) {
            $0.daysSinceBirthdate = expectedDaysSinceBirthdate
        }
        store.dependencies.date.now = now.addingTimeInterval(5)
        await clock.advance(by: .seconds(5))
        await store.receive(\.timerTick)
        store.dependencies.date.now = now.addingTimeInterval(10)
        await clock.advance(by: .seconds(5))
        await store.receive(\.timerTick) {
            $0.daysSinceBirthdate = expectedDaysSinceBirthdate + 1
        }
        await store.send(.stopTimer)
    }
}

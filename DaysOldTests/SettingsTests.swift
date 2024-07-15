//
//  SettingsTests.swift
//  DaysOldTests
//
//  Created by Glen Brixey on 7/14/24.
//

import ComposableArchitecture
import XCTest
@testable import DaysOld

final class SettingsTests: XCTestCase {

    @MainActor
    func testSetBirthdate() async {
        let oldBirthdate = Date(timeIntervalSince1970: 0)
        let newBirthdate = Date(timeIntervalSince1970: 1000000000)
        let calendar = Calendar(identifier: .gregorian)
        let store = TestStore(initialState: SettingsFeature.State(birthdate: oldBirthdate)) {
            SettingsFeature()
        } withDependencies: {
            $0.calendar = calendar
        }
        // The next line is just a sanity check
        XCTAssertNotEqual(KeychainHelper.test.fetchBirthdate(), newBirthdate)
        XCTAssertEqual(TestWidgetCenter.shared.kindsReloaded, [])
        await store.send(.setBirthdate(newBirthdate)) {
            $0.birthdate = newBirthdate
        }
        await store.receive(\.delegate.setBirthdate)
        XCTAssertEqual(KeychainHelper.test.fetchBirthdate(), newBirthdate)
        XCTAssertEqual(TestWidgetCenter.shared.kindsReloaded, ["DaysOldWidget"])
    }

    @MainActor
    func testSetShouldShowTime() async {
        let calendar = Calendar(identifier: .gregorian)
        let store = TestStore(initialState: SettingsFeature.State(birthdate: Date(timeIntervalSince1970: 0))) {
            SettingsFeature()
        } withDependencies: {
            $0.calendar = calendar
        }
        await store.send(.setShouldShowTime(true)) {
            $0.shouldShowTime = true
        }
        let birthdate1 = Date(timeIntervalSince1970: 946722960)
        await store.send(.setBirthdate(birthdate1)) {
            $0.birthdate = birthdate1
        }
        await store.receive(\.delegate.setBirthdate)

        // Setting `shouldShowTime` to false should also reset the birthdate to the beginning of the day
        await store.send(.setShouldShowTime(false)) {
            $0.shouldShowTime = false
        }
        let birthdate2 = birthdate1.movingToBeginningOfDay(with: calendar)
        await store.receive(\.setBirthdate) {
            $0.birthdate = birthdate2
        }
        await store.receive(\.delegate.setBirthdate)
    }

    @MainActor
    func testSetTimeZoneIdentifier() async {
        let birthdate = Date(timeIntervalSince1970: 0)
        let calendar = Calendar(identifier: .gregorian)
        let initialState = SettingsFeature.State(birthdate: birthdate, timeZoneIdentifier: "America/Chicago")
        let store = TestStore(initialState: initialState) {
            SettingsFeature()
        } withDependencies: {
            $0.calendar = calendar
        }
        await store.send(.setTimeZoneIdentifier("America/New_York")) {
            $0.timeZoneIdentifier = "America/New_York"
        }
        await store.receive(\.setBirthdate) {
            $0.birthdate = birthdate.addingTimeInterval(3600)
        }
        await store.receive(\.delegate.setBirthdate)
    }
}

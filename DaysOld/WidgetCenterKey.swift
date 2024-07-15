//
//  WidgetCenterKey.swift
//  DaysOld
//
//  Created by Glen Brixey on 7/15/24.
//

import Foundation
import WidgetKit
import ComposableArchitecture

protocol WidgetCenterProtocol {
    func reloadTimelines(ofKind: String)
}

class TestWidgetCenter: WidgetCenterProtocol {
    static let shared = TestWidgetCenter()
    var kindsReloaded: [String] = []

    func reloadTimelines(ofKind kind: String) {
        kindsReloaded.append(kind)
    }
}

extension WidgetCenter: WidgetCenterProtocol {
    // Already conforms
}

// MARK: - DependencyKey

private enum WidgetCenterKey: DependencyKey {
    static let liveValue: WidgetCenterProtocol = WidgetCenter.shared
    static let testValue: WidgetCenterProtocol = TestWidgetCenter.shared
    static let previewValue: WidgetCenterProtocol = TestWidgetCenter.shared
}

extension DependencyValues {
    var widgetCenter: WidgetCenterProtocol {
        get { self[WidgetCenterKey.self] }
        set { self[WidgetCenterKey.self] = newValue }
    }
}

//
//  WatchHelperKey.swift
//  DaysOld
//
//  Created by Glen Brixey on 4/4/26.
//

import Foundation
import WatchConnectivity
import ComposableArchitecture

private enum WatchHelperKey: DependencyKey {
    static let liveValue: WatchHelperProtocol = WatchHelper.shared
    static let testValue: WatchHelperProtocol = TestWatchHelper()
    static let previewValue: WatchHelperProtocol = TestWatchHelper()
}

extension DependencyValues {
    var watchHelper: WatchHelperProtocol {
        get { self[WatchHelperKey.self] }
        set { self[WatchHelperKey.self] = newValue }
    }
}

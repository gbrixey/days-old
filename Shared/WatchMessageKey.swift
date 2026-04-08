//
//  WatchMessageKey.swift
//  DaysOld
//
//  Created by Glen Brixey on 4/4/26.
//

struct WatchMessageKey {
    /// The watchOS app uses this key to request the birthdate from the iOS app
    static let requestWatchUpdate = "requestWatchUpdate"
    /// The iOS app uses this key to send the birthdate to the watchOS app
    static let birthdate = "birthdate"
}

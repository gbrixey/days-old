//
//  CalendarExtensions.swift
//  DaysOld
//
//  Created by Glen Brixey on 8/16/24.
//

import Foundation

extension Calendar {

    func daysBetween(date1: Date?, date2: Date?) -> Int? {
        guard let date1 = date1, let date2 = date2 else { return nil }
        return dateComponents([.day], from: date1, to: date2).day.map { abs($0) }
    }

    /// Sets the hour, minute, and second components of the given date to zero.
    func beginningOfDate(_ date1: Date) -> Date {
        date(bySettingHour: 0, minute: 0, second: 0, of: date1)!
    }
}

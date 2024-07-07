//
//  DateExtensions.swift
//  DaysOld
//
//  Created by Glen Brixey on 7/7/24.
//

import Foundation

extension Date {

    func daysBefore(_ date: Date) -> Int {
        -Int(timeIntervalSince(date) / 86400)
    }

    func movingToBeginningOfDay(with calendar: Calendar) -> Date {
        calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
}

extension PartialRangeThrough where Bound == Date {

    static var thePast: PartialRangeThrough<Date> {
        ...(.now)
    }
}

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
}

extension PartialRangeThrough where Bound == Date {

    static var thePast: PartialRangeThrough<Date> {
        ...(.now)
    }
}

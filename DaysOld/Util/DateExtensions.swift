//
//  DateExtensions.swift
//  DaysOld
//
//  Created by Glen Brixey on 7/7/24.
//

import Foundation

extension PartialRangeThrough where Bound == Date {

    static var thePast: PartialRangeThrough<Date> {
        ...(.now)
    }
}

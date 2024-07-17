//
//  StringExtensions.swift
//  DaysOld
//
//  Created by Glen Brixey on 7/16/24.
//

import Foundation

extension String {

    init(key: String) {
        self = NSLocalizedString(key, bundle: .main, comment: "")
    }
}

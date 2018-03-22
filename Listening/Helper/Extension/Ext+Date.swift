//
//  Ext+Date.swift
//  Listening
//
//  Created by huydoquang on 3/2/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

extension DateFormatter {
    static func dateFormatter(from dateFormat: DateFormat) -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormat.rawValue
        return dateformatter
    }
}

extension Date {
    func toString(with dateFormat: DateFormat) -> String {
        let dateFormatter = DateFormatter.dateFormatter(from: dateFormat)
        return dateFormatter.string(from: self)
    }
}

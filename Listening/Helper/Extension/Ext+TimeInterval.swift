//
//  Ext+TimeInterval.swift
//  Listening
//
//  Created by huydoquang on 3/5/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

extension TimeInterval {
    var toDateString: String {
        guard self.isFinite else {return Constants.String.timeIntervalZero}
        let hours = (Int(self) / 3600)
        let minutes = Int((self) / 60) - Int(hours * 60)
        let seconds = Int((self)) - (Int((self) / 60) * 60)
        return String(format: "%0.2d:%0.2d:%0.2d", hours ,minutes, seconds)
    }
}

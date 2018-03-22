//
//  Lyric.swift
//  Listening
//
//  Created by huydoquang on 3/7/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Paragraph: Equatable {
    var startIndex: Int
    var endIndex: Int
    var startTime: TimeInterval
    var endTime: TimeInterval
    var content: String
    
    init(startIndex: Int, endIndex: Int, startTime: TimeInterval, endTime: TimeInterval, content: String) {
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.startTime = startTime
        self.endTime = endTime
        self.content = content
    }
    
    init(json: JSON) {
        self.startIndex = json["startIndex"].intValue
        self.endIndex = json["endIndex"].intValue
        self.startTime = json["startTime"].doubleValue
        self.endTime = json["endTime"].doubleValue
        self.content = json["content"].stringValue
    }
    
    var dict: [String: Any] {
        return ["startIndex": self.startIndex, "endIndex": endIndex, "startTime": startTime, "endTime": endTime, "content": content]
    }
    
    public static func ==(lhs: Paragraph, rhs: Paragraph) -> Bool {
        return lhs.startIndex == rhs.startIndex && lhs.endIndex == rhs.endIndex
    }
}



//
//  TextFileParser.swift
//  Listening
//
//  Created by huydoquang on 3/4/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

class TextFileParser {
    var url: URL
    var mimeType: String
    
    init(url: URL, mimeType: String) {
        self.url = url
        self.mimeType = mimeType
    }
    
    func parse() -> String? {
        let mimeTypesAbleParse: [String] = [LyricFile.pdf, LyricFile.plain, LyricFile.rich].flatMap {$0.rawValue}
        guard mimeTypesAbleParse.contains(mimeType) else {return nil}
        do {
            return try String(contentsOf: self.url, encoding: .utf8)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

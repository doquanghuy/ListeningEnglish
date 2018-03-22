//
//  JsonParser.swift
//  Listening
//
//  Created by huydoquang on 3/10/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation
import SwiftyJSON

class JSONParser {
    var url: URL

    init(url: URL) {
        self.url = url
    }
    
    func parse() -> [Paragraph] {
        do {
            let jsonData = try Data(contentsOf: self.url)
            guard let jsonArray = JSON(jsonData).array else {return []}
            return jsonArray.flatMap {Paragraph(json: $0)}
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
}

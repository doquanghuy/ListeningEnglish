//
//  Ext+String.swift
//  Listening
//
//  Created by huydoquang on 3/3/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

extension Character {
    
}

extension String {
    func fileNameExceptExtension() -> String {
        var components = self.components(separatedBy: ".")
        components.removeLast()
        return components.joined(separator: ".")
    }
    
    var isFinte: Bool {
        let scalarsAlphanumeric = self.unicodeScalars
            .flatMap {$0.value}
            .filter {
                let isAlphabet = ($0 >= 65 && $0 <= 90) || ($0 >= 97 && $0 <= 122)
                let isNumeric = ($0 >= 48 && $0 <= 57)
                return isAlphabet || isNumeric
            }
        
        return !self.isEmpty && !scalarsAlphanumeric.isEmpty
    }
}

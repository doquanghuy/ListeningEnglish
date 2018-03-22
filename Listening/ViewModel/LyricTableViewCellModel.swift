//
//  LyricTableViewCellModel.swift
//  Listening
//
//  Created by huydoquang on 3/6/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

protocol LyricTableViewCellModelInterface {
    var content: String {get}
    var backgroundColor: UIColor {get}
    var isHiddenBottomLine: Bool {get}
}

class LyricTableViewCellModel: LyricTableViewCellModelInterface {
    var content: String = ""
    var backgroundColor: UIColor = .lightGray
    var isHiddenBottomLine: Bool = false
    
    init(content: String, backgroundColor: UIColor, isHiddenBottomLine: Bool) {
        self.content = content
        self.backgroundColor = backgroundColor
        self.isHiddenBottomLine = isHiddenBottomLine
    }
}

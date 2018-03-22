//
//  LListItemTableViewCellModel.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

protocol ListFolderTableViewCellModelInterface {
    var name: String? {get}
    var createdAt: String? {get}
    var isSelected: Bool {get}
}

class ListFolderTableViewCellModel: ListFolderTableViewCellModelInterface {
    var name: String?
    var createdAt: String?
    var isSelected: Bool
    
    init(folder: Folder, isSelected: Bool) {
        self.createdAt = folder.createdTime?.toString(with: .dayMonthYear) ?? ""
        self.name = folder.name
        self.isSelected = isSelected
    }
}

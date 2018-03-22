//
//  ListItemDownloadedTableViewCellModel.swift
//  Listening
//
//  Created by huydoquang on 3/4/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

protocol ListItemDownloadedTableViewCellModelInterface {
    var name: String? {get}
    var didGetJSONFile: Bool {get}
}

class ListItemDownloadedTableViewCellModel: ListItemDownloadedTableViewCellModelInterface {
    var name: String?
    var didGetJSONFile: Bool = false
    
    init(item: Item) {
        self.name = item.name
        guard let name = item.name,
            let folderId = item.folder?.folderId,
            let folderURL = CustomFileManager.shared.subFolder(with: name, folderId: folderId) else {
                return
        }
        let jsonURL = folderURL.appendingPathComponent("\(name).json")
        self.didGetJSONFile = FileManager.default.fileExists(atPath: jsonURL.path)
    }
}

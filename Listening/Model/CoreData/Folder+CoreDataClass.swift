//
//  Folder+CoreDataClass.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//
//

import Foundation
import CoreData
import GoogleAPIClientForREST

public class Folder: NSManagedObject {
    static func create(from file: GTLRDrive_File, on context: CoreDataContext) -> Folder {
        let folder = Folder(context: context.context)
        folder.update(from: file)
        return folder
    }
    
    func update(from file: GTLRDrive_File) {
        self.createdTime = file.createdTime?.date
        self.folderId = file.identifier
        self.name = file.name
    }
}

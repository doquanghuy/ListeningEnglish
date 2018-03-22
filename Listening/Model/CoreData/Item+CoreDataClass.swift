//
//  Item+CoreDataClass.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//
//

import Foundation
import CoreData
import GoogleAPIClientForREST

public class Item: NSManagedObject {
    var mediaItemSate: ItemState {
        return ItemState(rawValue: self.mediaState) ?? .none
    }
    
    var lyricItemState: ItemState {
        return ItemState(rawValue: self.lyricState) ?? .none
    }

    static func createOrUpdate(from folder: Folder, and file: GTLRDrive_File) -> Item? {
        guard let name = file.name?.fileNameExceptExtension() else {return nil}
        let item = self.item(name: name, and: User.currentUser!) ?? Item(context: CoreDataStack.shared.managedContext)
        item.update(from: file, and: folder)
        return item
    }
    
    static func item(name: String, and user: User) -> Item? {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@ && %K == %@", #keyPath(Item.name), name, #keyPath(Item.folder.user), user)
        fetchRequest.predicate = predicate
        
        do {
            return try CoreDataStack.shared.managedContext.fetch(fetchRequest).first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func itemsDownloaded() -> [Item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "(%K == %ld || %K == %ld) && %K == %@", #keyPath(Item.mediaState), ItemState.done.rawValue, #keyPath(Item.lyricState), ItemState.done.rawValue, #keyPath(Item.folder.user), User.currentUser!)
        fetchRequest.predicate = predicate
        
        do {
            return try CoreDataStack.shared.managedContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    private func update(from file: GTLRDrive_File, and folder: Folder) {
        self.name = file.name?.fileNameExceptExtension()
        self.createdAt = file.createdTime?.date
        self.folder = folder
        let fileType = FileType.fileType(from: file)
        if fileType == .media {
            self.mediaId = file.identifier
            self.mediaFileSize = file.size?.doubleValue ?? 0.0
            self.mediaName = file.name
            self.mediaMimeType = file.mimeType
        } else {
            self.lyricId = file.identifier
            self.lyricFileSize = file.size?.doubleValue ?? 0.0
            self.lyricName = file.name
            self.lyricMimeType = file.mimeType
        }
    }
}

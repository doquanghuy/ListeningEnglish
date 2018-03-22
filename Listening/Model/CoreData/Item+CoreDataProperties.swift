//
//  Item+CoreDataProperties.swift
//  Listening
//
//  Created by huydoquang on 3/3/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var lyricMimeType: String?
    @NSManaged public var mediaMimeType: String?
    @NSManaged public var name: String?
    @NSManaged public var lyricId: String?
    @NSManaged public var mediaId: String?
    @NSManaged public var mediaState: Int16
    @NSManaged public var lyricState: Int16
    @NSManaged public var mediaFileSize: Double
    @NSManaged public var lyricFileSize: Double
    @NSManaged public var folder: Folder?
    @NSManaged public var mediaName: String?
    @NSManaged public var lyricName: String?
    @NSManaged public var jsonName: String?

}

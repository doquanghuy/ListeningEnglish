//
//  Folder+CoreDataProperties.swift
//  Listening
//
//  Created by huydoquang on 3/2/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//
//

import Foundation
import CoreData


extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var createdTime: Date?
    @NSManaged public var folderId: String?
    @NSManaged public var name: String?
    @NSManaged public var user: User?
    @NSManaged public var items: Set<Item>?

}

// MARK: Generated accessors for items
extension Folder {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: Set<Item>)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: Set<Item>)

}

//
//  Ext+NSManagedObject.swift
//  TaLa
//
//  Created by huydoquang on 12/21/17.
//  Copyright © 2017 huydoquang. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    var temp: NSManagedObject {
        let childContext = CoreDataStack.shared.childContext
        return childContext.object(with: self.objectID)
    }
}

//
//  User+CoreDataClass.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//
//

import Foundation
import CoreData
import GoogleSignIn

public class User: NSManagedObject {
    @discardableResult
    static func createOrUpdateUser(googleUser: GIDGoogleUser) -> User? {
        guard let user = self.user(googleId: googleUser.userID) else {
            return User(context: CoreDataStack.shared.managedContext)
        }
        user.update(fromUser: googleUser)
        return user
    }
    
    static func user(googleId: String) -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(User.googleId), googleId)
        fetchRequest.predicate = predicate
        
        do {
            return try fetchRequest.execute().first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func update(fromUser: GIDGoogleUser) {
        self.name = fromUser.profile.name
        self.email = fromUser.profile.email
    }
}

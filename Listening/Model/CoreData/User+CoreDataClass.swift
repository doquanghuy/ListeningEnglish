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
import GTMOAuth2

public class User: NSManagedObject {
    static var currentAuthentication: GTMFetcherAuthorizationProtocol?
    
    @discardableResult
    static func createOrUpdateUser(googleUser: GIDGoogleUser) -> User? {
        let user = self.user(googleId: googleUser.userID) ?? User(context: CoreDataStack.shared.managedContext)
        user.update(fromUser: googleUser)
        return user
    }
    
    static func user(googleId: String) -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(User.googleId), googleId)
        fetchRequest.predicate = predicate
        
        do {
            return try CoreDataStack.shared.managedContext.fetch(fetchRequest).first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func update(fromUser: GIDGoogleUser) {
        self.googleId = fromUser.userID
        self.name = fromUser.profile.name
        self.email = fromUser.profile.email
        User.currentAuthentication = fromUser.authentication.fetcherAuthorizer()
        CoreDataStack.shared.saveContext()
    }
    
    static var currentUser: User?  {
        guard let googleId = Persistent.currentGoogleUserId, let user = self.user(googleId: googleId) else {return nil}
        return user
    }
}

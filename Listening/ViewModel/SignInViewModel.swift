//
//  SignInViewModel.swift
//  Listening
//
//  Created by huydoquang on 2/28/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation
import GoogleSignIn
import SwiftEventBus

protocol SignInViewModelInterface {
    var didSignInGoogleDrive: Dynamic<Bool>? {get}
}

class SignInViewModel: SignInViewModelInterface {
    var didSignInGoogleDrive: Dynamic<Bool>? = Dynamic(false)
    
    init() {
        self.addObserver()
    }
    
    private func addObserver() {
        SwiftEventBus.onMainThread(self, name: Constants.NotificationName.didSignIn) {[weak self] (notification) in
            self?.didSignInGoogleDrive?.value = true
        }
    }
}

class GoogleSignIn: NSObject {
    static let shared = GoogleSignIn()
    
    func start() {
        GIDSignIn.sharedInstance().clientID = "596723062186-bkd21gpv1lhh6ooj8osofhnfcjksq6qr.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/drive"]
    }
    
    func shouldOpenURL(url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
}

extension GoogleSignIn: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            return
        }
        Persistent.currentGoogleUserId = user.userID
        User.createOrUpdateUser(googleUser: user)
        SwiftEventBus.post(Constants.NotificationName.didSignIn)
    }
}

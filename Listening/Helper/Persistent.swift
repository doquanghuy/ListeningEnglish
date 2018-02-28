//
//  Persistent.swift
//  Listening
//
//  Created by huydoquang on 2/28/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

struct Persistent {
    static var currentGoogleUserId: String? {
        get {
            return UserDefaults.standard.string(forKey: Constants.PersistentKey.currentGoogleUserId)
        } set {
            UserDefaults.standard.set(newValue, forKey: Constants.PersistentKey.currentGoogleUserId)
        }
    }
}

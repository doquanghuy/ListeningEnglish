//
//  Constants.swift
//  Listening
//
//  Created by huydoquang on 2/28/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

struct Constants {
    struct NotificationName {
        static let didSignIn = "kDidSignIn"
    }
    
    struct Segue {
        static let fromSignInVCToChooseFolderVC = "fromSignInVCToChooseFolderVC"
    }
    
    struct PersistentKey {
        static let currentGoogleUserId = "currentGoogleUserId"
    }
}

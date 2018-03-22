//
//  Constants.swift
//  Listening
//
//  Created by huydoquang on 2/28/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

struct Storyboard {
    var name: String
    var viewControllers: [String: String]
}

struct Constants {
    struct Storyboards {
        static let main = Storyboard(name: "Main", viewControllers: ["SignInViewController": "SignInViewController", "SelectFolderViewController": "SelectFolderViewController", "ListFileViewController": "ListFileViewController"])
    }

    struct NotificationName {
        static let didSignIn = "kDidSignIn"
    }
    
    struct Segue {
        static let fromSignInVCToChooseFolderVC = "fromSignInVCToSelectFolderVC"
        static let fromSelectFolderVCToListFileVC = "fromSelectFolderVCToListFileVC"
        static let fromListFileVCToLyricSetting = "fromListFileVCToLyricSetting"
        static let fromLyricSettingVCToPlayVC = "fromLyricSettingVCToPlayVC"
        static let fromListFileVCToPlayVC = "fromListFileVCToPlayVC"
    }
    
    struct PersistentKey {
        static let currentGoogleUserId = "currentGoogleUserId"
    }
    
    struct TableViewCellIdentifier {
        static let listFolderTableViewCell = "ListFolderTableViewCell"
        static let listItemTableViewCell = "ListItemTableViewCell"
        static let listItemDownloadedTableViewCell = "ListItemDownloadedTableViewCell"
        static let loadingFooterView = "LoadingFooterView"
        static let lyricTableViewCell = "LyricTableViewCell"
    }
    
    struct Image {
        static let selected = "selected"
        static let thumb = "ic_thumb"
        static let pause = "pause"
        static let play = "play"
        static let loopForever = "ic_repeat"
        static let loopOne = "ic_repeat_one"
        static let unLoop = "ic_no_repeat"

    }
    
    struct String {
        static let alertSignOutTitle = "Sign out"
        static let alertSignOutMessage = "Do you want to sign out?"
        static let yes = "Yes"
        static let no = "No"
        static let timeIntervalZero = "00:00:00"
    }
    
    struct Folder {
        static let defaultFolderName = "Listening"
    }
}

//
//  ListFileCellModel.swift
//  Listening
//
//  Created by huydoquang on 3/2/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

protocol ListFileCellModelInterface {
    var name: String? {get}
    var isNotEnoughMedia: Bool {get}
    var isNotEnoughLyric: Bool {get}
    var state: String {get}
    var isNotDownloaded: Bool {get}
    var isDownloaded: Bool {get}
}

class ListFileCellModel: ListFileCellModelInterface {
    var name: String?
    var isNotEnoughLyric: Bool = false
    var isNotEnoughMedia: Bool = false
    var isNotDownloaded: Bool = true
    var isDownloaded: Bool = false
    var state: String = ""
    
    init(item: Item) {
        self.name = item.name
        self.isNotEnoughLyric = item.lyricId == nil
        self.isNotEnoughMedia = item.mediaId == nil
        self.isDownloaded = (item.mediaItemSate == .done && item.lyricItemState == .none) || (item.mediaItemSate == .none && item.lyricItemState == .done) || (item.mediaItemSate == .done && item.lyricItemState == .done)
        self.isNotDownloaded = item.lyricItemState == .none && item.mediaItemSate == .none
        if item.mediaItemSate != .none || item.lyricItemState != .none {
            let mediaState = item.mediaItemSate == .done ? 1 : 0
            let lyricState = item.lyricItemState == .done ? 1 : 0
            let states = mediaState + lyricState
            let allStates = (item.mediaId != nil ? 1 : 0) + (item.lyricId != nil ? 1 : 0)
            self.state = states < allStates ? "\(states) / \(allStates)" : ""
        } else {
            self.state = ""
        }
    }
}

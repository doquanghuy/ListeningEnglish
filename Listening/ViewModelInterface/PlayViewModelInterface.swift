//
//  PlayViewModelInterface.swift
//  Listening
//
//  Created by huydoquang on 3/11/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

protocol PlayViewModelInterface: PlayControlInterface {
    var didParseLyric: Dynamic<Bool> {get}
    var didSelect: Dynamic<IndexPath> {get}
    var didChangeMode: Dynamic<LyricVisible> {get}
    var didGetTitle: Dynamic<String?> {get}
    var didChangeCurrentIndex: Dynamic<(indexPath: IndexPath, content: String?)> {get}
    var didSetParagraphLoop: Dynamic<(content: String?, hide: Bool)> {get}

    func setup()
    func changeMode()
    func setParagraphLoop()
    func select(at indexPath: IndexPath)
    func numberOfRow(in section: Int) -> Int
    func lyricTableViewCellModel(at indexPath: IndexPath) -> LyricTableViewCellModelInterface
}

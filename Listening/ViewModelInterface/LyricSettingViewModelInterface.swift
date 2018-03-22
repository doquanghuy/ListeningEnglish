//
//  LyricSettingViewModelInterface.swift
//  Listening
//
//  Created by huydoquang on 3/11/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

protocol LyricSettingViewModelInterface: PlayControlInterface {
    var didParseLyric: Dynamic<Bool> {get}
    var didSelect: Dynamic<IndexPath> {get}
    var didSave: Dynamic<Bool> {get}
    var playViewModel: PlayViewModelInterface? {get}
    
    func setup()
    func select(at indexPath: IndexPath)
    func save()
    
    func numberOfRow(in section: Int) -> Int
    func lyricTableViewCellModel(at indexPath: IndexPath) -> LyricTableViewCellModelInterface
}

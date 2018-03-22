//
//  ListFileViewModelInterface.swift
//  Listening
//
//  Created by huydoquang on 3/11/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

protocol ListFileViewModelInterface {
    var didLoadFoldersSelected: Dynamic<Bool> {get}
    var didLoadFilesOfFoldersSelected: Dynamic<Int> {get}
    var didDownloadFilesAtIndexPath: Dynamic<IndexPath> {get}
    var didCancelDownloadFiles: Dynamic<IndexPath> {get}
    var didLoadItemsDownloaded: Dynamic<Bool> {get}
    var didRemoveItemDownloaded: Dynamic<IndexPath> {get}
    var didLoadMoreAtSection: Dynamic<Int> {get}
    var didSignOut: Dynamic<Bool> {get}
    
    func loadData()
    func selectItem(at indexPath: IndexPath)
    func loadItemsDownloaded()
    func removeItemDownloaded(at indexPath: IndexPath)
    func loadMore(at section: Int)
    func loadingFooterViewModel(at section: Int) -> LoadingFooterViewModelInterface
    func signout()
    func numberOfSection(at tag: Int) -> Int
    func numberOfRowIn(section: Int, at tag: Int) -> Int
    func listFileCellModel(at indexPath: IndexPath, at tag: Int) -> Any?
    func title(for section: Int, at tag: Int) -> String?
    func lyricSettingViewModel(at indexPath: IndexPath) -> LyricSettingViewModelInterface?
    func playViewModel(at indexPath: IndexPath) -> PlayViewModelInterface?
    func jsonFileExisted(at indexPath: IndexPath, at tag: Int) -> Bool
}

//
//  SelectFolderViewModelInterface.swift
//  Listening
//
//  Created by huydoquang on 3/11/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

protocol SelectFolderViewModelInterface {
    var didLoadingResults: Dynamic<(error: Error?, folders: [Folder]?)> {get}
    var didResetResults: Dynamic<Bool> {get}
    var didLoadSelectedFolders: Dynamic<[Folder]> {get}
    var didResetFolder: Dynamic<IndexPath> {get}
    var didSelectFolder: Dynamic<IndexPath> {get}
    var didDeselectFolder: Dynamic<IndexPath> {get}
    var didSave: Dynamic<Bool> {get}
    var didResetAll: Dynamic<Bool> {get}
    var didSignOut: Dynamic<Bool> {get}
    
    func loadSelectedFolders()
    func beginLoadingResults(searchText: String, isLoadMore: Bool)
    func resetResults()
    func selectFolder(at indexPath: IndexPath)
    func deSelectFolder(at indexPath: IndexPath)
    func resetSelectedAll()
    func save()
    func signOut()
    func numberOfRow(section: Int, at tag: Int) -> Int
    func listItemCellModel(at indexPath: IndexPath, at tag: Int) -> ListFolderTableViewCellModelInterface?
}

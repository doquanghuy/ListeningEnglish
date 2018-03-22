//
//  ChooseFolderViewModel.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

class SelectFolderViewModel: SelectFolderViewModelInterface {
    var didLoadingResults: Dynamic<(error: Error?, folders: [Folder]?)>
    var didResetFolder: Dynamic<IndexPath>
    var didLoadSelectedFolders: Dynamic<[Folder]>
    var didResetResults: Dynamic<Bool>
    var didSelectFolder: Dynamic<IndexPath>
    var didDeselectFolder: Dynamic<IndexPath>
    var didSave: Dynamic<Bool>
    var didResetAll: Dynamic<Bool>
    var didSignOut: Dynamic<Bool>
    
    private var pageToken: String?
    
    init() {
        self.didLoadingResults = Dynamic((nil, nil))
        self.didResetFolder = Dynamic(IndexPath())
        self.didResetResults = Dynamic(false)
        self.didSelectFolder = Dynamic(IndexPath())
        self.didDeselectFolder = Dynamic(IndexPath())
        self.didSave = Dynamic(false)
        self.didResetAll = Dynamic(false)
        self.didSignOut = Dynamic(false)
        self.didLoadSelectedFolders = Dynamic([])
    }
    
    func loadSelectedFolders() {
        self.didLoadSelectedFolders.value = User.currentUser?.folders?
            .sorted {$0.createdTime! < $1.createdTime!}
            .flatMap {$0.temp as? Folder} ?? []
    }
    
    func beginLoadingResults(searchText: String, isLoadMore: Bool) {
        guard !isLoadMore || pageToken != nil else {return}
        BaseServices.searchFolder(by: searchText, pageToken: isLoadMore ? pageToken : nil) {[weak self] (folders, nextPageToken, error) in
            guard let this = self else {return}
            let oldFolders = (isLoadMore ? this.didLoadingResults.value.folders : []) ?? []
            let newFolders = folders?.flatMap {Folder.create(from: $0, on: .child)} ?? []
            let folders = searchText.isEmpty ? [] : oldFolders + newFolders
            self?.didLoadingResults.value = (error, folders)
            self?.pageToken = nextPageToken
        }
    }
    
    func resetResults() {
        self.didLoadingResults.value = (nil, [])
        self.pageToken = nil
    }
    
    func selectFolder(at indexPath: IndexPath) {
        guard let folder = self.didLoadingResults.value.folders?[indexPath.row] else {return}
        let isSelected = self.didLoadSelectedFolders.value.filter {$0.folderId == folder.folderId}.isEmpty
        if isSelected {
            didLoadSelectedFolders.value.append(folder)
            didSelectFolder.value = indexPath
        } else {
            didLoadSelectedFolders.value = didLoadSelectedFolders.value.filter {$0.folderId != folder.folderId}
            didDeselectFolder.value = indexPath
        }
    }
    
    func deSelectFolder(at indexPath: IndexPath) {
        guard let folderURLRemoved = self.didLoadSelectedFolders.value[indexPath.row].folderId, CustomFileManager.shared.removeFolder(with: folderURLRemoved) else {return}
        self.didLoadSelectedFolders.value.remove(at: indexPath.row)
    }
    
    func numberOfRow(section: Int, at tag: Int) -> Int {
        if tag == SelectFolderTableViewType.all.rawValue {
            return self.didLoadingResults.value.folders?.count ?? 0
        } else {
            return self.didLoadSelectedFolders.value.count
        }
    }
    
    func listItemCellModel(at indexPath: IndexPath, at tag: Int) -> ListFolderTableViewCellModelInterface? {
        if tag == SelectFolderTableViewType.all.rawValue {
            guard let folder = self.didLoadingResults.value.folders?[indexPath.row] else {return nil}
            let isSelected = !self.didLoadSelectedFolders.value.filter {$0.folderId == folder.folderId}.isEmpty
            return ListFolderTableViewCellModel(folder: folder, isSelected: isSelected)
        } else {
            let folder = self.didLoadSelectedFolders.value[indexPath.row]
            return ListFolderTableViewCellModel(folder: folder, isSelected: true)
        }
    }
    
    func resetSelectedAll() {
        self.didLoadSelectedFolders.value.removeAll()
        self.didResetAll.value = true
    }
    
    func save() {
        (User.currentUser?.temp as? User)?.folders = Set(self.didLoadSelectedFolders.value)
        CoreDataStack.shared.save()

        for folder in self.didLoadSelectedFolders.value {
            guard let folderId = folder.folderId else {continue}
            CustomFileManager.shared.createFolder(with: folderId)
        }
        
        self.didSave.value = !self.didLoadSelectedFolders.value.isEmpty
    }
    
    func signOut() {
        CoreDataStack.shared.childContext.reset()
        self.didSignOut.value = true
    }
}

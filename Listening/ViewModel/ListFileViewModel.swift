//
//  ListFileViewModel.swift
//  Listening
//
//  Created by huydoquang on 3/2/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

class ListFileViewModel: ListFileViewModelInterface {
    var didLoadMoreAtSection: Dynamic<Int>
    var didLoadFoldersSelected: Dynamic<Bool>
    var didLoadFilesOfFoldersSelected: Dynamic<Int>
    var didDownloadFilesAtIndexPath: Dynamic<IndexPath>
    var didCancelDownloadFiles: Dynamic<IndexPath>
    var didLoadItemsDownloaded: Dynamic<Bool>
    var didRemoveItemDownloaded: Dynamic<IndexPath>
    var didSignOut: Dynamic<Bool>
    
    private var nextPageTokens: [String?]?
    private var loadingFooters: [Bool]?
    private var foldersSelected: [Folder]!
    private var itemsDownloaded: [Item]?
    private var tickets: [[CustomTicket?]]?
    private var items: [[Item]]?
    
    init() {
        self.didLoadMoreAtSection = Dynamic(0)
        self.didLoadFilesOfFoldersSelected = Dynamic(0)
        self.didDownloadFilesAtIndexPath = Dynamic(IndexPath())
        self.didCancelDownloadFiles = Dynamic(IndexPath())
        self.didLoadItemsDownloaded = Dynamic(false)
        self.didRemoveItemDownloaded = Dynamic(IndexPath())
        self.didSignOut = Dynamic(false)
        self.didLoadFoldersSelected = Dynamic(false)
    }
    
    func loadData() {
        self.foldersSelected = User.currentUser?.folders?.sorted {$0.createdTime! < $1.createdTime!} ?? []
        self.didLoadFoldersSelected.value = true

        let numberSections = self.foldersSelected.count
        self.nextPageTokens = Array(repeating: nil, count: numberSections)
        self.loadingFooters = Array(repeating: false, count: numberSections)
        self.items = Array(repeating: [], count: numberSections)
        self.tickets = Array(repeating: [], count: numberSections)
        self.loadItemsOfFoldersSelected()
    }
    
    func selectItem(at indexPath: IndexPath) {
        self.tickets?[indexPath.section][indexPath.row] != nil ? self.cancelDownloadItem(at: indexPath) : self.downloadItem(at: indexPath)
    }
    
    func loadItemsDownloaded() {
        self.itemsDownloaded = Item.itemsDownloaded()
        self.didLoadItemsDownloaded.value = true
    }
    
    func removeItemDownloaded(at indexPath: IndexPath) {
        guard let itemRemoved = self.itemsDownloaded?.remove(at: indexPath.row) else {return}
        self.resetItem(item: itemRemoved)
        self.didRemoveItemDownloaded.value = indexPath
    }
    
    func loadingFooterViewModel(at section: Int) -> LoadingFooterViewModelInterface {
        return LoadingFooterViewModel(isLoading: loadingFooters?[section] ?? false)
    }
    
    func loadMore(at section: Int) {
        guard let nextPageToken = nextPageTokens?[section] else {
            self.didLoadMoreAtSection.value = section
            return
        }
        loadingFooters?[section] = true
        loadFilesInFolder(folder: foldersSelected[section], nextPageToken: nextPageToken) {[weak self] (error, nextPageToken,  items) in
            self?.loadingFooters?[section] = false
            self?.items?[section] += items
            self?.nextPageTokens?[section] = nextPageToken
            self?.foldersSelected?[section].items = Set(self?.items?[section] ?? [])
            CoreDataStack.shared.save()
            self?.didLoadFilesOfFoldersSelected.value = section
        }
    }
    
    func signout() {
        CoreDataStack.shared.childContext.reset()
        self.didSignOut.value = true
    }
    
    func lyricSettingViewModel(at indexPath: IndexPath) -> LyricSettingViewModelInterface? {
        guard let item = self.itemsDownloaded?[indexPath.row] else {return nil}
        return LyricSettingViewModel(item: item)
    }
    
    func playViewModel(at indexPath: IndexPath) -> PlayViewModelInterface? {
        guard let item = self.itemsDownloaded?[indexPath.row] else {return nil}
        return PlayViewModel(item: item)
    }
    
    func jsonFileExisted(at indexPath: IndexPath, at tag: Int) -> Bool {
        guard let cellViewModel = self.listFileCellModel(at: indexPath, at: tag) as? ListItemDownloadedTableViewCellModelInterface else {return false}
        return cellViewModel.didGetJSONFile
    }
}

//MARK: Data provider
extension ListFileViewModel {
    func numberOfRowIn(section: Int, at tag: Int) -> Int {
        return (ListItemTableViewType(rawValue: tag) == .all ? self.items?[section].count : self.itemsDownloaded?.count) ?? 0
    }
    
    func numberOfSection(at tag: Int) -> Int {
        return ListItemTableViewType(rawValue: tag) == .all ? self.foldersSelected.count : 1
    }
    
    func listFileCellModel(at indexPath: IndexPath, at tag: Int) -> Any? {
        let type = ListItemTableViewType(rawValue: tag)
        if type == .all {
            guard let items = self.items else {return nil}
            let item = items[indexPath.section][indexPath.row]
            return ListFileCellModel(item: item)
        } else {
            guard let items = self.itemsDownloaded else { return nil}
            let item = items[indexPath.row]
            return ListItemDownloadedTableViewCellModel(item: item)
        }
    }
    
    func title(for section: Int, at tag: Int) -> String? {
        return tag == ListItemTableViewType.all.rawValue ? (foldersSelected[section].name ?? "No Name") : nil
    }
}

//MARK: Custom funcs
extension ListFileViewModel {
    fileprivate func loadItemsOfFoldersSelected() {
        for folder in foldersSelected {
            self.loadFilesInFolder(folder: folder, completion: {[weak self] (error, nextPageToken, itemsInAFolder) in
                guard let this = self else {return}
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let folder = itemsInAFolder.first?.folder, let index = this.foldersSelected.index(of: folder) else {
                    return
                }
                this.items?[index] = itemsInAFolder
                this.nextPageTokens?[index] = nextPageToken
                this.tickets?[index] = Array(repeating: nil, count: itemsInAFolder.count)
                this.foldersSelected?[index].items = Set(itemsInAFolder)
                CoreDataStack.shared.save()
                this.didLoadFilesOfFoldersSelected.value = index
            })
        }
    }
    
    fileprivate func loadFilesInFolder(folder: Folder, nextPageToken: String? = nil,  completion: ((_ error: Error?, _ nextPageToken: String?, _ files: [Item]) -> Void)?) {
        BaseServices.searchFilesIn(folder: folder, pageToken: nextPageToken) {(files, nextPageToken, error) in
            if let error = error {
                print(error.localizedDescription)
                completion?(error, nil, [])
                return
            }
            var items = files?.flatMap {Item.createOrUpdate(from: folder, and: $0)} ?? []
            items = Set(items).flatMap {$0}
            completion?(nil, nextPageToken, items)
        }
    }
    
    fileprivate func cancelDownloadItem(at indexPath: IndexPath) {
        self.tickets?[indexPath.section][indexPath.row]?.cancel()
        self.tickets?[indexPath.section][indexPath.row] = nil
        if let itemCanceled = self.items?[indexPath.section][indexPath.row] {
            self.resetItem(item: itemCanceled)
        }
        self.didCancelDownloadFiles.value = indexPath
    }
    
    fileprivate func downloadItem(at indexPath: IndexPath) {
        guard let item = self.items?[indexPath.section][indexPath.row] else {return}
        self.items?[indexPath.section][indexPath.row].mediaState = item.mediaId != nil ? ItemState.downloading.rawValue : ItemState.none.rawValue
        self.items?[indexPath.section][indexPath.row].lyricState = item.lyricId != nil ? ItemState.downloading.rawValue : ItemState.none.rawValue
        
        self.didDownloadFilesAtIndexPath.value = indexPath
        let tickets = BaseServices.downloadItem(item: item, completion: {[weak self] (error, item, isMedia) in
            self?.items?[indexPath.section][indexPath.row].setValue(ItemState.done.rawValue, forKey: isMedia ? #keyPath(Item.mediaState) : #keyPath(Item.lyricState))
            self?.didDownloadFilesAtIndexPath.value = indexPath
            }, completionAllTasks: {[weak self] (item) in
                self?.tickets?[indexPath.section][indexPath.row] = nil
                CoreDataStack.shared.save()
        })
        self.tickets?[indexPath.section][indexPath.row] = CustomTicket(tickets: tickets)
    }
    
    fileprivate func resetItem(item: Item) {
        guard self.removeItemDownloadedFromStorage(item: item) else {return}
        self.itemsDownloaded = self.itemsDownloaded?.filter {$0 != item}
        item.mediaState = ItemState.none.rawValue
        item.lyricState = ItemState.none.rawValue
        CoreDataStack.shared.save()
    }
    
    fileprivate func removeItemDownloadedFromStorage(item: Item) -> Bool {
        guard let name = item.name, let folderId = item.folder?.folderId, let subFolderURL = CustomFileManager.shared.subFolder(with: name, folderId: folderId) else {return false}
        return CustomFileManager.shared.removeFolder(at: subFolderURL)
    }
}

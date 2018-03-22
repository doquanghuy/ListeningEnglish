//
//  Services.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn
import GTMOAuth2

class BaseServices {
    static var driveService: GTLRDriveService {
        let driveService = GTLRDriveService()
        driveService.apiKey = "AIzaSyBpQsBktycjD5DMT_FnYYrJVOhF3OrkI5A"
        driveService.authorizer = User.currentAuthentication
        return driveService
    }
    
    static func searchFolder(by text: String, pageToken: String? = nil, completion: ((_ folder: [GTLRDrive_File]?, _ nextPageToken: String?, _ error: Error?) -> Void)? = nil) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 20
        query.q = Param.allParams(text: text, isFolder: true, isTrashed: false)
        query.fields = Field.field(from: [.id, .mime, .name, .createdTime], nextPageToken: true)
        query.pageToken = pageToken
        
        driveService.executeQuery(query) { (ticket, fileList, error) in
            if let error = error {
                completion?(nil, nil, error)
                return
            }
            
            guard let fileList = fileList as? GTLRDrive_FileList else {
                completion?(nil, nil, nil)
                return
            }
            completion?(fileList.files, fileList.nextPageToken, nil)
        }
    }
    
    static func searchFilesIn(folder: Folder, pageToken: String? = nil, completion: ((_ files: [GTLRDrive_File]?, _ nextPageToken: String?, _ error : Error?) -> Void)? = nil) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 10
        query.q = Param.allParams(parentId: folder.folderId, isFolder: false, isTrashed: false)
        query.fields = Field.field(from: [.id, .mime, .name, .createdTime], nextPageToken: true)
        query.pageToken = pageToken
        
        driveService.executeQuery(query) { (ticket, fileList, error) in
            if let error = error {
                completion?(nil, nil, error)
                return
            }
            
            guard let fileList = fileList as? GTLRDrive_FileList else {
                completion?(nil, nil, nil)
                return
            }
            completion?(fileList.files, fileList.nextPageToken, nil)
        }
    }
    
    static func downloadItem(item: Item, completion: ((_ error: Error?, _ item: Item, _ isMediaFileDownloading: Bool) -> Void)? = nil, completionAllTasks: ((_ item: Item) -> Void)? = nil) -> [GTLRServiceTicket?] {
        let group = DispatchGroup()
        
        group.enter()
        let mediaTicket = self.downloadFile(fileType: .media, item: item) { (error, item) in
            completion?(error, item, true)
            group.leave()
        }
        
        group.enter()
        let lyricTicket = self.downloadFile(fileType: .lyric, item: item) { (error, item) in
            completion?(error, item, false)
            group.leave()
        }
        
        group.notify(queue: .main) {
            completionAllTasks?(item)
        }
        
        return [mediaTicket, lyricTicket]
    }
    
    private static func downloadFile(fileType: FileType, item: Item, completion: ((_ error: Error?, _ item: Item) -> Void)? = nil) -> GTLRServiceTicket? {
        return self.downloadFile(fileId: fileType == .media ? item.mediaId : item.lyricId) { (error, file) in
            if let error = error {
                print(error.localizedDescription)
                completion?(error, item)
                return
            }
            
            guard let name = fileType == .media ? item.mediaName : item.lyricName, let folderURL = CustomFileManager.shared.createSubFolder(item: item) else {
                completion?(error, item)
                return
            }
            let url = folderURL.appendingPathComponent(name)
            do {
                try file?.data.write(to: url, options: .atomic)
                completion?(nil, item)
            } catch let writeError {
                print(writeError.localizedDescription)
                completion?(writeError, item)
            }
        }
    }
    
    private static func downloadFile(fileId: String?, completion: ((_ error: Error?, _ file: GTLRDataObject?) -> Void)? = nil) -> GTLRServiceTicket? {
        guard let fileId = fileId else {
            completion?(nil, nil)
            return nil
        }
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
        return driveService.executeQuery(query) { (ticket, file, error) in
            defer {
                let file = file as? GTLRDataObject
                completion?(error, file)
            }
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
}

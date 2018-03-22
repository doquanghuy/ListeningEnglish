//
//  CustomFileManager.swift
//  Listening
//
//  Created by huydoquang on 3/3/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

class CustomFileManager {
    static let shared = CustomFileManager()
    
    private lazy var defaultImagesFolder: URL?  = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let url = documentsDirectory.appendingPathComponent(Constants.Folder.defaultFolderName)
        return self.createFolder(with: url) ? url : nil
    }()
    
    private func createFolder(with url: URL) -> Bool {
        var isDir: ObjCBool = true
        guard !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) else {return true}
        do {
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
            return false
        }
    }
    
    func createFolder(with folderId: String) -> URL? {
        guard let url = self.defaultImagesFolder?.appendingPathComponent(folderId) else {return nil}
        return self.createFolder(with: url) ? url : nil
    }
    
    func createSubFolder(item: Item) -> URL? {
        guard let itemName = item.name, let folderId = item.folder?.folderId else {
            return nil
        }

        guard let parentURL = self.defaultImagesFolder?.appendingPathComponent(folderId) else {return nil}
        let url = parentURL.appendingPathComponent(itemName)
        return self.createFolder(with: url) ? url : nil
    }
    
    func subFolder(with itemName: String, folderId: String) -> URL? {
        guard let parentURL = self.defaultImagesFolder?.appendingPathComponent(folderId) else {return nil}
        return parentURL.appendingPathComponent(itemName)
    }
    
    func removeFolder(at url: URL) -> Bool {
        var isDir: ObjCBool = true
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) else {return true}
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
            return false
        }
    }
    
    func removeFolder(with folderId: String) -> Bool {
        guard let url = self.defaultImagesFolder?.appendingPathComponent(folderId) else {return false}
        return removeFolder(at: url)
    }
    
    func createLyricFile(jsonURL: URL, content: Data) -> Bool {
        if FileManager.default.fileExists(atPath: jsonURL.path) {
            do {
                try FileManager.default.removeItem(at: jsonURL)
            } catch let error {
                print(error.localizedDescription)
                return false
            }
        }
        return FileManager.default.createFile(atPath: jsonURL.path, contents: content, attributes: nil)
    }
}

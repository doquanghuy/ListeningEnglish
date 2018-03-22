//
//  Enumeration.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation
import CoreData
import GoogleAPIClientForREST

enum Param {
    case mime(isFolder: Bool)
    case name(name: String)
    case trashed(isTrashed: Bool)
    case parentId(id: String)
    
    var param: String? {
        switch self {
        case .name(let fullText):
            return "name contains '\(fullText)'"
        case .mime(let isFolder):
            let mimeTypeFolder = "mimeType = 'application/vnd.google-apps.folder'"
            let mimeTypeFile = "(mimeType contains 'video/' or mimeType contains 'audio/' or mimeType contains '\(LyricFile.epub.rawValue)' or mimeType contains '\(LyricFile.doc.rawValue)' or mimeType contains '\(LyricFile.pdf.rawValue)' or mimeType contains '\(LyricFile.html.rawValue)' or mimeType contains '\(LyricFile.plain.rawValue)' or mimeType contains '\(LyricFile.rich.rawValue)' or mimeType contains '\(LyricFile.rich1.rawValue)' or mimeType contains '\(LyricFile.rich2.rawValue)' or mimeType contains '\(LyricFile.docx.rawValue)')"
            return (isFolder ? mimeTypeFolder : mimeTypeFile)
        case .trashed(let isTrashed):
            return "trashed = \(isTrashed ? "true" : "false")"
        case .parentId(let id):
            return "'\(id)' in parents"
        }
    }
    
    static func allParams(text: String? = nil, parentId: String? = nil, isFolder: Bool, isTrashed: Bool) -> String {
        let allCases: [Param] = [.mime(isFolder: isFolder), .trashed(isTrashed: isTrashed)] + (text != nil ? [.name(name: text!)] : []) + (parentId != nil ? [.parentId(id: parentId!)] : [])
        let allParams = allCases.flatMap {$0.param}
        return allParams.joined(separator: " and ")
    }
}

enum FileListField: String {
    case id = "id", name = "name", mime = "mimeType", modifiedTime = "modifiedTime", createdTime = "createdTime", size = "size", kind = "kind"
    
    static func fileFields(from files: [FileListField]) -> String {
        let fileTypes = files.flatMap {$0.rawValue}.joined(separator: ",")
        return "files(\(fileTypes))"
    }
}

enum Field {
    case fileTypes(fileTypes: [FileListField])
    case pageToken(nextPageToken: String?)
    
    static func field(from fileTypes: [FileListField], nextPageToken: Bool) -> String {
        let fileTypes = FileListField.fileFields(from: fileTypes)
        let nextPageToken = "nextPageToken"
        return [fileTypes, nextPageToken].joined(separator: " ,")
    }
}

enum CoreDataContext {
    case main, child
    
    var context: NSManagedObjectContext {
        switch self {
        case .main:
            return CoreDataStack.shared.managedContext
        default:
            return CoreDataStack.shared.childContext
        }
    }
}

enum DateFormat: String {
    case dayMonthYear = "dd-MM-yyyy"
    case monthDayYear = "MM-dd-yyyy"
}

enum FileType {
    case lyric, media, none
    
    static func fileType(from file: GTLRDrive_File) -> FileType {
        let mediaMimeType = ["audio/mp3", "video/mp4"]
        let lyricMimeType = ["application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
        let mimeType = file.mimeType ?? ""
        
        if mediaMimeType.contains(mimeType) {
            return .media
        } else if lyricMimeType.contains(mimeType) {
            return .lyric
        } else {
            return .none
        }
    }
}

enum LyricFile: String {
    case pdf = "application/pdf"
    case html = "text/html"
    case plain = "text/plain"
    case rich = "application/rtf"
    case rich1 = "text/richtext"
    case rich2 = "application/x-rtf"
    case docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case epub = "application/epub+zip"
    case doc = "application/msword"
}

enum ItemState: Int16 {
    case none = 0, downloading, done
    
    var description: String {
        switch self {
        case .done:
            return "completed"
        case .downloading:
            return "downloading"
        default:
            return ""
        }
    }
}

enum ListItemTableViewType: Int {
    case all = 1, downloaded
}

enum SelectFolderTableViewType: Int {
    case all = 1, selected
}

enum Loop {
    case one, forever, none
    
    var next: Loop {
        switch self {
        case .none:
            return .forever
        case .one:
            return .none
        default:
            return .one
        }
    }
    
    var imageName: String {
        switch self {
        case .forever:
            return Constants.Image.loopForever
        case .one:
            return Constants.Image.loopOne
        default:
            return Constants.Image.unLoop
        }
    }
}

enum ParagraphLoop {
    static let maxTimes: Int = 3
    case none, custom(times: Int)
    
    var isLooping: Bool {
        switch self {
        case .none:
            return false
        case .custom(let times):
            return times > 0
        }
    }
    
    var next: ParagraphLoop {
        switch self {
        case .none:
            return .none
        case .custom(let times):
            return (times > 1) ? .custom(times: times - 1) : .none
        }
    }
    
    var back: ParagraphLoop {
        switch self {
        case .none:
            return .none
        case .custom(let times):
            return (times < ParagraphLoop.maxTimes) ? .custom(times: times + 1) : .none
        }
    }
}

enum LyricVisible: Int {
    case hide, all, current
    
    var next: LyricVisible {
        let nextRawVal = self.rawValue < 2 ? self.rawValue + 1 : 0
        return LyricVisible(rawValue: nextRawVal) ?? .hide
    }
}

enum Direction {
    case up, down, left, right
}

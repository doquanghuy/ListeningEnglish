//
//  LyricSettingViewModel.swift
//  Listening
//
//  Created by huydoquang on 3/4/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit
import SwiftyJSON

class LyricSettingViewModel: LyricSettingViewModelInterface {    
    var didStop: Dynamic<Bool> = Dynamic(false)
    var didMove: Dynamic<String> = Dynamic("")
    var didEndMove: Dynamic<String> = Dynamic("")
    var didBack: Dynamic<Bool> = Dynamic(false)
    var didPlay: Dynamic<Bool> = Dynamic(false)
    var didPause: Dynamic<Bool> = Dynamic(false)
    var didGetDuration: Dynamic<String> = Dynamic("")
    var didGetCurrentTime: Dynamic<(currentTime: String, percentage: Double)> = Dynamic((currentTime: Constants.String.timeIntervalZero, percentage: 0.0))
    var didSeekToEnd: Dynamic<Bool> = Dynamic(false)
    var didParseLyric: Dynamic<Bool> = Dynamic(false)
    var didSelect: Dynamic<IndexPath> = Dynamic(IndexPath())
    var didSave: Dynamic<Bool> = Dynamic(false)
    lazy var playViewModel: PlayViewModelInterface? = {
        return PlayViewModel(item: self.item)
    }()
    
    private var item: Item
    private var jsonURL: URL
    private var audioPlayer: CustomAudioPlayerInterface
    private var sentences = [String]()
    private var parser: TextFileParser
    private var currentIndex = -1
    private var newCurrentIndex = -1
    private var currentTime: TimeInterval = 0.0
    private var newCurrentTime: TimeInterval = 0.0
    private var paragraphs = [Paragraph]()
    
    init?(item: Item) {
        guard let name = item.name,
            let folderId = item.folder?.folderId,
            let folderURL = CustomFileManager.shared.subFolder(with: name, folderId: folderId),
            let mediaName = item.mediaName,
            let lyricName = item.lyricName,
            let lyricMimeType = item.lyricMimeType
        else {return nil}
        
        let mediaURL = folderURL.appendingPathComponent(mediaName)
        let lyricURL = folderURL.appendingPathComponent(lyricName)
        self.item = item
        self.jsonURL = folderURL.appendingPathComponent("\(name).json")
        self.audioPlayer = CustomAudioPlayer(url: mediaURL)
        self.parser = TextFileParser(url: lyricURL, mimeType: lyricMimeType)
    }
    
    func move(to value: Float) {
        let timeInterval = Double(value) * audioPlayer.duration
        self.didMove.value = timeInterval.toDateString
    }
    
    func endMove(to value: Float) {
        let timeInterval = Double(value) * audioPlayer.duration
        
        let paragraphRemoved = self.paragraphs.filter {$0.startTime < timeInterval && timeInterval < $0.endTime}.first
        let desIndex = paragraphRemoved?.endIndex ?? -1
        let startIndex = paragraphRemoved?.startIndex ?? -1
        let startTime = paragraphRemoved?.startTime ?? 0.0
        var newValue = Double(value)
        if desIndex >= 0 {
            self.paragraphs = self.paragraphs.filter {$0.startIndex < startIndex}
            self.currentIndex = startIndex - 1
            self.newCurrentIndex = startIndex - 1
            self.currentTime = startTime
            self.newCurrentTime = startTime
            newValue = startTime / audioPlayer.duration
        }
        
        self.audioPlayer.move(to: newValue)
        self.didEndMove.value = startTime.toDateString
    }

    func back() {
        guard !self.paragraphs.isEmpty else {return}
        let lastParagraph = self.paragraphs.removeLast()
        let time = lastParagraph.startTime
        let index = lastParagraph.startIndex - 1
        self.currentTime = time
        self.newCurrentTime = time
        self.currentIndex = index
        self.newCurrentIndex = index
        self.audioPlayer.move(toSpecificTime: time)
        
        self.didBack.value = true
    }
    
    func play() {
        self.audioPlayer.play()
        self.createNewParagraph()
    }
    
    func pause() {
        self.audioPlayer.pause()
    }
    
    func playOrPause() {
        if self.audioPlayer.status == .paused {
             self.play()
        } else if self.audioPlayer.status == .playing {
            self.pause()
        }
    }
    
    func stop() {
        self.audioPlayer.stop()
        self.didStop.value = true
    }
    
    func select(at indexPath: IndexPath) {
        guard indexPath.row > self.currentIndex && self.audioPlayer.status == .paused else {return}
        self.newCurrentIndex = indexPath.row
        self.didSelect.value = indexPath
    }
    
    func save() {
        self.stop()
        
        let paragsDict = self.paragraphs.map {$0.dict}
        let json = JSON(paragsDict)
        do {
            let jsonData = try json.rawData(options: .prettyPrinted)
            self.didSave.value = CustomFileManager.shared.createLyricFile(jsonURL: jsonURL, content: jsonData)
        } catch let error {
            print(error.localizedDescription)
            self.didSave.value = false
        }
    }
    
    func setup() {
        var content = self.parser.parse() ?? ""
        content = content.replacingOccurrences(of: "\n", with: ".")
        self.sentences = content.components(separatedBy: ".").filter {$0.isFinte}
        self.didParseLyric.value = true
        
        self.setupObservser()
        self.play()
    }
    
    private func createNewParagraph() {
        guard self.currentIndex != self.newCurrentIndex else {return}
        let content = self.sentences[self.currentIndex + 1...self.newCurrentIndex].joined(separator: ". ")
        self.paragraphs.append(Paragraph(startIndex: self.currentIndex + 1, endIndex: self.newCurrentIndex, startTime: self.currentTime, endTime: self.newCurrentTime, content: content))
        self.currentIndex = self.newCurrentIndex
        self.currentTime = self.newCurrentTime
    }
    
    private func setupObservser() {
        self.audioPlayer.observerCurrentTime = {[weak self] (time, percentage) in
            self?.newCurrentTime = time
            self?.didGetCurrentTime.value = (time.toDateString, percentage)
        }
        self.audioPlayer.observerDidEndTime = {[weak self] in
            guard let this = self else {return}
            this.didSeekToEnd.value = true
            this.newCurrentIndex = this.sentences.count - 1
            this.createNewParagraph()
        }
        
        self.audioPlayer.observerDuration = {[weak self](duration) in
            self?.didGetDuration.value = duration.toDateString
        }
        
        self.audioPlayer.observerPlayStatus = {[weak self](status) in
            switch status {
            case .paused:
                self?.didPause.value = true
            case .playing:
                self?.didPlay.value = true
            default:
                return
            }
        }
    }    
}

extension LyricSettingViewModel {
    func numberOfRow(in section: Int) -> Int {
        return self.sentences.count
    }

    func lyricTableViewCellModel(at indexPath: IndexPath) -> LyricTableViewCellModelInterface {
        var color: UIColor!
        var isHiddenBottomLine: Bool!
        
        if indexPath.row <= self.currentIndex {
            color = .orange
        } else if indexPath.row <= self.newCurrentIndex {
            color = .blue
        } else {
            color = .darkGray
        }
        let visibleBottomLineIndexs = self.paragraphs.flatMap {$0.endIndex}
        isHiddenBottomLine = !visibleBottomLineIndexs.contains(indexPath.row)
        
        return LyricTableViewCellModel(content: self.sentences[indexPath.row], backgroundColor: color, isHiddenBottomLine: isHiddenBottomLine)
    }
}

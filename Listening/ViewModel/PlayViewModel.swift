//
//  PlayViewModel.swift
//  Listening
//
//  Created by huydoquang on 3/10/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

class PlayViewModel: PlayViewModelInterface {
    var didStop: Dynamic<Bool> = Dynamic(false)
    var didBack: Dynamic<Bool> = Dynamic(false)
    var didPlay: Dynamic<Bool> = Dynamic(false)
    var didPause: Dynamic<Bool> = Dynamic(false)
    var didSeekToEnd: Dynamic<Bool> = Dynamic(false)
    var didParseLyric: Dynamic<Bool> = Dynamic(false)
    var didNext: Dynamic<Bool> = Dynamic(false)
    
    var didGetDuration: Dynamic<String> = Dynamic("")
    var didMove: Dynamic<String> = Dynamic("")
    var didEndMove: Dynamic<String> = Dynamic("")
    var didGetTitle: Dynamic<String?> = Dynamic("")
    
    var didChangeCurrentIndex: Dynamic<(indexPath: IndexPath, content: String?)> = Dynamic((indexPath: IndexPath(), content: nil))
    var didSelect: Dynamic<IndexPath> = Dynamic(IndexPath())
    var didGetCurrentTime: Dynamic<(currentTime: String, percentage: Double)>
        = Dynamic((currentTime: Constants.String.timeIntervalZero, percentage: 0.0))
    var didChangeMode: Dynamic<LyricVisible> = Dynamic(.all)
    var didSetParagraphLoop: Dynamic<(content: String?, hide: Bool)> = Dynamic((content: "", hide: true))
    var didSetLoop: Dynamic<Loop> = Dynamic(.none)
    
    private var itemName: String
    private var audioPlayer: CustomAudioPlayerInterface
    private var parser: JSONParser
    private var paragraphs = [Paragraph]()
    private var paragraphLoop: ParagraphLoop = .none {
        didSet {
            switch self.paragraphLoop {
            case .custom(let times):
                if times < ParagraphLoop.maxTimes {
                    self.loop()
                }
                self.didSetParagraphLoop.value = ("\(times)", false)
            default:
                self.didSetParagraphLoop.value = (nil, true)
            }
        }
    }
    private var paragraphIndexSelected = 0 {
        didSet {
            self.didChangeCurrentIndex.value = (IndexPath(row: paragraphIndexSelected, section: 0), self.paragraphs[paragraphIndexSelected].content)
        }
    }
    
    init?(item: Item) {
        guard let name = item.name,
            let folderId = item.folder?.folderId,
            let folderURL = CustomFileManager.shared.subFolder(with: name, folderId: folderId),
            let mediaName = item.mediaName
        else {return nil}
        
        let mediaURL = folderURL.appendingPathComponent(mediaName)
        let jsonURL = folderURL.appendingPathComponent("\(name).json")
        self.itemName = name
        self.audioPlayer = CustomAudioPlayer(url: mediaURL)
        self.parser = JSONParser(url: jsonURL)
    }
    
    func move(to value: Float) {
        let timeInterval = Double(value) * audioPlayer.duration
        self.didMove.value = timeInterval.toDateString
    }
    
    func endMove(to value: Float) {
        self.paragraphLoop = .none
        let timeInterval = Double(value) * audioPlayer.duration
        let paragraph = self.paragraphs.filter {$0.startTime <= timeInterval && timeInterval <= $0.endTime}.first
        guard let paragraphRemoved = paragraph, let index = paragraphs.index(of: paragraphRemoved) else {return}
        let startTime = paragraphRemoved.startTime
        let newValue = startTime / audioPlayer.duration
        self.paragraphIndexSelected = index
        self.audioPlayer.move(to: newValue)
    }
    
    func back() {
        self.paragraphLoop = self.paragraphLoop.back
        guard paragraphIndexSelected > 0, !self.paragraphLoop.isLooping else {return}
        let paragraph = self.paragraphs[self.paragraphIndexSelected - 1]
        let time = paragraph.startTime
        self.paragraphIndexSelected -= 1
        self.audioPlayer.move(toSpecificTime: time)
    }
    
    func next() {
        self.paragraphLoop = self.paragraphLoop.next
        guard paragraphIndexSelected < self.paragraphs.count - 1, !self.paragraphLoop.isLooping else {return}
        let paragraph = self.paragraphs[self.paragraphIndexSelected + 1]
        let time = paragraph.startTime
        self.paragraphIndexSelected += 1
        self.audioPlayer.move(toSpecificTime: time)
    }

    func play() {
        self.audioPlayer.play()
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
        self.paragraphLoop = .none
        let paragraph = self.paragraphs[indexPath.row]
        let time = paragraph.startTime
        self.paragraphIndexSelected = indexPath.row
        self.audioPlayer.move(toSpecificTime: time)
    }
    
    func setup() {
        self.paragraphs = self.parser.parse()
        self.didParseLyric.value = true
        self.didChangeCurrentIndex.value = (IndexPath(row: 0, section: 0), self.paragraphs.first?.content)
        self.didGetTitle.value = self.itemName
            
        self.setupObservser()
        self.play()
    }
    
    func changeMode() {
        self.didChangeMode.value = self.didChangeMode.value.next
    }
    
    func setParagraphLoop() {
        self.paragraphLoop = self.paragraphLoop.isLooping ? .none : .custom(times: ParagraphLoop.maxTimes)
    }
    
    func setLoop() {
        self.didSetLoop.value = self.didSetLoop.value.next
    }
}

extension PlayViewModel {
    func numberOfRow(in section: Int) -> Int {
        return self.paragraphs.count
    }
    
    func lyricTableViewCellModel(at indexPath: IndexPath) -> LyricTableViewCellModelInterface {
        return LyricTableViewCellModel(content: self.paragraphs[indexPath.row].content, backgroundColor: self.paragraphIndexSelected == indexPath.row ? .orange : .darkGray, isHiddenBottomLine: true)
    }
}

extension PlayViewModel {
    private func setupObservser() {
        self.audioPlayer.observerCurrentTime = {[weak self] (time, percentage) in
            guard let this = self else {return}
            this.didGetCurrentTime.value = (time.toDateString, percentage)
            let paragraph = this.paragraphs
                .filter {$0.startTime < time && time < $0.endTime}
                .last
            
            guard paragraph != nil,
                let index = this.paragraphs.index(of: paragraph!),
                this.paragraphIndexSelected != index else {return}
            if this.paragraphLoop.isLooping {
                this.paragraphLoop = this.paragraphLoop.next
            } else {
                this.paragraphIndexSelected = index
            }
        }
        
        self.audioPlayer.observerDidEndTime = {[weak self] in
            guard let this = self else {return}
            this.didSeekToEnd.value = true
            
            switch this.didSetLoop.value {
            case .forever:
                this.audioPlayer.move(to: 0.0)
            case .one:
                this.audioPlayer.move(to: 0.0)
                this.didSetLoop.value = .none
            default:
                break
            }
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

    private func loop() {
        self.audioPlayer.pause()
        let paragraphSelected = self.paragraphs[self.paragraphIndexSelected]
        let time = paragraphSelected.startTime
        self.audioPlayer.move(toSpecificTime: time)
    }
}

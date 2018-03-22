//
//  CustomAudioPlayer.swift
//  Listening
//
//  Created by huydoquang on 3/5/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftEventBus

class AVPlayerConfigure {
    static let shared = AVPlayerConfigure()
    private var isCompleted: Bool = false
    
    func setup() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            self.isCompleted = true
        } catch let error {
            print(error.localizedDescription)
            self.isCompleted = false
        }
    }
}

protocol CustomAudioPlayerInterface {
    var status: AVPlayerTimeControlStatus {get}
    var observerCurrentTime: ((_ currentTime: TimeInterval, _ percentage: Double) -> Void)? {get set}
    var observerDidEndTime: (() -> Void)? {get set}
    var observerPlayStatus: ((AVPlayerTimeControlStatus) -> Void)? {get set}
    var observerDuration: ((TimeInterval) -> Void)? {get set}
    var duration: TimeInterval {get}

    func play()
    func pause()
    func move(to percentage: TimeInterval)
    func move(toSpecificTime timeInterval: TimeInterval)
    func stop()
    func setLoop(loop: Loop)
}

class CustomAudioPlayer: NSObject, CustomAudioPlayerInterface {
    var duration: TimeInterval = 0.0
    var url: URL
    var loop: Loop = .none
    var status: AVPlayerTimeControlStatus {
        return self.player.timeControlStatus
    }
    var observerCurrentTime: ((TimeInterval, Double) -> Void)?
    var observerDuration: ((TimeInterval) -> Void)?
    var observerDidEndTime: (() -> Void)?
    var observerPlayStatus: ((AVPlayerTimeControlStatus) -> Void)?
    private var timeObserver: Any!
    lazy var player: AVPlayer = {
        return AVPlayer(playerItem: AVPlayerItem(asset: AVURLAsset(url: url)))
    }()

    init(url: URL) {
        self.url = url
        super.init()
        self.setupObserver()
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func move(to percentage: Double) {
        guard let durationTime = player.currentItem?.duration else { return }
        var targetTime = CMTimeMultiplyByFloat64(durationTime, percentage)
        guard targetTime.isValid && targetTime.isNumeric else { return }
        targetTime = targetTime.convertScale(durationTime.timescale, method: .default)
        guard targetTime.isValid && targetTime.isNumeric else { return }
        if targetTime > durationTime {
            targetTime = durationTime
        }
        player.pause()
        let minimumTime = CMTime(seconds: CMTimeGetSeconds(targetTime) + 0.25, preferredTimescale: durationTime.timescale)
        player.seek(to: minimumTime) {[weak self] (finished) in
            self?.player.play()
        }
    }
    
    func move(toSpecificTime timeInterval: TimeInterval) {
        guard let durationTime = player.currentItem?.duration else { return }
        var targetTime = CMTime(seconds: timeInterval, preferredTimescale: durationTime.timescale)
        guard targetTime.isValid && targetTime.isNumeric else { return }
        if targetTime > durationTime {
            targetTime = durationTime
        }
        player.pause()
        let minimumTime = CMTime(seconds: CMTimeGetSeconds(targetTime) + 0.25, preferredTimescale: durationTime.timescale)
        player.seek(to: minimumTime) {[weak self] (finished) in
            self?.player.play()
        }
    }
    
    func stop() {
        self.player.replaceCurrentItem(with: nil)
    }
    
    func setLoop(loop: Loop) {
        self.loop = loop
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            guard let newValue = change?[NSKeyValueChangeKey.newKey] as? Int else {return}
            let status = AVPlayerTimeControlStatus(rawValue: newValue) ?? .paused
            self.observerPlayStatus?(status)
        } else if keyPath == #keyPath(AVPlayerItem.duration) {
            guard let cmTime = change?[NSKeyValueChangeKey.newKey] as? CMTime else {return}
            self.duration = CMTimeGetSeconds(cmTime)
            self.observerDuration?(self.duration)
        }
    }
    
    deinit {
        self.player.replaceCurrentItem(with: nil)
        self.player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        self.player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration))
        self.player.removeTimeObserver(self.timeObserver)
        SwiftEventBus.unregister(self)
    }
}

extension CustomAudioPlayer {
    fileprivate func setupObserver() {
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 4), queue: .main) {[weak self] (time) in
            guard let this = self else {return}
            let seconds = CMTimeGetSeconds(time)
            let percentage = this.duration != 0.0 ? seconds / this.duration : 0.0
            this.observerCurrentTime?(seconds, percentage)
        }
        
        self.player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)
        
        self.player.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration), options: [.new], context: nil)
        
        SwiftEventBus.onMainThread(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime.rawValue) {[weak self] (notification) in
            self?.observerDidEndTime?()
        }
    }
}

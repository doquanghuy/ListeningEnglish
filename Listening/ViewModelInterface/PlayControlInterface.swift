//
//  PlayControlInterface.swift
//  Listening
//
//  Created by huydoquang on 3/11/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

protocol PlayControlInterface {
    var didMove: Dynamic<String> {get}
    var didEndMove: Dynamic<String> {get}
    var didBack: Dynamic<Bool> {get}
    var didPause: Dynamic<Bool> {get}
    var didPlay: Dynamic<Bool> {get}
    var didStop: Dynamic<Bool> {get}
    var didGetDuration: Dynamic<String> {get}
    var didGetCurrentTime: Dynamic<(currentTime: String, percentage: Double)> {get}
    var didSeekToEnd: Dynamic<Bool> {get}
    var didNext: Dynamic<Bool> {get}
    var didSetLoop: Dynamic<Loop> {get}
    
    func move(to value: Float)
    func endMove(to value: Float)
    func back()
    func playOrPause()
    func play()
    func pause()
    func stop()
    func next()
    func setLoop()
}

extension PlayControlInterface {
    var didNext: Dynamic<Bool> {return Dynamic(false)}
    var didSetLoop: Dynamic<Loop> {return Dynamic(.none)}

    func next() {}
    func setLoop() {}
}

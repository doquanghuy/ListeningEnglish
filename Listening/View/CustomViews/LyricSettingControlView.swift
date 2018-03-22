//
//  LyricSettingControlView.swift
//  Listening
//
//  Created by huydoquang on 3/5/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

protocol LyricSettingControlViewDelegate: class {
    func didClickBackButton(button: UIButton)
    func didClickPlayButton(playButton: UIButton)
    func didBeginTouchSlider(slider: UISlider)
    func didChangeValueSlider(slider: UISlider)
    func didEndChangeValudeSlider(slider: UISlider)
}

class LyricSettingControlView: UIView {
    weak var delegate: LyricSettingControlViewDelegate?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupFromXib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sliderView.setThumbImage(UIImage(named: Constants.Image.thumb), for: .normal)
        self.sliderView.addTarget(self, action: #selector(self.processSliderValueChanged(slider:)), for: .valueChanged)
        self.sliderView.addTarget(self, action: #selector(self.processSliderTouchUp(slider:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        self.sliderView.addTarget(self, action: #selector(self.processSliderTouchDown(slider:)), for: .touchDown)
    }
    
    @objc func processSliderValueChanged(slider: UISlider) {
        self.delegate?.didChangeValueSlider(slider: slider)
    }
    
    @objc func processSliderTouchUp(slider: UISlider) {
        self.delegate?.didEndChangeValudeSlider(slider: slider)
    }
    
    @objc func processSliderTouchDown(slider: UISlider) {
        self.delegate?.didBeginTouchSlider(slider: slider)
    }
        
    func seekToEnd() {
        self.pause()
    }
    
    func stop() {
        self.setPlayButton(isPlay: false)
        self.setLeftLabelContent(content: Constants.String.timeIntervalZero)
    }
    
    func play() {
        self.setPlayButton(isPlay: true)
    }
    
    func pause() {
        self.setPlayButton(isPlay: false)
    }
    
    func updateCurrentTime(currentTime: String, and percentage: Double) {
        self.setLeftLabelContent(content: currentTime)
        self.setSlider(to: percentage)
    }
    
    func updateCurrentTime(currentTime: String) {
        self.setLeftLabelContent(content: currentTime)
    }
    
    func updateDuration(duration: String) {
        self.setRightLabelContent(content: duration)
    }
        
    @IBAction func clickPlayButton(_ sender: UIButton) {
        self.delegate?.didClickPlayButton(playButton: sender)
    }
    
    @IBAction func clickBackButton(_ sender: UIButton) {
        self.delegate?.didClickBackButton(button: sender)
    }
}

extension LyricSettingControlView {
    fileprivate func setSlider(to percentage: Double) {
        self.sliderView.setValue(Float(percentage), animated: true)
    }
    
    fileprivate func setLeftLabelContent(content: String) {
        self.leftLabel.text = content
    }
    
    fileprivate func setRightLabelContent(content: String) {
        self.rightLabel.text = content
    }
    
    fileprivate func setPlayButton(isPlay: Bool) {
        self.playButton.setImage(isPlay ? UIImage(named: Constants.Image.pause) : UIImage(named: Constants.Image.play), for: .normal)
    }
}

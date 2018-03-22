//
//  LyricSettingFullControlView.swift
//  Listening
//
//  Created by huydoquang on 3/10/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

protocol LyricSettingFullControlViewDelegate: LyricSettingControlViewDelegate {
    func didClickNextButton(button: UIButton)
    func didClickLoopButton(button: UIButton)
}

class LyricSettingFullControlView: LyricSettingControlView {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var loopButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupFromXib()
    }
    
    override weak var delegate: LyricSettingControlViewDelegate? {
        get {
            return subDelegate
        } set {
            self.subDelegate = newValue as? LyricSettingFullControlViewDelegate
        }
    }
    private weak var subDelegate: LyricSettingFullControlViewDelegate?
    
    func setup(loop: Loop) {
        self.loopButton.setImage(UIImage(named: loop.imageName), for: .normal)
    }
    
    @IBAction func loop(_ sender: UIButton) {
        guard let delegate = self.delegate as? LyricSettingFullControlViewDelegate else {return}
        delegate.didClickLoopButton(button: sender)
    }
    
    @IBAction func next(_ sender: UIButton) {
        guard let delegate = self.delegate as? LyricSettingFullControlViewDelegate else {return}
        delegate.didClickNextButton(button: sender)
    }
}

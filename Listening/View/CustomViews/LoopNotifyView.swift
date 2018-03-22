//
//  LoopNotifyView.swift
//  Listening
//
//  Created by huydoquang on 3/11/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

class LoopNotifyView: UIView {
    @IBOutlet weak var contentLabel: UILabel!
    private var direction: Direction!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupFromXib()
    }
    
    func setup(content: String?) {
        self.contentLabel.text = content
    }
    
    func show(on view: UIView, animated: Bool, direction: Direction) {
        self.direction = direction
        let newFrame = self.frame
        var origin: CGPoint = .zero
        switch direction {
        case .up:
            origin = CGPoint(x: newFrame.origin.x, y: newFrame.origin.y + 2 * newFrame.size.height)
        case .down:
            origin = CGPoint(x: newFrame.origin.x, y: newFrame.origin.y - 2 * newFrame.size.height)
        default:
            break
        }
        self.frame = CGRect(origin: origin, size: newFrame.size)
        view.addSubview(self)
        UIView.animate(withDuration: animated ? 0.25 : 0.0) {
            self.frame = newFrame
        }
    }
    
    func dismiss(animated: Bool) {
        var origin: CGPoint!
        switch direction {
        case .up:
            origin = CGPoint(x: self.frame.origin.x, y: self.frame.origin.y + 2 * self.frame.size.height)
        case .down:
            origin = CGPoint(x: self.frame.origin.x, y: self.frame.origin.y - 2 * self.frame.size.height)
        default:
            break
        }
        UIView.animate(withDuration: animated ? 0.25 : 0.0, animations: {
            self.frame.origin = origin
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    deinit {
        print("Deinit")
    }
}

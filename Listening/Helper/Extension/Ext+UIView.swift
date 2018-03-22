//
//  Ext+UIView.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

extension UIView {
    static func setTintColor(tintColor: UIColor) {
        self.appearance().tintColor = tintColor
    }
    
    func setupFromXib(viewName: String? = nil) {
        guard let view = Bundle.main.loadNibNamed(viewName ?? String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
}

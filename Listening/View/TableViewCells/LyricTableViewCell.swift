//
//  LyricTableViewCell.swift
//  Listening
//
//  Created by huydoquang on 3/6/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

class LyricTableViewCell: UITableViewCell {
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentLabel.layer.cornerRadius = 5.0
        self.contentLabel.layer.masksToBounds = true
    }
    
    func setup(viewModel: LyricTableViewCellModelInterface) {
        self.contentLabel.text = viewModel.content
        self.contentLabel.textColor = viewModel.backgroundColor
        self.bottomLine.isHidden = viewModel.isHiddenBottomLine
    }
}


//
//  ListItemTableViewCell.swift
//  Listening
//
//  Created by huydoquang on 3/1/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

class ListFolderTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var selectedImgView: UIImageView!
    
    func setup(viewModel: ListFolderTableViewCellModelInterface) {
        self.nameLabel.text = viewModel.name
        self.createdAtLabel.text = viewModel.createdAt
        self.selectedImgView.isHidden = !viewModel.isSelected
    }
}

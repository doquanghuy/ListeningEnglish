//
//  ListItemDownloadedTableViewCell.swift
//  Listening
//
//  Created by huydoquang on 3/4/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

class ListItemDownloadedTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jsonFileExistedImgView: UIImageView!
    
    func setup(viewModel: ListItemDownloadedTableViewCellModelInterface) {
        self.nameLabel.text = viewModel.name
        self.jsonFileExistedImgView.isHidden = !viewModel.didGetJSONFile
    }
}

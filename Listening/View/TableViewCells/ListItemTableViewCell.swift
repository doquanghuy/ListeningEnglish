//
//  ListFolderTableViewCell.swift
//  Listening
//
//  Created by huydoquang on 3/3/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

class ListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(viewModel: ListFileCellModelInterface) {
        self.nameLabel.text = viewModel.name
        let isNotShowLoading = viewModel.isDownloaded || viewModel.isNotDownloaded
        isNotShowLoading ? self.activityIndicator.stopAnimating() : self.activityIndicator.startAnimating()
        self.stateLabel.text = viewModel.isDownloaded ? "Downloaded" : viewModel.state
    }
}

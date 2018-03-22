//
//  LoadingFooterView.swift
//  Listening
//
//  Created by huydoquang on 3/3/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

protocol LoadingFooterViewDelegate: class {
    func loading(loadingFooterView: LoadingFooterView, section: Int)
}

class LoadingFooterView: UITableViewHeaderFooterView {
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    private weak var delegate: LoadingFooterViewDelegate?
    private var section: Int!
    private var isLoading = false {
        didSet {
            isLoading ? self.activityIndicatorView.startAnimating() : self.activityIndicatorView.stopAnimating()
            self.loadingLabel.isHidden = isLoading
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupFromXib()
        self.setupGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupFromXib()
    }
    
    func setup(section: Int, delegate: LoadingFooterViewDelegate, viewModel: LoadingFooterViewModelInterface) {
        self.section = section
        self.delegate = delegate
        self.isLoading = viewModel.isLoading
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.loading(gesture:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func loading(gesture: UITapGestureRecognizer) {
        self.isLoading = true
        self.delegate?.loading(loadingFooterView: self, section: section)
    }
    
    func stopLoading() {
        self.isLoading = false
    }
    
    override func prepareForReuse() {
       self.isLoading = false
    }
}

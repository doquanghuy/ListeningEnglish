//
//  LoadingFooterViewModel.swift
//  Listening
//
//  Created by huydoquang on 3/3/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation

protocol LoadingFooterViewModelInterface {
    var isLoading: Bool {get}
}

class LoadingFooterViewModel: LoadingFooterViewModelInterface {
    var isLoading: Bool = false
    
    init(isLoading: Bool) {
        self.isLoading = isLoading
    }
}

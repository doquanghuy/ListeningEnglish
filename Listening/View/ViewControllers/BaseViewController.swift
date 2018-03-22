//
//  BaseViewController.swift
//  Listening
//
//  Created by huydoquang on 3/2/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    class var name: String {
        return String(describing: self)
    }

    func comeToRoot() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let navVC = appDelegate?.window?.rootViewController as? UINavigationController
        navVC?.viewControllers = [SignInViewController.instance]
        navVC?.dismiss(animated: true, completion: nil)
    }
    
    func signout() {
        let alertVC = UIAlertController(title: Constants.String.alertSignOutTitle, message: Constants.String.alertSignOutMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.String.yes, style: .default) { (action) in
            self.comeToRoot()
        }
        let cancelAction = UIAlertAction(title: Constants.String.no, style: .cancel, handler: nil)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
}

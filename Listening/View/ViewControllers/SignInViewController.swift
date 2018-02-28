//
//  SignInViewController.swift
//  Listening
//
//  Created by huydoquang on 2/28/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignInViewController: UIViewController {
    @IBOutlet weak var signInGoogleDriveButton: UIButton!
    private var viewModel: SignInViewModelInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    func setupUI() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GoogleSignIn.shared.start()
    }
    
    func setupData() {
        self.viewModel = SignInViewModel()
        self.viewModel?.didSignInGoogleDrive?.bind(listener: {[weak self] (didSignIn) in
            self?.performSegue(withIdentifier: Constants.Segue.fromSignInVCToChooseFolderVC, sender: nil)
        })
    }
    
    @IBAction func signInGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
}

extension SignInViewController: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
}

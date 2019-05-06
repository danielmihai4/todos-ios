//
//  LoginViewController.swift
//  todos-ios
//
//  Created by Daniel Mihai on 17/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, LoginDelegateProtocol {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabelField: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var authenticationService = AuthenticationService()
    var token: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticationService.loginDelegate = self
        authenticationService.ping()
        pingFailed()
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        //TODO check for empty fields
        authenticationService.login(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    internal func pingSuccessful(token: String) {
        self.token = token
        performSegue(withIdentifier: Segues.ShowMainView, sender: nil)
    }
    
    internal func pingFailed() {
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
        loginButton.isEnabled = true
        signUpButton.isEnabled = true
    }
    
    internal func loginSuccessful(token: String) {
        self.token = token
        performSegue(withIdentifier: Segues.ShowMainView, sender: nil)
    }
    
    internal func loginFailed() {
        errorLabelField.text = "Something went wrong. Please try again."
    }
}

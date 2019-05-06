//
//  SignUpViewController.swift
//  todos-ios
//
//  Created by Daniel Mihai on 17/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, SignUpDelegateProtocol {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var authenticationService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticationService.signUpDelegate = self
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        let password = self.passwordTextField.text!
        let confirmPassword = self.confirmPasswordTextField.text!
        
        if password != confirmPassword {
            showAlert(title: AlertLabels.errorTitle, message: AlertLabels.passwordsErrorMessage)
            return
        }
        
        authenticationService.signUp(
            email: emailTextField.text!,
            firstName: firstNameTextField.text!,
            lastName: lastNameTextField.text!,
            password: password)
    }
    
    internal func signUpSuccessful() {
        performSegue(withIdentifier: Segues.ShowMainViewAfterSignUp, sender: nil)
    }
    
    internal func signUpFailed() {
        showAlert(title: AlertLabels.errorTitle, message: AlertLabels.signUpErrorMessage)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: ButtonLabels.ok, style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
}

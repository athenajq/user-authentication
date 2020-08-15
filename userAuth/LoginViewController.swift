//
//  LoginViewController.swift
//  userAuth
//
//  Created by athena on 6/23/20.
//  Copyright © 2020 athena. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
    }
    //styles elements and creates a done button
    func setUpElements() {
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(resetPasswordButton)
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        emailTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        //removes keyboard
        self.view.endEditing(true)
    }
    
    func transitionToHome() {
        //makes the home vc show up
        let vc = storyboard!.instantiateViewController(identifier: "homeVC") as! HomeViewController
        view.window?.rootViewController = vc
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        //checks if fields are empty
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            errorLabel.text = "Please fill in all fields"
            errorLabel.alpha = 1
        }else {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //sign in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.numberOfLines = 0
                self.errorLabel.alpha = 1
                //make sure there is no error
            }else {
                //makes sure that the user verified email
                guard let user = Auth.auth().currentUser else {
                    return
                }
                user.reload { (error) in
                    switch user.isEmailVerified {
                    case true:
                        print("user email is verified")
                        self.transitionToHome()
                        
                    case false:
                        self.errorLabel.text = "Please verify your email."
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.errorLabel.alpha = 1
                        user.sendEmailVerification { (error) in
                            guard let error = error else {
                                print("user email verification sent")
                                return
                            }
                            print("error verifying email: \(error.localizedDescription)")
                        }
                        print("verify it now")
                    }
                }
                
            }
            }
        }
    }
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        //resets password through email
        Auth.auth().sendPasswordReset(withEmail: Auth.auth().currentUser!.email ?? "") { (error) in
            if let error = error {
                print("ERROR sending password reset: \(error.localizedDescription)")
                self.errorLabel.alpha = 1
                self.errorLabel.text = "Error sending passwording reset email. Try again later."
            }else {
                self.errorLabel.alpha = 1
                self.errorLabel.text = "The password reset email has been sent to your current email."
                let vc = self.storyboard!.instantiateViewController(identifier: "ViewController") as! ViewController
                self.view.window?.rootViewController = vc
                
            }
        }
    }
    
    
}

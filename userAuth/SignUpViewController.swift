//
//  SignUpViewController.swift
//  userAuth
//
//  Created by athena on 6/23/20.
//  Copyright © 2020 athena. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var schoolNameTextField: UITextField!
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var refererEmail: UITextField!
    
    var isSchoolEqual = false
    var isGradeEqual = false
    var isEmailEqual = false
    var isfirstNameEqual = false
    var islastNameEqual = false
    
    var data: [[String:Any]] = [] //will contain all the data in the referral section (under the collection of the email of the referer)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupElements()
    }
    
    func setupElements() {
        //styles the text fields and buttons and creates a button on top of keyboard
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(schoolNameTextField)
        Utilities.styleTextField(gradeTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(refererEmail)
        Utilities.styleFilledButton(signupButton)
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        firstNameTextField.inputAccessoryView = toolbar
        lastNameTextField.inputAccessoryView = toolbar
        schoolNameTextField.inputAccessoryView = toolbar
        gradeTextField.inputAccessoryView = toolbar
        emailTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
        refererEmail.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        //stops keyboard editing
        self.view.endEditing(true)
    }
    
    
    
    func validateFields() -> String? {
        //checks if the text fields are empty
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return("Please fill in all fields.")
        }
        //checks if password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return("Please make sure that your password is at least 8 characters long and contains a number and special character.")
        }
        return nil
    }
    
    
    //check if the input from the text fields are the same from someone who reffered them.
    func checkInfoFromReferrals() {
        print("Hello")
        let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let school = schoolNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let grade = gradeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let refEmail = refererEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        print(refEmail)
        let db = Firestore.firestore()
        //gets the collection under the referer
        db.collection("users").document("referrals").collection(refEmail).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.data.append(document.data()) //adds the document data to the array
                }
                print(self.data)
                for i in self.data {
                    for (key, value) in i {
                        print("key: \(key), value: \(value)")
                        if key == "school"{
                            if value as! String == school {
                                self.isSchoolEqual = true
                            }
                        }else if key == "grade" {
                            if value as! String == grade {
                                self.isGradeEqual = true
                            }
                        }else if key == "lastName" {
                            if value as! String == lastName {
                                self.islastNameEqual = true
                            }
                        }else if key == "firstName" {
                            if value as! String == firstName {
                                self.isfirstNameEqual = true
                            }
                        }else if key == "email" {
                            if value as! String == email {
                                self.isEmailEqual = true
                            }
                        }
                    }
                }
                print(self.isSchoolEqual, self.isGradeEqual, self.islastNameEqual, self.isfirstNameEqual, self.isEmailEqual)
            }
            
        }
        
        
    }
    
    
    func transitionToHome() {
        //sets the view controller to the home vc
        let vc = storyboard!.instantiateViewController(identifier: "homeVC") as! HomeViewController
        view.window?.rootViewController = vc
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        //checks if fields are not empty/the password is strong enough
        let error = validateFields()
        if error != nil {
            //there is an error
            print("error: \(error)")
            errorLabel.alpha = 1
            errorLabel.text = error
        }else {
            checkInfoFromReferrals() //matches info from referral database
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let school = schoolNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let grade = gradeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //if the info matches, creates the user
                self.errorLabel.alpha = 1
            if self.isfirstNameEqual == true && self.islastNameEqual == true && self.isGradeEqual == true && self.isSchoolEqual == true && self.isEmailEqual == true {
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if error != nil {
                        print("Error creating user: \(error?.localizedDescription)")
                        self.errorLabel.alpha = 1
                        self.errorLabel.text = "Error creating user. \(error!.localizedDescription)"
                    } else {
                        //verify email
                        self.errorLabel.text = "Please verify your email address. Click the link sent to your email."
                        self.errorLabel.alpha = 1
                        self.errorLabel.numberOfLines = 0
                        
                        //save sign up info to database
                        let db = Firestore.firestore()
                        db.collection("users").document("\(email)").setData(["firstName": firstName,
                                                                             "lastName": lastName,
                                                                             "grade": grade,
                                                                             "school": school,
                                                                             "uid": result?.user.uid ]) { (error) in
                                                                                if let error = error {
                                                                                    print("error saving name: \(error)")
                                                                                }else {
                                                                                    print("name successfully saved!")
                                                                                }
                        }
                        guard let user = Auth.auth().currentUser else {
                            return
                        }
                        //checks if user if verified; if it is, go to home vc; otherwise tells to login.
    
                        user.reload { (error) in
                            switch user.isEmailVerified {
                            case true:
                                print("user email is verified")
                                self.transitionToHome()
                                
                            case false:
                                self.errorLabel.text = "Please verify your email. We have sent a verification link to the email you have given us. "
                                self.errorLabel.alpha = 90
                                user.sendEmailVerification { (error) in
                                    guard let error = error else {
                                        print("user email verification sent")
                                        self.errorLabel.text = "If you already verified your email, please login under the login page. Thanks!"
                                        self.errorLabel.alpha = 1
                                        return
                                    }
                                    print("error verifying email: \(error.localizedDescription)")
                                }
                                print("verify it now")
                                
                                
                            }
                            
                        }
                        
                    }
                    
            }
            }else{
                errorLabel.alpha = 1
                errorLabel.text = "You have not been referred. "
                
            }
        }
        
    }
    
}

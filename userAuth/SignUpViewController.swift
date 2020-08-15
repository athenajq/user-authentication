//
//  SignUpViewController.swift
//  userAuth
//
//  Created by athena on 6/23/20.
//  Copyright © 2020 athena. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var monthTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var yearTextField: UITextField!
    var monthPIcker = UIPickerView()
    var datePicker = UIPickerView()
    var yearPicker = UIPickerView()
    var month = ["January", "Febraury", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var age: Int!
    var date = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
    
    var year: [String]!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == datePicker {
            return date.count
        }else if pickerView == yearPicker {
            return year.count
        }else if pickerView == monthPIcker {
            return month.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePicker {
            dateTextField.text = "\(date[row])"
        }else if pickerView == yearPicker {
            yearTextField.text = "\(year[row])"
        }else if pickerView == monthPIcker {
            monthTextField.text = month[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == datePicker {
            return "\(date[row])"
        }else if pickerView == yearPicker {
            return "\(year[row])"
        }else if pickerView == monthPIcker {
            return month[row]
        }
        return ""
    }
    
    
    var data: [[String:Any]] = [] //will contain all the data in the referral section (under the collection of the email of the referer)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupElements()
        monthPIcker.delegate = self
        monthPIcker.dataSource = self
        monthTextField.inputView = monthPIcker
        datePicker.delegate = self
        datePicker.dataSource = self
        dateTextField.inputView = datePicker
        yearPicker.delegate = self
        yearPicker.dataSource = self
        yearTextField.inputView = yearPicker
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        year = (1990...currentYear).map { String($0) }
    }
    
    func setupElements() {
        //styles the text fields and buttons and creates a button on top of keyboard
        
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(usernameTextField)
        Utilities.styleTextField(monthTextField)
        Utilities.styleFilledButton(signupButton)
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        monthTextField.inputAccessoryView = toolbar
        dateTextField.inputAccessoryView = toolbar
        yearTextField.inputAccessoryView = toolbar
        usernameTextField.inputAccessoryView = toolbar
        emailTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        //stops keyboard editing
        self.view.endEditing(true)
    }
    
    
    
    func validateFields() -> String? {
        //checks if the text fields are empty
        if  emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || monthTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return("Please fill in all fields.")
        }
        var mol = 0
        switch monthTextField.text {
        case "January":
            mol = 1
        case "February":
            mol = 2
        case "March":
            mol = 3
        case "April":
            mol = 4
        case "May":
            mol = 5
        case "June":
            mol = 6
        case "July":
            mol = 7
        case "August":
            mol = 8
        case "September":
            mol = 9
        case "October":
            mol = 10
        case "November":
            mol = 11
        case "December":
            mol = 12
        default:
            mol = 0
        }
        let now = Date()
        let dateString = "\(yearTextField.text!) \(mol) \(dateTextField.text!)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)
        guard let birthday = date else { return "CANt get bday"}
        let calendar = Calendar.current
        print(calendar)
        
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        age = ageComponents.year!
        print("AGE: \(age!)")
        if(age! < 13 || age! > 21) {
            return("Sorry, you do not meet our age requirements.")
        }
        //checks if password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return("Please make sure that your password is at least 8 characters long and contains a number and special character.")
        }
        return nil
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
            
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            self.errorLabel.alpha = 1
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
                    db.collection("users").document("\(email)").setData([             "uid": result?.user.uid , "age": self.age,
                                                                                      "username": username,
                                                                                      
                    ]) { (error) in
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
            
        }
        
        
    }
    
}

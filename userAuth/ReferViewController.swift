//
//  ReferViewController.swift
//  userAuth
//
//  Created by athena on 6/23/20.
//  Copyright © 2020 athena. All rights reserved.
//

import UIKit
import MessageUI
import Firebase
import FirebaseAuth

class ReferViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var Button: UIButton!
    
    var email = ""
    var firstName = ""
    var lastName = ""
    var grade = ""
    var school = ""
    var currentUserFirstName = ""
    var currentUserLastName = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
     setUpElements()

    }
    func setUpElements() {
        //styles text fields
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
             Utilities.styleTextField(schoolTextField)
             Utilities.styleTextField(gradeTextField)
             Utilities.styleTextField(emailTextField)
             Utilities.styleFilledButton(Button)
        
        //sets a done button on top of keyboard to remove it
        
        //creates empty space on top of keyboard
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //creates button 
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        firstNameTextField.inputAccessoryView = toolbar
        lastNameTextField.inputAccessoryView = toolbar
        schoolTextField.inputAccessoryView = toolbar
        gradeTextField.inputAccessoryView = toolbar
        emailTextField.inputAccessoryView = toolbar

    }
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    
    
    @IBAction func referButtonTapped(_ sender: Any) {
        let refererEmail = Auth.auth().currentUser!.email ?? ""
       
        //creates a popup with email template to send mail to the friend to check out the app and sign up
        func sendEmail() {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                 firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                school = schoolTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                grade = gradeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                print(self.currentUserLastName, self.currentUserFirstName)

                mail.setPreferredSendingEmailAddress(refererEmail) //sets the from to the email listed before
                mail.setSubject("User Authentication Practice Referral!") //can change to whatever you need
                mail.setMessageBody("<!DOCTYPE HTML SYSTEM><html><body><p>Hello \(firstName),</p><br /><p>Your friend \(currentUserFirstName) \(currentUserLastName) has referred you to try out this app.</p> <a href=\"https://console.firebase.google.com/u/0/project/userauth-3d0c3/database/firestore/data~2Fusers~2Freferrals\">This is the link.</a><br /><p>The email of the referer is \(refererEmail)</p><br /><p>Thanks, and have a great day!</p></body></html>", isHTML: true)
                print(currentUserLastName, currentUserFirstName)
                /*can change to whatever you need, but it basically says:
                 Hello _________,
                 Your friend, _____, has referred you to try out this app. This is the link.
                 The email of the refer is ____________.
                 Thanks, and have a great day!
                 
                 (the link is embedded in that statement of the link and the link is currently the firebase.)
                */
                
                email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                print(email)
                
                mail.setToRecipients([email]) //sets the TO part of email to the email listed in the text field earlier

                present(mail, animated: true)
            } else {
                // show failure alert
                print("Error sending message")
            }
        }
        let currentUser = Auth.auth().currentUser!.email
        sendEmail()
        //sets data in users->referrals->person who sent the referral (email) -> referral person's data
        let db = Firestore.firestore()
        db.collection("users").document("referrals").collection("\(currentUser!)").document("\(email)").setData([
            "email" : email,
            "firstName": firstName,
            "lastName": lastName,
            "grade": grade,
            "school": school
        ]) { (error) in
            if let error = error {
                print("Error saving referral info: \(error.localizedDescription)")
            }else {
                print("Referral info saved!")
            }
        }
            }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
           case MFMailComposeResult.cancelled.rawValue :
               print("Cancelled")
           case MFMailComposeResult.failed.rawValue :
               print("Failed")
           case MFMailComposeResult.saved.rawValue :
               print("Saved")
           case MFMailComposeResult.sent.rawValue :
               print("Sent")
           default: break
           }
        
        controller.dismiss(animated: true) {
            print("dismissed")
            let vc = self.storyboard?.instantiateViewController(identifier: "homeVC")
            self.view.window?.rootViewController = vc
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

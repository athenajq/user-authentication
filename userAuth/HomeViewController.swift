//
//  HomeViewController.swift
//  userAuth
//
//  Created by athena on 6/23/20.
//  Copyright © 2020 athena. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        Utilities.styleHollowButton(logoutButton)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            let vc = storyboard!.instantiateViewController(withIdentifier: "navVC")
            view.window?.rootViewController = vc
        }catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
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

//
//  ViewController.swift
//  XuChat
//
//  Created by Ercan on 1.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInScene: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func signIn(_ sender: Any) {
        
        guard let mail = email.text , let pass = password.text else {return}
        
        Auth.auth().signIn(withEmail: mail, password: pass) { (result, error) in
            
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: Constant.toTabbar, sender: nil)
        }
    }
    
    fileprivate func showAlert(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            
        }
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
}


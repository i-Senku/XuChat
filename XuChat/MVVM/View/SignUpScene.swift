//
//  SignUpScene.swift
//  XuChat
//
//  Created by Ercan on 1.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpScene: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var nickName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let nickname = nickName.text, let email = email.text, let userID = Auth.auth().currentUser?.uid else {return}
        
        let vc = segue.destination as! SelectImageScene
        vc.userID = userID
        vc.nickName = nickname
        vc.mail = email
    }

    @IBAction func signUp(_ sender: Any) {
        
        guard let nickname = nickName.text, let email = email.text, let password = password.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            
            let request = result?.user.createProfileChangeRequest()
            request?.displayName = nickname
            
            request?.commitChanges(completion: { (error) in
                if error == nil {
                    self.performSegue(withIdentifier: Constant.segueToImage, sender: nil)
                }
            })
            
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

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
        //isLogin()
    }


    @IBAction func signIn(_ sender: Any) {
        
        guard let mail = email.text , let pass = password.text else {return}
        
        Auth.auth().signIn(withEmail: mail, password: pass) { (result, error) in
            
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let messageScene = storyBoard.instantiateViewController(withIdentifier: "messageScene") as! MessageScene
            
            self.present(messageScene, animated: true, completion: nil)

            
        }
    }
    
    fileprivate func showAlert(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            
        }
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func isLogin() {
        if let _ = Auth.auth().currentUser {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "messageScene") as! MessageScene
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}


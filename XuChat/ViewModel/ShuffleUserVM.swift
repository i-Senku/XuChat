//
//  UserViewModel.swift
//  XuChat
//
//  Created by Ercan on 2.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ShuffleUserVM {
    
    let db : Firestore!
    var userList = [User]()

    
    init() {
        db = Firestore.firestore()
    }
    
    func getUser(completionHandler : @escaping () -> ()){
        let userCollection = db.collection(Constant.userCollection)
        userCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            if let myID = Auth.auth().currentUser?.uid{
                for document in snapshot!.documents {
                    
                    if myID == document.data()["id"] as! String{
                        continue
                    }
                    self.userList.append(User(user: document.data()))
                }
                completionHandler()
            }else{
                return
            }
        }
    }
}


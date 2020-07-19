//
//  FireStoreHelper.swift
//  XuChat
//
//  Created by Ercan on 11.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FireStoreHelper{
    
    static let shared = FireStoreHelper()
    
    let currentID = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    
    //MARK:- Set Status For User ( Online or Offline )
    func setUserStatus(isOnline : Bool, permission : Bool, time : Timestamp){
        let data : [String : Any] = [
            "isOnline" : isOnline,
            "permission" : permission,
            "time" : time
        ]
        db.collection("UserStatus").document(currentID!).setData(data) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("User Status Güncellendi")
        }
    }
    
    //MARK:- Listen User Status ( Online or Offline )
    func userStatusListener(userID : String,completionHandler : @escaping (UserStatus)->()){
        db.collection("UserStatus").document(userID).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else {return}
            
            completionHandler(UserStatus(data: snapshot.data()))
        }
    }
    
    //MARK:- Get Current User Data For Last Message Scene
    func getMyUserData(completionHandler : @escaping (User)->() ){
        guard let ID = Auth.auth().currentUser?.uid else {return}
        
        db.collection(Constant.userCollection).whereField("id", isEqualTo: ID).getDocuments { (snapshot, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                
                snapshot.documents.forEach { (queryDocumentSnapshot) in
                    let user = User(user: queryDocumentSnapshot.data())
                    completionHandler(user)
                }
            }
        }
    }
}

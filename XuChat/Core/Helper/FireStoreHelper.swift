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
    
    
    var usersID : Set<String> = []
    var currentUser : User!
    let myID = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    
    //MARK:- Set Status For User ( Online or Offline )
    func setUserStatus(isOnline : Bool, permission : Bool, time : Timestamp){
        let data : [String : Any] = [
            "isOnline" : isOnline,
            "permission" : permission,
            "time" : time
        ]
        db.collection("UserStatus").document(myID!).setData(data) { (error) in
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
    
    //MARK:- Get Data of Current User For Last Message Scene
    func fetchCurrentUser(){
        guard let ID = Auth.auth().currentUser?.uid else {return}
        
        db.collection(Constant.userCollection).whereField("id", isEqualTo: ID).getDocuments { (snapshot, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                
                snapshot.documents.forEach { (queryDocumentSnapshot) in
                    let user = User(user: queryDocumentSnapshot.data())
                    self.currentUser = user
                }
            }
        }
    }
    //MARK:- Set FCM Notification
    
    func pushNotification(userID : String,userName : String, to : String,title : String,body : String, imageURL : String){
        
        let session = URLSession.shared
        
        let url = URL(string:"https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("key=AAAAmpUlSxQ:APA91bFywgokqIOG2c8LejqE638qCy5cQkD_NW0KIjX5YmkXfeMQ5s8b1GIDoHrbOV9qEV9iNhUKRbxv2nqJHQJVzXaj_xmHqI1NlkoYbEpLRL2_wKdhpToLhDgXoKhOtBE7hvOl1CMi", forHTTPHeaderField: "Authorization")
        
        let body : [String : Any] = [
            "to":to,
            "notification": [
                "title": title,
                "body": body,
                "badge": "0",
                "sound": "default"
            ],
            "content_available": true,
            "data" : [
                "userID" : userID,
                "userName" : userName,
                "imageURL" : imageURL
            ]
        ]
        
        print(body)
        
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
            
        session.uploadTask(with: request, from: bodyData) { (data, response, error) in
        }.resume()
        
    }
    
    //MARK:- Deallocate & Locate In Room
    
    func deallocateRoom(id : String){
        usersID.remove(id)
    }
    
    func locateRoom(id : String){
        usersID.insert(id)
    }
    
    fileprivate func removeWithID(id : String){
        db.collection(Constant.messageCollection).document(id).collection("Status").document(myID!).updateData(["isInRoom" : false])
    }
    
    func removeFromRoom(){
        usersID.forEach { (id) in
            removeWithID(id: id)
        }
    }

    

}

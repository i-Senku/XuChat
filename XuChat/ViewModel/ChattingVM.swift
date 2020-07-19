//
//  MessageVM.swift
//  XuChat
//
//  Created by Ercan on 4.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth

class ChattingVM{
    var messageList = [Message]()
    let db : Firestore!
    let currentID : String!
    let senderID : String!
    
    init(senderID : String) {
        db = Firestore.firestore()
        currentID = Auth.auth().currentUser!.uid
        self.senderID = senderID
    }
    
    //MARK:- Read Message in Chatting
    func readMessage(completionHandler : @escaping ()->()){
        
        db.collection("Message").document(currentID).collection(senderID).order(by: "time").limit(toLast: 20).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else {return}
            snapshot.documentChanges.forEach { (document) in
                if document.type == .added {
                    self.messageList.append(Message(message: document.document.data()))
                }
            }
            completionHandler()
        }
    }
    //MARK:- Write new message for current user and other user.
    func writeMessage(messageText:String){
        
        let myData : [String:Any] = [
            "myID" : currentID!,
            "senderID" : senderID!,
            "isMyMessage" : true,
            "messageText" : messageText,
            "time" : Timestamp(date: Date())
        ]
        
        let senderData : [String:Any] = [
            "myID" : currentID!,
            "senderID" : senderID!,
            "isMyMessage" : false,
            "messageText" : messageText,
            "time" : Timestamp(date: Date())
        ]

        
        db.collection("Message").document(currentID).collection(senderID).addDocument(data: myData) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Mesaj gönderildi")
        }
        
        db.collection("Message").document(senderID).collection(currentID).addDocument(data: senderData) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Mesaj karşıya yazdırıldı")
        }
        
    }
    //MARK:- Load more message when user scroll tableview
    func loadMore(count : Int, completionHandler : @escaping ()->() ){
        
        db.collection("Message").document(currentID).collection(senderID).order(by: "time").limit(toLast: count+10).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let documents = snapshot?.documents {
                self.messageList.removeAll()
                for document in documents {
                    self.messageList.append(Message(message: document.data()))
                }
            }
            completionHandler()
        }
    }
    
    func setWritingStatus(status: WritingUserStatus){
        
        let data : [String : Any] = ["isWriting" : status.isWriting,"time" : status.time]
        db.collection("Message").document(senderID).collection("Status").document(currentID).setData(data)
    }
    
    func writingStatusListener(completionHandler : @escaping (Bool) -> ()){
        db.collection("Message").document(currentID).collection("Status").document(senderID).addSnapshotListener { (snapshot, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else {return}
            
            if let status = snapshot.data()?["isWriting"] as? Bool {
                
                if status {
                    completionHandler(true)
                }else{
                    completionHandler(false)
                }
            }else{
                completionHandler(false)
            }
            
        }
    }
    
    func setLastMessage(userID : String, userImage : String, userName : String, lastMessage : String){
           
        let dataForMe : [String : Any] =
            [
                "lastMessage" : lastMessage,
                "time" : Timestamp(date: Date()),
                "userID" : userID,
                "userImage" : userImage,
                "userName" : userName
        ]
        
        db.collection(Constant.messageCollection).document(currentID).collection("LastMessage").document(senderID).setData(dataForMe)

        FireStoreHelper.shared.getMyUserData { (user) in
            let dataForUser : [String : Any] = [
                "lastMessage" : lastMessage,
                "time" : Timestamp(date: Date()),
                "userID" : user.userID,
                "userImage" : user.imageURL!,
                "userName" : user.userName!
            ]
            
            self.db.collection(Constant.messageCollection).document(self.senderID).collection("LastMessage").document(self.currentID).setData(dataForUser)
        }

    }
}

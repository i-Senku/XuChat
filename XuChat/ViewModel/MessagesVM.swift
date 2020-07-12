//
//  MessagesVM.swift
//  XuChat
//
//  Created by Ercan on 12.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MessagesVM{
    
    let db : Firestore
    let myID : String

    var lastMessageList = [MessageUser]()
    
    init() {
        db = Firestore.firestore()
        myID = Auth.auth().currentUser!.uid
        print(myID)
    }
    var lastDictionary : [String : MessageUser] = [String : MessageUser]()
    
    func getLastMessages(completionHandler : @escaping ()->() ){
        
        db.collection(Constant.messageCollection).document(myID).collection("LastMessage").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let _ = querySnapshot?.count {
                    guard let documents = querySnapshot?.documentChanges else {return}
                    documents.forEach { (document) in
                        
                        if document.type == .added || document.type == .modified {
                            let user = MessageUser(data: document.document.data())
                            self.lastDictionary[user.userID] = user
                            
                        }
                        
                        if document.type == .removed {
                            let user = MessageUser(data: document.document.data())
                            self.lastDictionary.removeValue(forKey: user.userID)
                        }
                    }
                    self.updateLastMessage()
            }
            completionHandler()
            
        }
        
    }
    
    func updateLastMessage(){
        let array = Array(lastDictionary.values)
        lastMessageList = array
    }
}

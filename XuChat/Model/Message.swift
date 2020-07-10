//
//  Message.swift
//  XuChat
//
//  Created by Ercan on 4.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import FirebaseFirestore

struct Message {
    let myID : String
    let senderID : String
    let isMyMessage : Bool
    let messageText : String
    let time : Timestamp
    
    init(message:[String:Any]) {
        self.myID = message["myID"] as! String
        self.senderID = message["senderID"] as! String
        self.isMyMessage = message["isMyMessage"] as! Bool
        self.messageText = message["messageText"] as! String
        self.time = message["time"] as! Timestamp
    }
}

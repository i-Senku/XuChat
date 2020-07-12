//
//  MessageUser.swift
//  XuChat
//
//  Created by Ercan on 12.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct MessageUser {
    
    let userID : String
    let userName : String
    let lastMessage : String
    let userImage : String
    let time : Timestamp
    
    init(data : [String : Any]) {
        self.userID = data["userID"] as! String
        self.userName = data["userName"] as! String
        self.lastMessage = data["lastMessage"] as! String
        self.userImage = data["userImage"] as! String
        self.time = data["time"] as! Timestamp
    }
    
}

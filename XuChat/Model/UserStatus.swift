//
//  WritingUserStatus.swift
//  XuChat
//
//  Created by Ercan on 11.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct UserStatus {
    
    let isOnline : Bool
    let permission : Bool
    let time : Timestamp
    
    init(data : [String : Any]?) {
        self.isOnline = data?["isOnline"] as! Bool
        self.permission = data?["permission"] as! Bool
        self.time = data?["time"] as! Timestamp
    }
}

//
//  WritingUser.swift
//  XuChat
//
//  Created by Ercan on 10.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import Foundation
import FirebaseFirestore

class WritingUserStatus{
    
    let isWriting : Bool
    let time : Timestamp
    
    init(isWriting : Bool,time : Timestamp) {
        self.isWriting = isWriting
        self.time = time
    }
    
}
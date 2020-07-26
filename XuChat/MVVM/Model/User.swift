//
//  User.swift
//  XuChat
//
//  Created by Ercan on 1.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//


struct User {
    
    let userID : String
    let token : String
    let userName : String?
    let userMail : String?
    let imageURL : String?
    let description : String?
    let city : String?
    let gender : String?
    let job : String?
    let isPremium : Bool?
    
    init(user : [String:Any]) {
        self.userID = user["id"] as! String
        self.userName = user["name"] as? String
        self.userMail = user["mail"] as? String
        self.imageURL = user["imageURL"] as? String
        self.description = user["description"] as? String
        self.city = user["city"] as? String
        self.gender = user["gender"] as? String
        self.job = user["job"] as? String
        self.isPremium = user["isPremium"] as? Bool
        self.token = user["token"] as! String
    }
}

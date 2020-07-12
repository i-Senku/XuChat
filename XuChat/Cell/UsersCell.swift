//
//  UsersCell.swift
//  XuChat
//
//  Created by Ercan on 2.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit

class UsersCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var lastMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lastMessage.numberOfLines = 2
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
    }
}

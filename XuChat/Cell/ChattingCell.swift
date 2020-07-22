//
//  ChattingCell.swift
//  XuChat
//
//  Created by Ercan on 4.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit

class ChattingCell: UITableViewCell {

    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageText: UILabel!
    var containerLeading: NSLayoutConstraint!
    var containerTrailing : NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerLeading.isActive = false
        containerTrailing.isActive = false
    }
    
    
    var isMe : Bool? {
        didSet{
            if let isMe = isMe {
                containerTrailing = containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -14)
                containerLeading = containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 14)
                
                if isMe {
                    containerTrailing.isActive = true
                    containerView.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                }else{
                    containerLeading.isActive = true
                    containerView.backgroundColor = .systemBackground
                }
                containerView.layer.cornerRadius = 15
            }
            
        }
    }

}

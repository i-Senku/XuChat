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
                    containerView.backgroundColor = #colorLiteral(red: 0.1273299348, green: 0.4323398344, blue: 0.9686274529, alpha: 1)
                    messageText.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                }else{
                    containerLeading.isActive = true
                    containerView.backgroundColor = .systemBackground
                    messageText.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
                }
                containerView.layer.cornerRadius = 15
            }
            
        }
    }

}

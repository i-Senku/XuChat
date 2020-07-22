//
//  ShuffleCell.swift
//  XuChat
//
//  Created by Ercan on 3.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit

class ShuffleCell: UITableViewCell {

    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var premiumImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
    }
}

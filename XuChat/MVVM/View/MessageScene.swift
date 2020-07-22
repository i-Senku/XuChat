//
//  MessageScene.swift
//  XuChat
//
//  Created by Ercan on 2.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseFirestore
import Kingfisher

class MessageScene: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let lastMessage = MessagesVM()
    
    let hud = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 85
        
        
        showProgress()
        
        lastMessage.getLastMessages {
            self.hud.dismiss(animated: true)
            self.tableView.reloadData()
        }
    }
    
    fileprivate func showProgress(){
        hud.textLabel.text = "Loading"
        hud.show(in: view)
    }
}

extension MessageScene : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lastMessage.lastMessageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.userCellName, for: indexPath) as! UsersCell
        
        let data = lastMessage.lastMessageList[indexPath.row]
        let hour = data.time.dateValue().get(.hour)
        let minute = data.time.dateValue().get(.minute)
        
        cell.userName.text = data.userName
        cell.time.text = "\(hour):\(minute)"
        
        
        cell.lastMessage.text = data.lastMessage
        
        let resource = ImageResource(downloadURL: URL(string: data.userImage)!, cacheKey: data.userImage)
        
        cell.profileImage.kf.setImage(with: resource)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    
}

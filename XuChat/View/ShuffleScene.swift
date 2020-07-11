//
//  MessageScene.swift
//  XuChat
//
//  Created by Ercan on 1.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Kingfisher
import JGProgressHUD

class ShuffleUserScene: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let hud = JGProgressHUD(style: .dark)
    let shuffleVM = ShuffleUserVM()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProgressHUD()
        shuffleVM.getUser {
            self.hud.dismiss(animated: true)
            self.tableView.reloadData()
        }
    }
    
    fileprivate func setProgressHUD(){
        hud.textLabel.text = "Loading"
        hud.show(in: view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChattingScene
        let id = sender as! String
        vc.userID = id
    }
    
    @IBAction func exit(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
            print("Tıklandı")
        } catch let e {
            print(e.localizedDescription)
        }
    }
    
}

extension ShuffleUserScene : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shuffleVM.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.shuffleCellName, for: indexPath) as! ShuffleCell
        
        let user = shuffleVM.userList[indexPath.row]
        
        cell.name.text = user.userName
        
        let url = URL(string: user.imageURL!)!
        let resource = ImageResource(downloadURL: url, cacheKey: user.imageURL!)
        cell.profileImage.kf.setImage(with: resource)
        
        cell.selectionStyle = .none
        
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = shuffleVM.userList[indexPath.row]
        performSegue(withIdentifier: Constant.segueToChattingFromShuffle, sender: list.userID)
    }
    
    
}
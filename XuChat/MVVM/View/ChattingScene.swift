//
//  ChattingScene.swift
//  XuChat
//
//  Created by Ercan on 4.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher
import FirebaseAuth

class ChattingScene: UIViewController {

    @IBOutlet weak var chattingTableView: UITableView!
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var container: UIView!
    
    let titleLabel = UILabel()
    let subTitle = UILabel()
    
    var navigationBarImage : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
    
    var refreshControl : UIRefreshControl = {
       let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshControl(sender:)), for: .valueChanged)
        return control
    }()
    
    @objc func refreshControl(sender : UIRefreshControl){
        count += 10
        messageVM.loadMore(count: count) { [weak self] in
            self?.chattingTableView.reloadData()
        }
        sender.endRefreshing()
    }
    
    var messageVM : ChattingVM!
    
    var userID : String?
    var userName : String?
    var myUserName : String!
    var token : String?
    var isRoom = false
    
    var resource : ImageResource?
    var count = 15
    
        
    func setupUIScene(){
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(foreground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(foreground), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIScene()
        messageText.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        chattingTableView.refreshControl = refreshControl
        initConfiguration()
        keyboardResponder()
        setNavigationBarTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        myUserName = Auth.auth().currentUser?.displayName!
        navigationBarImage.kf.setImage(with: resource)
        animationKeyboard()
        messageVM = ChattingVM(senderID: userID!)
        readAllMessage()
        userStatusListener()
        messageVM.setWritingStatus(status: WritingUserStatus(isWriting: false, time: Timestamp(date: Date()), isInRoom: true))
        FireStoreHelper.shared.locateRoom(id: userID!)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        titleLabel.removeFromSuperview()
        subTitle.removeFromSuperview()
        navigationBarImage.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        FireStoreHelper.shared.deallocateRoom(id: userID!)
        messageVM.setWritingStatus(status: WritingUserStatus(isWriting: false, time: Timestamp(date: Date()), isInRoom: false))
    }
    
    @objc func foreground(){
        print("Açıldı")
        let isWrite = messageText.text.count>0
        messageVM.setWritingStatus(status: WritingUserStatus(isWriting: isWrite, time: Timestamp(date: Date()), isInRoom: true))
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        guard let message = messageText.text else { return }
        
        messageVM.writeMessage(messageText: message.trimmingCharacters(in: .whitespacesAndNewlines))
        
        if let userID = userID, let myID = Auth.auth().currentUser?.uid, let image = resource?.downloadURL.absoluteString, let userName = userName, let message = messageText.text , let to = token{
            
            messageVM.setLastMessage(userID: userID, userImage: image, userName: userName, lastMessage: message)
            
            if !isRoom {
                let user = FireStoreHelper.shared.currentUser!
                FireStoreHelper.shared.pushNotification(userID: myID, userName: myUserName, to: to, title: myUserName, body: message, imageURL: user.imageURL!)
            }
        }
        
        messageText.text = ""
        textViewHeight.constant = messageText.contentSize.height
        messageText.becomeFirstResponder()
        textViewDidEndEditing(messageText)
    }
}

//MARK:- Configuration other methods
extension ChattingScene{
    
    fileprivate func animationKeyboard(){
        let width = UIScreen.main.bounds.width
        container.transform = CGAffineTransform(translationX: width, y: .zero)
        
        UIView.animate(withDuration: 0.7) {
            self.container.transform = .identity
        }
    }
    
    fileprivate func initConfiguration(){
        chattingTableView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        chattingTableView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func endEditing(){
         messageText.endEditing(true)
    }
    
    fileprivate func setNavigationBarTitle(){
        
        if let navigationBar = navigationController?.navigationBar {
        
            titleLabel.text = userName!
            titleLabel.font = .boldSystemFont(ofSize: 17)
            
            subTitle.text = "Status"
            subTitle.font = .systemFont(ofSize: 13, weight: .semibold)
            subTitle.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                        
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            subTitle.translatesAutoresizingMaskIntoConstraints = false
            
            navigationBar.addSubview(navigationBarImage)
            navigationBar.addSubview(subTitle)
            navigationBar.addSubview(titleLabel)
            
            navigationBarImage.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor,constant: 50).isActive = true
            navigationBarImage.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor).isActive = true
            navigationBarImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
            navigationBarImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            
            titleLabel.topAnchor.constraint(equalTo: navigationBarImage.topAnchor).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: navigationBarImage.trailingAnchor,constant: 8).isActive = true
            
            
            
            subTitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 0).isActive = true
            subTitle.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        
        }
        
    }
    
    fileprivate func readAllMessage(){
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
            messageVM.readMessage(){
                self.chattingTableView.reloadData()
                if self.messageVM.messageList.count != 0 {
                    let indexPath = IndexPath(row: self.messageVM.messageList.count-1, section: 0)
                    self.chattingTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        
    }
    
    fileprivate func keyboardResponder(){
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func showKeyboard(keyboard : Notification){
        if let keyboardValue = keyboard.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            
            let keyboardFrame = keyboardValue.cgRectValue
            chattingTableView.frame.size = CGSize(width: chattingTableView.frame.size.width, height: view.safeAreaInsets.bottom - keyboardFrame.size.height)
            self.view.frame.origin.y = view.safeAreaInsets.bottom - keyboardFrame.size.height
        }
    }
    
    @objc func hideKeyboard(keyboard: Notification){
        self.view.frame.origin.y = 0
    }
    
}

//MARK:- TableView Methods
extension ChattingScene : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageVM.messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chattingCell", for: indexPath) as! ChattingCell
        let message = messageVM.messageList[indexPath.row]
        
        //Time Message
        let minute = message.time.dateValue().get(.minute)
        let hour = message.time.dateValue().get(.hour)

        cell.messageText.text = message.messageText
        cell.isMe = message.isMyMessage
        cell.messageTime.text = "\(hour):\(minute)"
        
        return cell
    }
    
}

//MARK:- TextViewDelegate Methods
extension ChattingScene : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textViewHeight.constant = textView.contentSize.height
        if messageVM.messageList.count > 1 {
            chattingTableView.scrollToRow(at: IndexPath(row: messageVM.messageList.count-1, section: 0), at: .bottom, animated: true)
        }
        
        if messageText.text.count > 0 && messageText.text.count == 1  {
            textViewDidBeginEditing(textView)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Çalışıyor")
        messageVM.setWritingStatus(status: WritingUserStatus(isWriting: true, time: Timestamp(date: Date()), isInRoom: true))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        messageVM.setWritingStatus(status: WritingUserStatus(isWriting: false, time: Timestamp(date: Date()), isInRoom: true))
    }
    
}

extension ChattingScene {
    
    fileprivate func userStatusListener(){
        guard let id = userID else {
            return
        }
        
        FireStoreHelper.shared.userStatusListener(userID: id) { (status) in
            
            if status.permission {
                
                if status.isOnline {
                    
                    self.messageVM.writingStatusListener { (isWrite,isInRoom) in
                        self.isRoom = isInRoom
                         if isWrite {
                            self.subTitle.text = "Yazıyor..."
                        }else{
                            self.subTitle.text = "Çevrimiçi"
                        }
                    }
                    
                }else{
                    
                    let minute = status.time.dateValue().get(.minute)
                    let hour = status.time.dateValue().get(.hour)
                    
                    self.subTitle.text = "Son Görülme : \(hour):\(minute)"
                }
            }else{
                self.subTitle.text = ""
            }
        }
    }
}

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
    
    var messageVM : MessageVM!
    
    var userID : String?
    var userName : String?
    var resource : ImageResource?
    var paginationCounter = 3
        
    override func viewDidLoad() {
        super.viewDidLoad()

        messageText.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        keyboardResponder()
        setNavigationBarTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationBarImage.kf.setImage(with: resource)
        animationKeyboard()
        messageVM = MessageVM(senderID: userID!)
        readAllMessage()
        messageVM.writingStatusListener { (status) in
            if status {
                self.subTitle.text = "Yazıyor..."
            }else{
                self.subTitle.text = "Çevrimiçi"
            }
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        titleLabel.removeFromSuperview()
        subTitle.removeFromSuperview()
        navigationBarImage.removeFromSuperview()
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        guard let message = messageText.text else { return }
        
        messageVM.writeMessage(messageText: message.trimmingCharacters(in: .whitespacesAndNewlines))
        
        messageText.text = ""
        textViewHeight.constant = messageText.contentSize.height
        messageText.becomeFirstResponder()
        view.endEditing(true)
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
    
    fileprivate func setNavigationBarTitle(){
        
        if let navigationBar = navigationController?.navigationBar {
        
            titleLabel.text = userName!
            titleLabel.font = .boldSystemFont(ofSize: 17)
            
            subTitle.text = "Status"
            subTitle.font = .systemFont(ofSize: 13)
            subTitle.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                        
            
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
        cell.messageText.text = message.messageText
        cell.isMe = message.isMyMessage
        return cell
    }

    //MARK: Load More Data
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        print(maxOffset)
        print(currentOffset)
        if maxOffset > currentOffset * CGFloat(paginationCounter) {
            paginationCounter += 2
            print("girdi")
            messageVM.loadMore(count: messageVM.messageList.count) {
                self.chattingTableView.reloadData()
            }
        }
    }
    
}

//MARK:- TextViewDelegate Methods
extension ChattingScene : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textViewHeight.constant = textView.contentSize.height
        if messageVM.messageList.count > 1 {
            chattingTableView.scrollToRow(at: IndexPath(row: messageVM.messageList.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        messageVM.writingStatus(status: UserStatus(isWriting: true, time: Timestamp(date: Date())))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        messageVM.writingStatus(status: UserStatus(isWriting: false, time: Timestamp(date: Date())))
    }
    
}

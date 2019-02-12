//
//  ChatViewController.swift
//  CocoaTalk
//
//  Created by Cocoa on 2019. 2. 11..
//  Copyright © 2019년 ksjung. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var message_textfield: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var uid: String?
    var chatRoomUid: String?
    var comments: [ChatModel.Comment] = []
    var userModel: UserModel?
    
    public var destinationUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
        self.tabBarController?.tabBar.isHidden = true
        
        let tab: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tab)
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = keyboardSize.height
        }
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }) { (completion) in
            if self.comments.count > 0 {
                self.tableview.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func createRoom() {
        let createRoomInfo = [ "users":[
            uid: true,
            destinationUid: true
            ]
        ]
        
        if(chatRoomUid == nil){ // 방 생성 코드
            
            self.sendButton.isEnabled = false
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo) { (err, ref) in
                
                if(err == nil){
                    self.checkChatRoom()
                }
            }
            
            
        }else {
            let message_value = [
                "uid": uid,
                "message": message_textfield.text
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(message_value) { (err, ref) in
                self.message_textfield.text = ""
            }
        }
    }
    
    func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                
                if let chatRoomdic = item.value as? [String:AnyObject]{
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    if(chatModel?.users[self.destinationUid!] == true){
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getDestinationInfo()
                    }
                }
            }
        }
    }
    
    func getDestinationInfo() {
        
        Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(datasnapshot.value as! [String : Any])
            self.getMessageList()
        }
    }
    
    func getMessageList() {
        
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value) { (datasnapshot) in
            
            self.comments.removeAll()
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                let comment = ChatModel.Comment(JSON: item.value as! [String : AnyObject])
                self.comments.append(comment!)
            }
            self.tableview.reloadData()
            
            if self.comments.count > 0 {
                self.tableview.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(self.comments[indexPath.row].uid == uid){
            let view = tableview.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.label_message.text = self.comments[indexPath.row].message
            view.label_message.numberOfLines = 0
            return view
        }else {
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.label_name.text = userModel?.userName
            view.label_message.text = self.comments[indexPath.row].message
            view.label_message.numberOfLines = 0
            
            let url = URL(string: (userModel?.profileImageUrl)!)
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                
                DispatchQueue.main.async {
                    view.imageview_profile.image = UIImage(data: data!)
                    view.imageview_profile.layer.cornerRadius = view.imageview_profile.frame.width/2
                    view.imageview_profile.clipsToBounds = true
                }
                
            }.resume()
            return view
        }
        //return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class MyMessageCell: UITableViewCell {
    
    @IBOutlet weak var label_message: UILabel!
}

class DestinationMessageCell: UITableViewCell {
    
    @IBOutlet weak var label_message: UILabel!
    @IBOutlet weak var imageview_profile: UIImageView!
    @IBOutlet weak var label_name: UILabel!
}


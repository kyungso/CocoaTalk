//
//  GroupChatRoomViewController.swift
//  CocoaTalk
//
//  Created by Cocoa on 2019. 2. 16..
//  Copyright © 2019년 ksjung. All rights reserved.
//

import UIKit
import Firebase

class GroupChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var message_textfield: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var destinationRoom: String?
    var uid: String?
    var comments: [ChatModel.Comment] = []
    var users: [String:AnyObject]?
    var peopleCount: Int?
    
    var databaseRef: DatabaseReference?
    var observe: UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            
            self.users = datasnapshot.value as? [String:AnyObject]
        
        }
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        getMessageList()
        
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
        
        databaseRef?.removeObserver(withHandle: observe!)
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
    
    @objc func sendMessage() {
        
        let value: Dictionary<String,Any> = [
            "uid": uid!,
            "message": message_textfield.text!,
            "timestamp": ServerValue.timestamp()
        ]
        
        Database.database().reference().child("chatrooms").child(destinationRoom!).child("comments").childByAutoId().setValue(value) { (err, ref) in
            self.message_textfield.text = ""
        }
    }
    
    func setReadCount(label: UILabel?, position: Int?) {
        
        let readCount = self.comments[position!].readUsers.count
        if(peopleCount == nil) {
            Database.database().reference().child("chatrooms").child(destinationRoom!).child("users").observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
                let dic = datasnapshot.value as! [String:Any]
                self.peopleCount = dic.count
                let noReadCount = self.peopleCount! - readCount
                
                if(noReadCount > 0) {
                    label?.isHidden = false
                    label?.text = String(noReadCount)
                }else {
                    label?.isHidden = true
                }
            }
        } else {
            let noReadCount = self.peopleCount! - readCount
            
            if(noReadCount > 0) {
                label?.isHidden = false
                label?.text = String(noReadCount)
            }else {
                label?.isHidden = true
            }
        }
    }
    
    func getMessageList() {
        
        databaseRef = Database.database().reference().child("chatrooms").child(self.destinationRoom!).child("comments")
        observe = databaseRef!.observe(DataEventType.value, with: { (datasnapshot) in
            
            self.comments.removeAll()
            
            var readUserDic: Dictionary<String,AnyObject> = [:]
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                let key = item.key as String
                let comment = ChatModel.Comment(JSON: item.value as! [String : AnyObject])
                let comment_motify = ChatModel.Comment(JSON: item.value as! [String : AnyObject])
                comment_motify?.readUsers[self.uid!] = true
                readUserDic[key] = comment_motify?.toJSON() as! NSDictionary
                self.comments.append(comment!)
            }
            
            let nsDic = readUserDic as NSDictionary
            
            if (self.comments.last?.readUsers.keys == nil){
                return
            }
            
            if !((self.comments.last?.readUsers.keys.contains(self.uid!))!) {
                datasnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                    self.tableview.reloadData()
                    
                    if self.comments.count > 0 {
                        self.tableview.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                    }
                })
            } else {
                self.tableview.reloadData()
                
                if self.comments.count > 0 {
                    self.tableview.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(self.comments[indexPath.row].uid == uid){
            let view = tableview.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.label_message.text = self.comments[indexPath.row].message
            view.label_message.numberOfLines = 0
            
            if let time = self.comments[indexPath.row].timestamp {
                view.label_timestamp.text = time.toDayTime
            }
            
             setReadCount(label: view.label_read_counter, position: indexPath.row)
            
            return view
            
        }else {
            let destinationUser = users![self.comments[indexPath.row].uid!]
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.label_name.text = destinationUser!["userName"] as! String
            view.label_message.text = self.comments[indexPath.row].message
            view.label_message.numberOfLines = 0
            
            let imageUrl = destinationUser!["profileImageUrl"] as! String
            let url = URL(string: imageUrl)
            view.imageview_profile.layer.cornerRadius = view.imageview_profile.frame.width/2
            view.imageview_profile.clipsToBounds = true
            view.imageview_profile.kf.setImage(with: url)
            
            if let time = self.comments[indexPath.row].timestamp {
                view.label_timestamp.text = time.toDayTime
            }
            
            setReadCount(label: view.label_read_counter, position: indexPath.row)
            
            return view
        }
        return UITableViewCell()
    }
    
}

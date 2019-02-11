//
//  ChatViewController.swift
//  CocoaTalk
//
//  Created by Cocoa on 2019. 2. 11..
//  Copyright © 2019년 ksjung. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var message_textfield: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var uid: String?
    var chatRoomUid: String?
    
    public var destinationUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
       
        checkChatRoom()
    }

    @objc func createRoom() {
        let createRoomInfo = [ "users":[
            uid: true,
            destinationUid: true
            ]
        ]
        
        if(chatRoomUid == nil){
            // 방 생성 코드
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)
        }else {
            let message_value = [ "comments": [
                "uid": uid,
                "message": message_textfield.text
                ]
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(message_value)
        }
    }
    
    func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                self.chatRoomUid = item.key
            }
        }
    }
}

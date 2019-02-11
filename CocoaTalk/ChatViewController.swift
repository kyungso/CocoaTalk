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

    @IBOutlet weak var sendButton: UIButton!
    
    public var destinationUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
       
    }

    @objc func createRoom() {
        let createRoomInfo = [
            "uid": Auth.auth().currentUser?.uid,
            "destinationUid": destinationUid
        ]
        Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)
    }
}

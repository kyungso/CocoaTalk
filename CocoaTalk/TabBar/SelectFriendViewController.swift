//
//  SelectFriendViewController.swift
//  CocoaTalk
//
//  Created by Cocoa on 2019. 2. 16..
//  Copyright © 2019년 ksjung. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox

class SelectFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BEMCheckBoxDelegate {

    var users: Dictionary<String,Bool> = [:]
    var array: [UserModel] = []
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var chatroom_button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Database.database().reference().child("users").observe(DataEventType.value) { (snapshot) in
            
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                
                userModel.setValuesForKeys(fchild.value as! [String : Any])
                
                if(userModel.uid == myUid){
                    continue
                }
                self.array.append(userModel)
            }
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
        
        chatroom_button.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        view.labelName.text = array[indexPath.row].userName
        view.imageviewProfile.kf.setImage(with: URL(string: array[indexPath.row].profileImageUrl!))
        view.checkbox.delegate = self
        view.checkbox.tag = indexPath.row
        
        return view
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        //체크박스가 체크 됬을 때 발생하는 이벤트
        if(checkBox.on){
            users[self.array[checkBox.tag].uid!] = true
        }else {
            users.removeValue(forKey: self.array[checkBox.tag].uid!)
        }
    }
    
    @objc func createRoom() {
        let myUid = Auth.auth().currentUser?.uid
        users[myUid!] = true
        let nsDic = users as NSDictionary
        
        Database.database().reference().child("chatrooms").childByAutoId().child("users").setValue(nsDic)
    }

}

class SelectFriendCell: UITableViewCell {
    
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var imageviewProfile: UIImageView!
    @IBOutlet weak var labelName: UILabel!
}

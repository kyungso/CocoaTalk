//
//  AccountViewController.swift
//  CocoaTalk
//
//  Created by Cocoa on 2019. 2. 13..
//  Copyright © 2019년 ksjung. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

    @IBOutlet weak var conditionsCommentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conditionsCommentButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    }
    
    @objc func showAlert() {
        
        let alertController = UIAlertController(title: "상태 메세지", message: nil
            , preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "상태메세지를 입력해주세요."
        }
        alertController.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (action) in
            
            if let textfield = alertController.textFields?.first{
                let dic = ["comment":textfield.text!]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
            }
            
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: { (action) in
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }

}

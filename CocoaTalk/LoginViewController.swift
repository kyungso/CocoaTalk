//
//  LoginViewController.swift
//  CocoaTalk
//
//  Created by Cocoa on 2019. 2. 7..
//  Copyright © 2019년 ksjung. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUp: UIButton!
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        try! Auth.auth().signOut()
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.height.equalTo(20)
        }
        color = remoteConfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color!)
        loginButton.backgroundColor = UIColor(hex: color!)
        signUp.backgroundColor = UIColor(hex: color!)
        
        loginButton.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        signUp.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil) {
                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func loginEvent() {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user
            , error) in
            
            if(error != nil) {
                let alert = UIAlertController(title: "에러", message: error.debugDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func presentSignup() {
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.present(signupVC, animated: true, completion: nil)
    }
    
}

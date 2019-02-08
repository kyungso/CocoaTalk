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

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUp: UIButton!
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        signUp.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        
    }
    
    @objc func presentSignup() {
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.present(signupVC, animated: true, completion: nil)
    }
    
}

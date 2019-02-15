
//
//  MainViewController.swift
//  CocoaTalk
//
//  Created by Cocoa on 2019. 2. 9..
//  Copyright © 2019년 ksjung. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Kingfisher

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var array: [UserModel] = []
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PeopleTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(20)
            make.left.bottom.right.equalTo(view)

        }

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
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PeopleTableViewCell

        let imageView = cell.imageview
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(10 )
            make.width.height.equalTo(50)
        }

        let url = URL(string: array[indexPath.row].profileImageUrl!)!
        imageView.layer.cornerRadius = 50/2
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: url)

        let label = cell.label
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(imageView.snp.right).offset(20)
        }
        label.text = array[indexPath.row].userName

        let label_comment = cell.label_comment
        label_comment.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell.uiview_comment_background)
            make.centerX.equalTo(cell.uiview_comment_background)
        }
        //not exist comment
        if let comment = array[indexPath.row].comment {
            label_comment.text = comment
        }
        cell.uiview_comment_background.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.right.equalTo(cell).offset(-10)
            if let count = label_comment.text?.count {
                make.width.equalTo(count * 10)
            } else {
                make.width.equalTo(0)
            }
            make.height.equalTo(30)
        }
        cell.uiview_comment_background.backgroundColor = UIColor.gray
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatView = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        chatView.destinationUid = self.array[indexPath.row].uid
        self.navigationController?.pushViewController(chatView, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class PeopleTableViewCell: UITableViewCell {
    var imageview: UIImageView = UIImageView()
    var label: UILabel = UILabel()
    var label_comment: UILabel = UILabel()
    var uiview_comment_background: UIView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageview)
        self.addSubview(label)
        self.addSubview(uiview_comment_background)
        self.addSubview(label_comment)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


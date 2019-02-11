
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

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var array: [UserModel] = []
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(20)
            make.left.bottom.right.equalTo(view)

        }

        Database.database().reference().child("users").observe(DataEventType.value) { (snapshot) in

            self.array.removeAll()

            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let userModel = UserModel()

                userModel.setValuesForKeys(fchild.value as! [String : Any])
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

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let imageView = UIImageView()
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(10)
            make.width.height.equalTo(50)
        }

        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { (data, response, err) in

            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!)
                imageView.layer.cornerRadius = imageView.frame.size.width/2
                imageView.clipsToBounds = true
            }
        }.resume()

        let label = UILabel()
        cell.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(imageView.snp.right).offset(20)
        }
        label.text = array[indexPath.row].userName

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatView = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController")
        self.navigationController?.pushViewController(chatView!, animated: true)
    }
}


//
//  ChatModel.swift
//  CocoaTalk
//
//  Created by Cocoa on 2019. 2. 11..
//  Copyright © 2019년 ksjung. All rights reserved.
//

import UIKit

class ChatModel: NSObject {

    public var users: Dictionary<String,Bool> = [:]       //채팅방에 참여한 사람들
    public var comments: Dictionary<String,Comment> = [:] //채팅방의 대화 내용
    
    public class Comment {
        public var uid: String?
        public var message: String?
    }
    
}

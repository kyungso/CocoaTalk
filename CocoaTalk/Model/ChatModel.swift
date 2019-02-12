//
//  ChatModel.swift
//  CocoaTalk
//
//  Created by Cocoa on 2019. 2. 11..
//  Copyright © 2019년 ksjung. All rights reserved.
//

import ObjectMapper

class ChatModel: Mappable {
    
    public var users: Dictionary<String,Bool> = [:]       //채팅방에 참여한 사람들
    public var comments: Dictionary<String,Comment> = [:] //채팅방의 대화 내용
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    
    public class Comment: Mappable {
        public var uid: String?
        public var message: String?
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
        }
    }
    
}

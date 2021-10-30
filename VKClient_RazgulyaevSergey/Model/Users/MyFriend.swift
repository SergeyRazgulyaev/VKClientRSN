//
//  MyFriend.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

struct MyFriend {
    let friendName: String
    let friendAvatarURL: String
    let friendID: Int
    
    init(friendName: String, friendAvatarURL: String, friendID: Int) {
        self.friendName = friendName
        self.friendAvatarURL = friendAvatarURL
        self.friendID = friendID
    }
}

//
//  MyGroup.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

struct MyGroup {
    let groupName: String
    let groupAvatarURL: String
    let groupID: Int
    
    init(groupName: String, groupAvatarURL: String, groupID: Int) {
        self.groupName = groupName
        self.groupAvatarURL = groupAvatarURL
        self.groupID = groupID
    }
}

//
//  UserResponse.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class UserResponse: Decodable {
    var count: Int = 0
    var items: [UserItem]?
}

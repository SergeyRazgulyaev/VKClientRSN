//
//  PhotoLikes.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class PhotoLikes: Object, Decodable {
    @objc dynamic var count: Int = 0
    @objc dynamic var userLikes: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case count
        case userLikes = "user_likes"
    }
}

//
//  UserItem.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class UserItem: Object, Decodable {
    @objc dynamic var city: UserCity?
    @objc dynamic var firstName: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var lastName: String = ""
    @objc dynamic var sex: Int = 0
    @objc dynamic var photo100: String = ""
    
    enum CodingKeys: String, CodingKey {
        case city
        case firstName = "first_name"
        case id
        case lastName = "last_name"
        case sex
        case photo100 = "photo_100"
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    override class func indexedProperties() -> [String] {
        ["firstName", "lastName"]
    }
}

//
//  GroupItem.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class GroupItem: Object, Decodable {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var photo100: String = ""
    @objc dynamic var screenName: String = ""
    @objc dynamic var type: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case photo100 = "photo_100"
        case screenName = "screen_name"
        case type
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

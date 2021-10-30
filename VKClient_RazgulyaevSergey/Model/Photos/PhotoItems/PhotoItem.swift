//
//  PhotoItem.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class PhotoItem: Object, Decodable {
    @objc dynamic var albumID: Int = 0
    @objc dynamic var date: Double = 0
    @objc dynamic var id: Int = 0
    @objc dynamic var likes: PhotoLikes?
    @objc dynamic var ownerID: Int = 0
    var sizes = List<PhotoSize>()
    
    enum CodingKeys: String, CodingKey {
        case albumID = "album_id"
        case date
        case id
        case likes
        case ownerID = "owner_id"
        case sizes
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

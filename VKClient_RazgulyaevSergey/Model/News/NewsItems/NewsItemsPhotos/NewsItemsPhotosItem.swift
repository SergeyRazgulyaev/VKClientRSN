//
//  NewsItemsPhotosItem.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class NewsItemsPhotosItem: Decodable {
    var date: Double = 0
    var id: Int = 0
    var ownerID: Int = 0
    var sizes: [NewsItemsPhotosItemsSize]
    var likes: NewsItemsPhotosLikes
    var reposts: NewsItemsPhotosReposts
    var comments: NewsItemsPhotosComments
    
    enum CodingKeys: String, CodingKey {
        case date
        case id
        case ownerID = "owner_id"
        case sizes
        case likes
        case reposts
        case comments
    }
}

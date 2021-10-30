//
//  NewsAttachmentsPhoto.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class NewsAttachmentsPhoto: Decodable {
    var date: Double = 0
    var id: Int = 0
    var ownerID: Int = 0
    var sizes: [NewsAttachmentsPhotoAndVideoSizes]
    
    enum CodingKeys: String, CodingKey {
        case date
        case id
        case ownerID = "owner_id"
        case sizes = "sizes"
    }
}


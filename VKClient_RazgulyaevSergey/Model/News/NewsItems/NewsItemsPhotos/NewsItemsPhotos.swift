//
//  NewsItemsPhotos.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class NewsItemsPhotos: Decodable {
    var count: Int = 0
    var items: [NewsItemsPhotosItem]
}


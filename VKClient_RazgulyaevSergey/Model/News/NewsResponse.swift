//
//  NewsResponse.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class NewsResponse: Decodable {
    var items: [NewsItem]
    var profiles: [NewsProfile]
    var groups: [NewsGroup]
    var newsResponseNewOffset: String?
    var nextFrom: String?
    
    enum CodingKeys: String, CodingKey {
        case items
        case profiles
        case groups
        case newsResponseNewOffset = "new_offset"
        case nextFrom = "next_from"
    }

    init(items: [NewsItem], profiles: [NewsProfile], groups: [NewsGroup], newsResponseNewOffset: String, nextFrom: String) {
        self.items = items
        self.profiles = profiles
        self.groups = groups
        self.newsResponseNewOffset = newsResponseNewOffset
        self.nextFrom = nextFrom
    }
}

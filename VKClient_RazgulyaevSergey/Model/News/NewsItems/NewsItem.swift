//
//  NewsItem.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class NewsItem: Decodable {
    var sourceID: Int = 0
    var date: Double = 0
    var photos: NewsItemsPhotos?
    var text: String?
    var newsCopyHistory: [NewsCopyHistory]?
    var newsAttachments: [NewsAttachments]?
    var likes: NewsLikes
    var comments: NewsComments
    var reposts: NewsReposts
    var views: NewsItemsViews
    var type: String?
    var postID: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case sourceID = "source_id"
        case date
        case photos
        case text
        case newsCopyHistory = "copy_history"
        case newsAttachments = "attachments"
        case likes
        case comments
        case reposts
        case views
        case type
        case postID = "post_id"
    }
}

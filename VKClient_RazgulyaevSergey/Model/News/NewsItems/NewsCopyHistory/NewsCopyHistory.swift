//
//  NewsCopyHistory.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class NewsCopyHistory: Decodable {
    var id: Int = 0
    var date: Double = 0
    var postType: String?
    var text: String?
    var newsAttachments: [NewsAttachments]?

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case postType = "post_type"
        case text
        case newsAttachments = "attachments"
    }
}

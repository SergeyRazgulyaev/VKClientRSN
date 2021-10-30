//
//  NewsAttachments.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class NewsAttachments: Decodable {
    var type: String?
    var photo: NewsAttachmentsPhoto?
    var link: NewsAttachmentsLink?
    var video: NewsAttachmentsVideo?
}

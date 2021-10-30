//
//  NewsAttachmentsLink.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 22.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class NewsAttachmentsLink: Decodable {
    var url: String = ""
    var title: String = ""
    var caption: String?
    var photo: NewsAttachmentsPhoto?
}

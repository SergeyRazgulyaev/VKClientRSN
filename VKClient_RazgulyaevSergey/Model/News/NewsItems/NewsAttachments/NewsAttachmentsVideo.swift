//
//  NewsAttachmentsVideo.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 07.10.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class NewsAttachmentsVideo: Decodable {
    var date: Double = 0
    var image: [NewsAttachmentsPhotoAndVideoSizes]?
}

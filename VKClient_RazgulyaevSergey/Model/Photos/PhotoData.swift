//
//  PhotoData.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

struct PhotoData {
    let photoNumber: Int
    let photoCardURL: String
    
    init(photoNumber: Int, photoCardURL: String) {
        self.photoNumber = photoNumber
        self.photoCardURL = photoCardURL
    }
}

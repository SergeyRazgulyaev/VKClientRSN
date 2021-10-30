//
//  GroupResponse.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class GroupResponse: Decodable {
    let count: Int = 0
    let items: [GroupItem]?
}

//
//  UserCity.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class UserCity: Object, Decodable {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
}

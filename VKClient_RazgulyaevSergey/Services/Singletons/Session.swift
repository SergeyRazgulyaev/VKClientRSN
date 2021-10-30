//
//  Session.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 07.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class Session {
    var token: String = ""
    var userID: Int = 0
    var newsNextFrom: String = ""
    
    static let instance = Session()
    private init(){}
}

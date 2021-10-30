//
//  ParseFriendsData.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 24.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation

class ParseFriendsData: Operation {
    private(set) var outputData: [UserItem] = []
    
    override func main() {
        guard let getDataOperation = dependencies.first as? ​GetDataOperation​,
              let data = getDataOperation.data else { return }
        guard let friends = try? JSONDecoder().decode(User.self, from: data).response?.items else { return }
        outputData = friends
    }
}

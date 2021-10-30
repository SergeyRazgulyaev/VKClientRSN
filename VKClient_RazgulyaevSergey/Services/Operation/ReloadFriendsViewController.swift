//
//  ReloadTableOfFriendsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 24.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation


class ReloadTableOfFriendsViewController: Operation {
    var controller: FriendsViewController
    
    init(controller: FriendsViewController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseData = dependencies.first as? ParseFriendsData else { return }
        controller.writeFriendsFromNetworkToRealm(writedObjects: parseData.getOutputData())
//        print("parseData.outputData\n \(parseData.outputData)")
        controller.tableView.reloadData()
    }
}

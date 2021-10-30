//
//  NetworkServicePromise.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 27.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import PromiseKit

class NetworkServicePromise {
    //MARK: - Properties for Interaction with Network
    private let baseUrl: String = "https://api.vk.com"
    private let apiVersion: String = "5.124"
    
    static let sessionAFPromise: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        let session = Alamofire.Session(configuration: configuration)
        return session
    }()
    
    //MARK: - Method for loading Information about Groups with Promise
    func loadGroupsPromise(token: String, on queue: DispatchQueue = .main) -> Promise<[GroupItem]> {
        let path = "/method/groups.get"
        
        let params: Parameters = [
            "access_token": token,
            "extended": 1,
            "v": apiVersion
        ]
        
        return Promise { resolver in
            NetworkServicePromise.sessionAFPromise.request(baseUrl + path, method: .get, parameters: params).responseData { response in
                switch response.result {
                case let .success(data):
                    guard let groups = try? JSONDecoder().decode(Group.self, from: data).response?.items else { return }
                    resolver.fulfill(groups)
                case let .failure(error):
                    resolver.reject(error)
                }
            }
        }
    }
}

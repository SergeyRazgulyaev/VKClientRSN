//
//  NetworkService.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 12.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import os.log

class NetworkService {
    enum AlbumID: String {
        case wall
        case profile
        case saved
    }
    
    enum TypeOfNews: String {
        case post
        case photo = "photo,wall_photo"
    }
    
    //MARK: - Properties for Interaction with Network
    private let baseUrl: String = "https://api.vk.com"
    private let apiVersion: String = "5.124"
    
    static let sessionAF: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        let session = Alamofire.Session(configuration: configuration)
        return session
    }()
    
    //MARK: - Method for loading Information about Friends
    func loadFriends(token: String, completion: ((Result<[UserItem], Error>) -> Void)? = nil) {
        let path = "/method/friends.get"
        
        let params: Parameters = [
            "access_token": token,
            "order": "name",
            "fields": ["nickname", "sex", "bdate", "city", "photo_100"],
            "v": apiVersion
        ]
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData { response in
            guard let data = response.value else { return }
            do {
                guard let friends = try JSONDecoder().decode(User.self, from: data).response?.items else { return }
                completion?(.success(friends))
            } catch {
                Logger.viewCycle.debug("\(error.localizedDescription)")
                completion?(.failure(error))
            }
        }.resume()
    }
    
    //MARK: - Method for loading Information about Photos
    func loadPhotos(token: String, ownerID: Int, albumID: AlbumID, photoCount: Int, completion: ((Result<[PhotoItem], Error>) -> Void)? = nil) {
        let path = "/method/photos.get"
        
        let params: Parameters = [
            "access_token": token,
            "owner_id": ownerID,
            "album_id": albumID.rawValue,
            "rev": 1,
            "extended": 1,
            "v": apiVersion
        ]
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData { response in
            guard let data = response.value else { return }
            do {
                guard let photos = try JSONDecoder().decode(Photo.self, from: data).response?.items else { return }
                completion?(.success(photos))
            } catch {
                Logger.viewCycle.debug("\(error.localizedDescription)")
                completion?(.failure(error))
            }
        }.resume()
    }
    
    //MARK: - Method for loading Information about Groups
    func loadGroups(token: String, completion: ((Result<[GroupItem], Error>) -> Void)? = nil) {
        let path = "/method/groups.get"
        
        let params: Parameters = [
            "access_token": token,
            "extended": 1,
            "v": apiVersion
        ]
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData { response in
            guard let data = response.value else { return }
            
            do {
                guard let groups = try JSONDecoder().decode(Group.self, from: data).response?.items else { return }
                completion?(.success(groups))
            } catch {
                Logger.viewCycle.debug("\(error.localizedDescription)")
                completion?(.failure(error))
            }
        }.resume()
    }
    
    //MARK: - Method for loading Information about News
    func loadNews(token: String, typeOfNews: TypeOfNews, startTime: Double? = nil, startFrom: String, completion: ((Result<NewsResponse, Error>) -> Void)? = nil) {
        let path = "/method/newsfeed.get"
        
        var params: Parameters = [
            "access_token": token,
            "filters": typeOfNews,
            "start_from": startFrom,
            "count": 5,
            "v": apiVersion
        ]
        
        if let startTime = startTime {
            params["start_time"] = startTime
        }
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData(queue: .global(qos: .utility)) { response in
            guard let data = response.value else { return }
            
            var newsItems = [NewsItem]()
            var newsProfiles = [NewsProfile]()
            var newsGroups = [NewsGroup]()
            var newsNextFrom = String()
            
            let parsedNewsElementsDispatchGroup = DispatchGroup()
            
            DispatchQueue.global().async(group: parsedNewsElementsDispatchGroup) {
                guard let newsItemsDecoded = try? JSONDecoder().decode(News.self, from: data).response.items else { return }
                newsItems = newsItemsDecoded
            }
            DispatchQueue.global().async(group: parsedNewsElementsDispatchGroup) {
                guard let newsProfilesDecoded = try? JSONDecoder().decode(News.self, from: data).response.profiles else { return }
                newsProfiles = newsProfilesDecoded
            }
            DispatchQueue.global().async(group: parsedNewsElementsDispatchGroup) {
                guard let newsGroupsDecoded = try? JSONDecoder().decode(News.self, from: data).response.groups else { return }
                newsGroups = newsGroupsDecoded
            }
            DispatchQueue.global().async(group: parsedNewsElementsDispatchGroup) {
                guard let newsNextFromDecoded = try? JSONDecoder().decode(News.self, from: data).response.nextFrom else { return }
                newsNextFrom = newsNextFromDecoded
                Session.instance.newsNextFrom = newsNextFrom
            }
            
            parsedNewsElementsDispatchGroup.notify(queue: DispatchQueue.main) {
                let news = NewsResponse(items: newsItems, profiles: newsProfiles, groups: newsGroups, newsResponseNewOffset: "", nextFrom: "")
                completion?(.success(news))
            }
        }
    }
    
    //MARK: - Method for loading Information about Searched Groups
    func loadSearchedGroups(token: String, searchedGroupName: String, completion: ((Result<[GroupItem], Error>) -> Void)? = nil) {
        let path = "/method/groups.search"
        
        let params: Parameters = [
            "access_token": token,
            "q": searchedGroupName,
            "count": 15,
            "v": apiVersion
        ]
        
        NetworkService.sessionAF.request(baseUrl + path, method: .get, parameters: params).responseData { response in
            guard let data = response.value else { return }
            
            do {
                guard let groups = try JSONDecoder().decode(Group.self, from: data).response?.items else { return }
                completion?(.success(groups))
            } catch {
                Logger.viewCycle.debug("\(error.localizedDescription)")
                completion?(.failure(error))
            }
        }.resume()
    }
}

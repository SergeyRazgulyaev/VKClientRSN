//
//  CachePhotoService.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 29.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import Alamofire

class CachePhotoService {
    //MARK: - Properties for Interaction with Network
    static let sharedManager: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        let manager = Alamofire.Session(configuration: configuration)
        return manager
    }()
    
    //MARK: - Base properties
    private let cacheLifeTime: TimeInterval = 30 * 24 * 60 * 60
    private var images = [String: UIImage]() // RAM cache
    private let container: DataReloadable
    
    // Path to the Cache Directory
    private static let pathName: String = {
        let pathName = "images"
        
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return pathName }
        
        let url = cachesDirectory.appendingPathComponent(pathName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil)
        }
        return pathName
    }()
    
    init(container: UITableView) {
        self.container = Table(tableView: container)
    }
    
    init(container: UICollectionView) {
        self.container = Collection(collectionView: container)
    }
    
    // MARK: - Methods
    
    // Path to the cached Image at its Internet address
    private func getFilePath(url: String) -> String? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        
        let hashName = url.split(separator: "/").last ?? "default"
        return cachesDirectory.appendingPathComponent(CachePhotoService.pathName + "/" + hashName).path
    }
    
    private func saveImageToCache(url: String, image: UIImage) {
        guard let fileName = getFilePath(url: url),
            let data = image.pngData()
            else { return }
        FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
    }
    
    private func getImageFromCache(url: String) -> UIImage? {
        guard let fileName = getFilePath(url: url),
            let info = try? FileManager.default.attributesOfItem(atPath: fileName),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date
            else { return nil }
        
        let lifeTime = Date().timeIntervalSince(modificationDate)
        
        guard lifeTime <= cacheLifeTime,
            let image = UIImage(contentsOfFile: fileName)
            else { return nil }
        
        DispatchQueue.main.async {
            self.images[url] = image
        }
        return image
    }
    
    private func loadPhoto(atIndexPath indexPath: IndexPath, byUrl url: String) {
        CachePhotoService.sharedManager.request(url).responseData(
            queue: DispatchQueue.global(),
            completionHandler: { [weak self] response in
                guard let data = response.data,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.images[url] = image
                }
                self?.saveImageToCache(url: url, image: image)
                
                // Container reloading
                DispatchQueue.main.async { [weak self] in
                    self?.container.reloadRow(atIndexPath: indexPath)
                }
            }
        )
    }
    
    func getPhoto(atIndexPath indexPath: IndexPath, byUrl url: String) -> UIImage? {
        var image: UIImage?
        if let photo = images[url] {
            // Loading from RAM
            image = photo
        } else if let photo = getImageFromCache(url: url) {
            //Loading from Physical Memory
            image = photo
        } else {
            //Loading from Network
            loadPhoto(atIndexPath: indexPath, byUrl: url)
        }
        return image
    }
}

fileprivate protocol DataReloadable {
    func reloadRow(atIndexPath indexPath: IndexPath)
}

extension CachePhotoService {
    private class Table: DataReloadable {
        let tableView: UITableView
        
        init(tableView: UITableView) {
            self.tableView = tableView
        }
        
        func reloadRow(atIndexPath indexPath: IndexPath) {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    private class Collection: DataReloadable {
        let collectionView: UICollectionView
        
        init(collectionView: UICollectionView) {
            self.collectionView = collectionView
        }
        
        func reloadRow(atIndexPath indexPath: IndexPath) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

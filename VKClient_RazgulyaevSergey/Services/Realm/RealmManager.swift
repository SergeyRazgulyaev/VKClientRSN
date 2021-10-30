//
//  RealmManager.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 25.08.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    static let instance = RealmManager()
    private let realm: Realm
    
    private init?(){
        let configuration = Realm.Configuration(schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        guard let realm = try? Realm(configuration: configuration) else { return nil }
        self.realm = realm
        print(realm.configuration.fileURL ?? "")
    }
    
    func add <T: Object> (object: T) throws {
        try realm.write {
            realm.add(object)
        }
    }
    
    func add <T: Object> (objects: [T]) throws {
        try realm.write {
            realm.add(objects, update: .all)
        }
    }
    
    func getObjects <T: Object> () -> Results <T> {
        return realm.objects(T.self)
    }
    
    func delete <T: Object> (object: T) throws {
        try realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll() throws {
        try realm.write {
            realm.deleteAll()
        }
    }
}

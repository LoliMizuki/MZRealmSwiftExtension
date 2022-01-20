//
//  DataEntitiesExtensions.swift
//
//  Created by Inaba Mizuki on 2020/11/17.
//  Copyright © 2020 mizukiclub. All rights reserved.
//

import Foundation
import RealmSwift
//import MZSwifts


#if swift(>=5.2) // 暫時對策 for old and new developing env
protocol RealmDataActionsProtocol: AnyObject, RealmCollectionValue {
    
    static var realm: Realm { get }
    
    static func fetch(includeDeleted: Bool) -> [Self]
    static func count() -> Int
    static func deleteAll() -> Error?
    static func removeAllDeletedData() -> Int
    static func printAll()
    
    var isSaved: Bool { get }
    var isDeleted: Bool { get set }
    var updatedAt: Date { get set }
    
    var shortDescription: String { get }
    
    func save(ignoreUpdatedAt: Bool, modifier: ((Self) -> ())?) -> Error?
    // Repace return with: Swift.Result or throw???
    func softDelete() -> Error?
    func delete() -> Error? // -> Swift.Result or throw?
    
    func beforeSaving() -> Error?
}
#else
protocol RealmDataActionsProtocol: class, RealmCollectionValue {
    
    static func fetch(includeDeleted: Bool) -> [Self]
    static func count() -> Int
    static func deleteAll() -> Error?
    static func removeAllDeletedData() -> Int
    static func printAll()
    
    var isSaved: Bool { get }
    var isDeleted: Bool { get set }
    var updatedAt: Date { get set }
    
    var shortDescription: String { get }
    
    func save(ignoreUpdatedAt: Bool, modifier: ((Self) -> ())?) -> Error?
    // Repace return with: Swift.Result or throw???
    func softDelete() -> Error?
    func delete() -> Error? // -> Swift.Result or throw?
    
    func beforeSaving() -> Error?
}
#endif


extension RealmDataActionsProtocol where Self: Object { // Object is Realm.Object
    
    static func count() -> Int { fetch().count }

    static func fetch(includeDeleted: Bool = false) -> [Self] {
        guard Thread.current.isMainThread else { fatalError("Only work on main thread") }
        
        return realm.objects(self.self)
            .filter { includeDeleted ? true : $0.isDeleted == false }
            .map { $0 }
    }
    
    static func deleteAll() -> Error? {
        let all = self.fetch()
        
        var error: Error? = nil
        
        all.forEach {
            let err = $0.delete()
            if error == nil { error = err }
        }
        
        return error
    }
    
    static func removeAllDeletedData() -> Int {
        let willDeleting = fetch(includeDeleted: true).filter { $0.isDeleted }
        
        let willDeletigCount = willDeleting.count
        
        willDeleting.forEach { _ = $0.delete() }
        
        return willDeletigCount
    }
    
    static func printAll() {
        Self.fetch().forEach { print($0) }
    }
    
    var isSaved: Bool { self.realm != nil }
    var updatedAt: Date { get { Date() } set { } }
    
    func beforeSaving() -> Error? { nil }
    
    func save(ignoreUpdatedAt: Bool = false, modifier: ((Self) -> ())? = nil) -> Error? {
        let realm = Self.realm
        
        func doSave() -> Error? {
            if !ignoreUpdatedAt { self.updatedAt = Date(timeIntervalSinceNow: 0) }
            
            modifier?(self)
            
            if let error = beforeSaving() {
                return error
            }
            
            realm.add(self, update: .all)
            
            return nil
        }
        
        if realm.isInWriteTransaction {
            return doSave()
        } else {
            do {
                var result: Error? = nil
                try realm.write { result = doSave() }
                
                return result
            } catch let error {
                return error
            }
        }
    }
    
    func softDelete() -> Error? {
        save { $0.isDeleted = true }
    }
    
    func delete() -> Error? {
        do {
            try Self.realm.write {
                Self.realm.delete(self)
            }
            
            return nil
        } catch let error {
            return error
        }
    }
}

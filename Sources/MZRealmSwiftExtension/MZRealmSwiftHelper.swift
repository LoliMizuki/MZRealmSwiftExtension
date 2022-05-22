//
//  MZRealmSwiftHelper.swift
//  
//
//  Created by Mizuki Inaba on 2022/5/23.
//

import Foundation
import RealmSwift


public struct MZRealmSwiftHelper {
    
    // MARK: Private
    
    private init() {
    }
}


extension Array where Element: RealmCollectionValue {
    
    public func realmList() -> List<Element> {
        let list = List<Element>()
        
        list.append(objectsIn: self)
        
        return list
    }
}


extension List {
    
    public func array() -> Array<Element> { map { $0 } }
}

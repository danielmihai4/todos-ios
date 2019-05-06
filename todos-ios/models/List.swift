//
//  List.swift
//  todos-ios
//
//  Created by Daniel Mihai on 30/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

class List {
    let id: Int
    let name: String
    let createdAt: String
    var items: [Item]
    
    public init(id: Int, name: String, createdAt: String, items: [Item]) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.items = items
    }
    
    func todosCount() -> Int {
        var count = 0
        
        for item in items {
            if !item.isDone {
                count += 1
            }
        }
        
        return count
    }
    
    func doneCount() -> Int  {
        return items.count - todosCount()
    }
}

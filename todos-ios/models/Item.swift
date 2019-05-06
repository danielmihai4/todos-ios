//
//  Item.swift
//  todos-ios
//
//  Created by Daniel Mihai on 30/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

class Item {
    let id: Int
    let name: String
    let dueDate: Date?
    let listId: Int
    var isDone: Bool
    let completedBy: User?
    let info: String
    
    public init(id: Int, name: String, dueDate: Date?, listId: Int, isDone: Bool, completedBy: User?, info: String) {
        self.id = id
        self.name = name
        self.dueDate = dueDate
        self.listId = listId
        self.isDone = isDone
        self.completedBy = completedBy
        self.info = info
    }
}

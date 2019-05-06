//
//  User.swift
//  todos-ios
//
//  Created by Daniel Mihai on 30/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

class User {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    
    public init(id: Int, email: String, firstName: String, lastName: String) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
}

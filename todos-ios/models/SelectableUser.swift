//
//  SelectableUser.swift
//  todos-ios
//
//  Created by Daniel Mihai on 07/04/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

class SelectableUser: User {
    var selected: Bool
    
    init(id: Int, email: String, firstName: String, lastName: String, selected: Bool) {
        self.selected = selected
        super.init(id: id, email: email, firstName: firstName, lastName: lastName)
    }    
}

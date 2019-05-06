//
//  UserTranslator.swift
//  todos-ios
//
//  Created by Daniel Mihai on 04/05/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

class UserTranslator {
    
    public static func translate(user: User) -> SelectableUser {
        return SelectableUser(id: user.id, email: user.email, firstName: user.firstName, lastName: user.lastName, selected: false)
    }
}

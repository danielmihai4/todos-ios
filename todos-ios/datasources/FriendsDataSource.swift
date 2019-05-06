//
//  FriendsDataSource.swift
//  todos-ios
//
//  Created by Daniel Mihai on 13/04/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import UIKit

protocol FriendsDataSourceDelegate: class {
    func displayDeletionConfirmation(friend: User)
}

class FriendsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var friends = [User]()
    weak var delegate: FriendsDataSourceDelegate?
    
    override init() {
        super.init()
    }
    
    func setData(friends: [User]) {
        self.friends = friends
    }
    
    func remove(friend: User) {
        self.friends = self.friends.filter { $0.id != friend.id}
    }
    
    func add(friend: User) {
        self.friends.append(friend)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Friend) as! FriendViewCell
        let friend = self.friends[indexPath.row]
        
        cell.nameLabel.text = "\(friend.firstName) \(friend.lastName)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.delegate?.displayDeletionConfirmation(friend: self.friends[indexPath.row])
        }
    }
}
